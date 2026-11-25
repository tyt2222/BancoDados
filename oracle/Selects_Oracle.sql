SELECT * FROM Pais;

SELECT * FROM Estados;

SELECT * FROM Municipios
ORDER BY renda_media ASC;

SELECT m.nome, m.uf, e.regiao, m.taxa_desemprego, m.renda_media
FROM Municipios m
JOIN Estados e ON e.id_estado = m.id_estado
ORDER BY m.taxa_desemprego DESC
FETCH FIRST 10 ROWS ONLY;

SELECT m.nome, m.uf, e.regiao, m.taxa_desemprego, m.renda_media
FROM Municipios m
JOIN Estados e ON e.id_estado = m.id_estado
ORDER BY m.taxa_desemprego ASC
FETCH FIRST 10 ROWS ONLY;

SELECT e.sigla, e.nome, e.regiao,
       ROUND(AVG(m.taxa_desemprego), 2) AS taxa_media,
       COUNT(m.id_municipio) AS qtd_municipios
FROM Estados e
JOIN Municipios m ON m.id_estado = e.id_estado
GROUP BY e.sigla, e.nome, e.regiao
ORDER BY taxa_media DESC;

SELECT e.regiao,
       ROUND(AVG(m.taxa_desemprego), 2) AS taxa_media,
       ROUND(AVG(m.renda_media), 2) AS renda_media
FROM Estados e
JOIN Municipios m ON m.id_estado = e.id_estado
GROUP BY e.regiao
ORDER BY taxa_media DESC;

SELECT e.sigla, COUNT(m.id_municipio) AS qtd
FROM Estados e
LEFT JOIN Municipios m ON m.id_estado = e.id_estado
GROUP BY e.sigla
ORDER BY qtd DESC;


-- 1. Regiões com área territorial e quantidade de estados cadastrados
SELECT r.nome, r.sigla, r.area_km2, r.qtd_estados,
       SUM(e.populacao) AS populacao_total,
       ROUND(AVG(e.taxa_desemprego), 2) AS taxa_desemprego_media
FROM Regioes r
JOIN Estados e ON e.id_regiao = r.id_regiao
GROUP BY r.nome, r.sigla, r.area_km2, r.qtd_estados
ORDER BY populacao_total DESC;

-- 2. Cruzamento de Indicadores Sociais com Desemprego e Renda
SELECT e.sigla, e.nome, e.taxa_desemprego, e.renda_media,
       i.idhm, i.pct_pobreza, i.indice_gini
FROM Estados e
JOIN Indicadores_Sociais i ON i.id_estado = e.id_estado
ORDER BY i.idhm DESC;

-- 3. Evolução temporal do desemprego por Estado (2021 a 2024)
SELECT e.sigla, e.nome, h.ano, h.taxa_desemprego, h.renda_media
FROM Historico_Desemprego h
JOIN Estados e ON e.id_estado = h.id_estado
ORDER BY e.sigla, h.ano ASC;

-- 4. Comparativo de redução do desemprego entre 2021 e 2024
SELECT e.sigla, e.nome,
       h2021.taxa_desemprego AS taxa_2021,
       h2024.taxa_desemprego AS taxa_2024,
       ROUND(h2021.taxa_desemprego - h2024.taxa_desemprego, 2) AS reducao_pontos_pct
FROM Estados e
JOIN Historico_Desemprego h2021 ON h2021.id_estado = e.id_estado AND h2021.ano = 2021
JOIN Historico_Desemprego h2024 ON h2024.id_estado = e.id_estado AND h2024.ano = 2024
ORDER BY reducao_pontos_pct DESC;

-- 5. Analistas ativos e auditorias realizadas
SELECT a.nome, a.cargo, a.departamento, COUNT(c.id_auditoria) AS total_auditorias
FROM Analistas a
LEFT JOIN Auditoria c ON c.id_analista = a.id_analista
WHERE a.ativo = 1
GROUP BY a.nome, a.cargo, a.departamento
ORDER BY total_auditorias DESC;

