-- Concessão de permissões de leitura (Views) para a role de consulta (usada pelo mapa_app e site_admin)
GRANT SELECT ON vw_desemprego_municipio TO role_consulta;
GRANT SELECT ON vw_desemprego_estado TO role_consulta;
GRANT SELECT ON vw_ranking_desemprego TO role_consulta;

GRANT SELECT ON vw_desemprego_municipio TO site_admin;
GRANT SELECT ON vw_desemprego_estado TO site_admin;
GRANT SELECT ON vw_ranking_desemprego TO site_admin;

-- Permissões de execução de Procedures para o perfil operacional/administrador (site_admin)
GRANT EXECUTE ON corrigir_municipio TO site_admin;
GRANT EXECUTE ON pr_cadastrar_municipio TO site_admin;
GRANT EXECUTE ON pr_atualizar_desemprego TO site_admin;
GRANT EXECUTE ON pr_registrar_historico TO site_admin;

-- Permissões de execução de Functions para o perfil site_admin e role_consulta
GRANT EXECUTE ON fn_media_desemprego TO site_admin;
GRANT EXECUTE ON fn_classificar_idhm TO site_admin;
GRANT EXECUTE ON fn_media_desemprego TO role_consulta;
GRANT EXECUTE ON fn_classificar_idhm TO role_consulta;
