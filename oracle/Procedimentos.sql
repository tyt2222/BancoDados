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


-- Procedure de correção de dados com auditoria (utilizada pelo site_admin no painel web)
CREATE OR REPLACE PROCEDURE corrigir_municipio (
    p_ibge IN Municipios.codigo_ibge%TYPE,
    p_campo IN VARCHAR2,
    p_novo IN NUMBER,
    p_analista IN VARCHAR2
) IS
    v_id NUMBER;
    v_antigo NUMBER;
    v_id_analista NUMBER;
BEGIN
    SELECT NVL(MAX(id_auditoria), 0) + 1 INTO v_id FROM Auditoria;

    BEGIN
        SELECT id_analista INTO v_id_analista
        FROM Analistas
        WHERE email = p_analista OR nome = p_analista
        FETCH FIRST 1 ROWS ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_id_analista := NULL;
    END;

    IF p_campo = 'renda_media' THEN
        SELECT renda_media INTO v_antigo
        FROM Municipios WHERE codigo_ibge = p_ibge;

        UPDATE Municipios SET renda_media = p_novo
        WHERE codigo_ibge = p_ibge;

    ELSIF p_campo = 'taxa_desemprego' THEN
        SELECT taxa_desemprego INTO v_antigo
        FROM Municipios WHERE codigo_ibge = p_ibge;

        UPDATE Municipios SET taxa_desemprego = p_novo
        WHERE codigo_ibge = p_ibge;

    ELSE
        RAISE_APPLICATION_ERROR(-20020, 'Campo inválido para correção: ' || p_campo);
    END IF;

    INSERT INTO Auditoria (id_auditoria, codigo_ibge, campo, valor_antigo, valor_novo, analista, id_analista, data_correcao)
    VALUES (v_id, p_ibge, p_campo, v_antigo, p_novo, p_analista, v_id_analista, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Auditoria gravada em ' || SQL%ROWCOUNT || ' município.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20021, 'Município ' || p_ibge || ' não encontrado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20022, 'Erro ao corrigir município: ' || SQLERRM);
END;
/
