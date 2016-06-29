{% set pg_version = '9.4'  %}
{% set saltfolder_pg_master = 'postgresql/postgres-master'  %}
{% set saltfolder_pg_slave = 'postgresql/postgres-slave'  %}
{% set ip_pg_master = '192.168.2.153'  %}
{% set ip_pg_slave = salt['network.interfaces']()['eth0']['inet'][0]['address'] %}
