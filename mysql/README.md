# Some retarded mysqld commands.

Good tutorials: [1](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7), [2](https://www.digitalocean.com/community/tutorials/a-basic-mysql-tutorial).

--------------------------------------------------------------------------------
```
SHOW DATABASES;
CREATE DATABASE database-name;
DROP DATABASE database-name;
USE database-name;
SHOW tables;
DESCRIBE potluck;
SELECT * FROM potluck;
DELETE FROM on_search WHERE search_date < NOW() - INTERVAL N DAY
```

*InnoDB is a storage engine for the database management system MySQL*

- To connect to an RDS instance use:
`mysql -h testing-rds.us-east-1.rds.amazonaws.com -u master -p -A`

A is for making the DB more responsive and quicker.

- To locate the largest application table on your DB instance, you can run a query similar to the following:
```
SELECT
    table_schema,
    table_name,
    (data_length + index_length + data_free)/1024/1024 AS total_mb,
    (data_length)/1024/1024 AS data_mb,
    (index_length)/1024/1024 AS index_mb,
    (data_free)/1024/1024 AS free_mb,
    CURDATE() AS today
FROM
    information_schema.tables
    ORDER BY 3 DESC;
```

When migrating to a newer RDS database:
Create a snapshot for rollback:
Create a schema for the new DB: `mysql -h new-host-endpoint -u master -ppassword testRDB < /usr/share/zabbix-mysql/schema.sql`
Import the needed data and drop what we don"t want: `mysqldump -h new-host-endpoint -u master -ppassword  zabbixRDB --ignore-table=zabbixRDB.history --ignore-table=zabbixRDB.history_log --ignore-table=zabbixRDB.history_text --ignore-table=zabbixRDB.history_str --ignore-table=zabbixRDB.history_uint > zabbix_migration.sql`
Import the data: mysql -h new-host-endpoint -u master -ppassword zabbixRDB < zabbix_migration.sql
-> Now you got your new empty databse without the unneeded old junk.
