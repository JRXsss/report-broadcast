SELECT
  '上一周' AS 数据周期,
  CONCAT(
    DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 7 DAY), '%Y.%c.%e'),
    '-',
    DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 1 DAY), '%c.%e')
  ) AS 周期,
  lw.商详UV,
  lw.加购数,
  lw.支付数,
  lw.净销售量,
  lw.销售额,
  lw.转化率,
  lw.加购率,
  lw.UV价值,
  lw.件单价,
  lw.客单价,
  lw.连带率,
	yd_qc.去重客户数,
	yd_qc.去重订单数
FROM (
  SELECT
    SUM(od.view_sessions) AS 商详UV,
    SUM(od.add_to_cart_sessions) AS 加购数,
    SUM(od.purchase_sessions) AS 支付数,
    SUM(od.product_quantity) AS 净销售量,
    SUM(od.product_sales) AS 销售额,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.purchase_sessions) / SUM(od.view_sessions)) AS 转化率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.add_to_cart_sessions) / SUM(od.view_sessions)) AS 加购率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.view_sessions)) AS UV价值,
    IF(SUM(od.product_quantity) = 0, 0, SUM(od.product_sales) / SUM(od.product_quantity)) AS 件单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.purchase_sessions)) AS 客单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_quantity) / SUM(od.purchase_sessions)) AS 连带率
  FROM caguuu_report.order_pay_sku od
  WHERE od.date BETWEEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 7 DAY) 
                    AND DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 1 DAY)
                    --   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) lw,
(SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d') BETWEEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 7 DAY) 
                    AND DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 1 DAY)
and spuId not in('16070460039054657262794095')
) yd_qc

UNION ALL

SELECT
  '前一周' AS 数据周期,
  CONCAT(
    DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 14 DAY), '%Y.%c.%e'),
    '-',
    DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 8 DAY), '%c.%e')
  ) AS 周期,
  pw.商详UV,
  pw.加购数,
  pw.支付数,
  pw.净销售量,
  pw.销售额,
  pw.转化率,
  pw.加购率,
  pw.UV价值,
  pw.件单价,
  pw.客单价,
  pw.连带率,
	pd_qc.去重客户数,
	pd_qc.去重订单数
FROM (
  SELECT
    SUM(od.view_sessions) AS 商详UV,
    SUM(od.add_to_cart_sessions) AS 加购数,
    SUM(od.purchase_sessions) AS 支付数,
    SUM(od.product_quantity) AS 净销售量,
    SUM(od.product_sales) AS 销售额,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.purchase_sessions) / SUM(od.view_sessions)) AS 转化率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.add_to_cart_sessions) / SUM(od.view_sessions)) AS 加购率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.view_sessions)) AS UV价值,
    IF(SUM(od.product_quantity) = 0, 0, SUM(od.product_sales) / SUM(od.product_quantity)) AS 件单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.purchase_sessions)) AS 客单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_quantity) / SUM(od.purchase_sessions)) AS 连带率
  FROM caguuu_report.order_pay_sku od
  WHERE od.date BETWEEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 14 DAY)
                    AND DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 8 DAY)
                    --   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) pw,
(SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d') BETWEEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 14 DAY)
                    AND DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 8 DAY)
and spuId not in('16070460039054657262794095')
) pd_qc


UNION ALL

SELECT
  '增长率' AS 数据周期,
  '' AS 周期,
  -- 计算各项指标的环比增长率(上一周-前一周)/前一周*100%
  CONCAT(ROUND((lw.商详UV - pw.商详UV) / IF(pw.商详UV = 0, NULL, pw.商详UV) * 100, 2), '%') AS 商详UV,
  CONCAT(ROUND((lw.加购数 - pw.加购数) / IF(pw.加购数 = 0, NULL, pw.加购数) * 100, 2), '%') AS 加购数,
  CONCAT(ROUND((lw.支付数 - pw.支付数) / IF(pw.支付数 = 0, NULL, pw.支付数) * 100, 2), '%') AS 支付数,
  CONCAT(ROUND((lw.净销售量 - pw.净销售量) / IF(pw.净销售量 = 0, NULL, pw.净销售量) * 100, 2), '%') AS 净销售量,
  CONCAT(ROUND((lw.销售额 - pw.销售额) / IF(pw.销售额 = 0, NULL, pw.销售额) * 100, 2), '%') AS 销售额,
  CONCAT(ROUND((lw.转化率 - pw.转化率) / IF(pw.转化率 = 0, NULL, pw.转化率) * 100, 2), '%') AS 转化率,
  CONCAT(ROUND((lw.加购率 - pw.加购率) / IF(pw.加购率 = 0, NULL, pw.加购率) * 100, 2), '%') AS 加购率,
  CONCAT(ROUND((lw.UV价值 - pw.UV价值) / IF(pw.UV价值 = 0, NULL, pw.UV价值) * 100, 2), '%') AS UV价值,
  CONCAT(ROUND((lw.件单价 - pw.件单价) / IF(pw.件单价 = 0, NULL, pw.件单价) * 100, 2), '%') AS 件单价,
  CONCAT(ROUND((lw.客单价 - pw.客单价) / IF(pw.客单价 = 0, NULL, pw.客单价) * 100, 2), '%') AS 客单价,
  CONCAT(ROUND((lw.连带率 - pw.连带率) / IF(pw.连带率 = 0, NULL, pw.连带率) * 100, 2), '%') AS 连带率,
	CONCAT(ROUND((yd_qc.去重客户数 - pd_qc.去重客户数) / IF(pd_qc.去重客户数 = 0, NULL, pd_qc.去重客户数) * 100, 2), '%') AS 去重客户数,
	CONCAT(ROUND((yd_qc.去重订单数 - pd_qc.去重订单数) / IF(pd_qc.去重订单数 = 0, NULL, pd_qc.去重订单数) * 100, 2), '%') AS 去重订单数
FROM (
  SELECT
    SUM(od.view_sessions) AS 商详UV,
    SUM(od.add_to_cart_sessions) AS 加购数,
    SUM(od.purchase_sessions) AS 支付数,
    SUM(od.product_quantity) AS 净销售量,
    SUM(od.product_sales) AS 销售额,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.purchase_sessions) / SUM(od.view_sessions)) AS 转化率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.add_to_cart_sessions) / SUM(od.view_sessions)) AS 加购率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.view_sessions)) AS UV价值,
    IF(SUM(od.product_quantity) = 0, 0, SUM(od.product_sales) / SUM(od.product_quantity)) AS 件单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.purchase_sessions)) AS 客单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_quantity) / SUM(od.purchase_sessions)) AS 连带率
  FROM caguuu_report.order_pay_sku od
  WHERE od.date BETWEEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 14 DAY)
                    AND DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 8 DAY)
                    --   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) pw
CROSS JOIN (
  SELECT
    SUM(od.view_sessions) AS 商详UV,
    SUM(od.add_to_cart_sessions) AS 加购数,
    SUM(od.purchase_sessions) AS 支付数,
    SUM(od.product_quantity) AS 净销售量,
    SUM(od.product_sales) AS 销售额,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.purchase_sessions) / SUM(od.view_sessions)) AS 转化率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.add_to_cart_sessions) / SUM(od.view_sessions)) AS 加购率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.view_sessions)) AS UV价值,
    IF(SUM(od.product_quantity) = 0, 0, SUM(od.product_sales) / SUM(od.product_quantity)) AS 件单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.purchase_sessions)) AS 客单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_quantity) / SUM(od.purchase_sessions)) AS 连带率
  FROM caguuu_report.order_pay_sku od
  WHERE od.date BETWEEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 7 DAY)
                    AND DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 1 DAY)
                    --   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) lw
CROSS JOIN (SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d') BETWEEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 7 DAY) 
                    AND DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 1 DAY)
and spuId not in('16070460039054657262794095')
) yd_qc
CROSS JOIN (SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d') BETWEEN DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 14 DAY)
                    AND DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 8 DAY)
and spuId not in('16070460039054657262794095')
) pd_qc
