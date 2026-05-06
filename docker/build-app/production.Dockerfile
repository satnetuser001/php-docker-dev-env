# build argument for PHP version
ARG PHP_VERSION

# base docker image
FROM php:${PHP_VERSION}fpm

# install system dependencies for PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# install PHP extensions for databases: pdo, pdo_pgsql
RUN docker-php-ext-install pdo pdo_pgsql

# set and create a working directory in image
WORKDIR /app

# copy application to image in WORKDIR
COPY ./project /app

# set application owner to PHP-FPM process
RUN chown -R www-data:www-data /app

# declare expose port
EXPOSE 9000