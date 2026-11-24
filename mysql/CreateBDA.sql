CREATE DATABASE IF NOT EXISTS IBGE_DESEMPREGO;
USE IBGE_DESEMPREGO;

DROP TABLE IF EXISTS Correcoes;
DROP TABLE IF EXISTS Historico_Desemprego;
DROP TABLE IF EXISTS Indicadores_Sociais;
DROP TABLE IF EXISTS Municipios;
DROP TABLE IF EXISTS Estados;
DROP TABLE IF EXISTS Regioes;
DROP TABLE IF EXISTS Analistas;
DROP TABLE IF EXISTS Pais;

CREATE TABLE Pais (
    id_pais INT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    populacao INT NOT NULL,
    renda_media FLOAT NOT NULL,
    taxa_desemprego FLOAT NOT NULL
);

CREATE TABLE Regioes (
    id_regiao INT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL UNIQUE,
    sigla VARCHAR(2) NOT NULL UNIQUE,
    area_km2 DECIMAL(10,2) NOT NULL,
    qtd_estados INT NOT NULL
);

CREATE TABLE Analistas (
    id_analista INT PRIMARY KEY,
    nome VARCHAR(60) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE,
    cargo VARCHAR(40) NOT NULL,
    departamento VARCHAR(50) NOT NULL,
    ativo TINYINT(1) DEFAULT 1 NOT NULL
);

CREATE TABLE Estados (
    id_estado INT PRIMARY KEY,
    id_pais INT NOT NULL,
    id_regiao INT,
    nome VARCHAR(50) NOT NULL,
    sigla VARCHAR(2) NOT NULL UNIQUE,
    regiao VARCHAR(50) NOT NULL,
    populacao INT NOT NULL,
    renda_media FLOAT NOT NULL,
    taxa_desemprego FLOAT NOT NULL,

    FOREIGN KEY (id_pais) REFERENCES Pais(id_pais),
    FOREIGN KEY (id_regiao) REFERENCES Regioes(id_regiao)
);

CREATE TABLE Municipios (
    id_municipio INT PRIMARY KEY,
    id_estado INT NOT NULL,
    uf VARCHAR(2) NOT NULL,
    nome VARCHAR(80) NOT NULL,
    codigo_ibge INT NOT NULL UNIQUE,
    populacao INT NOT NULL,
    renda_media FLOAT NOT NULL,
    taxa_desemprego FLOAT NOT NULL,

    FOREIGN KEY (id_estado) REFERENCES Estados(id_estado)
);

-- auditoria das correcoes do admin
CREATE TABLE Correcoes (
    id_correcao INT PRIMARY KEY,
    codigo_ibge INT NOT NULL,
    campo VARCHAR(20) NOT NULL,
    valor_antigo FLOAT,
    valor_novo FLOAT,
    analista VARCHAR(30),
    id_analista INT,
    data_correcao DATE,

    FOREIGN KEY (codigo_ibge) REFERENCES Municipios(codigo_ibge),
    FOREIGN KEY (id_analista) REFERENCES Analistas(id_analista)
);

CREATE TABLE Indicadores_Sociais (
    id_indicador INT PRIMARY KEY,
    id_estado INT NOT NULL UNIQUE,
    idhm DECIMAL(4,3) NOT NULL,
    pct_pobreza DECIMAL(5,2) NOT NULL,
    indice_gini DECIMAL(4,3) NOT NULL,

    FOREIGN KEY (id_estado) REFERENCES Estados(id_estado)
);

CREATE TABLE Historico_Desemprego (
    id_historico INT PRIMARY KEY,
    id_estado INT NOT NULL,
    ano INT NOT NULL,
    taxa_desemprego DECIMAL(5,2) NOT NULL,
    renda_media DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (id_estado) REFERENCES Estados(id_estado),
    UNIQUE (id_estado, ano)
);

CREATE INDEX idx_municipio_uf ON Municipios(uf);
CREATE INDEX idx_municipio_taxa ON Municipios(taxa_desemprego);
CREATE INDEX idx_estado_regiao ON Estados(regiao);
CREATE INDEX idx_historico_ano ON Historico_Desemprego(ano);
CREATE INDEX idx_historico_estado ON Historico_Desemprego(id_estado);
