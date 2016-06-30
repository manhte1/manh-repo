1. Enter manual IP_of_master and IP_of_slaves in pg_map.sls
2. Run SLS postgres-slave
3. Run SLS postgres-master
4. Manual Connect to postgres master, switch to postgres user by "su - postgres"
   ssh [ip-of-slave]
   => For generate known_hosts
5. Run SLS rsync

Refer: Test replication:
- Master:
    su - postgres
    plsql
    CREATE TABLE rep_test (test varchar(40));
    INSERT INTO rep_test VALUES ('data one');
    INSERT INTO rep_test VALUES ('some more words');
    INSERT INTO rep_test VALUES ('lalala');
    INSERT INTO rep_test VALUES ('hello there');
    INSERT INTO rep_test VALUES ('blahblah');
    \q


- Slave:
    su - postgres
    plsql
    SELECT * FROM rep_test;
    => See table
    INSERT INTO rep_test VALUES ('oops');
    => ERROR:  cannot execute INSERT in a read-only transaction
