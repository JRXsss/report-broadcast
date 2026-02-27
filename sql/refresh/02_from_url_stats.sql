START TRANSACTION;

DELETE FROM caguuu_report.from_url_stats
WHERE date = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d');

INSERT INTO caguuu_report.from_url_stats
SELECT
  fs.date,
  fs.channel_category,              -- 归因渠道大类
  fs.terminal,                      -- 终端类型
  fs.url_from,                      -- 归因域名
  fs.referer,                       -- 原始referer
  COUNT(DISTINCT fs.client_id) AS uv,                        -- 总 UV
  COUNT(DISTINCT IF(e.event_name = 'page_viewed', e.client_id, NULL)) AS page_viewed_uv,
  COUNT(DISTINCT IF(e.event_name = 'product_viewed', e.client_id, NULL)) AS product_viewed_uv,
  COUNT(DISTINCT IF(e.event_name = 'collection_viewed', e.client_id, NULL)) AS collection_viewed_uv,
  COUNT(DISTINCT IF(e.event_name = 'search_view_results', e.client_id, NULL)) AS search_view_results_uv,
  COUNT(DISTINCT IF(e.event_name = 'checkout_started', e.client_id, NULL)) AS checkout_started_uv,
  COUNT(DISTINCT IF(e.event_name = 'product_added_to_cart', e.client_id, NULL)) AS product_added_to_cart_uv,
  COUNT(DISTINCT IF(e.event_name = 'checkout_completed', e.client_id, NULL)) AS checkout_completed_uv
FROM (
  -- 只保留每个用户的首次来源
  SELECT
    client_id,
    date,
    domain AS url_from,
    referer,                       -- 新增referer字段
    channel_category,
    terminal
  FROM (
    -- 提取首次点击信息（用变量模拟ROW_NUMBER()，兼容MySQL 5.7）
    SELECT
      t.client_id,
      t.date,
      t.domain,
      t.referer,                   -- 新增referer字段
      t.channel_category,
      t.terminal,
      -- 用变量标记每个用户的首次记录（1为首次）
      @row_num := IF(@prev_client = t.client_id, @row_num + 1, 1) AS rn,
      @prev_client := t.client_id  -- 记录上一个client_id用于对比
    FROM (
      -- 内层子查询：先按client_id和event_time排序，确保顺序正确
      SELECT
        client_id,
        DATE(event_time) AS date,  -- 日期维度
        -- 域名提取逻辑
        CASE 
          WHEN referer IS NULL OR referer = '' THEN 'Direct'
          WHEN referer REGEXP '(^|\\.|m\\.|l\\.)google\\.' THEN 'google'
          WHEN referer REGEXP '(^|\\.)caguuu\\.' THEN 'caguuu'
          WHEN referer REGEXP '(^|\\.|m\\.)facebook\\.' THEN 'facebook'
          WHEN referer REGEXP '(^|\\.|l\\.)instagram\\.' THEN 'instagram'
          WHEN referer REGEXP '(^|\\.)twitter\\.' THEN 'twitter'
          WHEN referer REGEXP '(^|\\.)linkedin\\.' THEN 'linkedin'
          WHEN referer REGEXP '(^|\\.)weibo\\.' THEN 'weibo'
          WHEN referer REGEXP '^android-app://' THEN SUBSTRING_INDEX(referer, '://', -1)
          WHEN referer REGEXP 'googlesyndication' THEN 'googlesyndication'
          ELSE 
            SUBSTRING_INDEX(
              CASE 
                WHEN SUBSTRING_INDEX(IF(referer REGEXP '^https?://', SUBSTRING_INDEX(referer, '://', -1), referer), '/', 1) 
                     REGEXP '\\.(co\\.uk|com\\.hk|gov\\.cn|org\\.cn)$' 
                THEN SUBSTRING_INDEX(SUBSTRING_INDEX(IF(referer REGEXP '^https?://', SUBSTRING_INDEX(referer, '://', -1), referer), '/', 1), '.', -3)
                ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(IF(referer REGEXP '^https?://', SUBSTRING_INDEX(referer, '://', -1), referer), '/', 1), '.', -2)
              END,
              '.', 1
            )
        END AS domain,
        referer,   -- 新增referer字段
        -- 渠道分类逻辑
        CASE 
          WHEN referer IS NULL OR referer = '' THEN '直接访问'
          WHEN referer REGEXP 'caguuu|xn--caguuu-' THEN '直接访问'
          WHEN referer REGEXP 'googlesyndication' THEN '付费渠道'
          WHEN referer REGEXP 'google|bing|baidu|yahoo' THEN '自然搜索'
          WHEN referer REGEXP 'facebook|instagram|twitter|linkedin|weibo|youtube|tiktok' THEN '媒体'
          ELSE '其他' 
        END AS channel_category,
        -- 终端分类逻辑
        CASE 
          WHEN referer REGEXP 'm\\.' THEN '移动端'
          WHEN referer REGEXP 'app|android-app://' THEN 'APP'
          ELSE 'WEB' 
        END AS terminal,
        event_time  -- 用于排序
      FROM
        caguuu_erp.shopline_event_record_origin
         WHERE DATE_FORMAT(event_time, '%Y%m%d') = 
         DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d')
      ORDER BY
        client_id,  -- 按用户分组排序
        event_time  -- 按时间升序，确保最早的记录在前面
    ) t,
    -- 初始化变量（MySQL 5.7需在子查询中初始化）
    (SELECT @row_num := 0, @prev_client := '') AS init
  ) first_click
  WHERE rn = 1  -- 保留每个用户的首次记录
    -- AND LOWER(domain) <> 'caguuu'  -- 可选：排除自身域名
) fs
-- 关联原表统计事件
LEFT JOIN caguuu_erp.shopline_event_record_origin e
  ON fs.client_id = e.client_id
   WHERE DATE_FORMAT(event_time, '%Y%m%d') = 
         DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '%Y%m%d')
GROUP BY
  fs.date,
  fs.channel_category, 
  fs.terminal, 
  fs.url_from,
  fs.referer
ORDER BY
  fs.date DESC,
  uv DESC;
