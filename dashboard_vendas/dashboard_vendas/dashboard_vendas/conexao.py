"""
conexao.py - Modulo de conexao com o PostgreSQL via psycopg2 + SQLAlchemy
Altere as credenciais abaixo conforme o seu ambiente pgAdmin4.
"""

import psycopg2
import pandas as pd
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus

# ──────────────────────────────────────────────
#  CONFIGURACOES DO BANCO (ajuste aqui)
# ──────────────────────────────────────────────
DB_HOST     = "localhost"
DB_PORT     = 5432
DB_NAME     = "dashboard_vendas"   # nome do banco criado no pgAdmin4
DB_USER     = "postgres"
DB_PASSWORD = "1234"     # substitua pela sua senha


def get_engine():
    """Retorna um engine SQLAlchemy usando URL encoded (evita problemas com acentos)."""
    password_encoded = quote_plus(DB_PASSWORD)
    url = f"postgresql+psycopg2://{DB_USER}:{password_encoded}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    return create_engine(url, connect_args={"client_encoding": "utf8"})


def get_connection():
    """Retorna uma conexao psycopg2 pura."""
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        client_encoding="utf8"
    )


def query_df(sql: str, params: dict | None = None) -> pd.DataFrame:
    """
    Executa uma query SQL e devolve o resultado como DataFrame.

    Parametros
    ----------
    sql    : string SQL (pode usar :param para parametros nomeados)
    params : dicionario de parametros (opcional)
    """
    engine = get_engine()
    with engine.connect() as conn:
        return pd.read_sql(text(sql), conn, params=params)