# build argument for PHP version
ARG PHP_VERSION

# base docker image
FROM php:${PHP_VERSION}cli

# set and create a working directory in image
WORKDIR /app

# copy laravel application to image in WORKDIR
COPY ./project /app

# run artisan server on port 8000 in container
ENTRYPOINT ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
