# Manual de Cálculo do IPTU - Nova Trento/SC

## Introdução

Este manual apresenta o passo a passo para calcular o IPTU (Imposto Predial e Territorial Urbano) em Nova Trento/SC, conforme LC 661/2017 e alterações posteriores.

---

## 1. Conceitos Básicos

### O que é IPTU?

Imposto municipal sobre a propriedade predial e territorial urbana, devido anualmente pelo proprietário do imóvel.

### Quando é devido?

Todo imóvel situado na **zona urbana** do município está sujeito ao IPTU. Imóveis rurais pagam ITR (federal).

### Base legal

- Lei Complementar 661/2017 - Código Tributário Municipal
- LC 705/2023 - Atualizações de valores e alíquotas

---

## 2. Fórmula de Cálculo

```
IPTU = Valor Venal × Alíquota
```

**Onde**:
- **Valor Venal**: Valor do imóvel calculado pela Prefeitura
- **Alíquota**: Percentual aplicado conforme tipo e valor do imóvel

---

## 3. Cálculo do Valor Venal

### 3.1. Componentes

**Valor Venal Total** = Valor do Terreno + Valor da Construção

### 3.2. Valor do Terreno

```
Valor do Terreno = Área do Terreno (m²) × Valor do m² (tabela) × Fator de Correção
```

**Fatores de correção**:
- **Testada**: Largura da frente do lote (quanto maior, melhor)
- **Profundidade**: Profundidade do lote
- **Topografia**: Plano (1,0), aclive (0,9), declive (0,85)
- **Pedologia**: Tipo de solo (firme 1,0, alagável 0,7)
- **Situação**: Meio de quadra (1,0), esquina (1,1), duas frentes (1,15)

**Exemplo**:
- Área: 450 m²
- Valor m² (tabela bairro Centro): R$ 250,00
- Testada 15m × profundidade 30m: Fator 1,0
- Topografia plana: Fator 1,0
- Solo firme: Fator 1,0
- Meio de quadra: Fator 1,0

**Valor do terreno** = 450 × 250 × 1,0 × 1,0 × 1,0 × 1,0 = **R$ 112.500,00**

### 3.3. Valor da Construção

```
Valor da Construção = Área Construída (m²) × Valor do m² (por padrão) × Fator de Idade
```

**Padrões construtivos** (valor m² aproximado - 2025):
- **Rudimentar**: R$ 600,00/m² (madeira, sem acabamento)
- **Popular**: R$ 900,00/m² (alvenaria simples)
- **Médio**: R$ 1.400,00/m² (alvenaria, bom acabamento)
- **Alto**: R$ 2.000,00/m² (alvenaria, acabamento superior)
- **Luxo**: R$ 3.000,00/m² (alto padrão, acabamento nobre)

**Fator de depreciação por idade**:
- Construção nova (0-5 anos): 1,0
- 6-10 anos: 0,95
- 11-15 anos: 0,90
- 16-20 anos: 0,85
- 21-30 anos: 0,80
- 31-40 anos: 0,75
- Acima de 40 anos: 0,70

**Exemplo**:
- Área construída: 120 m²
- Padrão médio: R$ 1.400,00/m²
- Idade: 8 anos (fator 0,95)

**Valor da construção** = 120 × 1.400 × 0,95 = **R$ 159.600,00**

### 3.4. Valor Venal Total

**Valor Venal** = 112.500 + 159.600 = **R$ 272.100,00**

---

## 4. Alíquotas do IPTU

### 4.1. Imóvel Predial (com construção)

**Alíquotas progressivas** (conforme LC 705/2023):

| Valor Venal | Alíquota |
|-------------|----------|
| Até R$ 100.000,00 | 0,5% |
| De R$ 100.000,01 a R$ 200.000,00 | 0,7% |
| De R$ 200.000,01 a R$ 350.000,00 | 1,0% |
| De R$ 350.000,01 a R$ 500.000,00 | 1,2% |
| Acima de R$ 500.000,00 | 1,5% |

**Cálculo progressivo**: Aplica-se a alíquota correspondente à faixa de valor.

**Exemplo** (valor venal R$ 272.100,00):
- Alíquota aplicável: **1,0%**
- IPTU anual: 272.100 × 1,0% = **R$ 2.721,00**

### 4.2. Imóvel Territorial (sem construção)

**Alíquotas progressivas**:

| Valor Venal | Alíquota |
|-------------|----------|
| Até R$ 50.000,00 | 1,0% |
| De R$ 50.000,01 a R$ 150.000,00 | 2,0% |
| Acima de R$ 150.000,00 | 3,0% |

**IPTU Progressivo no Tempo** (terreno não edificado):
- A cada ano sem edificação, acréscimo de 0,5% na alíquota (até limite de 15%)

---

## 5. Descontos e Formas de Pagamento

### 5.1. Cota Única com Desconto

**Desconto**: 10% para pagamento em cota única

**Vencimento**: Último dia útil de março

**Exemplo**:
- IPTU anual: R$ 2.721,00
- Cota única: R$ 2.721,00 × 0,90 = **R$ 2.448,90**

### 5.2. Parcelamento em 10 vezes

**Sem desconto**

**Vencimento**: Último dia útil de cada mês (abril a janeiro)

**Valor mínimo da parcela**: R$ 50,00

**Exemplo**:
- IPTU anual: R$ 2.721,00
- 10 parcelas: **R$ 272,10/mês**

---

## 6. Casos Especiais

### 6.1. Imóveis Comerciais

Alíquotas diferenciadas podem se aplicar conforme uso:
- Comercial: Alíquotas normais
- Misto (residencial + comercial): Alíquota média ponderada

### 6.2. Imóveis com Isenção

**Isenções previstas** (conforme LC 661/2017):
- Aposentados/pensionistas (requisitos: renda até 3 SM, único imóvel até 70m² e valor até R$ 100.000)
- Pessoas com deficiência (requisitos: único imóvel de moradia)
- Templos religiosos (uso exclusivo para culto)
- Imóveis de entidades filantrópicas sem fins lucrativos

**Isenção reduz IPTU a zero**.

### 6.3. Imóveis Edificados Parcialmente

Quando há construção em andamento:
- Aplica-se alíquota territorial sobre área não construída
- Aplica-se alíquota predial sobre área construída (proporcionalmente)

---

## 7. Exemplos Práticos Completos

### Exemplo 1: Casa Padrão Popular

**Dados**:
- Terreno: 300 m² × R$ 200/m² = R$ 60.000
- Construção: 80 m² × R$ 900/m² × fator 0,90 (12 anos) = R$ 64.800
- Valor Venal Total: R$ 124.800

**Cálculo**:
- Alíquota: 0,7% (faixa R$ 100k-200k)
- IPTU anual: 124.800 × 0,7% = **R$ 873,60**
- Cota única (10% desc): **R$ 786,24**
- 10 parcelas: **R$ 87,36/mês**

### Exemplo 2: Terreno Urbano Não Edificado

**Dados**:
- Terreno: 600 m² × R$ 180/m² = R$ 108.000
- Sem construção
- 3º ano sem edificar

**Cálculo**:
- Alíquota base: 2,0% (faixa R$ 50k-150k)
- Progressividade: +1,0% (0,5% × 2 anos) = 3,0%
- IPTU anual: 108.000 × 3,0% = **R$ 3.240,00**

### Exemplo 3: Casa Alto Padrão com Isenção Aposentado

**Dados**:
- Valor Venal: R$ 85.000 (dentro do limite)
- Proprietário aposentado, renda familiar 2,5 SM
- Único imóvel, 65m² área construída

**Cálculo**:
- IPTU sem isenção: 85.000 × 0,5% = R$ 425,00
- **Com isenção**: **R$ 0,00** (isento)

---

## 8. Verificando seu IPTU

### Consulta on-line

**Portal**:
https://e-gov.betha.com.br/cdweb/03114-502/contribuinte/rel_guiaiptu.faces

**O que consultar**:
- Valor venal do imóvel
- Área do terreno e construção
- Alíquota aplicada
- Valor do IPTU (anual e parcelas)

### Impugnação de valor

Se discordar do valor venal ou IPTU calculado:
1. Protocolar impugnação em até 30 dias do recebimento do carnê
2. Fundamentar com documentos (laudos, fotos, comparativos)
3. Aguardar análise (até 60 dias)

---

## 9. Referências Legais

- **LC 661/2017**: Código Tributário Municipal
- **LC 705/2023**: Atualização de valores e alíquotas
- **CTN (Lei 5.172/1966)**: Código Tributário Nacional

---

**Atualizado em**: Novembro/2025
**Setor de Tributos - Prefeitura Municipal de Nova Trento/SC**
**Protocolo on-line**: https://e-gov.betha.com.br/cdweb/resource.faces?params=MHVx5_C9a7cJ50VtitcW8g==
