{% import 'postgresql/postgres-master/master-map.sls' as master with context %}


#Set password for replication:
set_replication_password:
  cmd.run:
    - user: postgres
    - name: psql -c "ALTER USER postgres REPLICATION LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD 'apveraadmin';"
    - require:
      - service: postgresql

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
    - name: rsync -cva --inplace --exclude=*pg_xlog* /var/lib/postgresql/{{ master.pg_version }}/main/ {{ master.ip_pg_slave_1 }}:/var/lib/postgresql/{{ master.pg_version }}/main/
#    - require:
#      - service: postgresql
#-----------1st sync to SLAVE2 -------------------#
rsync_db_2:
  cmd.run:
    - user: postgres
    - name: rsync -cva --inplace --exclude=*pg_xlog* /var/lib/postgresql/{{ master.pg_version }}/main/ {{ master.ip_pg_slave_2 }}:/var/lib/postgresql/{{ master.pg_version }}/main/
#    - require:
#      - service: postgresql
#      - cmd: rsync_db_1

pg_stop_backup:
  cmd.run:
    - user: postgres
    - name: psql -c "select pg_stop_backup();"
    - require:
      - service: postgresql
#      - cmd: rsync_db_2
