FROM bhojpur/platform-full:latest

USER root

# Install MySQL
RUN install-packages mysql-server \
 && mkdir -p /var/run/mysqld /var/log/mysql \
 && chown -R bhojpur:bhojpur /etc/mysql /var/run/mysqld /var/log/mysql /var/lib/mysql /var/lib/mysql-files /var/lib/mysql-keyring /var/lib/mysql-upgrade

# Install our own MySQL config
COPY mysql.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

# Install default-login for MySQL clients
COPY client.cnf /etc/mysql/mysql.conf.d/client.cnf

COPY mysql-bashrc-launch.sh /etc/mysql/mysql-bashrc-launch.sh

USER bhojpur

RUN echo "/etc/mysql/mysql-bashrc-launch.sh" >> ~/.bashrc
