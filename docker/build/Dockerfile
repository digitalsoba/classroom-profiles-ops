# Backend
FROM composer:latest as vendor
COPY database/ database/

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

# Frontend
FROM node:8-alpine as frontend

RUN mkdir -p /app/public

COPY package.json webpack.mix.js yarn.lock /app/
COPY resources/ /app/resources/

WORKDIR /app

RUN yarn install \
    && yarn production

# PHP/Apache 
FROM php:7.3-rc-apache

# Install php extensions
RUN docker-php-ext-install pdo_mysql \
    # Enable apache modules
    && a2enmod headers rewrite 

# Add apache.conf file 
COPY ./deploy/apache.conf /etc/apache2/sites-enabled/000-default.conf  

COPY . /var/www/html

# Copy Front/Backend packages
COPY --from=vendor /app/vendor/ /var/www/html/vendor/
COPY --from=frontend /app/public/js/ /var/www/html/public/js/
COPY --from=frontend /app/public/css/ /var/www/html/public/css/
COPY --from=frontend /app/mix-manifest.json /var/www/html/mix-manifest.json

# Change /var/www permission
RUN chown -hR www-data:www-data /var/www

# Expose port 80 and 443
EXPOSE 80 443
