FROM mariadb:10.1

EXPOSE 3306 4444 4567 4567/udp 4568

RUN apt-get update && apt-get install -y dnsutils

ADD ./mysql.cnf /etc/mysql/conf.d/mysql.cnf
ADD ./swarm-entrypoint.sh /usr/local/bin/swarm-entrypoint.sh

ENTRYPOINT ["swarm-entrypoint.sh"]
CMD ["mysqld"]
