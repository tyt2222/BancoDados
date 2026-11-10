CREATE DATABASE IBGE_DESEMPREGO;
USE IBGE_DESEMPREGO;

DROP TABLE IF EXISTS Pais;
DROP TABLE IF EXISTS Estados;
DROP TABLE IF EXISTS Municipios;
DROP TABLE IF EXISTS Correcoes;

CREATE TABLE Pais (
    id_pais INT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    populacao INT NOT NULL,
    renda_media FLOAT NOT NULL,
    taxa_desemprego FLOAT NOT NULL
);

CREATE TABLE Estados (
    id_estado INT PRIMARY KEY,
    id_pais INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    sigla VARCHAR(2) NOT NULL,
    regiao VARCHAR(50) NOT NULL,
    populacao INT NOT NULL,
    renda_media FLOAT NOT NULL,
    taxa_desemprego FLOAT NOT NULL,

    FOREIGN KEY (id_pais) REFERENCES Pais(id_pais),
    UNIQUE (sigla)
);

CREATE TABLE Municipios (
    id_municipio INT PRIMARY KEY,
    id_estado INT NOT NULL,
    uf VARCHAR(2) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    codigo_ibge INT NOT NULL,
    populacao INT NOT NULL,
    renda_media FLOAT NOT NULL,
    taxa_desemprego FLOAT NOT NULL,

    FOREIGN KEY (id_estado) REFERENCES Estados(id_estado),
    UNIQUE (codigo_ibge)
);

-- auditoria das correcoes do admin
CREATE TABLE Correcoes (
    id_correcao INT PRIMARY KEY,
    codigo_ibge INT NOT NULL,
    campo VARCHAR(20) NOT NULL,
    valor_antigo FLOAT,
    valor_novo FLOAT,
    analista VARCHAR(30),
    data_correcao DATE,

    FOREIGN KEY (codigo_ibge) REFERENCES Municipios(codigo_ibge)
);
