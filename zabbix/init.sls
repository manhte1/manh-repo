#SLS to install and configure Zabbix release 3.0.1
#By Apvera manh.nguyen
#Pls set DB information in 'mysql.sls', and linked 'files/zabbix_server.conf.jinja'
{% from "zabbix/mysql.sls" import db_name,mysql_root_password with context %}
#---Set DB info ---#
#Pls set in mysql.sls
#---Set DB info ---#
#Default Username/password to login Zabbix Potal Page: admin/zabbix ###

include:
  - zabbix.mysql
{% set zabbix_deb_filename = 'zabbix-release_3.0-1+trusty_all.deb'  %}
#Install Zabbix-Repo
copy_zabbix_deb:
  file.managed:
    - name: /tmp/{{ zabbix_deb_filename }}
    - source: salt://zabbix/files/{{ zabbix_deb_filename }}
    - makedirs: True
    - enless: /tmp/{{ zabbix_deb_filename }}     #Check if Exitsting
install_zabbix_repo:
  cmd.run:
   - name: dpkg -i /tmp/{{ zabbix_deb_filename }}
   - require:
      - file: copy_zabbix_deb
update_zabbix_repo:
  cmd.run:
    - name: apt-get update
    - require:
      - cmd: install_zabbix_repo
    - require_in:
      - pkg: zabbix-server-mysql
      - pkg: zabbix-frontend-php
#Install Zabbix-package
zabbix-server-mysql:
  pkg.installed
zabbix-frontend-php:
  pkg.installed
php5-mysql:
  pkg.installed

#Copy Zabbix Configuration
/etc/zabbix/zabbix_server.conf:
  file.managed:
    - name: /etc/zabbix/zabbix_server.conf
    - source: salt://zabbix/files/zabbix_server.conf.jinja
    - template: jinja
    - makedirs: True
/etc/php5/apache2/php.ini:
  file.managed:
    - name: /etc/php5/apache2/php.ini
    - source: salt://zabbix/files/php.ini.jinja
    - template: jinja
    - makedirs: True
restart_zabbix-server:
  service.running:
    - name: zabbix-server
    - enable: True
    - reload: True
    - watch:
       - file: /etc/zabbix/zabbix_server.conf
#----------------Set virtual host apache2--------------------#
#----Set site INFO here------#
{% set site_name = 'zabbix' %}
{% set ServerAdmin = 'apveraadmin@apvera.com' %}
{% set ServerName = 'localhost' %}
{% set ServerAlias = 'localhost' %}
{% set DocumentRoot = '/usr/share/zabbix' %}
#----Set site INFO here------#
/etc/apache2/sites-available/{{ site_name }}.conf:
  file.managed:
    - name: /etc/apache2/sites-available/{{ site_name }}.conf
    - contents: |
        ServerName localhost
        <VirtualHost *:80>
            ServerAdmin {{ ServerAdmin }}
            ServerName {{ ServerName }}
            ServerAlias {{ ServerAlias }}
            DocumentRoot {{ DocumentRoot }}
            ErrorLog ${APACHE_LOG_DIR}/error.log
            CustomLog ${APACHE_LOG_DIR}/access.log combined
         </VirtualHost>
    - makedirs: True
    - show_diff: True

#Set site available as default
/etc/apache2/conf-available/fqdn.conf:
  file.managed:
    - name: /etc/apache2/conf-available/fqdn.conf
    - contents: |
        ServerName localhost
    - makedirs: True
    - show_diff: True

a2enconf:
  cmd.run:
    - name: a2enconf fqdn

delete_000-default.conf:
  file.absent:
    - name: /etc/apache2/sites-available/000-default.conf
#Run command to apply VirtualHost
{{ site_name }}_virtual_host:
  cmd.run:
    - name: a2ensite {{ site_name }}.conf
restart_apache:
  service.running:
    - name: apache2
    - enable: True
    - reload: True
    - watch:
       - cmd: {{ site_name }}_virtual_host
#----------------Set virtual host apache2--------------------#

#----------------Restore initial DB to access frontend--------------------#
restore_zabbixcreate:
  cmd.run:
    - name: mysql -u root -p{{ mysql_root_password }} {{ db_name }} < /tmp/create.sql
    - require:
      - cmd: create.sql
  service.running:
   - name: mysql

create.zip:
  file.managed:
    - name: /tmp/create.zip
    - source: salt://zabbix/files/create.zip
create.sql:
  cmd.run:
    - name: unzip /tmp/create.zip -d /tmp
    - require:
      - file: create.zip
      - pkg: unzip
    - onlyif: 'test ! -e /tmp/create.sql' #Run if has not exits create.sql yet
unzip:
  pkg.installed

#----------------Restore initial DB to access frontend-#-end---------------#

restart_apache2:
  service.running:
    - name: apache2
    - enable: True
    - reload: True
