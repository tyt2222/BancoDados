# IBGE_DESEMPREGO

Banco de dados de estados e municipios do Brasil, com dados de renda media e taxa de desemprego.
Base futura para um mapa de desemprego (o join com o mapa do pais e pelo codigo_ibge).

## Ordem para rodar

1. oracle/CriarUsuarios_SYSTEM.sql` — SYSTEM
2. oracle/CreateBD_Oracle.sql — IBGE_DESEMPREGO
3. oracle/inserts/InsertPais_Oracle.sql — IBGE_DESEMPREGO
4. oracle/inserts/InsertEstados_Oracle.sql — IBGE_DESEMPREGO
5. oracle/inserts/InsertMunicipios_Oracle.sql — IBGE_DESEMPREGO
6. oracle/Views_IBGE.sql — IBGE_DESEMPREGO
7. oracle/Procedimentos_IBGE.sql — IBGE_DESEMPREGO
8. oracle/Privilegios_IBGE.sql — IBGE_DESEMPREGO
9. oracle/Selects_Oracle.sql — IBGE_DESEMPREGO

## Reset do banco (caso queira recomeçar do zero)

- oracle/Reset_Oracle.sql — Executar como SYSTEM (MUDAR PDB)
