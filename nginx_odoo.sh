#!/bin/bash

# Comprobar si se pasa un dominio como parámetro
if [ -z "$1" ]; then
  echo "Uso: $0 dominio.com"
  exit 1
fi

# Variables
DOMINIO=$1
EMAIL="info@odoonext.com"
CONFIG_PATH="/etc/nginx/sites-available/$DOMINIO.conf"
ENABLED_PATH="/etc/nginx/sites-enabled/$DOMINIO.conf"

# Crear el archivo de configuración para Nginx
cat <<EOL > $CONFIG_PATH
upstream odoowiki {
  server 127.0.0.1:8069;
}
upstream odoochatwiki {
  server 127.0.0.1:8072;
}

server {
  server_name www.$DOMINIO $DOMINIO;

  proxy_read_timeout 720s;
  proxy_connect_timeout 720s;
  proxy_send_timeout 720s;

  if (\$host = www.$DOMINIO) {
    return 301 \$scheme://$DOMINIO\$request_uri;
  }

  proxy_set_header X-Forwarded-Host \$host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_set_header X-Real-IP \$remote_addr;

  access_log /var/log/nginx/odoo.access.log;
  error_log /var/log/nginx/odoo.error.log;

  location / {
    proxy_redirect off;
    proxy_pass http://odoow;
  }
  location /longpolling {
    proxy_pass http://odoochatw;
  }

  gzip_types text/css text/less text/plain text/xml application/xml application/json application/javascript;
  gzip on;

  client_body_in_file_only clean;
  client_body_buffer_size 32K;
  client_max_body_size 500M;
  sendfile on;
  send_timeout 600s;
  keepalive_timeout 300;
}
EOL

# Crear el enlace simbólico en sites-enabled
ln -s $CONFIG_PATH $ENABLED_PATH

# Comprobar la configuración de Nginx
nginx -t
if [ $? -ne 0 ]; then
  echo "La configuración de Nginx es inválida. Verifique el archivo de configuración."
  exit 1
fi

# Recargar Nginx para aplicar los cambios
systemctl reload nginx
apt update
apt upgrade -y
apt install certbot python3-certbot-nginx -y

# Generar el certificado SSL con Certbot
certbot --nginx -d $DOMINIO -d www.$DOMINIO --noninteractive --agree-tos --email $EMAIL --redirect

# Recargar Nginx nuevamente para aplicar el nuevo certificado
systemctl reload nginx

echo "Configuración completa para $DOMINIO"
