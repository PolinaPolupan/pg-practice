
DROP TABLE IF EXISTS servers;

CREATE TABLE servers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    ip_address INET,
    location TEXT
);

INSERT INTO servers (name, ip_address, location) VALUES
('srv_a', '10.0.0.1', 'London'),
('srv_b', '10.0.0.2', 'Paris'),
('srv_c', '10.0.0.3', 'Berlin'),
('srv_d', '10.0.0.4', 'Rome'),
('srv_e', '10.0.0.5', 'Madrid');


SELECT pg_current_wal_insert_lsn();

UPDATE servers
SET location = 'Updated_London'
WHERE id = 1;

UPDATE servers
SET name = 'srv_b_updated'
WHERE id = 2;

DELETE FROM servers
WHERE id = 5;

SELECT * FROM servers;