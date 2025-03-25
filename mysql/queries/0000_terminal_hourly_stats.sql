WITH hourly_stats AS (
  SELECT 
    DATE_FORMAT(event_created, '%Y-%m-%d %H:00:00') as hour,
    JSON_UNQUOTE(JSON_EXTRACT(event_payload, '$.terminal')) as terminal,
    count(*) as event_count
  FROM order_events
  WHERE 
    event_created >= '2024-01-01' and event_created < '2024-02-01'
    AND event_type IN ('Created', 'Departed', 'Delivered')
  GROUP BY hour, terminal
)
SELECT 
  hour,
  terminal,
  event_count,
  AVG(event_count) OVER (
    PARTITION BY terminal 
    ORDER BY hour
    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
  ) as moving_avg_events
FROM hourly_stats
WHERE terminal IN ('Berlin', 'Hamburg', 'Munich')
ORDER BY terminal, hour;
