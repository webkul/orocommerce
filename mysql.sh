mysql -u root -pwebkul<<EOF
create database oro_commerce;
create user oro_commerce;
grant all privileges on oro_commerce.* to oro_commerce@'%' identified by 'oro_commerce';
EOF
