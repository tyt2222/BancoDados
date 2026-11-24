# Modelagem do Banco de Dados — IBGE_DESEMPREGO

Esta pasta contém os diagramas conceituais e relacionais atualizados do projeto.

---

## 📌 Arquivos Disponíveis

1. **`modelo_entidade_relacionamento.png` (MER Conceitual)**
   * Diagrama Conceitual Entidade-Relacionamento.
   * Apresenta as entidades (`Pais`, `Regioes`, `Estados`, `Municipios`, `Analistas`, `Auditoria`, `Indicadores_Sociais`, `Historico_Desemprego`), seus relacionamentos e cardinalidades `(min, max)`.

2. **`modelo_relacional.png` (Modelo Lógico Relacional / DER)**
   * Diagrama Lógico Relacional com todas as tabelas, colunas, tipos de dados Oracle/SQL, chaves primárias (PK), chaves estrangeiras (FK), constraints de unicidade (UQ) e as ligações de integridade referencial entre elas.

---

## 🔗 Resumo dos Relacionamentos

* **Regioes (1,1) ── (1,N) Estados**: Cada estado pertence obrigatoriamente a uma macro-região; cada região agrupa 1 ou mais estados (`Estados.id_regiao -> Regioes.id_regiao`).
* **Pais (1,1) ── (1,N) Estados**: Cada estado pertence a um país nacional (`Estados.id_pais -> Pais.id_pais`).
* **Estados (1,1) ── (1,N) Municipios**: Cada município pertence a um único estado (`Municipios.id_estado -> Estados.id_estado`).
* **Estados (1,1) ── (1,1) Indicadores_Sociais**: Cada estado possui exatamente um registro consolidado de indicadores sociais (`Indicadores_Sociais.id_estado -> Estados.id_estado`, UNIQUE).
* **Estados (1,1) ── (1,N) Historico_Desemprego**: Cada estado registra uma série temporal anual de desemprego e rendimento (`Historico_Desemprego.id_estado -> Estados.id_estado`).
* **Municipios (1,1) ── (0,N) Auditoria**: Cada município pode ter zero ou múltiplos registros de alterações manuais auditadas (`Auditoria.codigo_ibge -> Municipios.codigo_ibge`).
* **Analistas (1,1) ── (0,N) Auditoria**: Cada analista pode registrar zero ou múltiplas correções auditadas no sistema (`Auditoria.id_analista -> Analistas.id_analista`).
