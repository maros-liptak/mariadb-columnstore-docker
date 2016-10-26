FROM centos:7

# additional dependencies for docker image
RUN curl -s https://packagecloud.io/install/repositories/imeyer/runit/script.rpm.sh | bash && yum -y update && yum -y install expect perl perl-DBI openssl zlib rsyslog libaio boost file sudo libnl net-tools sysvinit-tools  perl-DBD-MySQL runit && yum clean all

# add in files to the container for install
ADD . /install

# install columnstore, you must copy mariadb-columnstore-<version>-centos7.x86_64.rpm.tar.gz into the directory
RUN tar xzf /install/mariadb-columnstore*.rpm.tar.gz -C /install && rpm -ivh /install/mariadb-columnstore*.rpm && rm -f /install/*.rpm /install/*.rpm.tar.gz && sh /install/install.sh && mkdir -p /etc/service/systemd-journald /etc/service/rsyslogd /etc/service/columnstore

# copy runit files
COPY journald.run /etc/service/systemd-journald/run
COPY rsyslogd.run /etc/service/rsyslogd/run
COPY columnstore.run /etc/service/columnstore/run
COPY runit_bootstrap /usr/sbin/runit_bootstrap

VOLUME /usr/local/mariadb/columnstore/data1
VOLUME /usr/local/mariadb/columnstore/mysql/db

EXPOSE 3306

CMD ["/usr/sbin/runit_bootstrap"]