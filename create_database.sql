/* Create or Override Database */
DROP DATABASE IF EXISTS cahokia;
CREATE DATABASE cahokia;
USE cahokia;

/* Create or Overide Main Table*/
DROP TABLE IF EXISTS Q_Values;
CREATE TABLE Q_Values (
    id MEDIUMINT UNSIGNED,
    status ENUM ('QUEUED', 'GENERATED', 'FORFEITED'),
    last_requested DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id)
);

/* Create or Overide Queue Table*/
DROP TABLE IF EXISTS Queue;
CREATE TABLE Queue (
    id MEDIUMINT UNSIGNED,
    place MEDIUMINT UNSIGNED,
    PRIMARY KEY(id),
    FOREIGN KEY(id) REFERENCES Q_Values(id)
);

