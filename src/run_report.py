import os
import argparse
import datetime as dt
import pandas as pd

from .mysql_client import get_mysql_engine, read_sql_file, run_query
from .report_format import build_brief_message
from .wecom import send_wecom_text

MODE_TO_SQL = {
    "daily": "sql/daily.sql",
    "daily_weekly": "sql/daily_weekly.sql",
    "weekly": "sql/weekly.sql",
    "monthly": "sql/monthly.sql",
}

MODE_TO_PREFIX = {
    "daily": "简报：\n",
    "daily_weekly": "简报-上周同期：\n",
    "weekly": "简报：\n",
    "monthly": "简报：\n",
}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True, choices=MODE_TO_SQL.keys())
    args = parser.parse_args()

    # 统一用 Asia/Shanghai（和你本地脚本语义一致：取 yesterday_str）
    tz = os.getenv("TZ", "Asia/Shanghai")
    # GitHub runner 默认 UTC；这里用“业务日”的概念：默认按北京时间计算 yesterday
    now_utc = dt.datetime.utcnow()
    # 简化：用环境变量传入“业务日期”更稳（比如 Cloud Scheduler 触发时传 biz_date）
    biz_date = os.getenv("BIZ_DATE")  # YYYY-MM-DD
    if biz_date:
        biz_dt = dt.datetime.strptime(biz_date, "%Y-%m-%d").date()
    else:
        # 默认：昨天（用于日、日周同期）；周/月 SQL 自己通常会算区间
        biz_dt = (now_utc + dt.timedelta(hours=8)).date() - dt.timedelta(days=1)

    engine = get_mysql_engine()

    sql_path = MODE_TO_SQL[args.mode]
    sql_text = read_sql_file(sql_path)

    # 如果你的 SQL 需要日期参数，推荐在 SQL 里写 {BIZ_DATE} 占位符
    sql_text = sql_text.replace("{BIZ_DATE}", biz_dt.strftime("%Y-%m-%d"))

    df = run_query(engine, sql_text)

    # 拼简报（通用）
    msg, is_alert = build_brief_message(df, mode=args.mode)

    prefix = "预警通知！！！\n" if is_alert else MODE_TO_PREFIX[args.mode]
    final_text = prefix + msg

    # 发企业微信机器人
    webhook = os.getenv("WECOM_WEBHOOK_URL")
    if not webhook:
        raise RuntimeError("Missing env var WECOM_WEBHOOK_URL")
    send_wecom_text(webhook, final_text)

    print("Sent wecom message OK.")
    print(final_text)

if __name__ == "__main__":
    main()
