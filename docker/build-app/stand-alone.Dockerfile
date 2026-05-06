# build argument for PHP version
ARG PHP_VERSION

# base docker image
FROM php:${PHP_VERSION}cli

# set and create a working directory in image
WORKDIR /app

# copy laravel application to image in WORKDIR
COPY ./project /app

# declare expose port for the PHP built-in server
EXPOSE 8000

# use PHP built-in server as the entrypoint
ENTRYPOINT ["php", "-S", "0.0.0.0:8000", "-t", "public"]
