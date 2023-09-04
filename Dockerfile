FROM php:8.2-fpm

ARG user
ARG uid

RUN apt-get update && apt-get install -y --no-install-recommends \
    ghostscript \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/* 

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    && docker-php-ext-install -j "$(nproc)" \
    bcmath exif gd intl mysqli zip \
    && pecl install imagick-3.6.0 \
    && docker-php-ext-enable imagick opcache \
    && rm -r /tmp/pear

RUN echo "opcache.memory_consumption=128\n\
    opcache.interned_strings_buffer=8\n\
    opcache.max_accelerated_files=4000\n\
    opcache.revalidate_freq=2" > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT\n\
    display_errors = Off\n\
    log_errors = On\n\
    error_log = /dev/stderr" > /usr/local/etc/php/conf.d/error-logging.ini

COPY ./.build/php.ini /usr/local/etc/php/conf.d/php.ini
COPY --chmod=755 ./.build/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN useradd -G www-data,root -u $uid -d /home/$user $user

WORKDIR /var/www/html

#ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
