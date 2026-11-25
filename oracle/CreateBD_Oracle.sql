DROP TABLE IF EXISTS Auditoria;
DROP TABLE IF EXISTS Correcoes;
DROP TABLE IF EXISTS Historico_Desemprego;
DROP TABLE IF EXISTS Indicadores_Sociais;
DROP TABLE IF EXISTS Municipios;
DROP TABLE IF EXISTS Estados;
DROP TABLE IF EXISTS Regioes;
DROP TABLE IF EXISTS Analistas;
DROP TABLE IF EXISTS Pais;

CREATE TABLE Pais (
    id_pais NUMBER(4) PRIMARY KEY,
    nome VARCHAR2(50) NOT NULL,
    populacao NUMBER(12) NOT NULL,
    renda_media NUMBER(12,2) NOT NULL,
    taxa_desemprego NUMBER(5,2) NOT NULL
);

CREATE TABLE Regioes (
    id_regiao NUMBER(1) PRIMARY KEY,
    id_pais NUMBER(4) NOT NULL,
    nome VARCHAR2(20) NOT NULL,
    sigla VARCHAR2(2) NOT NULL,
    area_km2 NUMBER(10,2) NOT NULL,
    qtd_estados NUMBER(2) NOT NULL,

    FOREIGN KEY (id_pais) REFERENCES Pais(id_pais),
    UNIQUE (sigla),
    UNIQUE (nome)
);

-- registra os usuarios do sistema
CREATE TABLE Analistas (
    id_analista NUMBER(4) PRIMARY KEY,
    nome VARCHAR2(60) NOT NULL,
    email VARCHAR2(80) NOT NULL,
    cargo VARCHAR2(40) NOT NULL,
    departamento VARCHAR2(50) NOT NULL,
    ativo NUMBER(1) DEFAULT 1 NOT NULL,

    UNIQUE (email)
);

CREATE TABLE Estados (
    id_estado NUMBER(2) PRIMARY KEY,
    id_regiao NUMBER(1) NOT NULL,
    nome VARCHAR2(50) NOT NULL,
    sigla VARCHAR2(2) NOT NULL,
    regiao VARCHAR2(20) NOT NULL,
    populacao NUMBER(12) NOT NULL,
    renda_media NUMBER(12,2) NOT NULL,
    taxa_desemprego NUMBER(5,2) NOT NULL,

    FOREIGN KEY (id_regiao) REFERENCES Regioes(id_regiao),
    UNIQUE (sigla)
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
    UNIQUE (codigo_ibge)
);

-- essa tabela funciona como um log para registrar alteracoes nos dados
CREATE TABLE Auditoria (
    id_auditoria NUMBER(8) PRIMARY KEY,
    codigo_ibge NUMBER(7) NOT NULL,
    campo VARCHAR2(20) NOT NULL,
    valor_antigo NUMBER(12,2),
    valor_novo NUMBER(12,2),
    analista VARCHAR2(30),
    id_analista NUMBER(4),
    data_correcao DATE,

    FOREIGN KEY (codigo_ibge) REFERENCES Municipios(codigo_ibge),
    FOREIGN KEY (id_analista) REFERENCES Analistas(id_analista)
);

CREATE TABLE Indicadores_Sociais (
    id_indicador NUMBER(4) PRIMARY KEY,
    id_estado NUMBER(2) NOT NULL,
    idhm NUMBER(4,3) NOT NULL,
    pct_pobreza NUMBER(5,2) NOT NULL,
    indice_gini NUMBER(4,3) NOT NULL,

    FOREIGN KEY (id_estado) REFERENCES Estados(id_estado),
    UNIQUE (id_estado)
);

CREATE TABLE Historico_Desemprego (
    id_historico NUMBER(6) PRIMARY KEY,
    id_estado NUMBER(2) NOT NULL,
    ano NUMBER(4) NOT NULL,
    taxa_desemprego NUMBER(5,2) NOT NULL,
    renda_media NUMBER(12,2) NOT NULL,

    FOREIGN KEY (id_estado) REFERENCES Estados(id_estado),
    UNIQUE (id_estado, ano)
);

-- indexes ajudam a acelerar as pesquisas atraves da criacao de indices de buscas
CREATE INDEX idx_municipio_uf ON Municipios(uf);
CREATE INDEX idx_municipio_taxa ON Municipios(taxa_desemprego);
CREATE INDEX idx_estado_regiao ON Estados(regiao);
CREATE INDEX idx_historico_ano ON Historico_Desemprego(ano);
CREATE INDEX idx_historico_estado ON Historico_Desemprego(id_estado);
