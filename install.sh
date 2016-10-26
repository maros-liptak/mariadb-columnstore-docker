#!/bin/sh
# ensure log dir exists - otherwise postConfigure errors because rsyslogd not running yet
mkdir -p /var/log/mariadb/columnstore/

# postConfigure with inputs for standard single server install
/bin/echo -e "1\ncolumnstore-1\n1\n1\n" | /usr/local/mariadb/columnstore/bin/postConfigure

# update root user to allow external connection, need to turn off NO_AUTO_CREATE_USER. 
/usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-file=/usr/local/mariadb/columnstore/mysql/my.cnf -uroot -vvv -Bse "set sql_mode=NO_ENGINE_SUBSTITUTION;GRANT ALL ON *.* to root@'%';FLUSH PRIVILEGES;"

# shutdown server so everything in clean state for running
/usr/local/mariadb/columnstore/bin/mcsadmin shutdownsystem y

# clear alarms
/usr/local/mariadb/columnstore/bin/mcsadmin resetAlarm ALL
