
FROM php:8.0-cli-alpine

RUN echo "UTC" > /etc/timezone

# Update the base image
RUN apk -U upgrade

# Install impitool and curl
RUN apk add --no-cache ipmitool curl bash grep supervisor curl zip unzip

# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Configure supervisor
RUN mkdir -p /etc/supervisor.d/
COPY .docker/supervisord.ini /etc/supervisor.d/supervisord.ini

# Build Application
COPY . /app
#RUN rm -rf /app/.git* /app/tests /app/builds /app/.github /app/.docker

RUN cd /app && composer install --no-dev


CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
