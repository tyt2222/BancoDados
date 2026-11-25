-- Procedure de cadastrar município
-- Só pode cadastrar um município somente se o estado existir e os dados forem válidos. 

CREATE OR REPLACE PROCEDURE pr_cadastrar_municipio (
    p_id_municipio IN NUMBER,
    p_id_estado IN NUMBER,
    p_uf IN VARCHAR2,
    p_nome IN VARCHAR2,
    p_codigo_ibge IN NUMBER,
    p_populacao IN NUMBER,
    p_renda_media IN NUMBER,
    p_taxa_desemprego IN NUMBER
)
IS
BEGIN
    INSERT INTO Municipios (
        id_municipio,
        id_estado,
        uf,
        nome,
        codigo_ibge,
        populacao,
        renda_media,
        taxa_desemprego
    )
    VALUES (
        p_id_municipio,
        p_id_estado,
        UPPER(p_uf),
        p_nome,
        p_codigo_ibge,
        p_populacao,
        p_renda_media,
        p_taxa_desemprego
    );

    DBMS_OUTPUT.PUT_LINE('Município cadastrado com sucesso.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Erro: ID do município ou código IBGE já cadastrado.'
        );

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'Erro ao cadastrar município: ' || SQLERRM
        );
END;
/


-- Procedure de atualizar taxa de desemprego
-- Permitir a atualização da taxa de desemprego de um município existente, respeitando o intervalo de 0% a 100%

CREATE OR REPLACE PROCEDURE pr_atualizar_desemprego (
    p_codigo_ibge IN NUMBER,
    p_nova_taxa IN NUMBER
)
IS
BEGIN
    IF p_nova_taxa < 0 OR p_nova_taxa > 100 THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'A taxa de desemprego deve estar entre 0 e 100.'
        );
    END IF;

    UPDATE Municipios
    SET taxa_desemprego = p_nova_taxa
    WHERE codigo_ibge = p_codigo_ibge;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20004,
            'Município não encontrado.'
        );
    END IF;

    DBMS_OUTPUT.PUT_LINE('Taxa de desemprego atualizada.');

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20005,
            'Erro ao atualizar desemprego: ' || SQLERRM
        );
END;
/


-- Procedure de registrar histórico de desemprego
-- Registrar a taxa de desemprego e a renda média de um estado em determinado ano. Não será permitido registrar duas vezes o mesmo estado no mesmo ano.

CREATE OR REPLACE PROCEDURE pr_registrar_historico (
    p_id_historico IN NUMBER,
    p_id_estado IN NUMBER,
    p_ano IN NUMBER,
    p_taxa_desemprego IN NUMBER,
    p_renda_media IN NUMBER
)
IS
BEGIN
    IF p_ano < 1900 OR p_ano > 2100 THEN
        RAISE_APPLICATION_ERROR(
            -20006,
            'Ano informado inválido.'
        );
    END IF;

    IF p_taxa_desemprego < 0 OR p_taxa_desemprego > 100 THEN
        RAISE_APPLICATION_ERROR(
            -20007,
            'Taxa de desemprego inválida.'
        );
    END IF;

    IF p_renda_media < 0 THEN
        RAISE_APPLICATION_ERROR(
            -20008,
            'Renda média não pode ser negativa.'
        );
    END IF;

    INSERT INTO Historico_Desemprego (
        id_historico,
        id_estado,
        ano,
        taxa_desemprego,
        renda_media
    )
    VALUES (
        p_id_historico,
        p_id_estado,
        p_ano,
        p_taxa_desemprego,
        p_renda_media
    );

    DBMS_OUTPUT.PUT_LINE('Histórico registrado com sucesso.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(
            -20009,
            'Já existe um histórico para esse estado e ano, ou o ID informado está em uso.'
        );

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Erro ao registrar histórico: ' || SQLERRM
        );
END;
/