FROM signnow/php:7.3-alpine-1.2.0
LABEL Maintainer="oloarte.manuel@pdffiller.team" 

# SimpleSAMLphp
ARG SIMPLESAMLPHP_VERSION=1.18.7
RUN curl -s -L -o /tmp/simplesamlphp.tar.gz https://github.com/simplesamlphp/simplesamlphp/releases/download/v$SIMPLESAMLPHP_VERSION/simplesamlphp-$SIMPLESAMLPHP_VERSION.tar.gz && \
    tar xzf /tmp/simplesamlphp.tar.gz -C /tmp && \
    rm -f /tmp/simplesamlphp.tar.gz  && \
    mkdir -p /app/public && \
    mv /tmp/simplesamlphp-* /app/public/simplesamlphp && \
    touch /app/public/simplesamlphp/modules/exampleauth/enable

COPY config/simplesamlphp/config.php /app/public/simplesamlphp/config/
COPY config/simplesamlphp/saml20-idp-hosted.php /app/public/simplesaml/metadata/
COPY config/simplesamlphp/server.crt /app/public/simplesamlphp/cert/
COPY config/simplesamlphp/server.pem /app/public/simplesamlphp/cert/

COPY config/nginx/ /etc/nginx/
COPY config/php/app.ini /etc/php7/conf.d/app.ini 
COPY config/supervisor/ /etc/supervisor/
COPY config/consul /app/consul
COPY config/consul-template /app/consul-template

COPY provision /app/provision
COPY entrypoint.d /entrypoint.d

RUN ln -s  /etc/php7/conf.d/app.ini /etc/php7/php-fpm.d/app.ini

RUN bash /app/provision/after-build.sh

EXPOSE 80

VOLUME ["/app/storage/logs", "/var/log/nginx", "/var/log/php"]

WORKDIR /app