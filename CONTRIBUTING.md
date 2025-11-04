# Guia de Contribuição

Obrigado pelo interesse em contribuir para o Chatbot de Tributos da Prefeitura Municipal de Nova Trento/SC! 🎉

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Padrões de Código](#padrões-de-código)
- [Processo de Desenvolvimento](#processo-de-desenvolvimento)
- [Commits](#commits)
- [Pull Requests](#pull-requests)
- [Testes](#testes)

## 🤝 Código de Conduta

Este projeto é mantido pela Prefeitura Municipal de Nova Trento/SC. Esperamos que todos os contribuidores:

- Sejam respeitosos e profissionais
- Foquem em melhorias técnicas e funcionais
- Mantenham a confidencialidade de dados sensíveis
- Sigam as boas práticas de segurança

## 🚀 Como Contribuir

### 1. Fork e Clone

```bash
# Fork no GitHub e clone localmente
git clone https://github.com/SEU-USUARIO/chatbot-tributos.git
cd chatbot-tributos
```

### 2. Configure o Ambiente

```bash
# Copie o arquivo de ambiente
cp .env.example .env

# Instale dependências de desenvolvimento
pip install -r requirements-dev.txt

# Instale pre-commit hooks
pre-commit install
```

### 3. Crie uma Branch

Use nomes descritivos seguindo o padrão:

```bash
# Features
git checkout -b feature/nome-da-funcionalidade

# Correções
git checkout -b fix/descricao-do-bug

# Documentação
git checkout -b docs/descricao-da-mudanca

# Refatoração
git checkout -b refactor/descricao-da-mudanca
```

## 💻 Padrões de Código

### Python

Seguimos as convenções **PEP 8** com algumas adaptações:

- **Formatador**: Black (line-length: 100)
- **Linter**: Ruff
- **Type Checker**: Mypy
- **Imports**: ordenados por `isort`

### Executar Validações

```bash
# Lint completo
./scripts/test.ps1

# Ou manualmente:
ruff check .
black --check .
mypy .

# Auto-fix
ruff check --fix .
black .
```

### Estrutura de Código

```python
"""
Docstring do módulo explicando o propósito.
"""

import standard_library
import third_party_library

from bot import local_module


def function_name(param: str) -> str:
    """
    Docstring da função com descrição, parâmetros e retorno.
    
    Args:
        param: Descrição do parâmetro
        
    Returns:
        Descrição do retorno
    """
    return param.upper()
```

## 🔄 Processo de Desenvolvimento

### 1. Desenvolvimento Local

```bash
# Inicie o ambiente de desenvolvimento
./scripts/up.ps1

# Carregue a base de conhecimento (se necessário)
./scripts/load-knowledge.ps1

# Execute testes durante desenvolvimento
pytest -v
```

### 2. Teste suas Mudanças

```bash
# Testes unitários
pytest tests/

# Cobertura de código
pytest --cov=. --cov-report=html

# Testes de integração
pytest tests/test_waha.py -v
```

### 3. Validação Pre-commit

Os hooks pre-commit executam automaticamente:

```bash
# Manual
pre-commit run --all-files
```

Hooks configurados:
- ✅ Ruff (lint)
- ✅ Black (formatação)
- ✅ Mypy (type checking)
- ✅ Trailing whitespace
- ✅ YAML/TOML validation

## 📝 Commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

### Formato

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação (não afeta código)
- `refactor`: Refatoração
- `test`: Adição/correção de testes
- `chore`: Tarefas de manutenção
- `perf`: Melhoria de performance
- `ci`: Mudanças no CI/CD

### Exemplos

```bash
# Feature
git commit -m "feat(rag): adiciona suporte a PDF com imagens"

# Fix
git commit -m "fix(waha): corrige timeout em mensagens longas"

# Docs
git commit -m "docs(readme): atualiza instruções de instalação"

# Breaking change
git commit -m "feat(api)!: altera estrutura de resposta do webhook

BREAKING CHANGE: O campo 'response' agora é 'message'"
```

## 🔀 Pull Requests

### Antes de Abrir um PR

- [ ] Código está formatado (Black)
- [ ] Passou no lint (Ruff)
- [ ] Passou no type check (Mypy)
- [ ] Testes adicionados/atualizados
- [ ] Todos os testes passando
- [ ] Documentação atualizada
- [ ] Commits seguem Conventional Commits

### Template de PR

```markdown
## Descrição

Breve descrição do que foi implementado/corrigido.

## Tipo de Mudança

- [ ] 🐛 Bug fix
- [ ] ✨ Nova feature
- [ ] 📝 Documentação
- [ ] 🔨 Refatoração
- [ ] ⚡ Performance

## Como Testar

1. Passo 1
2. Passo 2
3. Resultado esperado

## Checklist

- [ ] Código formatado e sem erros de lint
- [ ] Testes passando
- [ ] Documentação atualizada
- [ ] Screenshots (se aplicável)

## Issues Relacionadas

Closes #123
```

## 🧪 Testes

### Estrutura de Testes

```
tests/
├── test_ai_bot.py         # Testes do bot AI
├── test_health.py         # Testes de health check
└── test_waha.py          # Testes da integração WAHA
```

### Escrever Testes

```python
import pytest
from bot.ai_bot import AIBot


def test_ai_bot_initialization():
    """Testa inicialização do bot."""
    bot = AIBot()
    assert bot is not None


@pytest.mark.integration
def test_waha_send_message(mocker):
    """Testa envio de mensagem via WAHA."""
    # Seu teste aqui
    pass
```

### Executar Testes

```bash
# Todos os testes
pytest

# Testes específicos
pytest tests/test_ai_bot.py

# Com cobertura
pytest --cov=. --cov-report=html

# Apenas testes rápidos (excluir integration)
pytest -m "not integration"
```

## 📚 Documentação

### Quando Atualizar

- Nova funcionalidade → Adicionar em README.md e docs/
- Mudança de API → Atualizar exemplos
- Novas variáveis de ambiente → Atualizar .env.example
- Mudanças no Docker → Atualizar compose.yml e dockerfile

### Estilo de Documentação

- Use Markdown
- Inclua exemplos de código
- Adicione screenshots se relevante
- Mantenha conciso e claro

## 🔒 Segurança

### ⚠️ NUNCA Commit

- ❌ Arquivos `.env`
- ❌ API keys ou tokens
- ❌ Credenciais do WAHA
- ❌ Dados de produção
- ❌ Logs com informações sensíveis

### Reportar Vulnerabilidades

Envie email para: **ti@novatrento.sc.gov.br**

## 📞 Contato

Dúvidas? Entre em contato:

- **Email**: ti@novatrento.sc.gov.br
- **Issues**: https://github.com/arturmelo2/chatbot-tributos/issues

---

**Obrigado por contribuir! 🙏**
