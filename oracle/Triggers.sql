-- trigger para imprimir alteração da taxa de desemprego
-- sempre que a taxa de desemprego de um município for alterada, o banco deverá mostrar os valores anteriores, os novos e a diferença entre eles.

CREATE OR REPLACE TRIGGER imprimir_alteracao_desemprego
BEFORE UPDATE OF taxa_desemprego ON Municipios
FOR EACH ROW
DECLARE
    diferenca NUMBER;
BEGIN

    diferenca := :NEW.taxa_desemprego - :OLD.taxa_desemprego;

    DBMS_OUTPUT.PUT_LINE('ALTERACAO NA TAXA DE DESEMPREGO');
    DBMS_OUTPUT.PUT_LINE('Municipio: ' || :NEW.nome);

    DBMS_OUTPUT.PUT_LINE(
        'Taxa antiga: ' || :OLD.taxa_desemprego || '%'
    );

    DBMS_OUTPUT.PUT_LINE(
        'Taxa nova: ' || :NEW.taxa_desemprego || '%'
    );

    DBMS_OUTPUT.PUT_LINE(
        'Diferenca: ' || diferenca || ' pontos percentuais'
    );

END;
/


-- trigger voltada para impedir a taxa de desemprego inválida
-- não permitir que um município seja cadastrado ou atualizado com uma taxa de desemprego inferior a 0% ou superior a 100%.

CREATE OR REPLACE TRIGGER regra_desemprego
BEFORE INSERT OR UPDATE OF taxa_desemprego ON Municipios
FOR EACH ROW
WHEN (NEW.taxa_desemprego < 0 OR NEW.taxa_desemprego > 100)
BEGIN

    RAISE_APPLICATION_ERROR(
        -20001,
        'OPERACAO CANCELADA - TAXA DE DESEMPREGO INVALIDA'
    );

END;
/