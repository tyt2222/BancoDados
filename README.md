# IBGE_DESEMPREGO

Banco de dados de estados e municipios do Brasil, com dados de renda media e taxa de desemprego.
Base futura para um mapa de desemprego (o join com o mapa do pais e pelo codigo_ibge).

## Ordem para rodar (Oracle 23ai, via SQL Developer)

1. **Criar o schema** (uma vez, como SYS ou SYSTEM)
   - `oracle/CreateBD_Oracle.sql` (as 4 primeiras linhas comentadas criam o usuario)

2. **Conectar como IBGE_DESEMPREGO e rodar, nesta ordem:**
   - `oracle/CreateBD_Oracle.sql` (tabelas e indices)
   - `oracle/inserts/InsertPais_Oracle.sql`
   - `oracle/inserts/InsertEstados_Oracle.sql`
   - `oracle/inserts/InsertMunicipios_Oracle.sql` (5.570 municipios, demora um pouco)
   - `oracle/Views_IBGE.sql` (views usadas pelo mapa e pelo site)
   - `oracle/Privilegios_IBGE.sql` (usuarios mapa_app e site_admin)
   - `oracle/Procedimentos_IBGE.sql` (procedure corrigir_municipio + function)

3. **Consultas** (quando precisar)
   - `oracle/Selects_Oracle.sql`

## A versao MySQL

A pasta `mysql/` tem a mesma modelagem no MySQL (CreateBDA.sql + inserts/ + Selects.sql),
mantida so como referencia. O projeto roda no Oracle.

## Arquivos de dados

- `estados_ibge.csv` e `municipios_ibge.csv` sao as fontes originais (UTF-8)
- `aulas/` tem o material do professor (views, privilegios, transacoes, PL/SQL)
