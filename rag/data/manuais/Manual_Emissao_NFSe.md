# Manual de Emissão de NFS-e - Nova Trento/SC

## Introdução

Guia completo passo a passo para emissão de Nota Fiscal de Serviços Eletrônica (NFS-e) no município de Nova Trento/SC.

**Portal NFS-e**: https://e-gov.betha.com.br/nfse/03114-502/

---

## 1. Primeiro Acesso

### 1.1. Solicitar código de ativação

**Presencialmente**:
1. Ir ao Setor de Tributos com:
   - Contrato social ou MEI
   - RG e CPF do responsável
   - Comprovante de inscrição municipal
2. Solicitar código de ativação para NFS-e
3. Informar e-mail para recebimento do código

**On-line** (se já cadastrado):
1. Acessar: https://e-gov.betha.com.br/nfse/03114-502/
2. Clicar em "Primeiro Acesso"
3. Informar CNPJ
4. Sistema envia código para e-mail cadastrado

### 1.2. Cadastrar senha

1. Receber código por e-mail
2. Voltar ao portal NFS-e
3. "Ativar Cadastro"
4. Informar:
   - CNPJ
   - Código de ativação
   - Nova senha (mín. 8 caracteres)
5. Confirmar cadastro

---

## 2. Emitir NFS-e - Passo a Passo

### 2.1. Login

1. Acessar: https://e-gov.betha.com.br/nfse/03114-502/
2. Informar:
   - CNPJ (sem pontos/traços)
   - Senha
3. Clicar em "Entrar"

### 2.2. Nova NFS-e

**Menu**: Nota Fiscal > Emitir NFS-e

### 2.3. Dados do Tomador (Cliente)

**Campos obrigatórios**:
- **CPF ou CNPJ**: Sem pontos/traços
- Sistema preenche automaticamente: Nome, endereço (se cadastrado)

**Se tomador não estiver cadastrado**:
- Preencher manualmente:
  - Nome / Razão Social
  - Endereço completo
  - Município
  - E-mail (para envio automático da nota)

### 2.4. Dados do Serviço

**Campos principais**:

**1. Código do Serviço**:
- Selecionar da lista LC 116/2003
- Exemplo: "17.01 - Assessoria ou consultoria"
- **Sistema preenche automaticamente a alíquota**

**2. Descrição do Serviço**:
- Detalhar o que foi feito
- Exemplo: "Consultoria contábil referente ao mês de outubro/2025, incluindo análise de demonstrativos financeiros e orientação tributária"
- Mínimo 20 caracteres

**3. Valor do Serviço**:
- Informar valor **bruto** (sem descontos)
- Exemplo: R$ 2.500,00

**4. Deduções** (se aplicável):
- Material (apenas se permitido para o serviço)
- Subempreitada (com NFS-e)
- Deixar zero se não houver

### 2.5. Retenções

**Marcar se houver retenção pelo tomador**:

**ISS Retido**:
- ☑ Marcar se tomador for órgão público ou empresa optante
- Sistema não gerará cobrança de ISS

**PIS** (0,65%):
- Retido por pessoa jurídica em alguns serviços

**COFINS** (3,0%):
- Retido por pessoa jurídica em alguns serviços

**CSLL** (1,0%):
- Retido por pessoa jurídica em alguns serviços

**IR** (1,5% a 4,8%):
- Conforme serviço e valor

**INSS** (11%):
- Cessão de mão-de-obra e construção civil

### 2.6. Informações Complementares

**Campo opcional**:
- Informações adicionais para o tomador
- Exemplo: "Forma de pagamento: PIX - Vencimento: 10/11/2025"

### 2.7. Revisar e Emitir

1. Revisar todos os campos
2. Conferir:
   - Dados do tomador
   - Código do serviço
   - Valor e alíquota (calculado automaticamente)
   - Retenções (se houver)
3. Clicar em **"Emitir NFS-e"**
4. Sistema gera número da nota
5. Baixar PDF ou enviar por e-mail

---

## 3. Exemplos Práticos

### Exemplo 1: Consultoria para Pessoa Física

**Dados**:
- Tomador: João Silva - CPF 123.456.789-00
- Serviço: Consultoria administrativa (código 17.01)
- Valor: R$ 1.500,00
- Sem retenções

**Preenchimento**:
1. CPF do tomador: 12345678900
2. Código: 17.01
3. Descrição: "Consultoria administrativa para planejamento estratégico empresarial"
4. Valor: 1500,00
5. Retenções: Nenhuma
6. Emitir

**Resultado**:
- NFS-e nº 123
- ISS (5%): R$ 75,00
- Valor líquido: R$ 1.500,00 (sem retenção)

### Exemplo 2: Serviço para Prefeitura (com retenção)

**Dados**:
- Tomador: Prefeitura Municipal de Nova Trento - CNPJ 82.938.513/0001-90
- Serviço: Manutenção de software (código 1.03)
- Valor: R$ 5.000,00
- ISS retido pela Prefeitura

**Preenchimento**:
1. CNPJ: 82938513000190
2. Código: 1.03
3. Descrição: "Manutenção corretiva e preventiva de sistema de gestão municipal"
4. Valor: 5000,00
5. ☑ Marcar "ISS Retido pelo Tomador"
6. Emitir

**Resultado**:
- NFS-e nº 124
- ISS (2%): R$ 100,00 (**retido pela Prefeitura**)
- Valor líquido para prestador: R$ 5.000,00
- Prestador **não paga** ISS (já foi retido)
- Prefeitura recolhe R$ 100,00 até dia 10 do mês seguinte

### Exemplo 3: Obra de Construção Civil

**Dados**:
- Tomador: Construtora XYZ Ltda - CNPJ 12.345.678/0001-99
- Serviço: Execução de obra (código 7.02)
- Valor: R$ 80.000,00
- INSS retido (11%)

**Preenchimento**:
1. CNPJ: 12345678000199
2. Código: 7.02
3. Descrição: "Execução de obra residencial conforme projeto anexo, incluindo fundação, estrutura e acabamento"
4. Valor: 80000,00
5. ☑ ISS Retido (se tomador for PJ)
6. ☑ INSS Retido (11%) = R$ 8.800,00
7. Emitir

**Resultado**:
- NFS-e nº 125
- ISS (2%): R$ 1.600,00 (retido)
- INSS (11%): R$ 8.800,00 (retido)
- Total retido: R$ 10.400,00
- Valor líquido: R$ 69.600,00

---

## 4. Após Emitir

### 4.1. Baixar PDF

1. Após emitir, clicar em "Baixar PDF"
2. Salvar arquivo
3. Enviar ao cliente por e-mail

### 4.2. Envio automático

Se informou e-mail do tomador, sistema envia automaticamente.

### 4.3. Reenviar NFS-e

**Menu**: Nota Fiscal > Consultar Notas Emitidas

1. Localizar nota
2. Clicar em "Reenviar por E-mail"
3. Informar e-mail do destinatário
4. Enviar

---

## 5. Cancelar NFS-e

### 5.1. Prazo

**Até o último dia do mês seguinte** à emissão.

**Exemplo**:
- Nota emitida em: 15/10/2025
- Pode cancelar até: 30/11/2025

### 5.2. Como cancelar

1. Menu: Nota Fiscal > Consultar Notas Emitidas
2. Localizar nota a cancelar
3. Clicar em "Cancelar"
4. Informar motivo (obrigatório)
5. Confirmar cancelamento

**Motivos comuns**:
- Nota emitida em duplicidade
- Serviço não prestado
- Erro nos dados

**Atenção**: Cancelamento gera carta de correção. Informar ao cliente.

---

## 6. Substituir NFS-e

**Não existe substituição direta**. Procedimento:

1. **Cancelar** nota original
2. **Emitir** nova nota correta
3. Informar ao cliente

**Prazo**: Mesmo da cancelamento (até último dia do mês seguinte).

---

## 7. Consultar NFS-e Emitidas

**Menu**: Nota Fiscal > Consultar Notas Emitidas

**Filtros disponíveis**:
- Período (data de emissão)
- Número da nota
- CPF/CNPJ do tomador
- Situação (emitida, cancelada)

**Ações disponíveis**:
- Visualizar PDF
- Baixar XML
- Reenviar por e-mail
- Cancelar (dentro do prazo)

---

## 8. Consultar NFS-e Recebidas (Tomador)

**Portal do Tomador**:
https://e-gov.betha.com.br/nfse/03114-502/tomador/

**Funcionalidades**:
- Ver todas as NFS-e recebidas
- Baixar PDF para comprovação de despesa
- Filtrar por prestador e período

---

## 9. Declaração Mensal (DMS)

### 9.1. O que declarar

**DMS** inclui automaticamente todas as NFS-e emitidas no mês.

**Deve incluir manualmente**:
- Serviços prestados **sem NFS-e** (para pessoa física)

### 9.2. Prazo

**Até dia 10 do mês seguinte**.

### 9.3. Como declarar

**Portal DMS**:
https://e-gov.betha.com.br/dms/03114-502/

1. Login com CNPJ + senha
2. Selecionar mês/ano
3. Conferir NFS-e listadas (automático)
4. Adicionar serviços sem NFS-e (se houver)
5. Transmitir

**Penalidade por atraso**:
- Multa de 2% ao mês (mínimo R$ 50,00)
- Bloqueio de emissão de novas NFS-e

---

## 10. Problemas Comuns e Soluções

### Senha bloqueada

**Solução**:
1. Portal NFS-e > "Esqueci minha senha"
2. Informar CNPJ
3. Nova senha enviada por e-mail

### Erro "CPF/CNPJ não encontrado"

**Causa**: Tomador não cadastrado.

**Solução**: Preencher dados manualmente (nome, endereço).

### Sistema lento

**Dica**: Evitar dias 1-10 do mês (pico de uso).

### Nota não chega ao tomador

**Solução**:
- Verificar e-mail informado (confira se está correto)
- Baixar PDF e enviar manualmente

### Impossibilidade de emitir

**Causa**: Débitos de ISS ou DMS em atraso.

**Solução**:
1. Consultar débitos no portal
2. Pagar ou parcelar
3. Aguardar 1-2 dias úteis

---

**Atualizado em**: Novembro/2025
**Setor de Tributos - Prefeitura Municipal de Nova Trento/SC**
**Portal NFS-e**: https://e-gov.betha.com.br/nfse/03114-502/
**Suporte Betha**: 0800 646 2100
