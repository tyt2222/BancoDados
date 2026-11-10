-- banco IBGE_DESEMPREGO 
-- se o schema ainda nao existe, roda uma vez como SYS ou SYSTEM:
-- CREATE USER IBGE_DESEMPREGO IDENTIFIED BY sua_senha QUOTA UNLIMITED ON USERS;
-- GRANT CREATE SESSION, CREATE TABLE TO IBGE_DESEMPREGO;

DROP TABLE IF EXISTS Correcoes;
DROP TABLE IF EXISTS Municipios;
DROP TABLE IF EXISTS Estados;
DROP TABLE IF EXISTS Pais;

CREATE TABLE Pais (
    id_pais NUMBER(4) PRIMARY KEY,
    nome VARCHAR2(50) NOT NULL,
    populacao NUMBER(12) NOT NULL,
    renda_media NUMBER(12,2) NOT NULL,
    taxa_desemprego NUMBER(5,2) NOT NULL
);

CREATE TABLE Estados (
    id_estado NUMBER(2) PRIMARY KEY,
    id_pais NUMBER(4) NOT NULL,
    nome VARCHAR2(50) NOT NULL,
    sigla VARCHAR2(2) NOT NULL,
    regiao VARCHAR2(20) NOT NULL,
    populacao NUMBER(12) NOT NULL,
    renda_media NUMBER(12,2) NOT NULL,
    taxa_desemprego NUMBER(5,2) NOT NULL,

    FOREIGN KEY (id_pais) REFERENCES Pais(id_pais),
    UNIQUE (sigla),
    CHECK (regiao IN ('Norte','Nordeste','Centro-Oeste','Sudeste','Sul')),
    CHECK (taxa_desemprego BETWEEN 0 AND 100)
);

CREATE TABLE Municipios (
    id_municipio NUMBER(6) PRIMARY KEY,
    id_estado NUMBER(2) NOT NULL,
    uf VARCHAR2(2) NOT NULL,
    nome VARCHAR2(80) NOT NULL,
    codigo_ibge NUMBER(7) NOT NULL,
    populacao NUMBER(12) NOT NULL,
    renda_media NUMBER(12,2) NOT NULL,
    taxa_desemprego NUMBER(5,2) NOT NULL,

    FOREIGN KEY (id_estado) REFERENCES Estados(id_estado),
    UNIQUE (codigo_ibge),
    CHECK (renda_media >= 0),
    CHECK (taxa_desemprego BETWEEN 0 AND 100)
);

-- auditoria das correcoes do admin
CREATE TABLE Correcoes (
    id_correcao NUMBER(8) PRIMARY KEY,
    codigo_ibge NUMBER(7) NOT NULL,
    campo VARCHAR2(20) NOT NULL,
    valor_antigo NUMBER(12,2),
    valor_novo NUMBER(12,2),
    analista VARCHAR2(30),
    data_correcao DATE,

    FOREIGN KEY (codigo_ibge) REFERENCES Municipios(codigo_ibge),
    CHECK (campo IN ('renda_media', 'taxa_desemprego', 'populacao'))
);

-- indices que ajudam na hora de montar o mapa
CREATE INDEX idx_municipio_uf ON Municipios(uf);
CREATE INDEX idx_municipio_taxa ON Municipios(taxa_desemprego);
CREATE INDEX idx_estado_regiao ON Estados(regiao);
