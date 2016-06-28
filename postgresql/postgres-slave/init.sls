{% from "postgresql/postgres-slave/slave-map.jinja" import pg_version, saltfolder_pg_master, saltfolder_pg_slave, ip_pg_master, ip_pg_slave with context %}
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
#Install Postgresql
install-postgresql:
  pkg.installed:
    - name: postgresql-{{ pg_version }}
    - refresh: False

install-postgresql-client:
  pkg.installed:
    - name: postgresql-client-{{ pg_version }}
    - refresh: False

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
#-----------Install Postgres -------------------------------end#

#SSH key copy
#Generate SSH key for postgres user
/var/lib/postgresql/.ssh/authorized_keys:
  file.managed:
    - name: /var/lib/postgresql/.ssh/authorized_keys
    - source: salt://{{ saltfolder_pg_master }}/files/id_rsa.pub
    - user: postgres


#PG_HBA.CONF and POSTGRESQL.CONF
/etc/postgresql/{{ pg_version }}/main/postgresql.conf:
  file.managed:
    - name: /etc/postgresql/{{ pg_version }}/main/postgresql.conf
    - source: salt://{{ saltfolder_pg_slave }}/files/postgresql.conf.slave.jinja
    - template: jinja
    - show_changes: True
    - watch_in:
       - service: run-postgresql


/etc/postgresql/{{ pg_version }}/main/pg_hba.conf:
  file.managed:
    - name: /etc/postgresql/{{ pg_version }}/main/pg_hba.conf
    - source: salt://{{ saltfolder_pg_slave }}/files/pg_hba.conf.slave.jinja
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - pkg: install-postgresql
    - watch_in:
      - service: run-postgresql

/var/lib/postgresql/{{ pg_version }}/main/recovery.conf:
  file.managed:
    - name: /var/lib/postgresql/{{ pg_version }}/main/recovery.conf
    - source: salt://{{ saltfolder_pg_slave }}/files/recovery.conf.jinja
    - template: jinja
    - user: postgres
    - group: postgres
    - require:
      - pkg: install-postgresql
    - watch_in:
      - service: run-postgresql
