# build argument for PHP version
ARG PHP_VERSION

# base docker image
FROM php:${PHP_VERSION}fpm

# install system dependencies for intl
RUN apt-get update && apt-get install -y \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql intl

# build argument for Xdebug version
ARG XDEBUG_VERSION

# install and enable Xdebug PHP extension
RUN pecl install xdebug${XDEBUG_VERSION} \
    && docker-php-ext-enable xdebug

# create xdebug logs directory
RUN mkdir /xdebug-logs

# set and create a working directory in image
WORKDIR /project

# declare expose port
EXPOSE 9000
