SELECT processing_status, COUNT(*)
FROM tnbike.email_log
GROUP BY processing_status;