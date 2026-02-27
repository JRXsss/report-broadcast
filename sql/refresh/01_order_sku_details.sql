START TRANSACTION;

DELETE FROM caguuu_report.order_sku_details
WHERE date = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d');

INSERT INTO caguuu_report.order_sku_details
SELECT
  sale_g.*,
  order_sale.cf,
  sale_g.sale_price_gmv * order_sale.cf AS sale_gmv
FROM (
  -- sale_g子查询
  SELECT
    tday,
    client_id,
    event_id,
    order_seq,
    app_order_seq,
    order_value,
    shipping_amount,
    tax_amount,
    currency,
    user_email,
    user_phone,
    user_country,
    user_province,
    user_city,
    user_address,
    category,
    price,
    quantity,
    skuId,
    skuItemNo,
    spuId,
    title,
    variant,
    price * quantity AS sale_price_gmv
  FROM (
    -- exploded子查询：将item提取移到SELECT子句中
    SELECT
      f.tday,
      f.client_id,
      f.event_id,
      f.order_seq,
      f.app_order_seq,
      f.order_value,
      f.shipping_amount,
      f.tax_amount,
      f.currency,
      f.user_email,
      f.user_phone,
      f.user_country,
      f.user_province,
      f.user_city,
      f.user_address,
      -- 提取当前索引的item（移到这里，作为SELECT的列）
      JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')) AS item,
      -- 通过item提取商品字段
      JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.category')) AS category,
      CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.price')) AS UNSIGNED) AS price,
      CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.quantity')) AS UNSIGNED) AS quantity,
      JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.skuId')) AS skuId,
      JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.skuItemNo')) AS skuItemNo,
      JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.spuId')) AS spuId,
      JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.title')) AS title,
      JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.variant')) AS variant
    FROM (
      -- flattened子查询
      SELECT
        p.tday,
        p.client_id,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.eventId')) AS event_id,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.orderSeq')) AS order_seq,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.appOrderSeq')) AS app_order_seq,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.value')) AS UNSIGNED) AS order_value,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.shippingAmount')) AS UNSIGNED) AS shipping_amount,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.taxAmount')) AS UNSIGNED) AS tax_amount,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.currency')) AS currency,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.eventTime')) AS event_time,
        -- userInfo字段
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.userInfo.email')) AS user_email,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.userInfo.phone')) AS user_phone,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.userInfo.country')) AS user_country,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.userInfo.province')) AS user_province,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.userInfo.city')) AS user_city,
        JSON_UNQUOTE(JSON_EXTRACT(p.event_json, '$.userInfo.address')) AS user_address,
        -- 商品数组及长度
        JSON_EXTRACT(p.event_json, '$.list') AS product_array,
        JSON_LENGTH(JSON_EXTRACT(p.event_json, '$.list')) AS array_length
      FROM (
        -- parsed子查询
        SELECT
          DATE_FORMAT(CONVERT_TZ(event_time, '+00:00', '+08:00'), '%Y%m%d') as tday,
          client_id,
          event_data AS event_json
        FROM caguuu_erp.shopline_event_record_origin
        WHERE event_name = 'checkout_completed'
          AND DATE_FORMAT(CONVERT_TZ(event_time, '+00:00', '+08:00'), '%Y%m%d') 
              = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d')
            -- BETWEEN '20250822' and '20250824'
      ) p
    ) f
    -- 数字辅助表（0~100，可按需扩展）
    JOIN (
      SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
      SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL
      SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL
      SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL
      SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL
      SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL
      SELECT 30 UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL
      SELECT 35 UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL
      SELECT 40 UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL
      SELECT 45 UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL SELECT 49 UNION ALL
      SELECT 50 UNION ALL SELECT 51 UNION ALL SELECT 52 UNION ALL SELECT 53 UNION ALL SELECT 54 UNION ALL
      SELECT 55 UNION ALL SELECT 56 UNION ALL SELECT 57 UNION ALL SELECT 58 UNION ALL SELECT 59 UNION ALL
      SELECT 60 UNION ALL SELECT 61 UNION ALL SELECT 62 UNION ALL SELECT 63 UNION ALL SELECT 64 UNION ALL
      SELECT 65 UNION ALL SELECT 66 UNION ALL SELECT 67 UNION ALL SELECT 68 UNION ALL SELECT 69 UNION ALL
      SELECT 70 UNION ALL SELECT 71 UNION ALL SELECT 72 UNION ALL SELECT 73 UNION ALL SELECT 74 UNION ALL
      SELECT 75 UNION ALL SELECT 76 UNION ALL SELECT 77 UNION ALL SELECT 78 UNION ALL SELECT 79 UNION ALL
      SELECT 80 UNION ALL SELECT 81 UNION ALL SELECT 82 UNION ALL SELECT 83 UNION ALL SELECT 84 UNION ALL
      SELECT 85 UNION ALL SELECT 86 UNION ALL SELECT 87 UNION ALL SELECT 88 UNION ALL SELECT 89 UNION ALL
      SELECT 90 UNION ALL SELECT 91 UNION ALL SELECT 92 UNION ALL SELECT 93 UNION ALL SELECT 94 UNION ALL
      SELECT 95 UNION ALL SELECT 96 UNION ALL SELECT 97 UNION ALL SELECT 98 UNION ALL SELECT 99 UNION ALL
      SELECT 100
    ) nums ON nums.n < f.array_length  -- 只取有效索引
  ) exploded
  -- GROUP BY字段
  GROUP BY 
    tday, client_id, event_id, order_seq, app_order_seq, 
    order_value, shipping_amount, tax_amount, currency, 
    user_email, user_phone, user_country, user_province, 
    user_city, user_address, category, price, quantity, 
    skuId, skuItemNo, spuId, title, variant
) sale_g
-- 关联order_sale子查询
LEFT JOIN (
  -- order_sale子查询（逻辑同前，调整item提取位置）
  SELECT
    tday,
    order_seq,
    SUM(sale_price_gmv) AS sale_price_gmv,
    MAX(order_value) AS order_value,
    IF(SUM(sale_price_gmv) = 0, 0, MAX(order_value) / SUM(sale_price_gmv)) AS cf
  FROM (
    SELECT
      tday,
      order_seq,
      price * quantity AS sale_price_gmv,
      order_value
    FROM (
      SELECT
        f.tday,
        JSON_UNQUOTE(JSON_EXTRACT(f.event_json, '$.orderSeq')) AS order_seq,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.price')) AS UNSIGNED) AS price,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(f.product_array, CONCAT('$[', nums.n, ']')), '$.quantity')) AS UNSIGNED) AS quantity,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(f.event_json, '$.value')) AS UNSIGNED) AS order_value
      FROM (
        SELECT
          DATE_FORMAT(CONVERT_TZ(event_time, '+00:00', '+08:00'), '%Y%m%d') as tday,
          event_data AS event_json,
          JSON_EXTRACT(p.event_data, '$.list') AS product_array,
          JSON_LENGTH(JSON_EXTRACT(p.event_data, '$.list')) AS array_length
        FROM caguuu_erp.shopline_event_record_origin p
        WHERE event_name = 'checkout_completed'
          AND DATE_FORMAT(CONVERT_TZ(event_time, '+00:00', '+08:00'), '%Y%m%d') 
              = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d')
              -- BETWEEN '20250822' and '20250824'
      ) f
      JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) nums 
        ON nums.n < f.array_length
    ) exploded_min
  ) sale_g_min
  GROUP BY tday, order_seq
) order_sale 
  ;

COMMIT;
ON sale_g.tday = order_sale.tday 
   AND sale_g.order_seq = order_sale.order_seq
