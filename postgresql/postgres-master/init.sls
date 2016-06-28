{% from "postgresql/postgres-master/master-map.jinja" import pg_version, saltfolder_pg_master, saltfolder_pg_slave, ip_pg_master, ip_pg_slave with context %}
#PostgreSQL Repository
install-postgresql-repo:
  pkgrepo.managed:
    - humanname: PostgreSQL Official Repository
    - name: deb http://apt.postgresql.org/pub/repos/apt trusty-pgdg main {{ pg_version }}
    - keyid: B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
    - keyserver: keyserver.ubuntu.com
    - file: /etc/apt/sources.list.d/pgdg.list
    - require_in:
      - pkg: install-postgresql
#Make Dir
#/etc/postgresql/{{ pg_version }}/main:
#  file.directory:
#    - makedirs: True

#-----------Install Postgres -------------------------------start#
install-postgresql:
  pkg.installed:
    - name: postgresql-{{ pg_version }}
    - refresh: False

install-postgresql-client:
  pkg.installed:
    - name: postgresql-client-{{ pg_version }}
    - refresh: False

#Create-postgresql-cluster
create-postgresql-cluster:
  cmd.run:
    - cwd: /
    - user: root
    - name: pg_createcluster {{ pg_version }} main --start
    - unless: test -f /etc/postgresql/{{ pg_version }}/main/postgresql.conf
    - env:
      LC_ALL: C.UTF-8

postgresql-initdb:
  cmd.run:
    - cwd: /
    - user: root
    - name: service postgresql initdb
    - unless: test -f /etc/postgresql/{{ pg_version }}/main/postgresql.conf
    - env:
      LC_ALL: C.UTF-8

run-postgresql:
  service.running:
    - enable: true
    - name: postgresql
    - require:
      - pkg: install-postgresql

#Install postgresql-contrib
install-postgres-contrib:
  pkg.installed:
    - name: postgresql-contrib-{{ pg_version }}


#PG_HBA.CONF and POSTGRESQL.CONF
/etc/postgresql/{{ pg_version }}/main/postgresql.conf:
  file.managed:
    - name: /etc/postgresql/{{ pg_version }}/main/postgresql.conf
    - source: salt://{{ saltfolder_pg_master }}/files/postgresql.conf.master.jinja
    - template: jinja
    - show_changes: True
    - watch_in:
       - service: run-postgresql


/etc/postgresql/{{ pg_version }}/main/pg_hba.conf:
  file.managed:
    - name: /etc/postgresql/{{ pg_version }}/main/pg_hba.conf
    - source: salt://{{ saltfolder_pg_master }}/files/pg_hba.conf.master.jinja
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - pkg: install-postgresql
    - watch_in:
      - service: run-postgresql
#-----------Install Postgres -------------------------------end#

#-----------Copy SSH key for replication -------------------start#

/var/lib/postgresql/.ssh:
  file.directory:
    - name: /var/lib/postgresql/.ssh
    - makedir: True
    - user: postgres

/var/lib/postgresql/.ssh/id_rsa:
  file.managed:
    - name: /var/lib/postgresql/.ssh/id_rsa
    - source: salt://{{ saltfolder_pg_master }}/files/id_rsa
    - user: postgres
    - mode: 600

/var/lib/postgresql/.ssh/id_rsa.pub:
  file.managed:
    - name: /var/lib/postgresql/.ssh/id_rsa.pub
    - source: salt://{{ saltfolder_pg_master }}/files/id_rsa.pub
    - user: postgres

/var/lib/postgresql/.ssh/authorized_keys:
  file.managed:
    - name: /var/lib/postgresql/.ssh/authorized_keys
    - source: salt://{{ saltfolder_pg_master }}/files/id_rsa.pub
    - user: postgres

/var/lib/postgresql/.ssh/known_hosts:
  file.managed:
    - name: /var/lib/postgresql/.ssh/known_hosts
    - source: salt://{{ saltfolder_pg_master }}/files/known_hosts.jinja
    - template: jinja
    - create: True
#-----------Copy SSH key for replication -------------------start#


#Set password for replication:
set_replication_password:
  cmd.run:
    - user: postgres
    - name: psql -c "ALTER USER postgres REPLICATION LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD 'apveraadmin';"
#initial_backup_db
pg_start_backup:
  cmd.run:
    - user: postgres
    - name: psql -c "select pg_start_backup('initial_backup');"
    - require:
      - service: postgresql

#-----------1st sync to SLAVE1 -------------------#
rsync_db_1:
  cmd.run:
    - user: postgres
    - name: rsync -cva --inplace --exclude=*pg_xlog* /var/lib/postgresql/{{ pg_version }}/main/ {{ ip_pg_slave_1 }}:/var/lib/postgresql/{{ pg_version }}/main/
    - require:
      - service: postgresql
#-----------1st sync to SLAVE2 -------------------#
rsync_db_2:
  cmd.run:
    - user: postgres
    - name: rsync -cva --inplace --exclude=*pg_xlog* /var/lib/postgresql/{{ pg_version }}/main/ {{ ip_pg_slave_2 }}:/var/lib/postgresql/{{ pg_version }}/main/
    - require:
      - service: postgresql
      - cmd: rsync_db_1

pg_stop_backup:
  cmd.run:
    - user: postgres
    - name: psql -c "select pg_stop_backup();"
    - require:
      - service: postgresql
      - cmd: rsync_db_2
