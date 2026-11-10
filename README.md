# IBGE_DESEMPREGO

Banco de dados de estados e municipios do Brasil, com dados de renda media e taxa de desemprego.
Base futura para um mapa de desemprego (o join com o mapa do pais e pelo codigo_ibge).

## Ordem para rodar

1. **Criar o schema** (SYSTEM)
   - oracle/CreateBD_Oracle.sql (Script de criar o usuario esta nas 4 primeiras linhas)

2. **Conectar como IBGE_DESEMPREGO e rodar, nesta ordem:**
   - oracle/CreateBD_Oracle.sql (tabelas e indices)
   - oracle/inserts/InsertPais_Oracle.sql
   - oracle/inserts/InsertEstados_Oracle.sql
   - oracle/inserts/InsertMunicipios_Oracle.sql`
   - oracle/Views_IBGE.sql
   - oracle/Privilegios_IBGE.sql
   - oracle/Procedimentos_IBGE.sql

