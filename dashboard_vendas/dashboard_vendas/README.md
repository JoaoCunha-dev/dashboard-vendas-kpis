# Dashboard de KPIs — Sistema de Vendas

## Descrição do Sistema

O sistema simula uma plataforma de **e-commerce/vendas varejo**, contendo o
registro de clientes, produtos categorizados, pedidos e seus respectivos itens.
O objetivo é permitir a análise de desempenho comercial através de indicadores
(KPIs) extraídos diretamente de consultas SQL sobre o banco relacional.

---

## Estrutura do Banco de Dados

| Tabela | Descrição |
|---|---|
| `clientes` | Cadastro de 30 clientes de diferentes estados |
| `categorias` | 5 categorias de produtos |
| `produtos` | 25 produtos com preço e estoque |
| `vendas` | 60 pedidos com data e status |
| `itens_venda` | Produtos de cada pedido (N:N) |

**Relacionamentos:**
```
clientes ──< vendas ──< itens_venda >── produtos >── categorias
```

---

## KPIs do Dashboard

| # | Indicador | Descrição |
|---|---|---|
| 1 | **Total de Pedidos** | Quantidade de vendas no período |
| 2 | **Clientes Ativos** | Clientes únicos que compraram |
| 3 | **Receita Total** | Soma de quantidade × preço dos itens |
| 4 | **Ticket Médio** | Receita total ÷ número de pedidos |

---

## Gráficos

| # | Tipo | Conteúdo |
|---|---|---|
| 1 | Barras + Linha | Receita mensal e ticket médio por mês |
| 2 | Pizza (donut) | Participação de receita por categoria |
| 3 | Pizza (donut) | Distribuição de status das vendas |
| 4 | Barras horizontais | Top 10 produtos mais vendidos |
| 5 | Barras horizontais | Top 10 clientes por receita |

---

## Consultas SQL Utilizadas

- `SELECT` com `WHERE` (filtros por data e status)
- `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- `GROUP BY` + `ORDER BY ASC/DESC`
- `JOIN` entre múltiplas tabelas
- Funções de janela (`OVER`) para percentuais
- `TO_CHAR` para agrupamento mensal

---

## Tecnologias

- **Banco de dados:** PostgreSQL (pgAdmin 4)
- **Linguagem:** Python 3.11+
- **Conexão:** psycopg2 + SQLAlchemy
- **Dashboard:** Streamlit + Plotly

---

## Estrutura de Arquivos

```
dashboard_vendas/
├── 01_criar_banco.sql          # DDL + INSERT de todos os dados
├── 02_consultas_analiticas.sql # 6 queries analíticas documentadas
├── conexao.py                  # Módulo de conexão com o PostgreSQL
├── dashboard.py                # Aplicação Streamlit (dashboard principal)
├── requirements.txt            # Dependências Python
└── README.md                   # Este arquivo
```

---

## Integrantes

| Nome |
|---|
| João Victor da Cunha Oliveira |
| Luiz Eduardo Rios |

---

## Como Executar

```bash
# 1. Instalar dependências
pip install -r requirements.txt

# 2. Configurar credenciais em conexao.py
# 3. Criar banco e popular dados (pgAdmin4)

# 4. Rodar o dashboard
streamlit run dashboard.py
```
