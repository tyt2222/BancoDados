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
