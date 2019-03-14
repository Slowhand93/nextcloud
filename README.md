
### Building

```
git clone https://github.com/martmaiste/nextcloud.git
docker build -t nextcloud nextcloud
```

Run nextcloud-docker

```
docker run -d --name nextcloud -p 80:8080 -p 443:8443 \
       --link nextcloud-db:nextcloud-db \
       -v /mnt2/nextcloud-data:/data \
       -v /mnt2/nextcloud-config:/config \
       -v /mnt2/nextcloud-app:/apps2 \
       -e UID=1000 -e GID=1000 \
       -e UPLOAD_MAX_SIZE=10G \
       -e APC_SHM_SIZE=128M \
       -e OPCACHE_MEM_SIZE=128 \
       -e CRON_PERIOD=15m \
       -e DB_TYPE=mysql \
       -e DB_HOST=nextcloud-db \
       -e DB_USER=nextcloud \
       -e DB_PASSWORD=password \
       -e TZ=Etc/UTC \
       -e DOMAIN=localhost \
       -e EMAIL=hostmaster@localhost \
       -t nextcloud
```
DOMAIN and EMAIL are mainly used for generating Let's Encrypt certificate later. Remove if not needed.

Nextcloud needs to be accessible on ports 80 and 443 for generating Let's Encrypt certificates. 80 port is used for authenticating.

### Let's Encrypt certificate setup

```
docker exec -ti nextcloud letsencrypt-setup
```

Manual certificate renewal

```
docker exec -ti nextcloud letsencrypt-renew
```

### Credits

[Nextcloud Dockerfile by Wonderfall](https://github.com/Wonderfall/dockerfiles/tree/master/nextcloud/)

[Nginx with SSL and Let's Eencrypt support by ngineered](https://github.com/ngineered/nginx-php-fpm)

[Self Signed SSL Certificate Generator by paulczar](https://github.com/paulczar/omgwtfssl)
