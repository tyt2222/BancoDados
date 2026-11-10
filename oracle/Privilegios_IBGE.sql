-- usuarios e privilegios do ibge_desemprego
-- rodar depois do CreateBD_Oracle.sql e do Views_IBGE.sql

-- usuario do app do mapa, ele so consulta
CREATE USER mapa_app IDENTIFIED BY mapa123
    QUOTA 10M ON USERS;

GRANT CREATE SESSION TO mapa_app;

CREATE ROLE role_consulta;

GRANT SELECT ON vw_desemprego_municipio TO role_consulta;
GRANT SELECT ON vw_desemprego_estado TO role_consulta;
GRANT SELECT ON vw_ranking_desemprego TO role_consulta;

GRANT role_consulta TO mapa_app;

-- admin do site, a edicao de tabelas passa pela procedure corrigir_municipio

CREATE USER site_admin IDENTIFIED BY admin123
    QUOTA 10M ON USERS;

GRANT CREATE SESSION TO site_admin;

GRANT SELECT ON vw_desemprego_municipio TO site_admin;
GRANT SELECT ON vw_desemprego_estado TO site_admin;
