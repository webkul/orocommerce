From ubuntu:14.04

MAINTAINER Alankrit Srivastava alankrit.srivastava256@webkul.com

RUN apt-get update

RUN apt-get -y install apache2 libapache2-mod-php5 nodejs

RUN mkdir -p /var/lock/apache2 /var/run/apache2

RUN apt-get -y install php5 libapache2-mod-php5 php5-mcrypt php5-gd php5-curl php5-intl php5-json php5-mysql php5-readline php5-tidy

RUN php5enmod mcrypt

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nodejs

RUN apt-get -y install nano

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server 

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN touch /var/run/mysqld/mysqld.sock

RUN touch /var/run/mysqld/mysqld.pid

RUN chown -R mysql:mysql /var/run/mysqld/mysqld.sock

RUN chown -R mysql:mysql /var/run/mysqld/mysqld.pid

RUN chmod -R 644 /var/run/mysqld/mysqld.sock

RUN chmod -R 644 /var/run/mysqld/mysqld.pid

RUN apt-get install -y supervisor
 
RUN mkdir -p /var/log/supervisor
 
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
 
COPY mysql.sh /etc/mysql.sh

RUN chmod +x /etc/mysql.sh

RUN /etc/init.d/mysql restart


RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '61069fe8c6436a4468d0371454cf38a812e451a14ab1691543f25a9627b97ff96d8753d92a00654c21e2212a5ae1ff36') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

RUN php composer-setup.php

RUN php -r "unlink('composer-setup.php');"




COPY composer.phar /bin/composer

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git

RUN cd /var/www/ && git clone --recursive -b 1.0.0-beta.5 https://github.com/orocommerce/orocommerce-application.git

RUN cd /var/www/orocommerce-application/ && composer global require fxp/composer-asset-plugin:1.2.2

RUN echo " " > /etc/apache2/sites-enabled/000-default.conf

RUN echo '<VirtualHost *:80>\n\
         DirectoryIndex app.php\n\
         DocumentRoot /var/www/orocommerce-application/web/\n\
         <Directory  /var/www/orocommerce-application/web/>\n\
         Options FollowSymLinks\n\
         Require all granted\n\ 
         AllowOverride all\n\
         </Directory>\n\
         ErrorLog /var/log/apache2/orocrm_error.log\n\
         CustomLog /var/log/apache2/orocrm_access.log combined\n\
         </VirtualHost>\n'\
         >> /etc/apache2/sites-enabled/000-default.conf

RUN sed -i -e"s/^memory_limit\s*=\s*128M/memory_limit = 768M/" /etc/php5/apache2/php.ini

RUN echo "date.timezone = Asia/Kolkata" >> /etc/php5/apache2/php.ini

RUN echo "date.timezone = Asia/Kolkata" >> /etc/php5/cli/php.ini

RUN cd /var/www/orocommerce-application/ && composer install

COPY parameters.yml /var/www/orocommerce-application/app/config/parameters.yml

RUN chown -R www-data:www-data /var/www/html

RUN find /var/www/orocommerce-application/ -type f -exec chmod 644 {} \;

RUN find /var/www/orocommerce-application/ -type d -exec chmod 755 {} \;

RUN a2enmod rewrite

RUN a2enmod headers

RUN /etc/init.d/apache2 restart

EXPOSE 80

EXPOSE 22

EXPOSE 3306

CMD ["/usr/bin/supervisord"]

