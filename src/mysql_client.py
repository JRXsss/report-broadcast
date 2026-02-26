import os
from urllib.parse import quote_plus
import pandas as pd
from sqlalchemy import create_engine

def get_mysql_engine():
    host = os.getenv("MYSQL_HOST")
    port = int(os.getenv("MYSQL_PORT", "3306"))
    user = os.getenv("MYSQL_USER")
    password = os.getenv("MYSQL_PASSWORD")
    db = os.getenv("MYSQL_DB")

    missing = [k for k,v in {
        "MYSQL_HOST": host, "MYSQL_USER": user, "MYSQL_PASSWORD": password, "MYSQL_DB": db
    }.items() if not v]
    if missing:
        raise RuntimeError(f"Missing env vars: {', '.join(missing)}")

    encoded = quote_plus(password)
    return create_engine(
        f"mysql+pymysql://{user}:{encoded}@{host}:{port}/{db}?charset=utf8mb4",
        pool_pre_ping=True,
    )

def read_sql_file(path: str) -> str:
    with open(path, "r", encoding="utf-8-sig") as f:
        return f.read().strip()

def run_query(engine, sql: str) -> pd.DataFrame:
    # 你原脚本对 % 做过 escape，是因为有些 SQL 带 % 且 pandas read_sql 会做格式化。
    # 更稳：直接用 sqlalchemy text() 执行也可以；这里沿用“把单个%转%%”的策略。
    placeholder = "___PERCENT_PLACEHOLDER___"
    sql_safe = sql.replace("%%", placeholder).replace("%", "%%").replace(placeholder, "%%")
    return pd.read_sql(sql_safe, engine)
