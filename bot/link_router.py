"""
Router de Links - Extrai e serve mensagens do fluxo de atendimento (JSON).

Suporta dois modos:
  - Modo Menu: baseado em estado (nó atual + escolha numérica)
  - Modo Keywords: sem estado (casamento por intenção/termos)
"""

from __future__ import annotations

import re
from datetime import datetime
from typing import Any

try:
    from zoneinfo import ZoneInfo as _ZoneInfo
except ImportError:
    from backports.zoneinfo import ZoneInfo as _ZoneInfo  # type: ignore[import-not-found]

ZoneInfo = _ZoneInfo

BR_TZ = ZoneInfo("America/Sao_Paulo")


class LinkRouter:
    """
    Extrai, organiza e serve as mensagens de 'closeTicket' (action=3) do JSON de fluxo.
    - Modo menu: dado (node_name_atual, input_usuario "1|2|...|0"), retorna a mensagem já pronta.
    - Modo keywords: sem estado, tenta casar termos (iptu, iss, itbi etc.) com os ramos de link.
    Também aplica janelas de atendimento (opcional).
    """

    def __init__(self, flow_json: dict[str, Any]) -> None:
        self.flow = flow_json
        self.nodes: dict[str, dict[str, Any]] = {n["id"]: n for n in flow_json.get("nodeList", [])}
        # Índice por nome para modo menu:
        self.nodes_by_name: dict[str, dict[str, Any]] = {
            n["name"]: n for n in flow_json.get("nodeList", [])
        }

        # Mapa: (node_id, "opcao") -> mensagem_closeTicket
        self.menu_map: dict[tuple[str, str], str] = {}
        # Mapa auxiliar por "título" do nó
        self.menu_map_by_name: dict[tuple[str, str], str] = {}

        # Buckets semânticos simples para modo keywords
        self.keyword_buckets: list[tuple[re.Pattern[str], str]] = []

        # Mensagens de configuração (boas-vindas, fora do horário, etc.)
        nodes = flow_json.get("nodeList", [])
        self.cfg = nodes[1].get("configurations", {}) if len(nodes) > 1 else {}
        self._build()

    def _build(self) -> None:
        """Extrai todas as condições com action=3 (closeTicket) e monta os índices."""
        for node in self.nodes.values():
            for cond in node.get("conditions", []) or []:
                if cond.get("action") == 3 and cond.get("closeTicket"):
                    msg = cond["closeTicket"].strip()
                    for opt in cond.get("condition", []):
                        key = (node["id"], str(opt))
                        self.menu_map[key] = msg
                        self.menu_map_by_name[(node["name"], str(opt))] = msg

        # Buckets de palavras-chave -> redirecionar para um link específico
        # (simples e prático; ajuste livremente conforme sua realidade)
        def p(x: str) -> re.Pattern[str]:
            return re.compile(x, flags=re.I | re.U)

        self.keyword_buckets = [
            (p(r"\biptu\b|imobili(á|a)rio|guia(s)? de iptu|2.?a via"), "1 - Imobiliário (IPTU)"),
            (
                p(r"\biss\b|\baut(ô|o)nomo\b|constru(ç|c)ão|servi(c|ç)os|nfs[- ]?e"),
                "2 - ISS (Serviços)",
            ),
            (
                p(r"\bparcel(amento|ar)|acordo|negocia(ç|c)(ão|oes)|d(é|e)bitos"),
                "3 - Parcelamento e Débitos",
            ),
            (
                p(r"\bcertid(ão|oes)|cnd|cpen|situa(ç|c)(ão|oes) fiscal|cadastro"),
                "4 - Certidões e Situação Fiscal",
            ),
            (p(r"\bitbi\b|alvar(á|a)|taxas?|nfs[- ]?e|nota fiscal"), "5 - Taxas e NFS-e"),
            (p(r"\bcidad(ã|a)o web|portal|betha|cdweb|link(s)?"), "8 - Cidadão Web"),
            (p(r"\boutras informa(ç|c)(ões|ao)"), "7 - Outras informações"),
            (p(r"\bencaminhamentos?|outros setores"), "6 - Encaminhamentos para Outros Setores"),
        ]

    # ----- Janelas de atendimento (opcional) -----
    def inside_business_hours(self, now: datetime | None = None) -> bool:
        """Verifica se está dentro do horário de atendimento: Seg–Sex, 07:00–13:00 (Nova Trento/SC)."""
        now = now or datetime.now(BR_TZ)
        if now.weekday() > 4:  # 0=Mon .. 6=Sun
            return False
        h = now.hour + now.minute / 60
        return 7 <= h < 13

    def out_of_hours_message(self) -> str | None:
        """Retorna mensagem padrão para fora do horário."""
        cfg = self.cfg.get("outOpenHours") or {}
        # Se quiser customizar, use também cfg["destiny"], etc.
        welcome_msg = self.cfg.get("welcomeMessage")
        if welcome_msg and isinstance(welcome_msg, dict):
            msg = welcome_msg.get("message")
            if msg:
                return str(msg)
        return (
            "Nosso horário de atendimento é de Segunda-Feira à Sexta-Feira das 07h00 às 13h00. "
            "Assim que voltarmos, daremos sequência ao seu atendimento. Obrigado!"
        )

    # ----- MODO MENU -----
    def menu_reply(self, current_node_name: str, user_choice: str) -> str | None:
        """
        Retorna a mensagem do closeTicket baseada no nó atual e escolha do usuário.

        Args:
            current_node_name: Nome do nó atual (ex: "Menu Principal", "2 - ISS (Serviços)")
            user_choice: Escolha do usuário (ex: "1", "2", "3")

        Returns:
            Mensagem do closeTicket ou None se não encontrar
        """
        msg: str | None = self.menu_map_by_name.get((current_node_name, user_choice))
        return msg

    # ----- MODO KEYWORDS -----
    def keyword_reply(self, user_text: str) -> str | None:
        """
        Casamento simples por intenção; retorna a MELHOR mensagem (quando for menu que fecha).

        Args:
            user_text: Texto livre do usuário

        Returns:
            Mensagem do closeTicket ou None se não encontrar
        """
        text = user_text or ""
        # Encontra o primeiro bucket que bater
        for pat, node_title in self.keyword_buckets:
            if pat.search(text):
                # Escolhe a opção "padrão" por nó, quando fizer sentido:
                # - No fluxo, cada nó tem várias opções. Aqui definimos defaults úteis.
                defaults = {
                    "1 - Imobiliário (IPTU)": "1",  # Guias IPTU
                    "2 - ISS (Serviços)": "3",  # ISS Variável (mais geral)
                    "3 - Parcelamento e Débitos": "1",  # Consulta integrada
                    "4 - Certidões e Situação Fiscal": "1",  # CND
                    "5 - Taxas e NFS-e": "1",  # ITBI
                    "6 - Encaminhamentos para Outros Setores": "0",  # Voltar menu (texto informativo)
                    "7 - Outras informações": "0",  # Voltar menu
                    "8 - Cidadão Web": "0",  # Texto com links
                }
                opt = defaults.get(node_title, None)
                if opt is None:
                    continue
                msg: str | None = self.menu_map_by_name.get((node_title, opt))
                if msg:
                    return msg
        return None

    # ----- RENDER COM PLACEHOLDERS -----
    @staticmethod
    def render(msg: str, variables: dict[str, str] | None = None) -> str:
        """
        Substitui {{chaves}} simples no texto.

        Args:
            msg: Mensagem com placeholders no formato {{key}}
            variables: Dicionário com valores para substituição

        Returns:
            Mensagem com placeholders substituídos
        """
        variables = variables or {}
        out = msg
        for k, v in variables.items():
            out = out.replace("{{" + k + "}}", str(v))
        return out
