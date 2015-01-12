#!/bin/bash

if [ ! -d "/tmp/ckan-rpm/" ]; then

	mkdir /tmp/ckan-rpm/
	cd /tmp/ckan-rpm/
	wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

	rpm -Uvh /tmp/ckan-rpm/epel-release-6-8.noarch.rpm

	yum update -y ca-certificates
	yum install -y gcc gcc-c++ make centos-release-cr vim-common
	yum install -y xml-commons libxslt libxslt-devel libxml2 libxml2-devel
	yum install -y python-devel postgresql postgresql-server postgresql-devel
	yum install -y git-core python-pip python-virtualenv
	yum install -y java-1.7.0-openjdk java-1.7.0-openjdk-devel
	yum install -y tomcat6 xalan-j2 unzip policycoreutils-python mod_wsgi

	chkconfig postgresql on
	service postgresql initdb

	yes|cp -f /vagrant/ckan/setup/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
	chmod 0600 /var/lib/pgsql/data/pg_hba.conf

	service postgresql start

	sudo -u postgres psql -c "CREATE USER ckanuser WITH PASSWORD 'pass';"
	sudo -u postgres createdb -O ckanuser ckantest

	# ln -s /vagrant/ckan/inventory.dev /usr/local/inventory.dev

	useradd -m -s /sbin/nologin -d /usr/local/inventory.dev -c "CKAN User" ckan
	chmod -R 777 /usr/local/inventory.dev

	semanage fcontext --add --ftype -- --type httpd_sys_content_t "/usr/local/inventory.dev(/.*)?"
	semanage fcontext --add --ftype -d --type httpd_sys_content_t "/usr/local/inventory.dev(/.*)?"
	restorecon -vR /usr/local/inventory.dev


	chmod 0777 /vagrant/ckan/setup/ckan-pyenv.sh
	su -s /bin/bash -c /vagrant/ckan/setup/ckan-pyenv.sh ckan


	yes|cp -f /vagrant/ckan/setup/development.ini /usr/local/inventory.dev/pyenv/src/ckan/development.ini
	chmod 0664 /usr/local/inventory.dev/pyenv/src/ckan/development.ini


	curl http://archive.apache.org/dist/lucene/solr/1.4.1/apache-solr-1.4.1.tgz | tar xzf -

	mkdir -p /usr/share/solr/core0 /usr/share/solr/core1 /var/lib/solr/data/core0
	mkdir -p /var/lib/solr/data/core1 /etc/solr/core0 /etc/solr/core1

	yes|cp apache-solr-1.4.1/dist/apache-solr-1.4.1.war /usr/share/solr

	yes|cp -r apache-solr-1.4.1/example/solr/conf /etc/solr/core0

	yes|cp -f /vagrant/ckan/setup/solrconfig.xml /etc/solr/core0/conf/solrconfig.xml
	chmod 0644 /etc/solr/core0/conf/solrconfig.xml

	yes|cp -r /etc/solr/core0/conf /etc/solr/core1

	ln -s /etc/solr/core0/conf /usr/share/solr/core0/conf
	ln -s /etc/solr/core1/conf /usr/share/solr/core1/conf

	rm -f /etc/solr/core0/conf/schema.xml
	ln -s /usr/local/inventory.dev/pyenv/src/ckan/ckan/config/solr/schema-2.0.xml /etc/solr/core0/conf/schema.xml
	rm -f /etc/solr/core1/conf/schema.xml
	ln -s /usr/local/inventory.dev/pyenv/src/ckan/ckan/config/solr/schema-1.4.xml /etc/solr/core1/conf/schema.xml

	mkdir -p /etc/tomcat6/Catalina/localhost
	yes|cp -f /vagrant/ckan/setup/tomcat-solr.xml /etc/tomcat6/Catalina/localhost/solr.xml
	yes|cp -f /vagrant/ckan/setup/share-solr.xml /usr/share/solr/solr.xml

	chown -R tomcat:tomcat /usr/share/solr /var/lib/solr

	chkconfig tomcat6 on
	service tomcat6 start


	mkdir -p /usr/local/inventory.dev/pyenv/src/ckan/data /usr/local/inventory.dev/pyenv/src/ckan/sstore /var/log/ckan/inventory.dev
	chmod 0777 /usr/local/inventory.dev/pyenv/src/ckan/data /usr/local/inventory.dev/pyenv/src/ckan/sstore /var/log/ckan/inventory.dev
	chown apache:apache /usr/local/inventory.dev/pyenv/src/ckan/data /usr/local/inventory.dev/pyenv/src/ckan/sstore /var/log/ckan/inventory.dev

	touch /var/log/ckan/inventory.dev/ckan.log
	chmod 0777 /var/log/ckan/inventory.dev/ckan.log


	chmod 0777 /vagrant/ckan/setup/ckan-paster.sh
	su -s /bin/bash -c /vagrant/ckan/setup/ckan-paster.sh ckan


	yes|cp -f /vagrant/ckan/setup/inventory.dev.py /usr/local/inventory.dev/pyenv/bin/inventory.dev.py
	chmod 0664 /usr/local/inventory.dev/pyenv/bin/inventory.dev.py

	yes|cp -f /vagrant/ckan/setup/wsgi.conf /etc/httpd/conf.d/wsgi.conf
	chmod 0664 /etc/httpd/conf.d/wsgi.conf

	setsebool -P httpd_can_network_connect 1

	rm -rf /vagrant/ckan/src
	mv /usr/local/inventory.dev/pyenv/src/ckan /vagrant/ckan/src
	ln -s /vagrant/ckan/src /usr/local/inventory.dev/pyenv/src/ckan

	chkconfig httpd on

	service httpd start
fi

#yes|cp -f /vagrant/ckan/setup/iptables /etc/sysconfig/iptables
#chmod 0664 /etc/sysconfig/iptables


