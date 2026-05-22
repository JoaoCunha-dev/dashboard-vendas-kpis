-- ============================================================
--  CONSULTAS ANALÍTICAS – Dashboard de KPIs de Vendas
--  Todas as queries utilizam: SELECT, WHERE, GROUP BY,
--  ORDER BY, COUNT, SUM, AVG, MIN, MAX
-- ============================================================


-- ──────────────────────────────────────────────
--  QUERY 1 – Total de receita por mês (gráfico de linha)
-- ──────────────────────────────────────────────
SELECT
    TO_CHAR(v.data_venda, 'YYYY-MM')          AS mes,
    COUNT(DISTINCT v.id_venda)                AS total_vendas,
    SUM(i.quantidade * i.preco_unit)          AS receita_total,
    AVG(i.quantidade * i.preco_unit)          AS ticket_medio
FROM vendas v
JOIN itens_venda i ON i.id_venda = v.id_venda
WHERE v.status = 'Concluída'
GROUP BY TO_CHAR(v.data_venda, 'YYYY-MM')
ORDER BY mes ASC;


-- ──────────────────────────────────────────────
--  QUERY 2 – Receita por categoria de produto (gráfico de pizza/barras)
-- ──────────────────────────────────────────────
SELECT
    c.nome                                    AS categoria,
    COUNT(DISTINCT v.id_venda)                AS qtd_vendas,
    SUM(i.quantidade)                         AS unidades_vendidas,
    SUM(i.quantidade * i.preco_unit)          AS receita_total,
    ROUND(AVG(i.preco_unit), 2)               AS preco_medio
FROM itens_venda i
JOIN produtos p   ON p.id_produto   = i.id_produto
JOIN categorias c ON c.id_categoria = p.id_categoria
JOIN vendas v     ON v.id_venda     = i.id_venda
WHERE v.status = 'Concluída'
GROUP BY c.nome
ORDER BY receita_total DESC;


-- ──────────────────────────────────────────────
--  QUERY 3 – Top 10 produtos mais vendidos (gráfico de barras)
-- ──────────────────────────────────────────────
SELECT
    p.nome                                    AS produto,
    c.nome                                    AS categoria,
    SUM(i.quantidade)                         AS unidades_vendidas,
    SUM(i.quantidade * i.preco_unit)          AS receita_gerada,
    MIN(i.preco_unit)                         AS preco_min,
    MAX(i.preco_unit)                         AS preco_max
FROM itens_venda i
JOIN produtos p   ON p.id_produto   = i.id_produto
JOIN categorias c ON c.id_categoria = p.id_categoria
JOIN vendas v     ON v.id_venda     = i.id_venda
WHERE v.status = 'Concluída'
GROUP BY p.nome, c.nome
ORDER BY unidades_vendidas DESC
LIMIT 10;


-- ──────────────────────────────────────────────
--  QUERY 4 – KPIs gerais (totais para o painel)
-- ──────────────────────────────────────────────
SELECT
    COUNT(DISTINCT v.id_venda)                AS total_pedidos,
    COUNT(DISTINCT v.id_cliente)              AS clientes_ativos,
    SUM(i.quantidade * i.preco_unit)          AS receita_total,
    ROUND(
        SUM(i.quantidade * i.preco_unit) /
        NULLIF(COUNT(DISTINCT v.id_venda), 0)
    , 2)                                       AS ticket_medio
FROM vendas v
JOIN itens_venda i ON i.id_venda = v.id_venda
WHERE v.status = 'Concluída';


-- ──────────────────────────────────────────────
--  QUERY 5 – Status das vendas (Concluída / Cancelada / Pendente)
-- ──────────────────────────────────────────────
SELECT
    status,
    COUNT(*)                                  AS quantidade,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentual
FROM vendas
GROUP BY status
ORDER BY quantidade DESC;


-- ──────────────────────────────────────────────
--  QUERY 6 – Top 10 clientes por receita
-- ──────────────────────────────────────────────
SELECT
    cl.nome                                   AS cliente,
    cl.estado,
    COUNT(DISTINCT v.id_venda)                AS total_compras,
    SUM(i.quantidade * i.preco_unit)          AS total_gasto,
    MAX(v.data_venda)                         AS ultima_compra
FROM clientes cl
JOIN vendas v     ON v.id_cliente = cl.id_cliente
JOIN itens_venda i ON i.id_venda = v.id_venda
WHERE v.status = 'Concluída'
GROUP BY cl.nome, cl.estado
ORDER BY total_gasto DESC
LIMIT 10;
