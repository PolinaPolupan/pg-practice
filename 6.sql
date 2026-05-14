ALTER TABLE dpc ENABLE ROW LEVEL SECURITY;

CREATE POLICY admin_dpc_policy
ON dpc
FOR ALL
TO administrator
USING (id_dpc = current_setting('app.current_dpc')::int);

SET app.current_dpc = '1';
SELECT * FROM dpc;

SELECT
    d.id_dpc,
    d.address,
    SUM(c.total_amount) AS total_income
FROM dpc d
JOIN employees_in_dpc ed ON ed.id_dpc = d.id_dpc
JOIN employee e ON e.id_employee = ed.id_employee
JOIN client cl ON cl.id_employee = e.id_employee
JOIN check_of_purchase c ON c.id_client = cl.id_client
GROUP BY d.id_dpc, d.address;

SELECT
    s.name,
    SUM(cfs.price * cfs.services_quantity) AS income
FROM service s
JOIN services_in_dpc sid ON sid.id_service = s.id_service
JOIN check_for_services cfs ON cfs.id_service = s.id_service
GROUP BY s.name
ORDER BY income DESC;


SELECT
    srv.name,
    SUM(cfs.price * cfs.servers_quantity) AS income
FROM server srv
JOIN servers_in_dpc sid ON sid.id_server = srv.id_server
JOIN check_for_servers cfs ON cfs.id_server = srv.id_server
GROUP BY srv.name
ORDER BY income DESC;

--транзакция 1
BEGIN;
--первое чтение данных
SELECT s.name, c.cores_num, r.memory_quantity FROM server s
    LEFT JOIN cpu c ON s.id_cpu = c.id_cpu
    LEFT JOIN rom r ON s.id_rom = r.id_rom
    WHERE s.id_server = 1 AND s.price > 1000;
--другая транзакция изменяет данные и завершается
--второе чтение данных
SELECT s.name, c.cores_num, r.memory_quantity FROM server s
    LEFT JOIN cpu c ON s.id_cpu = c.id_cpu
    LEFT JOIN rom r ON s.id_rom = r.id_rom
    WHERE s.id_server = 1 AND s.price > 1000;
COMMIT;

--транзакция 2
BEGIN;
--обновляем данные о сервере и комплектующих (заменили виды комплектующих новыми)
UPDATE server SET price = 1500 WHERE id_server = 1;
UPDATE cpu SET cores_num = cores_num + 2 WHERE id_cpu = (SELECT id_cpu FROM server WHERE id_server = 1);
UPDATE rom SET memory_quantity = memory_quantity + 500 WHERE id_rom = (SELECT id_rom FROM server WHERE id_server = 1);
COMMIT;



--транзакция 1
BEGIN;
--первое чтение данных
SELECT * FROM employee
    RIGHT JOIN employees_in_dpc eid on employee.id_employee = eid.id_employee
    WHERE eid.id_dpc = 5;
--вторая транзакция удаляет строки из таблиц и завершается
--второе чтение данных
SELECT * FROM employee
    RIGHT JOIN employees_in_dpc eid on employee.id_employee = eid.id_employee
    WHERE eid.id_dpc = 5;
--третья транзакция добваляет строку и завершается
--третье чтение данных
SELECT * FROM employee
    RIGHT JOIN employees_in_dpc eid on employee.id_employee = eid.id_employee
         WHERE eid.id_dpc = 5;
COMMIT;

--транзакция 2
BEGIN;
--уволился работник
UPDATE dpc SET num_of_employees = num_of_employees – 1 WHERE id_dpc IN (SELECT id_dpc FROM employees_in_dpc WHERE id_employee = 31)
DELETE FROM employees_in_dpc WHERE id_employee = 31;
DELETE FROM employee WHERE id_employee = 31;
COMMIT;

--транзакция 3
BEGIN;
--другой работник взял его ставку
INSERT INTO employees_in_dpc (id_dpc, id_employee) VALUES (5,30);
COMMIT;

--транзакция 1
BEGIN;
--выполняется 1-ой
UPDATE server SET price = price + 500 WHERE id_server = 1;
--выполняется 3-ей
UPDATE server SET price = price + 1000 WHERE id_server = 2;
COMMIT;

--транзакция 2
BEGIN;
--выполняется 2-ой
UPDATE server SET price = price + 500 WHERE id_server = 2;
--выполняется 4-ой
UPDATE server SET price = price + 1000 WHERE id_server = 1;
COMMIT;

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- блокируем клиента, чтобы избежать гонок
SELECT num_of_bonuses
FROM client
WHERE id_client = 1
FOR UPDATE;

-- начисление бонуса (пример: +10)
UPDATE client
SET num_of_bonuses = num_of_bonuses + 10
WHERE id_client = 1;

COMMIT;

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- проверка: не начисляли ли уже бонус за конкретный чек/событие
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM bonus_log
        WHERE id_client = 1 AND id_check = 100
    ) THEN

        UPDATE client
        SET num_of_bonuses = num_of_bonuses + 10
        WHERE id_client = 1;

        INSERT INTO bonus_log(id_client, id_check)
        VALUES (1, 100);
    END IF;
END $$;

COMMIT;

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

UPDATE client
SET num_of_bonuses = num_of_bonuses + 10
WHERE id_client = 1;

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

UPDATE client
SET num_of_bonuses = num_of_bonuses + 10
WHERE id_client = 1;


SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;

SELECT COUNT(*) FROM client;


CREATE TEMP TABLE temp_purchases AS
SELECT *
FROM check_of_purchase
WHERE date_of_purchase BETWEEN '2026-01-01' AND '2026-01-31';

SELECT *
FROM pg_catalog.pg_tables
WHERE tablename = 'temp_purchases';