-- ============================================================
-- TESTE DA QUESTÃO 6
-- ============================================================

BEGIN;

-- P1 - Estoque antes da venda
SELECT produto_id, nome, estoque
FROM produto
WHERE produto_id = 4;

-- P2 - Criar pedido
INSERT INTO pedido (cliente_id, status)
VALUES (3, 'PENDENTE');

-- P3 - Inserir 2 unidades
INSERT INTO item_pedido (
    pedido_id,
    produto_id,
    quantidade
)
VALUES (
    currval(pg_get_serial_sequence('pedido', 'pedido_id')),
    4,
    2
);
-- P4 - Conferir estoque
SELECT produto_id, nome, estoque
FROM produto
WHERE produto_id = 4;

-- P5 - Conferir movimentações
SELECT
    movimentacao_id,
    produto_id,
    tipo,
    quantidade
FROM movimentacao_estoque
WHERE produto_id = 4
ORDER BY movimentacao_id;

-- P6 - Remover o item
DELETE FROM item_pedido
WHERE pedido_id =
      currval(pg_get_serial_sequence('pedido', 'pedido_id'))
  AND produto_id = 4;
ELSIF TG_OP = 'DELETE'

-- P7 - Estoque após DELETE
SELECT produto_id, nome, estoque
FROM produto
WHERE produto_id = 4;

-- P8 - Movimentações após DELETE
SELECT
    movimentacao_id,
    produto_id,
    tipo,
    quantidade
FROM movimentacao_estoque
WHERE produto_id = 4
ORDER BY movimentacao_id;

-- P9 - Desfazer todo o teste
ROLLBACK;

-- P10 - Estoque após ROLLBACK
SELECT produto_id, nome, estoque
FROM produto
WHERE produto_id = 4;

-- P11 - Movimentações após ROLLBACK
SELECT
    movimentacao_id,
    produto_id,
    tipo,
    quantidade
FROM movimentacao_estoque
WHERE produto_id = 4
ORDER BY movimentacao_id;
