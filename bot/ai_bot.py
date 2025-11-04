"""
Chatbot especializado do Setor de Tributos Municipais de Nova Trento/SC
com integração de RAG (Chroma), roteamento de links e suporte a histórico.
"""
from __future__ import annotations

import os
import re
from typing import Dict, List, Optional, TYPE_CHECKING, Any

from langchain_chroma import Chroma
from langchain_core.documents import Document
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_huggingface import HuggingFaceEmbeddings

from services.config import get_settings

# Tipos apenas para checagem estática
if TYPE_CHECKING:  # pragma: no cover - usado apenas por mypy
    from bot.link_router import LinkRouter as LinkRouterType
else:
    LinkRouterType = Any

# Import em tempo de execução (pode falhar e seguiremos sem roteador)
try:
    from bot.link_router import LinkRouter as LinkRouterRuntime
except Exception:  # noqa: BLE001 - queremos capturar indisponibilidade do módulo
    LinkRouterRuntime = None


SPECIALIZED_SYSTEM_TEMPLATE = """
Você é o **Atendente Virtual do Setor de Tributos Municipais de Nova Trento/SC**.
Responda em **português do Brasil**, de forma **clara, objetiva e cordial**.

Regras de atuação:
1) Escopo: IPTU, ISS (fixo/variável), TLL, ITBI, CND/Certidões, Parcelamentos, 2ª via, atualização de débitos, DF-e, cadastro imobiliário/mercantil, taxas, processos fiscais e rotinas do Setor.
2) Use **apenas** o conhecimento fornecido no <context>. Se faltar base, **diga explicitamente** que não encontrou informação nos documentos e ofereça o encaminhamento adequado (contato humano, link, protocolo).
3) Normas: ao citar dispositivos legais, **só use o texto exato** presente na base. Se o texto oficial não estiver na base, informe que **não foi verificado** e evite fundamentar a resposta com esse dispositivo.
4) Precisão: nunca invente prazos, valores, links ou e-mails. Não prometa o que depende de análise humana.
5) Privacidade: colete apenas o mínimo necessário (ex.: CPF/CNPJ, inscrição, endereço do imóvel, nº do processo). Não solicite fotos de documentos sensíveis.
6) Tom: profissional, humano e direto. Evite jargões; se for usar, explique.
7) Saída: entregue **resposta direta** ao usuário. Se depender de ação interna, informe passo a passo.

Seja sucinto; use listas apenas quando melhorarem a leitura.

<context>
{context}
</context>
"""


def _to_langchain_messages(history_messages: List[Dict[str, str]]) -> List[BaseMessage]:
    """
    Converte [{'role': 'user'|'assistant', 'content': '...'}, ...] em mensagens LangChain.
    Ignora roles desconhecidos.
    """
    msgs: List[BaseMessage] = []
    role_map = {"user": HumanMessage, "assistant": AIMessage}
    for m in history_messages or []:
        klass = role_map.get(m.get("role", "").lower())
        if klass and m.get("content"):
            msgs.append(klass(content=m["content"]))
    return msgs


class AIBot:
    """
    Bot de IA especializado em Tributos com RAG (Chroma + HuggingFace Embeddings)
    e integração com roteador de links do fluxo de atendimento.
    """

    def __init__(self):
        # Provider/model selection
        settings = get_settings()
        provider = (settings.LLM_PROVIDER or "groq").strip().lower()
        model_name = (settings.LLM_MODEL or "").strip()

        def _normalize_model(p: str, m: str) -> str:
            """Mapeia aliases e nomes legados para modelos atuais por provedor."""
            p = (p or "").strip().lower()
            m = (m or "").strip()

            # Defaults por provedor
            defaults = {
                # OpenAI: manter gpt-4.1 por compatibilidade; 'o4-mini' também é suportado
                "openai": "gpt-4.1",
                # xAI/Grok: preferir modo reasoning por padrão
                "xai": "grok-4-fast-reasoning",
                "grok": "grok-4-fast-reasoning",  # alias para xAI
                # Groq: última estável e versátil
                "groq": "llama-3.3-70b-versatile",
            }

            if not m:
                return defaults.get(p, m)

            ml = m.lower()

            # OpenAI (alguns mapeamentos comuns)
            if p == "openai":
                openai_map = {
                    "gpt-4o": "gpt-4.1",
                    "gpt-4-turbo": "gpt-4.1",
                    "gpt-3.5-turbo": "gpt-4.1-mini",
                    "o1": "o4-mini",
                    "o4-mini": "o4-mini",
                }
                return openai_map.get(ml, m)

            # xAI / Grok (aceita ambos provedores 'xai' e 'grok')
            if p in ("xai", "grok"):
                xai_map = {
                    "grok-2-1212": "grok-4-fast-reasoning",
                    "grok-beta": "grok-4-fast-reasoning",
                    "grok-2-latest": "grok-4-fast-reasoning",
                    "grok-4-raciocinio-rapido": "grok-4-fast-reasoning",
                    "grok-4-raciocínio-rápido": "grok-4-fast-reasoning",
                    "grok-4-fast": "grok-4-fast-reasoning",
                    "grok-4-fast-reasoning": "grok-4-fast-reasoning",
                    "grok-4-fast-non-reasoning": "grok-4-fast-non-reasoning",
                    "grok-code-fast-1": "grok-code-fast-1",
                    "grok-4": "grok-4-fast-reasoning",
                }
                return xai_map.get(ml, m)

            # Groq
            if p == "groq":
                groq_map = {
                    "llama-3.1-405b-reasoning": "llama-3.3-70b-versatile",
                    "mixtral-8x7b-32768": "llama-3.3-70b-versatile",  # preferir llama 3.3 70b para QA
                }
                return groq_map.get(ml, m)

            return m

        model_name = _normalize_model(provider, model_name)

        if provider == "openai":
            # OpenAI - modelo recomendado: gpt-4o (multimodal, rápido)
            # Evite 'o1' aqui (muitos wrappers ainda não suportam bem)
            if settings.OPENAI_API_KEY:
                os.environ["OPENAI_API_KEY"] = settings.OPENAI_API_KEY
            from langchain_openai import ChatOpenAI

            openai_model = model_name if model_name else "gpt-4.1"
            self.__chat = ChatOpenAI(model=openai_model)

        elif provider in ("grok", "xai"):
            # xAI Grok - API compatível com OpenAI
            xai_api_key = settings.XAI_API_KEY
            from langchain_openai import ChatOpenAI

            grok_model = model_name if model_name else "grok-4-fast-reasoning"
            self.__chat = ChatOpenAI(
                model=grok_model, api_key=xai_api_key, base_url="https://api.x.ai/v1"
            )

        elif provider == "groq":
            # Groq - rápido e econômico: llama-3.3-70b-versatile
            if settings.GROQ_API_KEY:
                os.environ["GROQ_API_KEY"] = settings.GROQ_API_KEY
            from langchain_groq import ChatGroq

            groq_model = model_name if model_name else "llama-3.3-70b-versatile"
            self.__chat = ChatGroq(model=groq_model)

        else:
            raise ValueError(
                f"Unsupported LLM_PROVIDER '{provider}'. Use 'openai', 'grok'/'xai', or 'groq'."
            )

        # Construir retriever com MMR para reduzir redundância
        self.__retriever = self.__build_retriever()

        # Prompt para QA
        self.__qa_prompt = ChatPromptTemplate.from_messages(
            [
                ("system", SPECIALIZED_SYSTEM_TEMPLATE),
                MessagesPlaceholder(variable_name="messages"),
            ]
        )

        # Inicializar roteador de links (se disponível)
        self.__link_router: Optional[LinkRouterType] = None
        if LinkRouterRuntime is not None:
            try:
                import json

                flow_path = settings.FLOW_JSON_PATH
                if os.path.exists(flow_path):
                    with open(flow_path, encoding="utf-8") as f:
                        flow_json = json.load(f)
                    # type: ignore[call-arg]
                    self.__link_router = LinkRouterRuntime(flow_json)  # type: ignore[assignment]
            except Exception as e:
                print(f"⚠️  Falha ao carregar LinkRouter: {e}")

    def __build_retriever(self):
        """Constrói retriever com MMR para melhor diversidade de resultados."""
        settings = get_settings()
        persist_directory = settings.CHROMA_DIR
        embedding_model = settings.EMBEDDING_MODEL
        embedding = HuggingFaceEmbeddings(model_name=embedding_model)

        vector_store = Chroma(
            persist_directory=persist_directory,
            embedding_function=embedding,
        )
        # MMR com parâmetros aprimorados: mais documentos (k=30) e maior diversidade (lambda=0.5)
        # Isso permite que o modelo LLM "aprenda" de mais contexto e reduza redundância
        return vector_store.as_retriever(
            search_type="mmr",
            search_kwargs={"k": 30, "lambda_mult": 0.5},
        )

    def _format_context(self, docs: List[Document]) -> str:
        """
        Consolida conteúdos e anota fontes quando houver metadata['source'].
        """
        if not docs:
            return "NÃO HÁ DOCUMENTOS RELEVANTES NA BASE PARA ESTA PERGUNTA."
        blocks = []
        for i, d in enumerate(docs, start=1):
            src = (
                d.metadata.get("source")
                or d.metadata.get("file")
                or d.metadata.get("id")
                or f"doc_{i}"
            )
            blocks.append(f"[Fonte: {src}]\n{d.page_content}".strip())
        return "\n\n---\n\n".join(blocks)

    def invoke(
        self,
        history_messages: List[Dict[str, str]],
        question: str,
        menu_node_name: str | None = None,
        vars_fmt: Dict[str, str] | None = None,
    ) -> str:
        """
        Processa a pergunta do usuário com suporte a:
        - Roteamento automático de links (se disponível)
        - RAG com base vetorial
        - Histórico de conversa

        Args:
            history_messages: Lista de mensagens [{'role': 'user'|'assistant', 'content': '...'}]
            question: Pergunta atual do usuário
            menu_node_name: Nome do nó atual do menu (para roteamento contextual)
            vars_fmt: Variáveis para substituição em placeholders (ex: {{name}}, {{protocol}})

        Returns:
            Resposta textual do bot
        """
        # 1) TENTATIVA DE RESPOSTA RÁPIDA via LinkRouter
        if self.__link_router:
            # Modo Menu: se vier escolha numérica e nó atual
            if menu_node_name:
                m = re.search(r"\b([0-9]|10)\b", question or "", flags=re.U)
                if m:
                    choice = m.group(1)
                    quick = self.__link_router.menu_reply(menu_node_name, choice)
                    if quick:
                        return self.__link_router.render(quick, vars_fmt)

            # Modo Keywords: sem estado — tenta casar intenções
            quick = self.__link_router.keyword_reply(question or "")
            if quick:
                return self.__link_router.render(quick, vars_fmt)

        # 2) RECUPERAÇÃO via RAG
        docs = self.__retriever.invoke(question)
        context_text = self._format_context(docs)

        # 3) MONTAGEM DE MENSAGENS (com histórico real)
        lc_history: List[BaseMessage] = _to_langchain_messages(history_messages)
        # Adiciona a pergunta atual
        lc_history.append(HumanMessage(content=question))

        # 4) EXECUÇÃO - invoca o LLM diretamente com o contexto formatado
        formatted_prompt = self.__qa_prompt.invoke(
            {
                "context": context_text,
                "messages": lc_history,
            }
        )
        response = self.__chat.invoke(formatted_prompt)

        # 5) EXTRAÇÃO do texto da resposta
        content: str | None = getattr(response, "content", None)
        if content is not None:
            text = str(content).strip()
        else:
            text = str(response).strip()

        # 6) FALLBACK defensivo
        if not text:
            text = (
                "Não encontrei base suficiente nos documentos para responder com segurança. "
                "Posso encaminhar para atendimento humano do Setor de Tributos ou verificar os dados no sistema."
            )

        return text
