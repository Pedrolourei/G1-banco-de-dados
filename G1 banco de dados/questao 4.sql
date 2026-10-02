-- ============================================================
-- QUESTÃO 4A - TRIGGER DE AUDITORIA
-- ============================================================

CREATE OR REPLACE FUNCTION fn_auditar_saldo()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF OLD.saldo IS DISTINCT FROM NEW.saldo THEN

        INSERT INTO auditoria_conta (
            conta_id,
            saldo_anterior,
            saldo_novo
        )
        VALUES (
            OLD.conta_id,
            OLD.saldo,
            NEW.saldo
        );

    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auditar_saldo
AFTER UPDATE ON conta
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_saldo();

SELECT conta_id, saldo
FROM conta
ORDER BY conta_id;

-- ============================================================
-- TESTE 1 - Transferência confirmada
-- ============================================================

BEGIN;

UPDATE conta
SET saldo = saldo - 100
WHERE conta_id = 1;

UPDATE conta
SET saldo = saldo + 100
WHERE conta_id = 2;

COMMIT;
SELECT conta_id, saldo
FROM conta
ORDER BY conta_id;

-- ============================================================
-- TESTE 2 - Transferência desfeita
-- ============================================================

BEGIN;

UPDATE conta
SET saldo = saldo - 50
WHERE conta_id = 1;

UPDATE conta
SET saldo = saldo + 50
WHERE conta_id = 3;

ROLLBACK;
SELECT conta_id, saldo
FROM conta
ORDER BY conta_id;

-- ============================================================
-- TESTE 3 - UPDATE sem alteração real
-- ============================================================

UPDATE conta
SET saldo = saldo
WHERE conta_id = 1;
OLD.saldo = NEW.saldo
IF OLD.saldo IS DISTINCT FROM NEW.saldo THEN

SELECT
    auditoria_id,
    conta_id,
    saldo_anterior,
    saldo_novo,
    usuario_bd,
    data_operacao
FROM auditoria_conta
ORDER BY auditoria_id;