SELECT
  '上一个月' AS 数据周期,
  DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y.%c') AS 周期,
  lm.商详UV,
  lm.加购数,
  lm.支付数,
  lm.净销售量,
  lm.销售额,
  lm.转化率,
  lm.加购率,
  lm.UV价值,
  lm.件单价,
  lm.客单价,
  lm.连带率,
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
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.add_to_cart_sessions) / SUM(od.view_sessions)) AS 加购率,  -- 确保此处正确定义了加购率
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.view_sessions)) AS UV价值,
    IF(SUM(od.product_quantity) = 0, 0, SUM(od.product_sales) / SUM(od.product_quantity)) AS 件单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.purchase_sessions)) AS 客单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_quantity) / SUM(od.purchase_sessions)) AS 连带率
  FROM caguuu_report.order_pay_sku od
  WHERE od.date BETWEEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01')
                    AND LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
                    --   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) lm,
(SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d') BETWEEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01')
                    AND LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
and spuId not in('16070460039054657262794095')
) yd_qc

UNION ALL

SELECT
  '前一个月' AS 数据周期,
  DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 2 MONTH), '%Y.%c') AS 周期,
  pm.商详UV,
  pm.加购数,
  pm.支付数,
  pm.净销售量,
  pm.销售额,
  pm.转化率,
  pm.加购率,  -- 确保引用正确
  pm.UV价值,
  pm.件单价,
  pm.客单价,
  pm.连带率,
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
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.add_to_cart_sessions) / SUM(od.view_sessions)) AS 加购率,  -- 确保此处正确定义了加购率
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.view_sessions)) AS UV价值,
    IF(SUM(od.product_quantity) = 0, 0, SUM(od.product_sales) / SUM(od.product_quantity)) AS 件单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.purchase_sessions)) AS 客单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_quantity) / SUM(od.purchase_sessions)) AS 连带率
  FROM caguuu_report.order_pay_sku od
  WHERE od.date BETWEEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 2 MONTH), '%Y-%m-01')
                    AND LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
                    --   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) pm,
(SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d') BETWEEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 2 MONTH), '%Y-%m-01')
                    AND LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
and spuId not in('16070460039054657262794095')
) pd_qc

UNION ALL

SELECT
  '增长率' AS 数据周期,
  '' AS 周期,
  CONCAT(ROUND((lm.商详UV - pm.商详UV) / IF(pm.商详UV = 0, NULL, pm.商详UV) * 100, 2), '%') AS 商详UV,
  CONCAT(ROUND((lm.加购数 - pm.加购数) / IF(pm.加购数 = 0, NULL, pm.加购数) * 100, 2), '%') AS 加购数,
  CONCAT(ROUND((lm.支付数 - pm.支付数) / IF(pm.支付数 = 0, NULL, pm.支付数) * 100, 2), '%') AS 支付数,
  CONCAT(ROUND((lm.净销售量 - pm.净销售量) / IF(pm.净销售量 = 0, NULL, pm.净销售量) * 100, 2), '%') AS 净销售量,
  CONCAT(ROUND((lm.销售额 - pm.销售额) / IF(pm.销售额 = 0, NULL, pm.销售额) * 100, 2), '%') AS 销售额,
  CONCAT(ROUND((lm.转化率 - pm.转化率) / IF(pm.转化率 = 0, NULL, pm.转化率) * 100, 2), '%') AS 转化率,
  CONCAT(ROUND((lm.加购率 - pm.加购率) / IF(pm.加购率 = 0, NULL, pm.加购率) * 100, 2), '%') AS 加购率,  -- 确保引用正确
  CONCAT(ROUND((lm.UV价值 - pm.UV价值) / IF(pm.UV价值 = 0, NULL, pm.UV价值) * 100, 2), '%') AS UV价值,
  CONCAT(ROUND((lm.件单价 - pm.件单价) / IF(pm.件单价 = 0, NULL, pm.件单价) * 100, 2), '%') AS 件单价,
  CONCAT(ROUND((lm.客单价 - pm.客单价) / IF(pm.客单价 = 0, NULL, pm.客单价) * 100, 2), '%') AS 客单价,
  CONCAT(ROUND((lm.连带率 - pm.连带率) / IF(pm.连带率 = 0, NULL, pm.连带率) * 100, 2), '%') AS 连带率,
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
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.add_to_cart_sessions) / SUM(od.view_sessions)) AS 加购率,  -- 确保此处正确定义了加购率
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.view_sessions)) AS UV价值,
    IF(SUM(od.product_quantity) = 0, 0, SUM(od.product_sales) / SUM(od.product_quantity)) AS 件单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.purchase_sessions)) AS 客单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_quantity) / SUM(od.purchase_sessions)) AS 连带率
  FROM caguuu_report.order_pay_sku od
  WHERE od.date BETWEEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 2 MONTH), '%Y-%m-01')
                    AND LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
                    --   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) pm
CROSS JOIN (
  SELECT
    SUM(od.view_sessions) AS 商详UV,
    SUM(od.add_to_cart_sessions) AS 加购数,
    SUM(od.purchase_sessions) AS 支付数,
    SUM(od.product_quantity) AS 净销售量,
    SUM(od.product_sales) AS 销售额,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.purchase_sessions) / SUM(od.view_sessions)) AS 转化率,
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.add_to_cart_sessions) / SUM(od.view_sessions)) AS 加购率,  -- 确保此处正确定义了加购率
    IF(SUM(od.view_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.view_sessions)) AS UV价值,
    IF(SUM(od.product_quantity) = 0, 0, SUM(od.product_sales) / SUM(od.product_quantity)) AS 件单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_sales) / SUM(od.purchase_sessions)) AS 客单价,
    IF(SUM(od.purchase_sessions) = 0, 0, SUM(od.product_quantity) / SUM(od.purchase_sessions)) AS 连带率
  FROM caguuu_report.order_pay_sku od
  WHERE od.date BETWEEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01')
                    AND LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
                    --   and lower(od.SPU) not in('custom000')
  and od.product_id not in('16070460039054657262794095')
) lm
CROSS JOIN (SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d') BETWEEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01')
                    AND LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
and spuId not in('16070460039054657262794095')
) yd_qc
CROSS JOIN (SELECT 
count(DISTINCT client_id) as 去重客户数,
count(DISTINCT order_seq) as 去重订单数
-- ,count(DISTINCT spuId) as 去重动销SPU数, count(DISTINCT skuId) as 去重动销SKU数 
FROM caguuu_report.order_sku_details
WHERE STR_TO_DATE(tday,'%Y%m%d') BETWEEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 2 MONTH), '%Y-%m-01')
                    AND LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
and spuId not in('16070460039054657262794095')
) pd_qc
