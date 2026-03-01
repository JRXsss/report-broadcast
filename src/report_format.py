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

# 整数展示（千分位，无小数）
INT_METRICS = {
    "商详UV",
    "销售额",
    "件单价",
    "客单价",
}

# 两位小数展示（千分位，两位小数）
DEC2_METRICS = {
    "加购数",
    "支付数",
    "净销售量",
    "UV价值",
    "连带率",
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

def _fmt_metric_value(metric_name: str, val):
    import pandas as pd
    if val is None or (isinstance(val, float) and pd.isna(val)):
        return "无"

    try:
        x = float(val)
    except Exception:
        return str(val)

    if metric_name in INT_METRICS:
        return f"{x:,.0f}"
    # 默认两位小数（也可只对白名单 DEC2_METRICS 生效）
    return f"{x:,.2f}"

def _fmt_percent(val):
    import pandas as pd
    if val is None or (isinstance(val, float) and pd.isna(val)):
        return "无"

    # 已经带%（可能是 "10.96%"）
    if isinstance(val, str) and "%" in val:
        try:
            x = float(val.strip().replace("%", ""))
            return f"{x:.2f}%"
        except Exception:
            return val

    try:
        # 如果 val 是 0.0038 这种比例
        x = float(val) * 100
        return f"{x:.2f}%"
    except Exception:
        return str(val)

def build_brief_message(df: pd.DataFrame, mode: str):
    # ✅ 只需要 3 行：当前 / 对比 / 增长率
    if df is None or df.empty or len(df) < 3:
        return ("SQL返回行数不足（需要>=3行用于：当前/对比/增长率）", True)

    cols = list(df.columns)
    if len(cols) < 3:
        return ("SQL返回列数不足（需要>=3列）", True)

    indicator_cols = cols[2:]

    # ✅ 对齐你同事脚本：df 第1行就是“昨日”(Excel第2行)
    current_row = df.iloc[0]
    compare_row = df.iloc[1]
    growth_row  = df.iloc[2]

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

        # 百分比类（转化率/加购率等）用百分比格式；其余按指标白名单走整数/两位小数
        is_percent = (str(name) in PERCENT_KEYS)

        if is_percent:
            y_fmt = _fmt_percent(y_val)   # e.g. 0.0038 -> 0.38%
            p_fmt = _fmt_percent(p_val)
        else:
            y_fmt = _fmt_metric_value(str(name), y_val)  # 整数/两位小数 + 千分位
            p_fmt = _fmt_metric_value(str(name), p_val)

        # 增长率统一按百分比两位小数展示（兼容 0.1096 或 "10.96%"）
        g_show = _fmt_growth(g_val)
        g_float = _to_float_growth(g_val)

        if g_float is not None and g_float < -0.10:
            warn = " （预警-↓↓↓）"
        elif g_float is not None and g_float > 0.20:
            warn = " （增长-↑↑↑）"
        else:
            warn = ""

        # 对比口径文案差异
        cmp_name = MODE_COMPARE_NAME.get(mode, "对比")
        cur_name = MODE_CURRENT_NAME.get(mode, "当前")

        lines.append(f"{name}：{cur_name}{y_fmt}，{cmp_name}{p_fmt}，增长率{g_show}{warn}")

    # 总预警：销售额增长率 < -10%
    alert = False
    if ALERT_KEY in indicator_cols:
        g_float = _to_float_growth(growth_row[ALERT_KEY])
        if g_float is not None and g_float < -0.10:
            alert = True

    return ("\n".join(lines), alert)


