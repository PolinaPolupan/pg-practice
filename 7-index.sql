

/*
Удаляем бесполезные hash-индексы,
дублирующие PRIMARY KEY или UNIQUE.
B-tree уже существует автоматически.
*/

DROP INDEX IF EXISTS index_id_cell;
DROP INDEX IF EXISTS index_id_rack;
DROP INDEX IF EXISTS index_id_rom;
DROP INDEX IF EXISTS index_addr;


/*
Удаляем hash-индексы,
которые лучше заменить на B-tree.
*/

DROP INDEX IF EXISTS index_id_dpc_from_cfser;
DROP INDEX IF EXISTS index_id_dpc_from_cfserc;

DROP INDEX IF EXISTS index_price_srvr;
DROP INDEX IF EXISTS index_price_srvi;

DROP INDEX IF EXISTS index_f_name_cli;
DROP INDEX IF EXISTS index_f_name_emp;

DROP INDEX IF EXISTS index_model_name;

DROP INDEX IF EXISTS index_name;
DROP INDEX IF EXISTS index_name_srvi;
DROP INDEX IF EXISTS index_name_stat;


/*
Создаем нормальные B-tree индексы.
Они универсальнее hash:
- работают для =
- работают для < > BETWEEN
- поддерживают ORDER BY
*/

CREATE INDEX idx_cfser_dpc
ON check_for_servers(id_dpc);

CREATE INDEX idx_cfserv_dpc
ON check_for_services(id_dpc);

CREATE INDEX idx_cfser_price
ON check_for_servers(price);

CREATE INDEX idx_cfserv_price
ON check_for_services(price);

CREATE INDEX idx_client_full_name
ON client(full_name);

CREATE INDEX idx_employee_full_name
ON employee(full_name);

CREATE INDEX idx_cpu_model_name
ON cpu(model_name);

CREATE INDEX idx_server_name
ON server(name);

CREATE INDEX idx_service_name
ON service(name);

CREATE INDEX idx_status_name
ON status(name);


/*
Индексы для foreign key.
Ускоряют JOIN,
DELETE/UPDATE родительских строк,
а также политики RLS.
*/

CREATE INDEX idx_check_purchase_client
ON check_of_purchase(id_client);

CREATE INDEX idx_client_employee
ON client(id_employee);

CREATE INDEX idx_client_status
ON client(id_status);

CREATE INDEX idx_rentalcell_client
ON rentalcell(id_client);

CREATE INDEX idx_rentalcell_rack
ON rentalcell(id_rack);

CREATE INDEX idx_rentalrack_dpc
ON rentalrack(id_dpc);

CREATE INDEX idx_servers_in_dpc_server
ON servers_in_dpc(id_server);

CREATE INDEX idx_services_in_dpc_service
ON services_in_dpc(id_service);

CREATE INDEX idx_check_for_servers_check
ON check_for_servers(id_check);

CREATE INDEX idx_check_for_services_check
ON check_for_services(id_check);


ANALYZE;