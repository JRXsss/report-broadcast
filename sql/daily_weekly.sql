SELECT
  '昨日' AS 数据日期,
  DATE_SUB(CURDATE(), INTERVAL 1 DAY) as 日期,
  yd.商详UV,
  yd.加购数,
  yd.支付数,
  yd.净销售量,
  yd.销售额,
  yd.转化率,
  yd.加购率,
  yd.UV价值,
  yd.件单价,
  yd.客单价,
  yd.连带率,
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
  WHERE od.date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)  -- 昨日
--   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) yd,
(SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d')=DATE_SUB(CURDATE(), INTERVAL 1 DAY)
and spuId not in('16070460039054657262794095')
) yd_qc

UNION ALL

SELECT
  '上周同期' AS 数据日期,
  DATE_SUB(CURDATE(), INTERVAL 8 DAY) as 日期,
  pd.商详UV,
  pd.加购数,
  pd.支付数,
  pd.净销售量,
  pd.销售额,
  pd.转化率,
  pd.加购率,
  pd.UV价值,
  pd.件单价,
  pd.客单价,
  pd.连带率,
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
  WHERE od.date = DATE_SUB(CURDATE(), INTERVAL 8 DAY)  -- 前日
--   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) pd,
(SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d')=DATE_SUB(CURDATE(), INTERVAL 8 DAY)
and spuId not in('16070460039054657262794095')
) pd_qc

UNION ALL

SELECT
  '增长率' AS 数据日期,
  "" as 日期,
  -- 计算各项指标的环比增长率(昨日-前日)/前日*100%
  CONCAT(ROUND((yd.商详UV - pd.商详UV) / IF(pd.商详UV = 0, NULL, pd.商详UV) * 100, 2), '%') AS 商详UV,
  CONCAT(ROUND((yd.加购数 - pd.加购数) / IF(pd.加购数 = 0, NULL, pd.加购数) * 100, 2), '%') AS 加购数,
  CONCAT(ROUND((yd.支付数 - pd.支付数) / IF(pd.支付数 = 0, NULL, pd.支付数) * 100, 2), '%') AS 支付数,
  CONCAT(ROUND((yd.净销售量 - pd.净销售量) / IF(pd.净销售量 = 0, NULL, pd.净销售量) * 100, 2), '%') AS 净销售量,
  CONCAT(ROUND((yd.销售额 - pd.销售额) / IF(pd.销售额 = 0, NULL, pd.销售额) * 100, 2), '%') AS 销售额,
  CONCAT(ROUND((yd.转化率 - pd.转化率) / IF(pd.转化率 = 0, NULL, pd.转化率) * 100, 2), '%') AS 转化率,
  CONCAT(ROUND((yd.加购率 - pd.加购率) / IF(pd.加购率 = 0, NULL, pd.加购率) * 100, 2), '%') AS 加购率,
  CONCAT(ROUND((yd.UV价值 - pd.UV价值) / IF(pd.UV价值 = 0, NULL, pd.UV价值) * 100, 2), '%') AS UV价值,
  CONCAT(ROUND((yd.件单价 - pd.件单价) / IF(pd.件单价 = 0, NULL, pd.件单价) * 100, 2), '%') AS 件单价,
  CONCAT(ROUND((yd.客单价 - pd.客单价) / IF(pd.客单价 = 0, NULL, pd.客单价) * 100, 2), '%') AS 客单价,
  CONCAT(ROUND((yd.连带率 - pd.连带率) / IF(pd.连带率 = 0, NULL, pd.连带率) * 100, 2), '%') AS 连带率,
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
  WHERE od.date = DATE_SUB(CURDATE(), INTERVAL 8 DAY)  -- 前日
--   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) pd
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
  WHERE od.date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)  -- 昨日
--   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) yd
CROSS JOIN (SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d')=DATE_SUB(CURDATE(), INTERVAL 1 DAY)
and spuId not in('16070460039054657262794095')
) yd_qc
CROSS JOIN (SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d')=DATE_SUB(CURDATE(), INTERVAL 8 DAY)
and spuId not in('16070460039054657262794095')
) pd_qc
