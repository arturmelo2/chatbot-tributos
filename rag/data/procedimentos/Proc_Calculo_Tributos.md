# Procedimento: Cálculo de Tributos Municipais

**Responsável**: Fiscal Tributário / Atendente  
**Objetivo**: Padronizar cálculos de IPTU, ISS, ITBI e Taxas  
**Base Legal**: LC 661/2017

---

## 1. IPTU - Imposto Predial e Territorial Urbano

### 1.1. Fórmula básica

```
IPTU = Valor Venal × Alíquota
```

### 1.2. Cálculo do Valor Venal

**Valor Venal Total** = Valor do Terreno + Valor da Construção

#### Valor do Terreno

```
VT = Área Terreno (m²) × Valor m² (PGV) × Fatores de Correção
```

**Fatores de correção**:
- Topografia: Plano (1,0), Aclive (0,9), Declive (0,85)
- Situação: Meio quadra (1,0), Esquina (1,1), Duas frentes (1,15)
- Pedologia: Firme (1,0), Alagável (0,7)

#### Valor da Construção

```
VC = Área Construída (m²) × Valor m² (padrão) × Fator Depreciação
```

**Valores m² por padrão** (ano 2025):
- Rudimentar: R$ 600/m²
- Popular: R$ 900/m²
- Médio: R$ 1.400/m²
- Alto: R$ 2.000/m²
- Luxo: R$ 3.000/m²

**Depreciação por idade**:
- 0-5 anos: 1,0
- 6-10 anos: 0,95
- 11-15 anos: 0,90
- 16-20 anos: 0,85
- 21-30 anos: 0,80
- 31-40 anos: 0,75
- 40+ anos: 0,70

### 1.3. Alíquotas

**Predial**:
- Até R$ 100k: 0,5%
- R$ 100k-200k: 0,7%
- R$ 200k-350k: 1,0%
- R$ 350k-500k: 1,2%
- Acima R$ 500k: 1,5%

**Territorial**:
- Até R$ 50k: 1,0%
- R$ 50k-150k: 2,0%
- Acima R$ 150k: 3,0%
- + Progressividade (terreno não edificado): +0,5%/ano (até 15%)

### 1.4. Exemplo prático

**Dados**:
- Terreno: 450 m² × R$ 250/m² × 1,0 (fatores) = R$ 112.500
- Construção: 120 m² × R$ 1.400/m² × 0,95 (8 anos) = R$ 159.600
- **Valor Venal**: R$ 272.100
- **Alíquota**: 1,0% (faixa R$ 200k-350k)

**IPTU** = 272.100 × 1,0% = **R$ 2.721,00/ano**

**Cota única** (10% desc): R$ 2.448,90  
**10 parcelas**: R$ 272,10/mês

---

## 2. ISS - Imposto Sobre Serviços

### 2.1. Fórmula básica

```
ISS = Valor do Serviço × Alíquota
```

### 2.2. Alíquotas por serviço

**2%**: Construção civil, locação, transporte  
**3%**: Educação, consultoria técnica  
**5%**: Saúde, advocacia, engenharia, contabilidade, publicidade

### 2.3. Base de cálculo

**Regra geral**: Valor total do serviço (sem dedução de materiais).

**Exceções (apenas se previstas em lei municipal vigente e devidamente comprovadas)**:
- Próteses dentárias: Pode haver dedução de material quando expressamente prevista em lei e com comprovação.
- Subempreitadas: Pode haver dedução do valor de NFS-e de subcontratados quando a legislação municipal permitir e houver documentação idônea.

### 2.4. Exemplo prático

**Consultoria contábil**:
- Valor: R$ 3.000,00
- Alíquota: 5%
- **ISS** = 3.000 × 5% = **R$ 150,00**

**Obra de construção civil** (exemplo hipotético com dedução de subempreitada):
- Valor total: R$ 200.000,00
- Subempreitada: R$ 50.000,00 (com NFS-e)
- Base de cálculo: 200.000 - 50.000 = R$ 150.000
- Alíquota: 2%
- **ISS** = 150.000 × 2% = **R$ 3.000,00**
Observação: Aplicável apenas se a dedução de subempreitada estiver prevista na legislação municipal do exercício.

### 2.5. ISS Fixo (Sociedade Uniprofissional)

**Exemplo**: Clínica com 3 médicos
- ISS fixo por profissional: R$ 300/mês
- **Total**: 3 × 300 = **R$ 900/mês**

---

## 3. ITBI - Imposto de Transmissão de Bens Imóveis

### 3.1. Fórmula básica

```
ITBI = Base de Cálculo × 2%
```

### 3.2. Base de cálculo

**Regra**: O **maior valor** entre:
- Valor da transação (escritura)
- Valor venal (IPTU)
- Valor de mercado (se houver avaliação)

### 3.3. Exemplo prático

**Compra de imóvel**:
- Valor escritura: R$ 280.000
- Valor venal IPTU: R$ 250.000
- **Base de cálculo**: R$ 280.000 (maior)
- **ITBI** = 280.000 × 2% = **R$ 5.600,00**

**Permuta de imóveis**:
- Imóvel A: R$ 300.000
- Imóvel B: R$ 350.000
- **Base**: R$ 350.000 (maior)
- **ITBI** = 350.000 × 2% = **R$ 7.000,00**

---

## 4. Taxas Municipais

### 4.1. Taxa de Fiscalização de Funcionamento (TFF)

**Fórmula**:
```
TFF = Área do Estabelecimento (m²) × UFIR × Multiplicador
```

**Multiplicadores**:
- Comércio: 0,5
- Serviços: 1,0
- Indústria: 1,5

**UFIR** (2025): R$ 4,50 (valor hipotético)

**Exemplo**:
- Comércio varejista
- Área: 80 m²
- **TFF** = 80 × 4,50 × 0,5 = **R$ 180,00/ano**

### 4.2. Taxa de Licença de Localização (inicial)

**Tabela fixa por porte**:
- MEI: Isento
- ME: R$ 200,00
- EPP: R$ 500,00
- Grande porte: R$ 1.500,00

### 4.3. Taxa de Coleta de Lixo (TCL)

**Fórmula**:
```
TCL = Categoria × Frequência
```

**Categorias**:
- Residencial: R$ 80,00/ano
- Comercial: R$ 150,00/ano
- Industrial: R$ 300,00/ano

---

## 5. Acréscimos Moratórios

### 5.1. Pagamento em atraso

**Componentes**:
- Multa: 2% sobre valor principal
- Juros: SELIC acumulada do vencimento até pagamento
- Atualização monetária: IPCA acumulado

### 5.2. Cálculo de juros SELIC

**Exemplo**:
- IPTU vencido em 31/03/2023
- Pagamento em 05/11/2025
- Período: 32 meses
- SELIC acumulada: ~12% (exemplo)

**Débito**:
- Principal: R$ 1.500,00
- Multa (2%): R$ 30,00
- Juros SELIC (12%): R$ 180,00
- Atualização IPCA (18%): R$ 270,00
- **Total**: R$ 1.980,00

### 5.3. Cálculo simplificado (sistema Betha)

**Sistema faz automaticamente**:
1. Informar data de vencimento
2. Informar data de pagamento
3. Sistema calcula SELIC e IPCA do período
4. Gera guia atualizada

---

## 6. Descontos e Benefícios

### 6.1. Desconto 10% IPTU cota única

**Aplicação**: Automática na guia de cota única

**Exemplo**:
- IPTU: R$ 2.000,00
- Cota única: R$ 1.800,00

### 6.2. Quitação antecipada de parcelamento

**Desconto 10% sobre juros/multa**:
- Saldo: R$ 8.000 (sendo R$ 6.000 principal + R$ 2.000 juros/multa)
- Desconto: R$ 200 (10% sobre juros)
- **Total**: R$ 7.800,00

---

## 7. Ferramentas de Cálculo

### 7.1. Sistema Betha

**Módulos**:
- Cadastro Imobiliário: Calcula IPTU automaticamente
- Tributos Diversos: ISS, ITBI, Taxas
- Dívida Ativa: Acréscimos moratórios

**Vantagem**: Cálculo automático, auditável, com histórico

### 7.2. Planilha de cálculo (backup)

**Quando usar**: Sistema fora do ar, cálculos específicos

**Excel**: `Cálculos_Tributos_2025.xlsx`
- Aba IPTU
- Aba ISS
- Aba ITBI
- Aba Acréscimos

### 7.3. Calculadora on-line (cidadão)

**Portal**: https://e-gov.betha.com.br/cdweb/03114-502/simulador/

**Funcionalidades**:
- Simular IPTU por endereço
- Calcular ISS por serviço
- Simular parcelamento

---

## 8. Conferência e Auditoria

### 8.1. Antes de emitir guia

**Checklist**:
- ✅ Dados do contribuinte corretos
- ✅ Inscrição (imobiliária, econômica) correta
- ✅ Valor principal conferido
- ✅ Acréscimos calculados corretamente
- ✅ Vencimento futuro (não retroativo)

### 8.2. Revisão de cálculos

**Periodicidade**: Anual (antes do lançamento do IPTU)

**Ações**:
- Revisar Planta Genérica de Valores
- Atualizar valores m² por padrão
- Conferir alíquotas vigentes
- Testar cálculos em amostra de imóveis

---

## 9. Casos Especiais

### 9.1. Imóvel com múltiplos usos (misto)

**Exemplo**: Térreo comercial + 2º andar residencial

**Cálculo**:
- Área comercial × alíquota comercial
- Área residencial × alíquota residencial
- Somar IPTU das duas partes

### 9.2. Terreno em condomínio

**Fração ideal**:
- Valor total do terreno / número de unidades = Valor por unidade
- Cada proprietário paga IPTU da fração + sua construção

### 9.3. Imóvel rural na zona urbana

**Regra**: Se tem infraestrutura urbana (2 de 5 melhoramentos) → IPTU  
**Se não**: ITR (federal)

---

**Última atualização**: Novembro/2025  
**Setor de Tributos - Prefeitura Municipal de Nova Trento/SC**
