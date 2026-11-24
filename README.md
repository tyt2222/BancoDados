# IBGE_DESEMPREGO

Banco de dados relacional contendo dados socioeconômicos dos estados e municípios do Brasil, com taxa de desocupação (desemprego), rendimento médio habitual, indicadores sociais, série temporal histórica e auditoria de alterações.

Base ideal para consultas analíticas, cruzamentos estatísticos e integração com malhas cartográficas (joins via `codigo_ibge` e `sigla`).


## Ordem de Execução dos Scripts

### Oracle Database

1. `oracle/CriarUsuarios_SYSTEM.sql` — Executar como `SYSTEM` (cria usuários `IBGE_DESEMPREGO`, `mapa_app`, `site_admin` e role)
2. `oracle/CreateBD_Oracle.sql` — Executar como `IBGE_DESEMPREGO` (criação das tabelas e índices)
3. `oracle/inserts/InsertPais_Oracle.sql` — Carga do Brasil
4. `oracle/inserts/InsertRegioes_Oracle.sql` — Carga das 5 macro-regiões
5. `oracle/inserts/InsertAnalistas_Oracle.sql` — Carga da equipe de analistas
6. `oracle/inserts/InsertEstados_Oracle.sql` — Carga dos 27 estados (com vínculo para regiões)
7. `oracle/inserts/InsertMunicipios_Oracle.sql` — Carga dos 5.570 municípios
8. `oracle/inserts/InsertIndicadoresSociais_Oracle.sql` — Carga dos indicadores sociais por UF
9. `oracle/inserts/InsertHistoricoDesemprego_Oracle.sql` — Carga da série temporal 2021-2024
10. `oracle/Views_IBGE.sql` — Criação das views analíticas
11. `oracle/Procedimentos_IBGE.sql` — Criação de procedures e funções de auditoria
12. `oracle/Privilegios_IBGE.sql` — Concessão de grants para os perfis
13. `oracle/Selects_Oracle.sql` — Consultas de teste e relatórios

### MySQL

1. `mysql/CreateBDA.sql` — Criação do banco, tabelas e chaves estrangeiras
2. `mysql/inserts/InsertPais.sql` — Carga do país
3. `mysql/inserts/InsertRegioes.sql` — Carga das macro-regiões
4. `mysql/inserts/InsertAnalistas.sql` — Carga dos analistas
5. `mysql/inserts/InsertEstados.sql` — Carga dos estados
6. `mysql/inserts/InsertMunicipios.sql` — Carga dos municípios
7. `mysql/inserts/InsertIndicadoresSociais.sql` — Carga dos indicadores sociais
8. `mysql/inserts/InsertHistoricoDesemprego.sql` — Carga do histórico anual
9. `mysql/Selects.sql` — Consultas e relatórios

---

## Reset do Banco (Oracle)

Caso deseje recomeçar a estrutura do zero:
- `oracle/Reset_Oracle.sql` — Executar conectado como `SYSTEM` (ajuste o serviço/PDB se necessário).

---

## Painel Web de Demonstração

O projeto conta com um painel web em Node.js (`web/server.js` e `web/index.html`) para demonstração das tabelas, views e permissões de usuários (dono, `mapa_app` e `site_admin`).

Consulte as instruções detalhadas em [`web/LEIA-ME.md`](web/LEIA-ME.md).

---

## 📚 Fontes e Referências Oficiais dos Dados

Todos os dados contidos nos scripts e nos arquivos CSV da raiz do projeto foram obtidos a partir de bases públicas oficiais:

1. **Taxa de Desocupação e Rendimento Médio Habitual (2021 a 2024 e consolidado):**
   * **Órgão:** IBGE — Instituto Brasileiro de Geografia e Estatística.
   * **Pesquisa:** PNAD Contínua (Pesquisa Nacional por Amostra de Domicílios Contínua).
   * **Tabelas SIDRA:**
     * *Tabela 4093*: Taxa de desocupação das pessoas de 14 anos ou mais de idade, por UF.
     * *Tabela 5434*: Rendimento médio mensal real habitualmente recebido de todos os trabalhos.
   * **Links:** [IBGE SIDRA](https://sidra.ibge.gov.br/) | [Mercado de Trabalho IBGE](https://www.ibge.gov.br/estatisticas/sociais/trabalho/9173-pesquisa-nacional-por-amostra-de-domicilios-continua-trimestral.html)

2. **Áreas Territoriais das Macro-regiões e Divisão Regional:**
   * **Órgão:** IBGE — Coordenação de Estruturas Territoriais.
   * **Documento:** Resolução da Presidência do IBGE nº PR-5/2002 e Malha Territorial Censo 2022.
   * **Link:** [IBGE Áreas Territoriais](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/15761-areas-territoriais.html)

3. **Alfabetização, Analfabetismo e Escolaridade:**
   * **Órgão:** IBGE — Censo Demográfico 2022 (Alfabetização) e PNAD Contínua Educação.
   * **Link:** [Panorama do Censo 2022](https://censo2022.ibge.gov.br/panorama/)

4. **Índice de Desenvolvimento Humano Municipal (IDHM Estadual):**
   * **Órgão:** Atlas do Desenvolvimento Humano no Brasil.
   * **Parceria:** PNUD Brasil (Programa das Nações Unidas para o Desenvolvimento), IPEA (Instituto de Pesquisa Econômica Aplicada) e FJP (Fundação João Pinheiro).
   * **Link:** [Atlas Brasil](http://www.atlasbrasil.org.br/)

5. **Linha de Pobreza e Índice de Gini:**
   * **Órgão:** IBGE — Síntese de Indicadores Sociais (SIS).
   * **Metodologia:** Critério da Linha de Pobreza do Banco Mundial (US$ 6,85/dia em PPC) e Coeficiente de Gini do rendimento domiciliar per capita.
   * **Link:** [Síntese de Indicadores Sociais - IBGE](https://www.ibge.gov.br/estatisticas/sociais/populacao/9221-sintese-de-indicadores-sociais.html)
