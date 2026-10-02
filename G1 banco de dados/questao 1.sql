-- ============================================================
-- QUESTÃO 1 - Venda em uma transação com SAVEPOINT
-- ============================================================

BEGIN;

-- 1. Criar pedido para a cliente 3
INSERT INTO pedido (cliente_id, status)
VALUES (3, 'PENDENTE');


-- 2. Inserir 2 unidades do produto 2
-- O preço é obtido diretamente da tabela produto
INSERT INTO item_pedido (
    pedido_id,
    produto_id,
    quantidade,
    preco_unitario
)
SELECT
    currval(pg_get_serial_sequence('pedido', 'pedido_id')),
    produto_id,
    2,
    preco
FROM produto
WHERE produto_id = 2;


-- 3. Baixar 2 unidades do estoque do produto 2
-- Escrita atômica: não fazemos SELECT do estoque antes
UPDATE produto
SET estoque = estoque - 2
WHERE produto_id = 2
  AND estoque >= 2;


-- 4. Inserir 1 unidade do produto 5
INSERT INTO item_pedido (
    pedido_id,
    produto_id,
    quantidade,
    preco_unitario
)
SELECT
    currval(pg_get_serial_sequence('pedido', 'pedido_id')),
    produto_id,
    1,
    preco
FROM produto
WHERE produto_id = 5;


-- 5. Baixar 1 unidade do estoque do produto 5
UPDATE produto
SET estoque = estoque - 1
WHERE produto_id = 5
  AND estoque >= 1;


-- ============================================================
-- TENTATIVA DO BRINDE
-- ============================================================

SAVEPOINT antes_brinde;


-- 6. Tentar inserir o produto 7 como brinde
INSERT INTO item_pedido (
    pedido_id,
    produto_id,
    quantidade,
    preco_unitario
)
SELECT
    currval(pg_get_serial_sequence('pedido', 'pedido_id')),
    produto_id,
    1,
    preco
FROM produto
WHERE produto_id = 7;


-- 7. Tentar baixar o estoque do produto 7
UPDATE produto
SET estoque = estoque - 1
WHERE produto_id = 7
  AND estoque >= 1;


-- O produto 7 possui estoque 0.
-- Portanto, o UPDATE acima atualiza 0 linhas.
-- Como o brinde não pode ser realizado, desfazemos apenas
-- as operações feitas depois do SAVEPOINT.

ROLLBACK TO SAVEPOINT antes_brinde;


-- 8. Confirmar a venda principal
COMMIT;


-- ============================================================
-- CONFERÊNCIA
-- ============================================================

-- Consultar os itens do pedido criado
SELECT
    ip.pedido_id,
    ip.produto_id,
    p.nome,
    ip.quantidade,
    ip.preco_unitario
FROM item_pedido ip
JOIN produto p
    ON p.produto_id = ip.produto_id
WHERE ip.pedido_id =
    currval(pg_get_serial_sequence('pedido', 'pedido_id'))
ORDER BY ip.produto_id;


-- Consultar estoque dos produtos envolvidos
SELECT
    produto_id,
    nome,
    estoque
FROM produto
WHERE produto_id IN (2, 5, 7)