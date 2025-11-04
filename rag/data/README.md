# 📚 Base de Conhecimento - Setor de Tributos

Esta pasta contém os documentos que alimentam a base de conhecimento do chatbot.

## 📂 Estrutura de Pastas

```
data/
├── leis/              # Legislação municipal (PDFs)
├── manuais/           # Manuais e guias (PDFs ou TXTs)
├── faqs/              # Perguntas frequentes (Markdown ou TXT)
└── procedimentos/     # Fluxos e procedimentos internos (TXT ou MD)
```

## ✅ Documentos Recomendados

### 📜 Leis (pasta `leis/`)

**Essenciais**:
- LC 661/2017 - Código Tributário Municipal de Nova Trento
- LC 705/2023 - Alterações no Código Tributário
- Lei Complementar Federal 116/2003 - Lista de Serviços ISS
- CTN - Código Tributário Nacional (artigos relevantes)
- Lei Federal 13.709/2018 - LGPD (seções sobre atendimento)

**Formato**: PDF com OCR (para leitura de texto)

**Dica**: Nomeie os arquivos de forma clara, ex:
- `LC_661_2017_Codigo_Tributario_Nova_Trento.pdf`
- `LC_116_2003_Lista_Servicos_ISS.pdf`

### 📖 Manuais (pasta `manuais/`)

**Sugestões**:
- Manual de emissão de IPTU
- Manual de cálculo de ISS
- Manual de parcelamento de débitos
- Guia de uso do Cidadão Web (Portal Betha)
- Manual de emissão de NFS-e
- Instruções para ITBI
- Procedimento para certidões

**Formato**: PDF, TXT ou Markdown

### ❓ FAQs (pasta `faqs/`)

**Já incluídos**:
- ✅ FAQ_Certidoes.md
- ✅ FAQ_IPTU.md

**Para adicionar**:
- FAQ_ISS.md (Serviços)
- FAQ_Parcelamento.md
- FAQ_ITBI.md
- FAQ_NFSe.md
- FAQ_Alvaras.md

**Formato**: Markdown (.md) ou TXT (.txt)

**Estrutura recomendada**:
```markdown
# FAQ - [Assunto]

## 1. [Pergunta 1]

[Resposta detalhada]

**Link útil**: [URL se houver]

---

## 2. [Pergunta 2]

[Resposta]

---
```

### 📋 Procedimentos (pasta `procedimentos/`)

**Sugestões**:
- Fluxo de atendimento presencial
- Prazos de análise de processos
- Checklist para abertura de protocolos
- Procedimento de vistoria fiscal
- Fluxo de cobrança e execução fiscal
- Roteiro de cálculo de tributos

**Formato**: TXT ou Markdown

## 🚀 Como Adicionar Novos Documentos

### 1. Prepare o documento

- **PDFs**: Certifique-se de que o PDF tem texto (OCR), não apenas imagem
- **TXTs**: Use codificação UTF-8
- **Markdown**: Use sintaxe Markdown padrão

### 2. Coloque na pasta adequada

```bash
cp MeuDocumento.pdf rag/data/leis/
# ou
cp FAQ_Novo.md rag/data/faqs/
```

### 3. Execute o script de ingestão

```bash
# Adicionar novos documentos (mantém existentes)
python rag/load_knowledge.py

# Ou limpar tudo e recarregar do zero
python rag/load_knowledge.py --clear
```

### 4. Verifique a ingestão

O script mostrará:
- Número de arquivos encontrados
- Número de documentos carregados
- Número de chunks gerados

```
📂 Encontrados 12 arquivo(s)
   📄 Carregando: leis/LC_661_2017.pdf
   📄 Carregando: faqs/FAQ_IPTU.md
   ...
✅ 12 documento(s) carregado(s)
✂️  Dividindo documentos em chunks...
   ✅ 247 chunk(s) criado(s)
```

## 📝 Boas Práticas

### Nomeação de Arquivos

✅ **Bom**:
- `LC_661_2017_Codigo_Tributario.pdf`
- `FAQ_Certidoes_Negativas.md`
- `Manual_Calculo_ISS_2024.pdf`

❌ **Ruim**:
- `documento.pdf`
- `novo.txt`
- `arquivo final v2 (1).pdf`

### Organização de Conteúdo

**Para FAQs e Manuais**:
1. Use títulos claros e objetivos
2. Inclua links oficiais sempre que possível
3. Especifique "Quem pode usar" e "Documentos necessários"
4. Atualize datas e valores regularmente

**Para Leis**:
1. Use a versão consolidada mais recente
2. Indique a data de atualização no nome do arquivo
3. Se houver alterações, mantenha ambas as versões (original + alterada)

### Atualização Periódica

**Quando atualizar**:
- Publicação de nova legislação
- Alteração de prazos ou valores
- Mudanças nos links do Portal Betha
- Feedback dos atendentes sobre informações desatualizadas

**Como atualizar**:
1. Substitua o arquivo antigo pelo novo (mesmo nome)
2. Execute: `python rag/load_knowledge.py --clear`
3. Teste o chatbot com perguntas sobre o conteúdo atualizado

## 🔍 Verificando o Conteúdo da Base

Após carregar documentos, você pode testar consultas:

```python
from bot.ai_bot import AIBot

bot = AIBot()
resposta = bot.invoke(
    history_messages=[],
    question="Qual o prazo para pagamento do IPTU em cota única?"
)
print(resposta)
```

## 📊 Tamanho Recomendado

- **Chunk size**: 1000 caracteres (padrão)
- **Overlap**: 200 caracteres (padrão)
- **Total de chunks**: Ideal 200-500 para performance ótima

Se tiver mais de 1000 chunks, considere:
- Aumentar chunk_size para 1500
- Remover documentos redundantes
- Consolidar múltiplos documentos similares

## ⚠️ Atenção

**Dados sensíveis**:
- ❌ NÃO adicione documentos com dados pessoais de contribuintes
- ❌ NÃO adicione processos específicos com CPF/CNPJ
- ✅ Use apenas documentos genéricos e públicos

**Responsabilidade**:
- Toda informação aqui será usada pelo chatbot
- Garanta que os documentos estejam atualizados e corretos
- Prefira fontes oficiais (Diário Oficial, portal da Prefeitura)

## 📞 Suporte

Dúvidas sobre como adicionar documentos? Entre em contato com o Setor de TI.

---

**Última atualização**: 31/10/2025
**Responsável**: Setor de Tributos + TI
