From ubuntu:14.04

MAINTAINER Alankrit Srivastava alankrit.srivastava256@webkul.com
##update server
RUN apt-get update

##install apache2 and other required packages
RUN apt-get -y install apache2 libapache2-mod-php5 nodejs

RUN mkdir -p /var/lock/apache2 /var/run/apache2

## install php and its dependencies
RUN apt-get -y install php5 libapache2-mod-php5 php5-mcrypt php5-gd php5-curl php5-intl php5-json php5-mysql php5-readline php5-tidy

RUN php5enmod mcrypt

##install nodejs
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nodejs

RUN apt-get -y install nano

##install mysql-server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server 

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN touch /var/run/mysqld/mysqld.sock

RUN touch /var/run/mysqld/mysqld.pid

RUN chown -R mysql:mysql /var/run/mysqld/mysqld.sock

RUN chown -R mysql:mysql /var/run/mysqld/mysqld.pid

RUN chmod -R 644 /var/run/mysqld/mysqld.sock

RUN chmod -R 644 /var/run/mysqld/mysqld.pid

##install supervisor and setup supervisord.conf file
RUN apt-get install -y supervisor
 
RUN mkdir -p /var/log/supervisor
 
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
 
## setup mysql.sh script 
 
COPY mysql.sh /etc/mysql.sh

RUN chmod a+x /etc/mysql.sh

RUN /etc/init.d/mysql restart

##copy composer.phar to bin folder as composer 
COPY composer.phar /bin/composer

RUN chmod a+x /bin/composer

##install git
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git


## clone orocommerce application
RUN cd /var/www/ && git clone --recursive -b 1.0.0 https://github.com/orocommerce/orocommerce-application.git

## install require dependencies for orocommerce
RUN cd /var/www/orocommerce-application/ && composer global require fxp/composer-asset-plugin:1.2.2

## Update apache2 000-default.conf file
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

## manage php memory and date-timezone setttings
RUN sed -i -e"s/^memory_limit\s*=\s*128M/memory_limit = 768M/" /etc/php5/apache2/php.ini

RUN echo "date.timezone = Asia/Kolkata" >> /etc/php5/apache2/php.ini

RUN echo "date.timezone = Asia/Kolkata" >> /etc/php5/cli/php.ini

##install orocommerce by composer
RUN cd /var/www/orocommerce-application/ && composer install

## copy parameters.yml file
COPY parameters.yml /var/www/orocommerce-application/app/config/parameters.yml

##change ownership and permissions
RUN chown -R www-data:www-data /var/www/html

RUN find /var/www/orocommerce-application/ -type f -exec chmod 644 {} \;

RUN find /var/www/orocommerce-application/ -type d -exec chmod 755 {} \;

RUN a2enmod rewrite

RUN a2enmod headers

RUN /etc/init.d/apache2 restart

EXPOSE 80

EXPOSE 3306

## This command will run inside the container when container gets launched
CMD ["/usr/bin/supervisord"]

