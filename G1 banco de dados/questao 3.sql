-- ============================================================
-- QUESTÃO 3A - ATUALIZAÇÃO PERDIDA
-- ============================================================

-- P1 [Preparação]
UPDATE produto
SET estoque = 10
WHERE produto_id = 1;

SELECT estoque
FROM produto
WHERE produto_id = 1;
-- P2 [Sessão A]
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT estoque
FROM produto
WHERE produto_id = 1;

-- P3 [Sessão B]
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT estoque
FROM produto
WHERE produto_id = 1;

-- P4 [Sessão A]
UPDATE produto
SET estoque = 9
WHERE produto_id = 1;

COMMIT;

-- P5 [Sessão B]
UPDATE produto
SET estoque = 9
WHERE produto_id = 1;

COMMIT;
-- P6 [Conferência]
SELECT estoque
FROM produto
WHERE produto_id = 1;

-- ============================================================
-- QUESTÃO 3B - SELECT FOR UPDATE
-- ============================================================

-- P1 [Preparação]
UPDATE produto
SET estoque = 10
WHERE produto_id = 1;

SELECT estoque
FROM produto
WHERE produto_id = 1;

-- P2 [Sessão A]
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT estoque
FROM produto
WHERE produto_id = 1
FOR UPDATE;


-- P3 [Sessão B]
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT estoque
FROM produto
WHERE produto_id = 1
FOR UPDATE;

-- P4 [Sessão A]
UPDATE produto
SET estoque = 9
WHERE produto_id = 1;

COMMIT;

-- P5 [Sessão B]
UPDATE produto
SET estoque = 8
WHERE produto_id = 1;

COMMIT;

-- P6 [Conferência]
SELECT estoque
FROM produto
WHERE produto_id = 1;
