
START TRANSACTION;

DELETE FROM caguuu_report.order_pay_sku
WHERE date = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d');

INSERT INTO caguuu_report.order_pay_sku

SELECT
  DATE_FORMAT(date, '%Y-%m') AS month,
  DATE_FORMAT(date, '%Y-%v') AS week,
  date,
  product_category,
  spu,
  title,
  product_id,
  status,
  SUM(view_sessions) AS view_sessions,
  SUM(add_to_cart_sessions) AS add_to_cart_sessions,
  SUM(checkout_sessions) AS checkout_sessions,
  SUM(purchase_sessions) AS purchase_sessions,
  SUM(product_subtotal_sales) AS product_subtotal_sales,
  SUM(product_quantity) AS product_quantity,
  SUM(discounts) AS discounts,
  SUM(net_sales) AS net_sales,
  SUM(product_taxes) AS product_taxes,
  SUM(product_shipping_taxes) AS product_shipping_taxes,
  SUM(product_sales) AS product_sales
FROM (
  SELECT
    DATE(date_time) AS date,
    CAST(product_id AS CHAR) AS product_id,
      SUM(view_sessions) AS view_sessions,
    SUM(add_to_cart_sessions) AS add_to_cart_sessions,
    SUM(checkout_sessions) AS checkout_sessions,
    SUM(if(purchase_sessions>0,purchase_sessions,0)) AS purchase_sessions,
    SUM(if(product_subtotal_sales>0,product_subtotal_sales,0))/100 AS product_subtotal_sales,
    SUM(if(product_quantity>0,product_quantity,0)) AS product_quantity,
    SUM(if(discounts>0,discounts,0))/100 AS discounts,
    SUM(if(net_sales>0,net_sales,0))/100 AS net_sales,
    SUM(if(product_taxes>0,product_taxes,0))/100 AS product_taxes,
    SUM(if(product_shipping_taxes>0,product_shipping_taxes,0))/100 AS product_shipping_taxes,
    SUM(if(product_sales>0,product_sales,0))/100 AS product_sales
  FROM caguuu_erp.shopline_product_statistics od
  WHERE 
  -- DATE(date_time) between '2025-08-22' and '2025-08-24'
  DATE(date_time) =DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY) 
  GROUP BY 1, 2
) od
LEFT JOIN (
  SELECT
    spu.product_category,
    UPPER(spu.spu) AS spu,
    CAST(spu.spu_id AS CHAR) AS spu_id,
    spu.title,
    CASE 
      WHEN spu.status = 'active' THEN '在售'
      WHEN spu.status = 'archived' THEN '下架' 
      WHEN spu.status = 'draft' THEN '待上架' 
    END AS status
  FROM caguuu_erp.shopline_product_sku sku
  LEFT JOIN caguuu_erp.shopline_product_spu spu 
    ON CAST(spu.id AS CHAR) = CAST(sku.spu_id AS CHAR)
  GROUP BY 1, 2, 3, 4, 5
) pro_sku ON pro_sku.spu_id = od.product_id
GROUP BY 
  DATE_FORMAT(date, '%Y-%m'), 
  DATE_FORMAT(date, '%Y-%v'), 
  date, 
  product_category, 
  spu, 
  title, 
  product_id, 
  status;

COMMIT;
