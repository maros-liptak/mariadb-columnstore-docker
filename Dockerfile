FROM centos:7

# add runit repo
RUN curl -s https://packagecloud.io/install/repositories/imeyer/runit/script.rpm.sh | bash

# additional for docker image
RUN yum -y update && yum -y install expect perl perl-DBI openssl zlib rsyslog libaio boost file sudo libnl net-tools sysvinit-tools  perl-DBD-MySQL runit less

# hack to avoid tty error with sudo
RUN sed -i -e 's/Defaults    requiretty.*/ #Defaults    requiretty/g' /etc/sudoers

# remove runit repo as seems to cause gpg key errors
RUN rm rm -rf /etc/yum.repos.d/imeyer_runit.repo

# set TERM to linux so less works ok.
RUN echo "export TERM=linux" > /etc/profile.d/termlinux.sh

# columnstore build, assumes install file below present
ADD . /install

# install columnstore
RUN tar xzf /install/mariadb-columnstore*.rpm.tar.gz -C /install
RUN rpm -ivh /install/mariadb-columnstore*.rpm
RUN rm -f /install/*.rpm /install/*.rpm.tar.gz

# run post cfg / install steps, must be done as one RUN so can shutdown cleanly after postConfigure.
RUN sh /install/install.sh

# setup runit for systemd-journald rsylogd and columnstore
RUN mkdir -p /etc/service/systemd-journald /etc/service/rsyslogd /etc/service/columnstore
COPY journald.run /etc/service/systemd-journald/run
COPY rsyslogd.run /etc/service/rsyslogd/run
COPY columnstore.run /etc/service/columnstore/run
COPY runit_bootstrap /usr/sbin/runit_bootstrap
RUN chmod 755 /etc/service/systemd-journald/run /etc/service/rsyslogd/run /etc/service/columnstore/run /usr/sbin/runit_bootstrap

VOLUME /usr/local/mariadb/columnstore/data1
VOLUME /usr/local/mariadb/columnstore/mysql/db

EXPOSE 3306

CMD ["/usr/sbin/runit_bootstrap"]
