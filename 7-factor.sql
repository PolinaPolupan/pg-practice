
/*
Таблицы с частыми UPDATE:
- client
- servers_in_dpc
- rentalrack
- rentalcell

Для них уменьшаем fillfactor,
чтобы оставить свободное место
на страницах для HOT-update.
*/

ALTER TABLE client
SET (fillfactor = 75);

ALTER TABLE servers_in_dpc
SET (fillfactor = 80);

ALTER TABLE rentalrack
SET (fillfactor = 80);

ALTER TABLE rentalcell
SET (fillfactor = 80);


/*
Таблицы со смешанной нагрузкой:
INSERT + редкие UPDATE.
*/

ALTER TABLE check_of_purchase
SET (fillfactor = 90);

ALTER TABLE check_for_servers
SET (fillfactor = 90);

ALTER TABLE check_for_services
SET (fillfactor = 90);

ALTER TABLE employees_in_dpc
SET (fillfactor = 90);

ALTER TABLE services_in_dpc
SET (fillfactor = 90);


/*
Справочные таблицы.
Почти не обновляются.
Максимальная плотность хранения.
*/

ALTER TABLE cpu
SET (fillfactor = 100);

ALTER TABLE ram
SET (fillfactor = 100);

ALTER TABLE rom
SET (fillfactor = 100);

ALTER TABLE service
SET (fillfactor = 100);

ALTER TABLE status
SET (fillfactor = 100);

ALTER TABLE dpc
SET (fillfactor = 95);

ALTER TABLE employee
SET (fillfactor = 95);

ALTER TABLE server
SET (fillfactor = 95);


/*
Показывает:
- обычные UPDATE
- HOT UPDATE
*/

SELECT
    relname,
    n_tup_upd,
    n_tup_hot_upd
FROM pg_stat_user_tables
ORDER BY n_tup_upd DESC;


/*
Показывает использование индексов.
Если idx_scan = 0,
индекс может быть бесполезным.
*/

SELECT
    schemaname,
    relname,
    indexrelname,
    idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan;


/*
Размер таблиц.
*/

SELECT
    relname,
    pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;