FROM php:7.2.7-fpm
RUN apt-get update && docker-php-ext-install mysqli pdo_mysql
