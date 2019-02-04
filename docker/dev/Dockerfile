FROM php:7.3-rc-apache

# Install php extensions
RUN apt-get update \
  && apt-get install libldap2-dev -y  \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
  && docker-php-ext-install ldap pdo_mysql \
# Enable apache modules
  && a2enmod headers rewrite 
# Add apache.conf file 
COPY ./apache.conf /etc/apache2/sites-enabled/000-default.conf  

# Expose port 80 and 443
EXPOSE 80 443
