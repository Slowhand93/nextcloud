FROM alpine:3.9

ARG NEXTCLOUD_VERSION=15.0.5

ENV UID=1000 GID=1000 \
    UPLOAD_MAX_SIZE=20G \
    APC_SHM_SIZE=2048M \
    OPCACHE_MEM_SIZE=2048 \
    MEMORY_LIMIT=2048M \
    CRON_PERIOD=15m \
    CRON_MEMORY_LIMIT=2g \
    TZ=Etc/UTC \
    DB_TYPE=sqlite3 \
    DOMAIN=fnetmail.de \
    EMAIL=webmaster@fabek.net

RUN BUILD_DEPS=" \
    gnupg \
    tar \
    build-base \
    autoconf \
    automake \
    pcre-dev \
    libtool \
    libffi-dev \
    openssl-dev \
    python-dev \
    samba-dev" \
 && apk -U upgrade && apk add \
    ${BUILD_DEPS} \
    bash \
    nginx \
    python \
    py-pip \
    openssl \
    s6 \
    libressl \
#    libressl2.4-libcrypto \
    ca-certificates \
    libsmbclient \
    samba-client \
    su-exec \
    tzdata \
    php7 \
    php7-fpm \
    php7-intl \
    php7-mbstring \
    php7-curl \
    php7-gd \
    php7-fileinfo \
    php7-mcrypt \
    php7-opcache \
    php7-json \
    php7-session \
    php7-pdo \
    php7-dom \
    php7-ctype \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pgsql \
    php7-pdo_sqlite \
    php7-sqlite3 \
    php7-zlib \
    php7-zip \
    php7-xmlreader \
    php7-xml \
    php7-xmlwriter \
    php7-simplexml \
    php7-posix \
    php7-openssl \
    php7-ldap \
    php7-ftp \
    php7-pcntl \
    php7-exif \
    php7-redis \
    php7-iconv \
    php7-pear \
    php7-pecl-apcu \
    php7-dev \
 && pecl install smbclient \
 && echo "extension=smbclient.so" > /etc/php7/conf.d/00_smbclient.ini \
 && sed -i 's|;session.save_path = "/tmp"|session.save_path = "/data/session"|g' /etc/php7/php.ini \
 && pip install -U pip \
 && pip install -U requests \
 && pip install -U certbot \
 && mkdir -p /etc/letsencrypt/webrootauth /etc/letsencrypt/live/localhost /etc/letsencrypt/archive \
 && mkdir /nextcloud \
 && NEXTCLOUD_TARBALL="nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" \
 && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL} \
 && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}.sha512 \
 && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}.asc \
 && wget -q https://nextcloud.com/nextcloud.asc \
 && echo "All seems good, now unpacking ${NEXTCLOUD_TARBALL}..." \
 && tar xjf ${NEXTCLOUD_TARBALL} --strip 1 -C /nextcloud \
 && apk del ${BUILD_DEPS} php7-pear php7-dev \
 && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php7/php-fpm.conf
COPY opcache.ini /etc/php7/conf.d/00_opcache.ini
COPY apcu.ini /etc/php7/conf.d/apcu.ini
COPY run.sh /usr/local/bin/run.sh
COPY setup.sh /usr/local/bin/setup.sh
COPY occ /usr/local/bin/occ
COPY s6.d /etc/s6.d
COPY generate-certs /usr/local/bin/generate-certs
COPY letsencrypt-setup /usr/local/bin/letsencrypt-setup
COPY letsencrypt-renew /usr/local/bin/letsencrypt-renew

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*

VOLUME /data /config /apps2

EXPOSE 8080 8443

LABEL description="A server software for creating file hosting services" \
      nextcloud="Nextcloud v${NEXTCLOUD_VERSION}" \
      maintainer="com>"

CMD ["run.sh"]
