-- ============================================================
-- QUESTÃO 5 - TRIGGER DE VALIDAÇÃO
-- ============================================================

CREATE OR REPLACE FUNCTION fn_validar_item()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_preco   NUMERIC(10,2);
    v_estoque INTEGER;
    v_ativo   BOOLEAN;
BEGIN
    -- Buscar informações do produto
    SELECT preco, estoque, ativo
    INTO v_preco, v_estoque, v_ativo
    FROM produto
    WHERE produto_id = NEW.produto_id;

    -- 1. Produto inexistente
    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Produto % inexistente.',
            NEW.produto_id;
    END IF;

    -- 1. Produto inativo
    IF v_ativo = FALSE THEN
        RAISE EXCEPTION
            'Produto % está inativo.',
            NEW.produto_id;
    END IF;

    -- 2. Quantidade maior que estoque disponível
    IF NEW.quantidade > v_estoque THEN
        RAISE EXCEPTION
            'Estoque insuficiente. Disponível: %, solicitado: %.',
            v_estoque,
            NEW.quantidade;
    END IF;

    -- 3. Preencher preço quando não informado
    IF NEW.preco_unitario IS NULL THEN
        NEW.preco_unitario := v_preco;
    END IF;

    RETURN NEW;
END;
$$;
-- =============================================================
CREATE TRIGGER trg_validar_item
BEFORE INSERT ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_validar_item();
-- =============================================================
-- teste 1

INSERT INTO pedido (cliente_id, status)
VALUES (2, 'PENDENTE');

SELECT currval(pg_get_serial_sequence('pedido', 'pedido_id'))
       AS pedido_criado;

-- =============================================================
-- tete 2

INSERT INTO item_pedido (
    pedido_id,
    produto_id,
    quantidade
)
VALUES (
    currval(pg_get_serial_sequence('pedido', 'pedido_id')),
    2,
    3
);

SELECT
    pedido_id,
    produto_id,
    quantidade,
    preco_unitario
FROM item_pedido
WHERE pedido_id =
    currval(pg_get_serial_sequence('pedido', 'pedido_id'));
--=============================================================
-- teste 3

INSERT INTO item_pedido (
    pedido_id,
    produto_id,
    quantidade
)
VALUES (
    currval(pg_get_serial_sequence('pedido', 'pedido_id')),
    7,
    1
);
--=============================================================
-- teste 4

INSERT INTO item_pedido (
    pedido_id,
    produto_id,
    quantidade
)
VALUES (
    currval(pg_get_serial_sequence('pedido', 'pedido_id')),
    5,
    10
);
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
    currval(pg_get_serial_sequence('pedido', 'pedido_id'));

    