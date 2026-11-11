SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE corrigir_municipio (
    p_ibge Municipios.codigo_ibge%TYPE,
    p_campo VARCHAR2,
    p_novo NUMBER,
    p_analista VARCHAR2
) IS
    v_id NUMBER;
    v_antigo NUMBER;
BEGIN

    SELECT NVL(MAX(id_correcao), 0) + 1 INTO v_id FROM Correcoes;

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
        DBMS_OUTPUT.PUT_LINE('Campo invalido: ' || p_campo);
        RETURN;
    END IF;

    INSERT INTO Correcoes (id_correcao, codigo_ibge, campo, valor_antigo, valor_novo, analista, data_correcao)
    VALUES (v_id, p_ibge, p_campo, v_antigo, p_novo, p_analista, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Correcao gravada em ' || SQL%ROWCOUNT || ' municipio.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Municipio ' || p_ibge || ' nao encontrado.');
END;
/

CREATE OR REPLACE FUNCTION fx_municipios_acima_media (
    p_sigla Estados.sigla%TYPE
) RETURN NUMBER IS
    qtd NUMBER;
BEGIN
    SELECT COUNT(*) INTO qtd
    FROM Municipios
    WHERE uf = p_sigla
    AND taxa_desemprego > (SELECT AVG(taxa_desemprego) FROM Municipios);
    RETURN qtd;
END;
/
