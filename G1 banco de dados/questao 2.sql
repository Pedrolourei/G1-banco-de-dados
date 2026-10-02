-- ============================================================
-- QUESTÃO 2A - READ COMMITTED
-- ============================================================

-- P1 [Sessão A]
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT preco
FROM produto
WHERE produto_id = 5;


SELECT COUNT(*)
FROM produto
WHERE preco < 300;


-- P2 [Sessão B]
BEGIN;

UPDATE produto
SET preco = 599.00
WHERE produto_id = 5;

INSERT INTO produto (
    nome,
    categoria_id,
    preco,
    estoque,
    ativo
)
VALUES (
    'Produto Fantasma',
    1,
    45.00,
    10,
    TRUE
);

COMMIT;
-- P3 [Sessão A]

SELECT preco
FROM produto
WHERE produto_id = 5;


SELECT COUNT(*)
FROM produto
WHERE preco < 300;

COMMIT;

-- ============================================================
-- QUESTÃO 2B - REPEATABLE READ
-- ============================================================

-- P4 [Sessão B]
UPDATE produto
SET preco = 499.00
WHERE produto_id = 5;

DELETE FROM produto
WHERE nome = 'Produto Fantasma';

SELECT preco
FROM produto
WHERE produto_id = 5;

SELECT COUNT(*)
FROM produto
WHERE preco < 300;

-- P5 [Sessão A]
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT preco
FROM produto
WHERE produto_id = 5;

SELECT COUNT(*)
FROM produto
WHERE preco < 300;
-- P6 [Sessão B]
BEGIN;

UPDATE produto
SET preco = 599.00
WHERE produto_id = 5;

INSERT INTO produto (
    nome,
    categoria_id,
    preco,
    estoque,
    ativo
)
VALUES (
    'Produto Fantasma',
    1,
    45.00,
    10,
    TRUE
);

COMMIT;
-- P7 [Sessão A]

SELECT preco
FROM produto
WHERE produto_id = 5;
-- Resultado: 499.00

SELECT COUNT(*)
FROM produto
WHERE preco < 300;
-- Resultado: 5

COMMIT;

UPDATE produto
SET preco = 499.00
WHERE produto_id = 5;

DELETE FROM produto
WHERE nome = 'Produto Fantasma';