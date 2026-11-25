# IBGE_DESEMPREGO

Banco de dados de estados e municipios do Brasil, com dados de renda media e taxa de desemprego.
Base futura para um mapa de desemprego (o join com o mapa do pais e pelo codigo_ibge).

## Ordem para rodar

### Oracle

1. oracle/CriarUsuarios_SYSTEM.sql — SYSTEM
2. oracle/CreateBD_Oracle.sql — IBGE_DESEMPREGO
3. oracle/inserts/InsertPais_Oracle.sql — IBGE_DESEMPREGO
4. oracle/inserts/InsertRegioes_Oracle.sql — IBGE_DESEMPREGO
5. oracle/inserts/InsertEstados_Oracle.sql — IBGE_DESEMPREGO
6. oracle/inserts/InsertMunicipios_Oracle.sql — IBGE_DESEMPREGO
7. oracle/inserts/InsertAnalistas_Oracle.sql — IBGE_DESEMPREGO
8. oracle/inserts/InsertHistoricoDesemprego_Oracle.sql — IBGE_DESEMPREGO
9. oracle/inserts/InsertIndicadoresSociais_Oracle.sql — IBGE_DESEMPREGO
10. oracle/Views_IBGE.sql — IBGE_DESEMPREGO
11. oracle/Functions.sql — IBGE_DESEMPREGO
12. oracle/Procedimentos.sql — IBGE_DESEMPREGO
13. oracle/Triggers.sql — IBGE_DESEMPREGO
14. oracle/Privilegios_IBGE.sql — IBGE_DESEMPREGO
15. oracle/Selects_Oracle.sql — IBGE_DESEMPREGO

### MySQL

1. mysql/CreateBDA.sql
2. mysql/inserts/InsertPais.sql
3. mysql/inserts/InsertRegioes.sql
4. mysql/inserts/InsertEstados.sql
5. mysql/inserts/InsertMunicipios.sql
6. mysql/inserts/InsertAnalistas.sql
7. mysql/inserts/InsertHistoricoDesemprego.sql
8. mysql/inserts/InsertIndicadoresSociais.sql
9. mysql/Selects.sql

## Reset do banco

- oracle/Reset_Oracle.sql — Executar como SYSTEM (MUDAR PDB)

## Minimundo (Descrição Conceitual do Domínio)

O sistema **IBGE_DESEMPREGO** tem por finalidade centralizar, gerenciar e disponibilizar dados socioeconômicos e estatísticas oficiais sobre o mercado de trabalho brasileiro, permitindo análises comparativas e espaciais entre macro-regiões, unidades federativas e municípios.

### Estrutura Territorial Base
O domínio abrange o território nacional (**Pais**), subdividido nas cinco macro-regiões oficiais do IBGE (**Regioes**: Norte, Nordeste, Sudeste, Sul e Centro-Oeste). Cada região agrega múltiplos **Estados** (UFs), e cada estado é composto por múltiplos **Municipios**.
* Cada estado possui código de identificação (`id_estado`), vínculo com o país (`id_pais`) e com sua região geográfica (`id_regiao`), sigla única de 2 caracteres, nome oficial, população residente, renda média e taxa de desocupação (desemprego).
* Cada município é identificado unicamente pelo seu **código oficial do IBGE de 7 dígitos**, além de armazenar seu nome, UF de vínculo (`Municipios.id_estado -> Estados.id_estado`), população e os indicadores locais de rendimento médio e taxa de desemprego.

### Expansão Analítica e Séries Históricas
Para viabilizar estudos longitudinais e cruzamento de vulnerabilidades:
* Cada estado possui exatamente um registro consolidado de **Indicadores_Sociais** (relação 1:1), contemplando o Índice de Desenvolvimento Humano Municipal médio da UF (**IDHM**), a proporção de pessoas abaixo da linha de pobreza monetária (**pct_pobreza**) e a desigualdade na distribuição de renda (**indice_gini**).
* Para análise de séries temporais pós-pandemia, cada estado possui múltiplos registros no **Historico_Desemprego** (relação 1:N), onde são gravadas anualmente a taxa de desemprego e a renda média real, com a garantia de que não existam registros duplicados para a mesma UF no mesmo ano (`UNIQUE(id_estado, ano)`).

### Governança, Controle de Acesso e Auditoria
Para manter a integridade dos dados, as informações municipais podem ser corrigidas e atualizadas por uma equipe técnica de **Analistas** devidamente cadastrados no sistema (com nome, e-mail único corporativo, cargo e departamento).
* Sempre que uma taxa de desemprego, renda ou população for corrigida por meio de procedimentos armazenados ou rotinas administrativas, o evento gera automaticamente um registro na tabela associativa de **Auditoria** (relação N:M entre Analistas e Municípios).
* A auditoria registra o identificador da alteração, o código do município afetado, o campo modificado, o valor antigo, o valor novo, a identificação do analista responsável e a data/hora exata do registro (`SYSDATE`).
