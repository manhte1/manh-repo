##{% from "postgresql/postgres-master/master-map.sls import pg_version, saltfolder_pg_master, saltfolder_pg_slave, ip_pg_master, ip_pg_slave with context %}
{% set pg_version = '9.4'  %}
{% set saltfolder_pg_master = 'postgresql/postgres-master'  %}
{% set saltfolder_pg_slave = 'postgresql/postgres-slave'  %}
{% set ip_pg_master = '10.1.1.141'  %}
{% set ip_pg_slave_1 = '10.1.2.89'  %}
{% set ip_pg_slave_2 = '10.1.2.90'  %}
