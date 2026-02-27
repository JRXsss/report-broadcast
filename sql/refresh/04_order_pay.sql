START TRANSACTION;

DELETE FROM caguuu_report.order_pay
WHERE date = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d');

INSERT INTO caguuu_report.order_pay

SELECT
    DATE_FORMAT(e.date, '%Y-%m') AS month,
    DATE_FORMAT(e.date, '%Y-%v') AS week,  -- %v表示ISO周数，与原%V含义相同
    e.date,
    SUM(pv) AS pv,
    SUM(uv) AS uv,
    SUM(search_view_uv) AS search_view_uv,
    SUM(search_view_pv) AS search_view_pv,
    SUM(product_detail_uv) AS product_detail_uv,
    SUM(product_detail_pv) AS product_detail_pv,
    SUM(checkout_started_uv) AS checkout_started_uv,
    SUM(checkout_started_pv) AS checkout_started_pv,
    SUM(collection_viewed_uv) AS collection_viewed_uv,
    SUM(collection_viewed_pv) AS collection_viewed_pv,
    SUM(product_added_to_cart_uv) AS product_added_to_cart_uv,
    SUM(product_added_to_cart_pv) AS product_added_to_cart_pv,
    SUM(search_view_results_uv) AS search_view_results_uv,
    SUM(search_view_results_pv) AS search_view_results_pv,
    SUM(payment_orders) AS payment_orders,
    SUM(total_payment) AS total_payment,
    SUM(gross_sales) AS gross_sales,
    SUM(discounts) AS discounts,
    SUM(net_sales) AS net_sales,
    SUM(tax) AS tax,
    SUM(express_tax_amount) AS express_tax_amount,
    SUM(member_point_amount) AS member_point_amount,
    SUM(shipping) AS shipping,
    SUM(tips) AS tips,
    SUM(refunds) AS refunds,
    SUM(total_sales) AS total_sales,
    SUM(order_quantity) AS order_quantity,
    SUM(return_quantity) AS return_quantity,
    SUM(adjust_amount) AS adjust_amount,
    SUM(refund_adjust_amt) AS refund_adjust_amt
FROM (
    SELECT
        DATE_FORMAT(event_time, '%Y%m%d') AS date,
        COUNT(*) AS pv,
        COUNT(DISTINCT client_id) AS uv,
        COUNT(DISTINCT IF(LOWER(event_name) = 'search_view_results', client_id, NULL)) AS search_view_uv,
        COUNT(IF(LOWER(event_name) = 'search_view_results', 1, NULL)) AS search_view_pv,
        COUNT(DISTINCT IF(LOWER(event_name) = 'product_viewed', client_id, NULL)) AS product_detail_uv,
        COUNT(IF(LOWER(event_name) = 'product_viewed', 1, NULL)) AS product_detail_pv,
        COUNT(DISTINCT IF(LOWER(event_name) = 'checkout_started', client_id, NULL)) AS checkout_started_uv,
        COUNT(IF(LOWER(event_name) = 'checkout_started', 1, NULL)) AS checkout_started_pv,
        COUNT(DISTINCT IF(LOWER(event_name) = 'collection_viewed', client_id, NULL)) AS collection_viewed_uv,
        COUNT(IF(LOWER(event_name) = 'collection_viewed', 1, NULL)) AS collection_viewed_pv,
        COUNT(DISTINCT IF(LOWER(event_name) = 'product_added_to_cart', client_id, NULL)) AS product_added_to_cart_uv,
        COUNT(IF(LOWER(event_name) = 'product_added_to_cart', 1, NULL)) AS product_added_to_cart_pv,
        COUNT(DISTINCT IF(LOWER(event_name) = 'search_view_results', client_id, NULL)) AS search_view_results_uv,
        COUNT(IF(LOWER(event_name) = 'search_view_results', 1, NULL)) AS search_view_results_pv
    FROM caguuu_erp.shopline_event_record_origin
    WHERE DATE_FORMAT(event_time, '%Y%m%d') 
    -- BETWEEN '20250823' and '20250824'
    = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d')
    GROUP BY date
) e
LEFT JOIN (
--     SELECT
--         DATE_FORMAT(date_time, '%Y%m%d') AS date,
--         COUNT(DISTINCT IF(order_quantity > 0, order_seq, NULL)) AS payment_orders,
--         SUM(total_sales) / 100 AS total_payment,
--         SUM(gross_sales) / 100 AS gross_sales,
--         SUM(discounts) / 100 AS discounts,
--         SUM(net_sales) / 100 AS net_sales,
--         SUM(tax) / 100 AS tax,
--         SUM(express_tax_amount) / 100 AS express_tax_amount,
--         SUM(member_point_amount) / 100 AS member_point_amount,
--         SUM(shipping) / 100 AS shipping,
--         SUM(tips) / 100 AS tips,
--         SUM(refunds) / 100 AS refunds,
--         SUM(total_sales) / 100 AS total_sales,
--         SUM(order_quantity) AS order_quantity,
--         SUM(return_quantity) AS return_quantity,
--         SUM(adjust_amount) / 100 AS adjust_amount,
--         SUM(refund_adjust_amt) / 100 AS refund_adjust_amt
--     FROM caguuu_erp.shopline_order_statistics
--     WHERE DATE_FORMAT(date_time, '%Y%m%d') 
--     -- BETWEEN '20250823' and '20250824'
--     = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d')
--     GROUP BY date
    SELECT
        DATE_FORMAT(date_time, '%Y%m%d') AS date,
        COUNT(DISTINCT IF(order_quantity > 0, order_seq, NULL)) AS payment_orders,
        SUM(if(total_sales>0,total_sales,0)) / 100 AS total_payment,
        SUM(if(gross_sales>0,gross_sales,0)) / 100 AS gross_sales,
        SUM(discounts) / 100 AS discounts,
        SUM(if(net_sales>0,net_sales,0)) / 100 AS net_sales,
        SUM(tax) / 100 AS tax,
        SUM(express_tax_amount) / 100 AS express_tax_amount,
        SUM(member_point_amount) / 100 AS member_point_amount,
        SUM(shipping) / 100 AS shipping,
        SUM(tips) / 100 AS tips,
        SUM(refunds) / 100 AS refunds,
        SUM(if(total_sales>0,total_sales,0)) / 100 AS total_sales,
        SUM(if(order_quantity>0,order_quantity,0)) AS order_quantity,
        SUM(return_quantity) AS return_quantity,
        SUM(adjust_amount) / 100 AS adjust_amount,
        SUM(refund_adjust_amt) / 100 AS refund_adjust_amt
    FROM caguuu_erp.shopline_order_statistics
    WHERE DATE_FORMAT(date_time, '%Y%m%d') 
    -- BETWEEN '20250823' and '20250824'
    = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d')
    GROUP BY date
) o ON e.date = o.date
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

COMMIT;
