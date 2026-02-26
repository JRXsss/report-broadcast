import pandas as pd

PERCENT_KEYS = {"转化率", "加购率"}
ALERT_KEY = "销售额"  # 你原脚本对“销售额增长率<-10%”做总预警判断 :contentReference[oaicite:8]{index=8}

MODE_COMPARE_NAME = {
    "daily": "前日",
    "daily_weekly": "上周同期",
    "weekly": "前周",
    "monthly": "前月",
}

MODE_CURRENT_NAME = {
    "daily": "昨日",
    "daily_weekly": "昨日",
    "weekly": "上周",
    "monthly": "上月",
}

def _to_float_growth(x):
    if x is None or (isinstance(x, float) and pd.isna(x)):
        return None
    if isinstance(x, str):
        s = x.strip()
        if s.endswith("%"):
            try:
                return float(s[:-1]) / 100
            except:
                return None
        try:
            return float(s)
        except:
            return None
    try:
        return float(x)
    except:
        return None

def _fmt_val(val, is_percent=False):
    if val is None or (isinstance(val, float) and pd.isna(val)):
        return "无"
    if is_percent:
        if isinstance(val, str) and "%" in val:
            return val
        try:
            return f"{float(val)*100:.2f}%"
        except:
            return str(val)
    if isinstance(val, (int,)):
        return str(val)
    if isinstance(val, float):
        # 跟你原脚本的展示风格接近：大数不保留小数
        if abs(val) > 10000:
            return f"{val:,.0f}"
        return f"{val:,.2f}"
    return str(val)

def build_brief_message(df: pd.DataFrame, mode: str):
    """
    df: SQL 输出表。约定：
      - 第0行：表头
      - 第1行：current（昨日/上周/上月）
      - 第2行：compare（前日/前周/前月/上周同期）
      - 第3行：growth（增长率）
    """
    if df is None or df.empty or len(df) =< 4:
        return ("SQL返回行数不足（需要>=3行用于：表头/当前/对比/增长率）", True)

    # 把列名当“表头行”；兼容你原结构：前2列是 label/date，其余是指标
    cols = list(df.columns)
    if len(cols) < 3:
        return ("SQL返回列数不足（需要>=3列）", True)

    indicator_cols = cols[2:]

    current_row = df.iloc[1]
    compare_row = df.iloc[2]
    growth_row = df.iloc[3]

    # 日期信息（等价于你读取 A2:B2 / A3:B3）:contentReference[oaicite:9]{index=9}
    current_label = str(current_row.iloc[0])
    current_date  = str(current_row.iloc[1])
    compare_label = str(compare_row.iloc[0])
    compare_date  = str(compare_row.iloc[1])

    lines = []
    lines.append(f"{current_label} : {current_date}")
    lines.append(f"{compare_label} : {compare_date}")

    for name in indicator_cols:
        y_val = current_row[name]
        p_val = compare_row[name]
        g_val = growth_row[name]

        is_percent = (str(name) in PERCENT_KEYS)
        y_fmt = _fmt_val(y_val, is_percent=is_percent)
        p_fmt = _fmt_val(p_val, is_percent=is_percent)

        g_float = _to_float_growth(g_val)
        if g_float is not None and g_float < -0.10:
            warn = " （预警-↓↓↓）"
        elif g_float is not None and g_float > 0.20:
            warn = " （增长-↑↑↑）"
        else:
            warn = ""

        # 增长率展示：优先保留原值（你原脚本也是直接用cell值）:contentReference[oaicite:10]{index=10}
        g_show = "无" if g_val is None else str(g_val)

        # 对比口径文案差异
        cmp_name = MODE_COMPARE_NAME.get(mode, "对比")
        cur_name = MODE_CURRENT_NAME.get(mode, "当前")

        lines.append(f"{name}：{cur_name}{y_fmt}，{cmp_name}{p_fmt}，增长率{g_show}{warn}")

    # 总预警：销售额增长率 < -10% :contentReference[oaicite:11]{index=11}
    alert = False
    if ALERT_KEY in indicator_cols:
        g_float = _to_float_growth(growth_row[ALERT_KEY])
        if g_float is not None and g_float < -0.10:
            alert = True

    return ("\n".join(lines), alert)
