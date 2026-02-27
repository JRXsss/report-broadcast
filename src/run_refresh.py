# src/run_refresh.py
import os
import glob
import pymysql
from pymysql.constants import CLIENT

def read_sql(path: str) -> str:
    with open(path, "r", encoding="utf-8-sig") as f:
        return f.read().strip()

def get_conn():
    host = os.getenv("MYSQL_HOST")
    port = int(os.getenv("MYSQL_PORT", "3306"))
    user = os.getenv("MYSQL_USER")
    password = os.getenv("MYSQL_PASSWORD")
    db = "caguuu_report"

    missing = [k for k,v in {
        "MYSQL_HOST": host, "MYSQL_USER": user, "MYSQL_PASSWORD": password, "MYSQL_DB": db
    }.items() if not v]
    if missing:
        raise RuntimeError(f"Missing env vars: {', '.join(missing)}")

    return pymysql.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=db,
        charset="utf8mb4",
        autocommit=False,
        client_flag=CLIENT.MULTI_STATEMENTS,
    )

def main():
    sql_files = sorted(glob.glob("sql/refresh/*.sql"))
    if not sql_files:
        raise RuntimeError("No SQL files found in sql/refresh/")

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            for f in sql_files:
                sql = read_sql(f)
                print(f"Running: {f}")
                # multi statements
                for _ in cur.execute(sql, multi=True):
                    pass
            conn.commit()
        print("Refresh completed.")
    except Exception as e:
        conn.rollback()
        raise
    finally:
        conn.close()

if __name__ == "__main__":
    main()
