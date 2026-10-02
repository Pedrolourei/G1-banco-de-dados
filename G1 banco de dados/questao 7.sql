-- ============================================================
-- 7A - CRIAÇÃO DA VIEW MATERIALIZADA
-- ============================================================

DROP MATERIALIZED VIEW IF EXISTS mv_faturamento_mensal;

CREATE MATERIALIZED VIEW mv_faturamento_mensal AS
SELECT
    DATE_TRUNC('month', p.data_pedido)::date AS mes,
    COUNT(DISTINCT p.pedido_id) AS qtd_pedidos,
    COALESCE(
        SUM(ip.quantidade * ip.preco_unitario),
        0
    ) AS faturamento
FROM pedido p
JOIN item_pedido ip
    ON ip.pedido_id = p.pedido_id
WHERE p.status <> 'CANCELADO'
GROUP BY DATE_TRUNC('month', p.data_pedido)::date
ORDER BY mes;

-- ------------------------------------------------------------

CREATE UNIQUE INDEX idx_mv_faturamento_mensal_mes
ON mv_faturamento_mensal (mes);


-- ============================================================
-- 7B - DEMONSTRAÇÃO DA DEFASAGEM
-- ============================================================


-- P1 - Consultar dezembro de 2025 ANTES do novo pedido

SELECT
    mes,
    qtd_pedidos,
    faturamento
FROM mv_faturamento_mensal
WHERE mes = DATE '2025-12-01';
-- ============================================================
-- P2 - INSERIR NOVO PEDIDO PAGO
-- ============================================================

INSERT INTO pedido (
    cliente_id,
    data_pedido,
    status
)
VALUES (
    1,
    DATE '2025-12-15',
    'PAGO'
);


-- ------------------------------------------------------------
-- Inserir 1 unidade do produto 11
-- ------------------------------------------------------------

INSERT INTO item_pedido (
    pedido_id,
    produto_id,
    quantidade
)
VALUES (
    currval(pg_get_serial_sequence('pedido', 'pedido_id')),
    11,
    1
);


-- ============================================================
-- P3 - CONSULTAR A VIEW NOVAMENTE
-- ============================================================


SELECT
    mes,
    qtd_pedidos,
    faturamento
FROM mv_faturamento_mensal
WHERE mes = DATE '2025-12-01';

-- ============================================================
-- P4 - ATUALIZAR A MATERIALIZED VIEW
-- ============================================================

REFRESH MATERIALIZED VIEW CONCURRENTLY
mv_faturamento_mensal;


-- ============================================================
-- P5 - CONSULTAR DEZEMBRO NOVAMENTE
-- ============================================================

SELECT
    mes,
    qtd_pedidos,
    faturamento
FROM mv_faturamento_mensal
WHERE mes = DATE '2025-12-01';

