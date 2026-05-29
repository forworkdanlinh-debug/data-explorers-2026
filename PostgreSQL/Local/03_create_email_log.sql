SELECT 'email_log' AS table_name, COUNT(*) FROM tnbike.email_log
UNION ALL
SELECT 'sales_order', COUNT(*) FROM tnbike.sales_order
UNION ALL
SELECT 'order_line', COUNT(*) FROM tnbike.order_line
UNION ALL
SELECT 'processing_error_log', COUNT(*) FROM tnbike.processing_error_log
UNION ALL
SELECT 'stg_email_log', COUNT(*) FROM tnbike.stg_email_log
UNION ALL
SELECT 'stg_orders', COUNT(*) FROM tnbike.stg_orders
UNION ALL
SELECT 'stg_order_lines', COUNT(*) FROM tnbike.stg_order_lines
UNION ALL
SELECT 'stg_error_log', COUNT(*) FROM tnbike.stg_error_log;