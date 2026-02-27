import os, glob, pymysql
from pymysql.constants import CLIENT

def read_sql(path: str) -> str:
    with open(path, "r", encoding="utf-8-sig") as f:
        return f.read().strip()

def get_conn():
    return pymysql.connect(
        host=os.getenv("MYSQL_HOST"),
        port=int(os.getenv("MYSQL_PORT", "3306")),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv("MYSQL_DB"),
        charset="utf8mb4",
        autocommit=False,
        client_flag=CLIENT.MULTI_STATEMENTS,
    )

def main():
    sql_files = sorted(glob.glob("sql/refresh/*.sql"))
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            for f in sql_files:
                sql = read_sql(f)
                print(f"Running: {f}")
                cur.execute(sql)
                while cur.nextset():
                    pass
        conn.commit()
        print("Refresh completed.")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

if __name__ == "__main__":
    main()
