# Configurar Dominio con Nginx y Certbot

Este script configura un nuevo dominio en Nginx, crea un certificado SSL usando Certbot, y aplica todas las configuraciones necesarias para asegurar el sitio web.

## Requisitos

- Ubuntu/Debian (puede necesitar ajustes para otras distribuciones)
- Nginx instalado
- Certbot instalado

## Instalación de Certbot

Si Certbot no está instalado, puedes instalarlo con los siguientes comandos:

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
```

CentOS/RHEL
```bash
sudo yum install epel-release -y
sudo yum install certbot python3-certbot-nginx -y
```

Uso
Guarda el script en un archivo, por ejemplo configurar_dominio.sh.
Dale permisos de ejecución al script:

```bash
chmod +x nginx_odoo.sh
```

Ejecuta el script pasando el dominio como parámetro:
```bash
./nginx_odoo.sh ejemplo.com
```

Descripción del Script
El script realiza las siguientes acciones:

Comprueba si se ha proporcionado un dominio como parámetro.
Define variables clave, incluyendo el nombre del dominio, el correo electrónico para Certbot, y las rutas de configuración de Nginx.
Crea un archivo de configuración para Nginx con el dominio especificado.
Crea un enlace simbólico en el directorio sites-enabled de Nginx.
Verifica la configuración de Nginx.
Recarga Nginx para aplicar la nueva configuración.
Genera el certificado SSL utilizando Certbot.
Recarga Nginx nuevamente para aplicar el nuevo certificado SSL.
Archivo de Configuración de Nginx
El archivo de configuración creado por el script tendrá el siguiente formato:

nginx
Copiar código
upstream odooejemplocomw {
  server 127.0.0.1:8069;
}
upstream odooejemplocomchatw {
  server 127.0.0.1:8072;
}

server {
  server_name www.ejemplo.com ejemplo.com;

  proxy_read_timeout 720s;
  proxy_connect_timeout 720s;
  proxy_send_timeout 720s;

  if (\$host = www.ejemplo.com) {
    return 301 \$scheme://ejemplo.com\$request_uri;
  }

  proxy_set_header X-Forwarded-Host \$host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_set_header X-Real-IP \$remote_addr;

  access_log /var/log/nginx/odoo.access.log;
  error_log /var/log/nginx/odoo.error.log;

  location / {
    proxy_redirect off;
    proxy_pass http://odooejemplocomw;
  }
  location /longpolling {
    proxy_pass http://odooejemplocomchatw;
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
```

### Notas
Asegúrate de tener nginx y certbot correctamente instalados en tu sistema.
El script recarga Nginx dos veces: una después de crear la configuración y otra después de obtener el certificado SSL.
Ajusta las direcciones y puertos de los upstreams (127.0.0.1:8069 y 127.0.0.1:8072) según sea necesario para tu configuración de Odoo.
Problemas Comunes
Configuración inválida de Nginx: Si nginx -t falla, revisa el archivo de configuración generado y asegúrate de que todos los valores sean correctos.
Certbot no instalado: Asegúrate de que Certbot esté instalado y accesible en tu sistema.
Permisos: Ejecuta el script con permisos suficientes (por ejemplo, usando sudo).
