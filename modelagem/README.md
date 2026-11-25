# Entregável 1: Modelagem do Banco de Dados — IBGE_DESEMPREGO

Este documento e pasta compõem o **Entregável Documental (Concepção e Modelagem)** da disciplina Banco de Dados 2 (IFSP), contemplando o **Minimundo**, o **Modelo Entidade-Relacionamento (MER)** e o **Modelo Relacional** integrando o esquema base do IBGE.

---

## 1. 📖 Minimundo (Descrição Conceitual do Domínio)

O sistema **IBGE_DESEMPREGO** tem por finalidade centralizar, gerenciar e disponibilizar dados socioeconômicos e estatísticas oficiais sobre o mercado de trabalho brasileiro, permitindo análises comparativas e espaciais entre macro-regiões, unidades federativas e municípios.

### 1.1. Estrutura Territorial Base
O domínio abrange o território nacional (**Pais**), subdividido nas cinco macro-regiões oficiais do IBGE (**Regioes**: Norte, Nordeste, Sudeste, Sul e Centro-Oeste). Cada região agrega múltiplos **Estados** (UFs), e cada estado é composto por dezenas ou centenas de **Municipios**. 
* Cada estado possui código de identificação, sigla única de 2 caracteres, nome oficial, população residente, renda média e taxa de desocupação (desemprego).
* Cada município é identificado unicamente pelo seu **código oficial do IBGE de 7 dígitos**, além de armazenar seu nome, UF de vínculo, população e os indicadores locais de rendimento médio e taxa de desemprego.

### 1.2. Expansão Analítica e Séries Históricas
Para viabilizar estudos longitudinais e cruzamento de vulnerabilidades:
* Cada estado possui exatamente um registro consolidado de **Indicadores_Sociais** (relação 1:1), contemplando o Índice de Desenvolvimento Humano Municipal médio da UF (**IDHM**), a proporção de pessoas abaixo da linha de pobreza monetária (**pct_pobreza**) e a desigualdade na distribuição de renda (**indice_gini**).
* Para análise de séries temporais pós-pandemia, cada estado possui múltiplos registros no **Historico_Desemprego** (relação 1:N), onde são gravadas anualmente a taxa de desemprego e a renda média real, com a garantia de que não existam registros duplicados para a mesma UF no mesmo ano (`UNIQUE(id_estado, ano)`).

### 1.3. Governança, Controle de Acesso e Auditoria
Para manter a integridade dos dados, as informações municipais podem ser corrigidas e atualizadas por uma equipe técnica de **Analistas** devidamente cadastrados no sistema (com nome, e-mail único corporativo, cargo e departamento).
* Sempre que uma taxa de desemprego, renda ou população for corrigida por meio de procedimentos armazenados ou rotinas administrativas, o evento gera automaticamente um registro na tabela associativa de **Auditoria** (relação N:M entre Analistas e Municípios).
* A auditoria registra o identificador da alteração, o código do município afetado, o campo modificado, o valor antigo, o valor novo, a identificação do analista responsável e a data/hora exata do registro (`SYSDATE`).

---

## 2. 📌 Arquivos e Diagramas Disponíveis

1. **`modelo_entidade_relacionamento.png` (MER Conceitual)**
   * Diagrama Conceitual Entidade-Relacionamento.
   * Contempla as 8 entidades (`Pais`, `Regioes`, `Estados`, `Municipios`, `Analistas`, `Auditoria`, `Indicadores_Sociais`, `Historico_Desemprego`).
   * Apresenta os losangos de relacionamento com verbos semânticos (`ABRIGA`, `AGRUPA`, `CONTÉM`, `POSSUI`, `REGISTRA`, `AUDITADO_EM`, `EFETUA`), badges destacados com a cardinalidade macro (`1:N` e `1:1`) e as cardinalidades estruturais mínimas/máximas `(min, max)`.

2. **`modelo_relacional.png` (Modelo Lógico Relacional / DER)**
   * Esquema Lógico Relacional detalhado com todas as tabelas normalizadas.
   * Especificação formal das colunas com tipos de dados nativos do Oracle/MySQL (`NUMBER`, `VARCHAR2`, `DATE`).
   * Identificação de chaves primárias (**PK**), chaves estrangeiras (**FK**) e restrições de unicidade (**UQ**).
   * Linhas ortogonais de integridade referencial com marcadores e badges indicando as cardinalidades `1:N` e `1:1`.

3. **`gerar_diagramas.py`**
   * Script Python automatizado responsável pela renderização gráfica vetorial dos diagramas para PNG em alta resolução (300 DPI).

---

## 3. 🔗 Matriz de Relacionamentos e Cardinalidades

| Entidade Origem (1) | Verbo de Ligação | Cardinalidade | Entidade Destino (N / 1) | Chave Estrangeira (FK) | Regra de Integridade |
| :--- | :---: | :---: | :--- | :--- | :--- |
| **Pais** | Abriga | **1:N** | **Estados** | `Estados.id_pais` ──> `Pais.id_pais` | Cada estado pertence obrigatoriamente a 1 país. |
| **Regioes** | Agrupa | **1:N** | **Estados** | `Estados.id_regiao` ──> `Regioes.id_regiao` | Cada estado pertence obrigatoriamente a 1 macro-região. |
| **Estados** | Contém | **1:N** | **Municipios** | `Municipios.id_estado` ──> `Estados.id_estado` | Cada município pertence a um único estado. |
| **Estados** | Possui | **1:1** | **Indicadores_Sociais** | `Indicadores_Sociais.id_estado` ──> `Estados.id_estado` | Exclusivo (`UNIQUE`), 1 registro de indicadores por UF. |
| **Estados** | Registra | **1:N** | **Historico_Desemprego** | `Historico_Desemprego.id_estado` ──> `Estados.id_estado` | Série histórica anual por estado (`UNIQUE(id_estado, ano)`). |
| **Municipios** | Auditado em | **1:N** | **Auditoria** | `Auditoria.codigo_ibge` ──> `Municipios.codigo_ibge` | Log histórico de alterações ocorridas no município. |
| **Analistas** | Efetua | **1:N** | **Auditoria** | `Auditoria.id_analista` ──> `Analistas.id_analista` | Rastreamento do analista responsável pela alteração. |

### Notações Adotadas:
* **1:N (Um para Muitos)**: Ocorrência singular no lado 1 associada a múltiplas no lado N.
* **1:1 (Um para Um)**: Ocorrência singular em ambos os lados, assegurada por restrição de unicidade (`UNIQUE`) na chave estrangeira.
* **N:M (Muitos para Muitos)**: Resolvido fisicamente através da tabela associativa `Auditoria` conectando `Analistas` e `Municipios`.
* **(min, max)**:
  * `(1,1)`: Participação obrigatória unívoca.
  * `(1,n)`: Participação obrigatória múltipla.
  * `(0,n)`: Participação opcional múltipla (ex.: municípios ou analistas que ainda não possuem registros de auditoria).
