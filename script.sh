#!/etc/bin/sh
#
# Script v0.1
# Se supone instalado OpenBSD 5.7 y las configuraciones de red necesarias realizadas
# Se debería ejecutar el script con sudo para evitar problemas de permisos
# Variables de entorno esperadas:
# PROXIED_SERVER_IP = IP del servidor a proteger, se utiliza para configurar el nginx

# Instalar dependencias
# Instalar PCRE: 
pkg_add ftp://ftp.openbsd.org/pub/OpenBSD/5.6/packages/amd64/pcre-8.35.tgz
# Instalar libxml2 :
# pkg_add ftp://ftp.openbsd.org/pub/OpenBSD/5.6/packages/amd64/libxml-2.9.1p1.tgz

# Descargar NGINX
ftp http://nginx.org/download/nginx-1.9.0.tar.gz
tar -zxvf nginx-1.9.0.tar.gz
rm -rf nginx-1.9.0.tar.gz

# Descargar NAXSI
ftp https://github.com/nbs-system/naxsi/archive/0.54rc2.tar.gz
tar -zxvf 0.54rc2.tar.gz
rm -rf 0.54rc2.tar.gz

# Compilar nginx con mod security como modulo externo e instalar
./nginx-1.9.0/configure --conf-path=/etc/nginx/nginx.conf --add-module=../naxsi-0.54rc2/naxsi_src/ \
 --error-log-path=/var/log/nginx/error.log --http-client-body-temp-path=/var/lib/nginx/body \
 --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-log-path=/var/log/nginx/access.log \
 --http-proxy-temp-path=/var/lib/nginx/proxy --lock-path=/var/lock/nginx.lock \
 --pid-path=/var/run/nginx.pid --with-http_ssl_module \
 --without-mail_pop3_module --without-mail_smtp_module \
 --without-mail_imap_module --without-http_uwsgi_module \
 --without-http_scgi_module --with-ipv6 --prefix=/usr
make ./nginx-1.9.0/
sudo make install ./nginx-1.9.0/

# Para que nginx se ejecute al inicio
echo “#!/bin/sh\n/usr/local/sbin/nginx” > /etc/rc.local

# Configurar nginx para hacer de reverse proxy
echo “location / { \n           ModSecurityEnabled on;\n           ModSecurityConfig modsecurity.conf;\n           # ip del server a proteger\n           proxy_pass $PROXIED_SERVER_IP;\n           proxy_read_timeout 180s;\n       }” >> /etc/nginx/nginx.conf


