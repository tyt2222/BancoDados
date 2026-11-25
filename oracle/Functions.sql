--Calcular taxa média de desemprego de um município em um estado 

CREATE OR REPLACE FUNCTION fn_media_desemprego (
    p_id_estado IN NUMBER
)
RETURN NUMBER
IS
    v_media NUMBER(5,2);
BEGIN
    SELECT AVG(taxa_desemprego)
    INTO v_media
    FROM Municipios
    WHERE id_estado = p_id_estado;

    IF v_media IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'Estado inexistente ou sem municípios cadastrados.'
        );
    END IF;

    RETURN v_media;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20012,
            'Erro ao calcular média: ' || SQLERRM
        );
END;
/


--Classificar o IDHM de um estado

CREATE OR REPLACE FUNCTION fn_classificar_idhm (
    p_id_estado IN NUMBER
)
RETURN VARCHAR2
IS
    v_idhm NUMBER(4,3);
BEGIN
    SELECT idhm
    INTO v_idhm
    FROM Indicadores_Sociais
    WHERE id_estado = p_id_estado;

    IF v_idhm < 0 OR v_idhm > 1 THEN
        RAISE_APPLICATION_ERROR(
            -20013,
            'Valor de IDHM inválido.'
        );

    ELSIF v_idhm < 0.500 THEN
        RETURN 'Muito baixo';

    ELSIF v_idhm < 0.600 THEN
        RETURN 'Baixo';

    ELSIF v_idhm < 0.700 THEN
        RETURN 'Médio';

    ELSIF v_idhm < 0.800 THEN
        RETURN 'Alto';

    ELSE
        RETURN 'Muito alto';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20014,
            'Não existem indicadores sociais para esse estado.'
        );

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20015,
            'Erro ao classificar IDHM: ' || SQLERRM
        );
END;
/
