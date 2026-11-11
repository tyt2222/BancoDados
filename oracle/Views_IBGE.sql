CREATE OR REPLACE VIEW vw_desemprego_municipio AS
SELECT m.codigo_ibge, m.nome, m.uf, e.regiao, m.populacao, m.renda_media, m.taxa_desemprego
FROM Municipios m
JOIN Estados e ON e.id_estado = m.id_estado;

CREATE OR REPLACE VIEW vw_desemprego_estado AS
SELECT  e.sigla, 
        e.nome, 
        e.regiao, 
        e.populacao,
ROUND(AVG(m.taxa_desemprego), 2) AS taxa_media,
ROUND(AVG(m.renda_media), 2) AS renda_media,
COUNT(m.id_municipio) AS qtd_municipios
FROM Estados e
JOIN Municipios m ON m.id_estado = e.id_estado
GROUP BY e.sigla, e.nome, e.regiao, e.populacao;

CREATE OR REPLACE VIEW vw_ranking_desemprego AS
SELECT nome, uf, regiao, taxa_desemprego, renda_media
FROM vw_desemprego_municipio
WITH READ ONLY;
