# IBGE_DESEMPREGO

Banco de dados de estados e municipios do Brasil, com dados de renda media e taxa de desemprego.
Base futura para um mapa de desemprego (o join com o mapa do pais e pelo codigo_ibge).

## Ordem para rodar

1. **Criar usuários, roles e privilégios de sistema (conectar como SYSTEM no PDB, ex: XEPDB1):**
   - oracle/CriarUsuarios_SYSTEM.sql

2. **Conectar como IBGE_DESEMPREGO e rodar, nesta ordem:**
   - oracle/CreateBD_Oracle.sql
   - oracle/inserts/InsertPais_Oracle.sql
   - oracle/inserts/InsertEstados_Oracle.sql
   - oracle/inserts/InsertMunicipios_Oracle.sql
   - oracle/Views_IBGE.sql
   - oracle/Procedimentos_IBGE.sql
   - oracle/Privilegios_IBGE.sql
