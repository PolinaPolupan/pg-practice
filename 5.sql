-- серверы
SELECT s.name, COUNT(*) AS usage_count
FROM check_for_servers cfs
JOIN server s ON s.id_server = cfs.id_server
GROUP BY s.name
ORDER BY usage_count DESC
LIMIT 1;

-- услуги
SELECT s.name, COUNT(*) AS usage_count
FROM check_for_services cfs
JOIN service s ON s.id_service = cfs.id_service
GROUP BY s.name
ORDER BY usage_count DESC
LIMIT 1;

WITH popular_server AS (
    SELECT id_server
    FROM check_for_servers
    GROUP BY id_server
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT c.full_name, COUNT(*) AS cnt
FROM check_for_servers cfs
JOIN check_of_purchase cp ON cp.id_check = cfs.id_check
JOIN client c ON c.id_client = cp.id_client
WHERE cfs.id_server = (SELECT id_server FROM popular_server)
GROUP BY c.full_name
ORDER BY cnt DESC;

WITH popular_service AS (
    SELECT id_service
    FROM check_for_services
    GROUP BY id_service
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT c.full_name, COUNT(*) AS cnt
FROM check_for_services cfs
JOIN check_of_purchase cp ON cp.id_check = cfs.id_check
JOIN client c ON c.id_client = cp.id_client
WHERE cfs.id_service = (SELECT id_service FROM popular_service)
GROUP BY c.full_name
ORDER BY cnt DESC;


WITH top_client AS (
    SELECT id_client
    FROM client
    ORDER BY money_spent DESC
    LIMIT 1
)
SELECT s.name, COUNT(*) AS cnt
FROM check_for_servers cfs
JOIN check_of_purchase cp ON cp.id_check = cfs.id_check
JOIN server s ON s.id_server = cfs.id_server
WHERE cp.id_client = (SELECT id_client FROM top_client)
GROUP BY s.name
ORDER BY cnt DESC;

WITH top_client AS (
    SELECT id_client
    FROM client
    ORDER BY money_spent DESC
    LIMIT 1
)
SELECT s.name, COUNT(*) AS cnt
FROM check_for_services cfs
JOIN check_of_purchase cp ON cp.id_check = cfs.id_check
JOIN service s ON s.id_service = cfs.id_service
WHERE cp.id_client = (SELECT id_client FROM top_client)
GROUP BY s.name
ORDER BY cnt DESC;

-- доход от серверов
SELECT SUM(price * servers_quantity) AS total_servers_income
FROM check_for_servers;

-- доход от услуг
SELECT SUM(price * services_quantity) AS total_services_income
FROM check_for_services;