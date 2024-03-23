# php7-fpm/Dockerfile
FROM php:8.3-fpm-alpine

ADD .docker/php/php.ini /usr/local/etc/php/

RUN apk update
RUN apk add \
    git \
    unzip \
    wget \
    g++ \
    nodejs \
    npm \
    icu-dev \
    zlib-dev \
    autoconf \
    make \
    bash \
    nginx

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install pdo pdo_mysql intl opcache
RUN pecl install pcov
RUN docker-php-ext-enable pcov

WORKDIR /www
ADD . /www

# NGINX
ADD .docker/nginx/nginx.conf /etc/nginx/
ADD .docker/nginx/app.conf /etc/nginx/sites-available/

RUN mkdir -p /etc/nginx/sites-enabled
RUN ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app

EXPOSE 80
EXPOSE 443

COPY .docker/entrypoint.sh /etc/entrypoint.sh
RUN chmod u+x /etc/entrypoint.sh

ENTRYPOINT ["/etc/entrypoint.sh"]