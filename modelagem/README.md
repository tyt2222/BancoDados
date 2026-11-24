# Modelagem do Banco de Dados — IBGE_DESEMPREGO

Esta pasta contém os diagramas conceituais e relacionais atualizados do projeto.

---

## 📌 Arquivos Disponíveis

1. **`modelo_entidade_relacionamento.png` (MER Conceitual)**
   * Diagrama Conceitual Entidade-Relacionamento.
   * Apresenta as 8 entidades (`Pais`, `Regioes`, `Estados`, `Municipios`, `Analistas`, `Auditoria`, `Indicadores_Sociais`, `Historico_Desemprego`), os losangos de relacionamento com verbos de ligação, badges de cardinalidade macro (`1:N`, `1:1`) e cardinalidades mínimas/máximas `(min, max)`.

2. **`modelo_relacional.png` (Modelo Lógico Relacional / DER)**
   * Diagrama Lógico Relacional com todas as tabelas, colunas, tipos de dados Oracle/SQL, chaves primárias (PK), chaves estrangeiras (FK), constraints de unicidade (UQ) e as ligações de integridade referencial com badges indicando cardinalidade `1:N` e `1:1`.

---

## 🔗 Resumo das Cardinalidades

| Entidade Origem (1) | Relação | Cardinalidade | Entidade Destino (N / 1) | Chave Estrangeira (FK) |
| :--- | :---: | :---: | :--- | :--- |
| **Pais** | Abriga | **1:N** | **Estados** | `Estados.id_pais` ──> `Pais.id_pais` |
| **Regioes** | Agrupa | **1:N** | **Estados** | `Estados.id_regiao` ──> `Regioes.id_regiao` |
| **Estados** | Contém | **1:N** | **Municipios** | `Municipios.id_estado` ──> `Estados.id_estado` |
| **Estados** | Possui | **1:1** | **Indicadores_Sociais** | `Indicadores_Sociais.id_estado` ──> `Estados.id_estado` (`UNIQUE`) |
| **Estados** | Registra | **1:N** | **Historico_Desemprego** | `Historico_Desemprego.id_estado` ──> `Estados.id_estado` |
| **Municipios** | Auditado em | **1:N** | **Auditoria** | `Auditoria.codigo_ibge` ──> `Municipios.codigo_ibge` |
| **Analistas** | Efetua | **1:N** | **Auditoria** | `Auditoria.id_analista` ──> `Analistas.id_analista` |

### Detalhamento das Notações
* **1:N (Um para Muitos)**: Uma única ocorrência da entidade do lado 1 pode se associar a várias ocorrências da entidade do lado N (ex.: 1 estado tem N municípios).
* **1:1 (Um para Um)**: Relação exclusiva e unívoca mantida por restrição `UNIQUE` na chave estrangeira (ex.: cada estado tem exatamente 1 registro de indicadores sociais consolidados).
* **(min, max)**:
  * `(1,1)`: Participação obrigatória unívoca.
  * `(1,n)`: Participação obrigatória múltipla (pelo menos 1).
  * `(0,n)`: Participação opcional múltipla (pode haver zero ou várias ocorrências, como as auditorias).
