# build argument for PHP version
ARG PHP_VERSION

# base docker image
FROM php:${PHP_VERSION}fpm

# install PHP extensions for databases: pdo, pdo_mysql
RUN docker-php-ext-install pdo pdo_mysql

# set and create a working directory in image
WORKDIR /app

# copy application to image in WORKDIR
COPY ./project /app

# set application owner to PHP-FPM process
RUN chown -R www-data:www-data /app

# declare expose port
EXPOSE 9000
