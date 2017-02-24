FROM ubuntu:14.04

RUN apt-get update \
    && apt-get install -y \
       curl \
       nginx \
       supervisor \
       php5-fpm \
       php5-cli \
       php5-curl \
       php5-gd \
       php5-json \ 
       php5-pgsql \
       php5-mysql \
       php5-mcrypt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# enable the mcrypt module
RUN php5enmod mcrypt

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/sites-available/ttrss
RUN ln -s /etc/nginx/sites-available/ttrss /etc/nginx/sites-enabled/ttrss
RUN rm /etc/nginx/sites-enabled/default

# install ttrss and patch configuration
WORKDIR /var/www
RUN curl -SL https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.tar.gz?ref=17.1 | tar xzC /var/www --strip-components 1 \
    && chown www-data:www-data -R /var/www
RUN cp config.php-dist config.php

# expose only nginx HTTP port
EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD configure.php /configure.php
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# from https://github.com/vishnubob/wait-for-it
ADD wait-for-it.sh /bin/wait-for-it.sh

CMD wait-for-it.sh $DB_HOST:$DB_PORT -t 30 -- \
    php /configure.php \
    && supervisord -c /etc/supervisor/conf.d/supervisord.conf
