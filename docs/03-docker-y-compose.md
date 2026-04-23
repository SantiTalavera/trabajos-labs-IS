# 03 - Docker y Docker Compose

## Objetivo

Instalar Docker Engine y Docker Compose Plugin en Rocky Linux 9.7 y validar que funcionen.

## Instalación

El script instala Docker con:

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

sudo dnf install -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

## Verificar servicio

```bash
systemctl status docker
systemctl list-unit-files | grep docker
```

Estado esperado:

```text
docker.service enabled
docker.socket disabled
```

y:

```text
Active: active (running)
```

## Probar Docker

```bash
docker --version
docker run hello-world
```

Si todavía requiere sudo:

```bash
sudo docker run hello-world
```

Luego cerrar sesión y volver a entrar para que aplique el grupo `docker`.

## Probar Docker Compose con Nginx

Crear carpeta:

```bash
mkdir -p ~/dev/prueba-compose
cd ~/dev/prueba-compose
```

Crear archivo `compose.yaml`:

```bash
cat > compose.yaml <<'EOF'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
EOF
```

Validar configuración:

```bash
docker compose config
```

Levantar contenedor:

```bash
docker compose up -d
docker compose ps
```

Probar dentro de la VM:

```bash
curl http://localhost:8080
```

Si devuelve HTML de Nginx, Docker y Compose funcionan.

## Acceder desde Windows

Requiere port forwarding en VirtualBox:

```text
Host port: 8080
Guest port: 8080
```

Luego abrir en Windows:

```text
http://localhost:8080
```

## Bajar el servicio

```bash
docker compose down
```

## Error común: YAML mal escrito

Error:

```text
yaml: line 2: found character that cannot start any token
```

o:

```text
services.web.ports must be a array
```

Solución: revisar indentación. Debe quedar así:

```yaml
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
```

No usar tabs; usar espacios.
