FROM wordpress:6.5.2-php8.1-apache
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

    # Tạo user và group "www"
RUN groupadd -g 1000 www && useradd -g 1000 -u 1000 -d /var/www/html -s /bin/bash www

RUN mkdir -p /var/www/html
# Thiết lập quyền sở hữu cho thư mục /var/www/html
RUN chown -R www:www /var/www/html

# Cấu hình Apache để chạy dưới user "www" thay vì www-data
RUN sed -i 's/www-data/www/g' /etc/apache2/envvars

USER www