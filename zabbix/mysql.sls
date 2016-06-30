#SLS to install mysql-server with creating a database
#By Apvera manh.nguyen
#---Pls set INFO here---#
{% set mysql_root_password = 'apveraadmin' %}
{% set db_name = 'zabbix_db' %}
{% set db_username = 'zabbixadmin' %}
{% set db_passwd = 'apveraadmin' %}
#---Pls set INFO here---#

#dependencies
debconf-utils:
  pkg.installed
python-mysqldb:
  pkg.installed

#define root_password for mysql-server
mysql_setup:
  debconf.set:
    - name: mysql-server
    - data:
        'mysql-server/root_password': {'type': 'string', 'value': '{{ mysql_root_password }}'}
        'mysql-server/root_password_again': {'type': 'string', 'value': '{{ mysql_root_password }}'}
    - require:
      - pkg: debconf-utils

mysql-server:
  pkg:
    - installed
    - require:
      - debconf: mysql_setup
      - pkg: python-mysqldb
  service.running:
    - name: mysql
    - enable: True

mysql:
  service.running:
    - watch:
      - pkg: mysql-server

#Create DB and grant to user
{{ db_name }}:
  mysql_database:
    - present
    - name: {{ db_name }}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ mysql_root_password }}
    - connection_charset: utf8
    - connection_collate: utf8_general_ci
  mysql_grants:
    - present
    - grant: all privileges
    - database: {{ db_name }}.*
    - user: {{ db_username }}
    - host: 'localhost'
    - connection_user: root
    - connection_pass: {{ mysql_root_password }}
    - require:
      - mysql_database: {{ db_name }}
  mysql_user:
    - present
    - name: {{ db_username }}
    - password: {{ db_passwd }}
    - host: 'localhost'
    - connection_user: root
    - connection_pass: {{ mysql_root_password }}
    - require:
      - mysql_grants: {{ db_name }}
