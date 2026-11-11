GRANT SELECT ON vw_desemprego_municipio TO role_consulta;
GRANT SELECT ON vw_desemprego_estado TO role_consulta;
GRANT SELECT ON vw_ranking_desemprego TO role_consulta;

GRANT SELECT ON vw_desemprego_municipio TO site_admin;
GRANT SELECT ON vw_desemprego_estado TO site_admin;
GRANT SELECT ON vw_ranking_desemprego TO site_admin;

GRANT EXECUTE ON corrigir_municipio TO site_admin;
GRANT EXECUTE ON fx_municipios_acima_media TO site_admin;
