This is a Dockerfile that holds the installation and configuation steps for orocommerce. Database name, user and password has been mentioned in mysql.sh that will be called upon by supervisor. Also, supervisor manage multiple processes, here managing apache2 and mysql server. Composer.phar has already been cloned from its repository and ready to be copied in dockerfile. Parameters.yml holds database and other configuration setup for orocommerce (that can be changed as per requirements).

To begin with its docker image run command "docker run -d -p 80:80 -p 3306:3306 webkul/orocommerce:latest" .

Take a note that no other services should be running on port 80 and 3306 of your host system. If so, change ports in the above docker command.

We have taken oro_commerce as database name, user, and password. You can create different database by altering in mysql.sh file as per requirements.

Once container is running, you can access container and change database credentials. To access the container run "docker exec -it container_id bash"
