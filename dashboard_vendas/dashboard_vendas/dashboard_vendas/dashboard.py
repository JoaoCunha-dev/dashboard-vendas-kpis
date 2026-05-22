"""
dashboard.py – Dashboard de KPIs de Vendas
Execute com:  streamlit run dashboard.py
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from conexao import query_df

# ──────────────────────────────────────────────
#  CONFIGURAÇÃO DA PÁGINA
# ──────────────────────────────────────────────
st.set_page_config(
    page_title="Dashboard de Vendas",
    page_icon="🛒",
    layout="wide",
    initial_sidebar_state="expanded",
)

# CSS customizado
st.markdown("""
<style>
    .metric-card {
        background: linear-gradient(135deg, #1e3a5f, #2d6a9f);
        border-radius: 12px;
        padding: 20px;
        color: white;
        text-align: center;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
    }
    .metric-label { font-size: 0.85rem; opacity: 0.85; margin-bottom: 6px; }
    .metric-value { font-size: 1.9rem; font-weight: 700; }
    h1 { color: #1e3a5f; }
    .stSidebar { background-color: #f0f4f8; }
</style>
""", unsafe_allow_html=True)


# ──────────────────────────────────────────────
#  FUNÇÕES DE CONSULTA (SQL → DataFrame)
# ──────────────────────────────────────────────

@st.cache_data(ttl=60)
def carregar_kpis(status_list: list[str], data_ini: str, data_fim: str):
    sql = """
        SELECT
            COUNT(DISTINCT v.id_venda)                                        AS total_pedidos,
            COUNT(DISTINCT v.id_cliente)                                      AS clientes_ativos,
            COALESCE(SUM(i.quantidade * i.preco_unit), 0)                     AS receita_total,
            COALESCE(
                ROUND(SUM(i.quantidade * i.preco_unit) /
                      NULLIF(COUNT(DISTINCT v.id_venda), 0), 2), 0)          AS ticket_medio
        FROM vendas v
        JOIN itens_venda i ON i.id_venda = v.id_venda
        WHERE v.status = ANY(:status_list)
          AND v.data_venda BETWEEN :data_ini AND :data_fim
    """
    return query_df(sql, {"status_list": status_list,
                          "data_ini": data_ini, "data_fim": data_fim})


@st.cache_data(ttl=60)
def carregar_receita_mensal(status_list: list[str], data_ini: str, data_fim: str):
    sql = """
        SELECT
            TO_CHAR(v.data_venda, 'YYYY-MM')           AS mes,
            COUNT(DISTINCT v.id_venda)                 AS total_vendas,
            SUM(i.quantidade * i.preco_unit)           AS receita_total,
            ROUND(SUM(i.quantidade * i.preco_unit) /
                  NULLIF(COUNT(DISTINCT v.id_venda),0), 2) AS ticket_medio
        FROM vendas v
        JOIN itens_venda i ON i.id_venda = v.id_venda
        WHERE v.status = ANY(:status_list)
          AND v.data_venda BETWEEN :data_ini AND :data_fim
        GROUP BY TO_CHAR(v.data_venda, 'YYYY-MM')
        ORDER BY mes ASC
    """
    return query_df(sql, {"status_list": status_list,
                          "data_ini": data_ini, "data_fim": data_fim})


@st.cache_data(ttl=60)
def carregar_receita_categoria(status_list: list[str], data_ini: str, data_fim: str):
    sql = """
        SELECT
            c.nome                                     AS categoria,
            COUNT(DISTINCT v.id_venda)                 AS qtd_vendas,
            SUM(i.quantidade)                          AS unidades,
            SUM(i.quantidade * i.preco_unit)           AS receita_total
        FROM itens_venda i
        JOIN produtos p    ON p.id_produto   = i.id_produto
        JOIN categorias c  ON c.id_categoria = p.id_categoria
        JOIN vendas v      ON v.id_venda     = i.id_venda
        WHERE v.status = ANY(:status_list)
          AND v.data_venda BETWEEN :data_ini AND :data_fim
        GROUP BY c.nome
        ORDER BY receita_total DESC
    """
    return query_df(sql, {"status_list": status_list,
                          "data_ini": data_ini, "data_fim": data_fim})


@st.cache_data(ttl=60)
def carregar_top_produtos(status_list: list[str], data_ini: str, data_fim: str,
                          categorias: list[str]):
    sql = """
        SELECT
            p.nome                                     AS produto,
            c.nome                                     AS categoria,
            SUM(i.quantidade)                          AS unidades_vendidas,
            SUM(i.quantidade * i.preco_unit)           AS receita_gerada
        FROM itens_venda i
        JOIN produtos p    ON p.id_produto   = i.id_produto
        JOIN categorias c  ON c.id_categoria = p.id_categoria
        JOIN vendas v      ON v.id_venda     = i.id_venda
        WHERE v.status = ANY(:status_list)
          AND v.data_venda BETWEEN :data_ini AND :data_fim
          AND c.nome = ANY(:categorias)
        GROUP BY p.nome, c.nome
        ORDER BY unidades_vendidas DESC
        LIMIT 10
    """
    return query_df(sql, {"status_list": status_list, "data_ini": data_ini,
                          "data_fim": data_fim, "categorias": categorias})


@st.cache_data(ttl=60)
def carregar_status_vendas(data_ini: str, data_fim: str):
    sql = """
        SELECT
            status,
            COUNT(*) AS quantidade
        FROM vendas
        WHERE data_venda BETWEEN :data_ini AND :data_fim
        GROUP BY status
        ORDER BY quantidade DESC
    """
    return query_df(sql, {"data_ini": data_ini, "data_fim": data_fim})


@st.cache_data(ttl=60)
def carregar_top_clientes(status_list: list[str], data_ini: str, data_fim: str):
    sql = """
        SELECT
            cl.nome                                    AS cliente,
            cl.estado,
            COUNT(DISTINCT v.id_venda)                 AS total_compras,
            SUM(i.quantidade * i.preco_unit)           AS total_gasto
        FROM clientes cl
        JOIN vendas v      ON v.id_cliente = cl.id_cliente
        JOIN itens_venda i ON i.id_venda   = v.id_venda
        WHERE v.status = ANY(:status_list)
          AND v.data_venda BETWEEN :data_ini AND :data_fim
        GROUP BY cl.nome, cl.estado
        ORDER BY total_gasto DESC
        LIMIT 10
    """
    return query_df(sql, {"status_list": status_list,
                          "data_ini": data_ini, "data_fim": data_fim})


def carregar_categorias_lista():
    return query_df("SELECT nome FROM categorias ORDER BY nome")["nome"].tolist()


# ──────────────────────────────────────────────
#  SIDEBAR – FILTROS DINÂMICOS
# ──────────────────────────────────────────────
st.sidebar.image(
    "https://img.icons8.com/color/96/000000/shopping-cart.png", width=64
)
st.sidebar.title("🔍 Filtros")

data_ini = st.sidebar.date_input("Data inicial", value=pd.to_datetime("2024-01-01"))
data_fim = st.sidebar.date_input("Data final",   value=pd.to_datetime("2024-12-31"))

status_opcoes = ["Concluída", "Cancelada", "Pendente"]
status_sel = st.sidebar.multiselect(
    "Status da venda", status_opcoes, default=["Concluída"]
)

todas_cats = carregar_categorias_lista()
cats_sel = st.sidebar.multiselect(
    "Categorias (Top Produtos)", todas_cats, default=todas_cats
)

if not status_sel:
    st.sidebar.warning("Selecione ao menos um status.")
    st.stop()
if not cats_sel:
    st.sidebar.warning("Selecione ao menos uma categoria.")
    st.stop()

d_ini = str(data_ini)
d_fim = str(data_fim)

# ──────────────────────────────────────────────
#  TÍTULO
# ──────────────────────────────────────────────
st.markdown("## 🛒 Dashboard de Vendas")
st.markdown(
    f"**Período:** {data_ini.strftime('%d/%m/%Y')} → {data_fim.strftime('%d/%m/%Y')} "
    f"&nbsp;|&nbsp; **Status:** {', '.join(status_sel)}"
)
st.divider()

# ──────────────────────────────────────────────
#  KPI CARDS
# ──────────────────────────────────────────────
kpi = carregar_kpis(status_sel, d_ini, d_fim)
if kpi.empty:
    st.warning("Nenhum dado encontrado para os filtros selecionados.")
    st.stop()

row = kpi.iloc[0]

c1, c2, c3, c4 = st.columns(4)

def card(col, icon, label, value):
    col.markdown(f"""
    <div class="metric-card">
        <div class="metric-label">{icon} {label}</div>
        <div class="metric-value">{value}</div>
    </div>
    """, unsafe_allow_html=True)

card(c1, "📦", "Total de Pedidos",   f"{int(row['total_pedidos']):,}")
card(c2, "👥", "Clientes Ativos",    f"{int(row['clientes_ativos']):,}")
card(c3, "💰", "Receita Total",      f"R$ {float(row['receita_total']):,.2f}")
card(c4, "🎯", "Ticket Médio",       f"R$ {float(row['ticket_medio']):,.2f}")

st.markdown("<br>", unsafe_allow_html=True)

# ──────────────────────────────────────────────
#  GRÁFICO 1 – Receita mensal (Linha + Barras)
# ──────────────────────────────────────────────
st.subheader("📈 Receita Mensal")
df_mensal = carregar_receita_mensal(status_sel, d_ini, d_fim)

if not df_mensal.empty:
    fig1 = go.Figure()
    fig1.add_trace(go.Bar(
        x=df_mensal["mes"],
        y=df_mensal["receita_total"],
        name="Receita (R$)",
        marker_color="#2d6a9f",
        opacity=0.85,
        yaxis="y1",
    ))
    fig1.add_trace(go.Scatter(
        x=df_mensal["mes"],
        y=df_mensal["ticket_medio"],
        name="Ticket Médio (R$)",
        mode="lines+markers",
        line=dict(color="#e07b39", width=2.5),
        marker=dict(size=7),
        yaxis="y2",
    ))
    fig1.update_layout(
        yaxis=dict(title="Receita (R$)", title_font=dict(color="#2d6a9f")),
        yaxis2=dict(title="Ticket Médio (R$)", title_font=dict(color="#e07b39"),
                    overlaying="y", side="right"),
        legend=dict(x=0, y=1.12, orientation="h"),
        hovermode="x unified",
        plot_bgcolor="rgba(0,0,0,0)",
        paper_bgcolor="rgba(0,0,0,0)",
        height=380,
    )
    st.plotly_chart(fig1, use_container_width=True)
else:
    st.info("Sem dados de receita mensal para o período.")

# ──────────────────────────────────────────────
#  GRÁFICOS 2 e 3 lado a lado
# ──────────────────────────────────────────────
col_a, col_b = st.columns(2)

# Gráfico 2 – Pizza por Categoria
with col_a:
    st.subheader("🥧 Receita por Categoria")
    df_cat = carregar_receita_categoria(status_sel, d_ini, d_fim)
    if not df_cat.empty:
        fig2 = px.pie(
            df_cat,
            names="categoria",
            values="receita_total",
            color_discrete_sequence=px.colors.qualitative.Set2,
            hole=0.4,
        )
        fig2.update_traces(textinfo="percent+label", pull=[0.03]*len(df_cat))
        fig2.update_layout(
            showlegend=True,
            height=380,
            paper_bgcolor="rgba(0,0,0,0)",
        )
        st.plotly_chart(fig2, use_container_width=True)
    else:
        st.info("Sem dados de categorias.")

# Gráfico 3 – Status das Vendas (Rosca)
with col_b:
    st.subheader("📊 Status das Vendas")
    df_status = carregar_status_vendas(d_ini, d_fim)
    if not df_status.empty:
        cores_status = {"Concluída": "#27ae60", "Pendente": "#f39c12", "Cancelada": "#e74c3c"}
        fig3 = px.pie(
            df_status,
            names="status",
            values="quantidade",
            color="status",
            color_discrete_map=cores_status,
            hole=0.5,
        )
        fig3.update_traces(textinfo="value+percent")
        fig3.update_layout(
            height=380,
            paper_bgcolor="rgba(0,0,0,0)",
        )
        st.plotly_chart(fig3, use_container_width=True)
    else:
        st.info("Sem dados de status.")

# ──────────────────────────────────────────────
#  GRÁFICO 4 – Top 10 Produtos (barras horizontais)
# ──────────────────────────────────────────────
st.subheader("🏆 Top 10 Produtos Mais Vendidos")
df_prod = carregar_top_produtos(status_sel, d_ini, d_fim, cats_sel)

if not df_prod.empty:
    fig4 = px.bar(
        df_prod.sort_values("unidades_vendidas"),
        x="unidades_vendidas",
        y="produto",
        orientation="h",
        color="categoria",
        color_discrete_sequence=px.colors.qualitative.Pastel,
        text="unidades_vendidas",
        labels={"unidades_vendidas": "Unidades Vendidas", "produto": ""},
    )
    fig4.update_traces(textposition="outside")
    fig4.update_layout(
        height=430,
        plot_bgcolor="rgba(0,0,0,0)",
        paper_bgcolor="rgba(0,0,0,0)",
        legend=dict(title="Categoria"),
        xaxis=dict(title="Unidades Vendidas"),
    )
    st.plotly_chart(fig4, use_container_width=True)
else:
    st.info("Sem dados de produtos para o período e categorias selecionados.")

# ──────────────────────────────────────────────
#  GRÁFICO 5 – Top 10 Clientes (barras)
# ──────────────────────────────────────────────
st.subheader("👑 Top 10 Clientes por Receita")
df_cli = carregar_top_clientes(status_sel, d_ini, d_fim)

if not df_cli.empty:
    fig5 = px.bar(
        df_cli.sort_values("total_gasto"),
        x="total_gasto",
        y="cliente",
        orientation="h",
        color="total_compras",
        color_continuous_scale="Blues",
        text=df_cli.sort_values("total_gasto")["total_gasto"].apply(
            lambda v: f"R$ {v:,.0f}"
        ),
        labels={"total_gasto": "Total Gasto (R$)", "cliente": "",
                "total_compras": "Nº Compras"},
    )
    fig5.update_traces(textposition="outside")
    fig5.update_layout(
        height=400,
        plot_bgcolor="rgba(0,0,0,0)",
        paper_bgcolor="rgba(0,0,0,0)",
    )
    st.plotly_chart(fig5, use_container_width=True)

# ──────────────────────────────────────────────
#  TABELA DETALHADA (expansível)
# ──────────────────────────────────────────────
with st.expander("📋 Ver tabela — Receita Mensal Detalhada"):
    if not df_mensal.empty:
        df_show = df_mensal.copy()
        df_show["receita_total"] = df_show["receita_total"].apply(
            lambda v: f"R$ {v:,.2f}"
        )
        df_show["ticket_medio"] = df_show["ticket_medio"].apply(
            lambda v: f"R$ {v:,.2f}"
        )
        df_show.columns = ["Mês", "Total Vendas", "Receita Total", "Ticket Médio"]
        st.dataframe(df_show, use_container_width=True, hide_index=True)

st.divider()
st.caption("Dashboard de Vendas · Desenvolvido com Python + Streamlit + PostgreSQL")