This is a Dockerfile that holds the installation and configuation steps for orocommerce. Database name, user and password has been mentioned in mysql.sh that will be called upon by supervisor. Also, supervisor manage multiple processes, here managing apache2 and mysql server. Composer.phar has already been cloned from its repository and ready to be copied in dockerfile. Parameters.yml holds database and other configuration setup for orocommerce (that can be changed as per requirements).

To begin with its docker image run command docker run -d -p 80:80 -p 3306:3306 alankrit29/orocommerce:latest .

We have taken oro_commerce as database name, user, and password. You can create different database by altering in mysql.sh file as per requirements.
