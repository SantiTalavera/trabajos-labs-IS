#  Docker Lab — Infraestructura con Nginx

> **Para alumnos** | Guía didáctica paso a paso para entender Docker,
> volúmenes, multi-stage builds y buenas prácticas de seguridad.

---

##  Requisitos previos

| Herramienta | Versión mínima | Verificar con |
|-------------|----------------|---------------|
| Docker      | 24.x           | `docker --version` |
| Docker Compose | 2.x         | `docker compose version` |

---

## Estructura del proyecto

```
docker-lab/
│
├── 📁 parte-0-efimero/          ← Ejemplo fundamentales sobre linea de comandos, sin persistencia
├── 📁 parte-1-volumen/          ← Ejemplo básico con volumen local
│   ├── Dockerfile               ← Imagen de Nginx personalizada
│   ├── docker-compose.yml       ← Orquestación del contenedor
│   ├── nginx.conf               ← Configuración segura de Nginx
│   └── html/
│       └── index.html           ← Tu página web (editá esta!)
│
├── 📁 parte-2-multistage/       ← Multi-stage build + Hot Reload
│   ├── Dockerfile               ← Build en 2 etapas (builder + production)
│   ├── docker-compose.yml       ← Perfiles: dev y prod
│   ├── nginx.conf               ← Config Nginx optimizada para prod
│   ├── package.json             ← Simula dependencias de proyecto real
│   └── src/
│       └── index.html           ← Código fuente
│
└── README.md                    ← Esta guía
```

---

##  Conceptos clave antes de empezar

### ¿Qué es una imagen Docker?
Una imagen es una **plantilla de solo lectura** con todo lo necesario para
ejecutar una aplicación: código, runtime, librerías, configuración.
Es como una foto de un sistema operativo en un estado específico.

```
Imagen = Sistema operativo + Runtime + Configuración + Código
```

### ¿Qué es un contenedor Docker?
Un contenedor es una **instancia en ejecución de una imagen**. Si la imagen
es el molde, el contenedor es el objeto fabricado con ese molde. Podés crear
muchos contenedores de la misma imagen.

```
docker run nginx  →  crea un contenedor a partir de la imagen "nginx"
```

### ¿Qué es un volumen?
Un volumen es un **mecanismo para persistir datos** fuera del ciclo de vida
del contenedor. Si el contenedor se borra, los datos en un volumen sobreviven.

```
Sin volumen:  datos en el contenedor → se pierden al borrar el contenedor
Con volumen:  datos en el host      → persisten aunque el contenedor muera
```

---

##  Parte 1 — Nginx + Volumen Local

### ¿Qué aprenderás?
- Construir una imagen Docker personalizada
- Montar un volumen para persistir/editar contenido
- Configurar Nginx con buenas prácticas
- Ver cambios en el navegador sin reiniciar el contenedor

### Cómo funciona

```
┌─────────────────────────────────────────┐
│          TU MÁQUINA (Host)              │
│                                         │
│  parte-1-volumen/html/index.html  ◄─────┼──── Editás con tu editor
│              │                          │
└──────────────┼──────────────────────────┘
               │ bind mount (volumen)
               ▼
┌─────────────────────────────────────────┐
│         CONTENEDOR Docker               │
│                                         │
│  /usr/share/nginx/html/index.html       │
│              │                          │
│              ▼                          │
│         Nginx sirve el archivo          │
└─────────────────────────────────────────┘
               │
               ▼
        http://localhost:8080
```

### Comandos

```bash
# 1. Entrá al directorio de la Parte 1
cd parte-1-volumen

# 2. Construir la imagen y levantar el contenedor
docker compose up -d --build

# 3. Verificar que el contenedor está corriendo
docker compose ps

# 4. Ver los logs en tiempo real
docker compose logs -f

# 5. Abrir en el navegador
open http://localhost:8080
# o en Linux: xdg-open http://localhost:8080
```

### ¡Probá el Hot Reload del volumen!

```bash
# Editá el archivo HTML desde tu editor favorito
code html/index.html
# o
nano html/index.html

# Recargá el navegador → los cambios aparecen INMEDIATAMENTE
# sin reiniciar el contenedor ni reconstruir la imagen 
```

### Explorar el contenedor (opcional)

```bash
# Entrar al shell del contenedor (útil para debug)
docker compose exec web sh

# Dentro del contenedor:
ls /usr/share/nginx/html    # Ver los archivos servidos
cat /etc/nginx/nginx.conf   # Ver la configuración
nginx -t                    # Validar configuración
exit                        # Salir del contenedor
```

### Detener y limpiar

```bash
# Detener el contenedor (sin borrarlo)
docker compose stop

# Detener Y borrar el contenedor (la imagen queda)
docker compose down

# Borrar todo, incluyendo imágenes y volúmenes
docker compose down --rmi all --volumes
```

---

##  Parte 2 — Multi-Stage Build + Hot Reload

### ¿Qué aprenderás?
- Qué es un multi-stage build y por qué usarlo
- Diferencia entre imágenes de desarrollo y producción
- Hot reload para desarrollo ágil
- Profiles de Docker Compose

### ¿Por qué multi-stage?

Imaginate que tu proyecto usa Node.js para compilar React/Vue/Sass:

```
SIN multi-stage:          CON multi-stage:
┌─────────────────┐       ┌─────────────────┐
│ Nginx           │       │ Nginx           │  ← Solo el servidor
│ Node.js         │  vs   │ Tu web (dist/)  │  ← Solo el resultado
│ npm             │       └─────────────────┘
│ node_modules    │         Tamaño: ~25 MB ✅
│ Código fuente   │
└─────────────────┘
  Tamaño: ~400 MB ❌
```

### El flujo de multi-stage

```
DOCKERFILE:

FROM node:20-alpine AS builder     ← Stage 1: herramientas de build
    │
    ├─ npm install
    ├─ npm run build
    └─ genera: dist/

FROM nginx:1.27-alpine AS production  ← Stage 2: imagen final
    │
    └─ COPY --from=builder /app/dist /usr/share/nginx/html
              ↑
       Solo copia los archivos compilados, NO node_modules ni código fuente
```

### Modo Desarrollo (Hot Reload)

En desarrollo usamos un bind mount de `src/` directamente en Nginx.
No necesitamos el stage builder porque no hay nada que compilar en tiempo real.

```bash
# Entrá al directorio de la Parte 2
cd parte-2-multistage

# Iniciar en modo DESARROLLO
docker compose --profile dev up -d

# Accedé en: http://localhost:8081
```

**Probá el hot reload:**
```bash
# Editá cualquier archivo en src/
echo "<h1>Cambio instantáneo!</h1>" >> src/index.html

# Recargá el navegador → ¡los cambios aparecen inmediatamente! 
```

### Modo Producción (Multi-Stage Build)

```bash
# Construir con multi-stage y levantar en modo PRODUCCIÓN
docker compose --profile prod up -d --build

# Accedé en: http://localhost:8082
```

### Comparar el tamaño de las imágenes

```bash
# Ver todas las imágenes creadas y sus tamaños
docker images | grep -E "nginx|node|parte"

# Esperá ver algo así:
# parte-2-multistage-web-prod   latest   a1b2c3d4   25MB    ← Imagen final optimizada
# node                          20-alpine  ...       200MB  ← Solo usada en build
```

### Inspeccionar la imagen (opcional)

```bash
# Ver los stages de construcción
docker history parte-2-multistage-web-prod

# Ver metadatos de la imagen
docker inspect parte-2-multistage-web-prod

# Verificar que Node.js NO está en la imagen final
docker run --rm parte-2-multistage-web-prod node --version
# → Error: node not found ✅ (esperado! no queremos Node en producción)
```

---

##  Buenas prácticas implementadas

### Seguridad

| Práctica | Dónde | Por qué |
|----------|-------|---------|
| Imagen Alpine | Dockerfile | Menos paquetes = menos vulnerabilidades |
| Versiones fijas | `nginx:1.27-alpine` | Reproducibilidad y control |
| Usuario no-root | `USER nginx` | Principio de mínimo privilegio |
| Volúmenes `:ro` | docker-compose.yml | El contenedor no puede modificar el host |
| Headers HTTP de seguridad | nginx.conf | Protección contra XSS, clickjacking, etc. |
| `server_tokens off` | nginx.conf | Oculta la versión de Nginx |
| Bloquear archivos ocultos | nginx.conf | Evita exponer `.env`, `.git`, etc. |

### Rendimiento

| Práctica | Dónde | Beneficio |
|----------|-------|-----------|
| `sendfile on` | nginx.conf | Transferencia de archivos optimizada |
| Compresión gzip | nginx.conf | Menos ancho de banda |
| Cache de assets | nginx.conf | Menos requests al servidor |
| Multi-stage build | Dockerfile | Imagen final 87% más pequeña |
| Layers cacheadas | Dockerfile | Builds más rápidos |
| Límites de recursos | docker-compose.yml | Evita consumo excesivo |
| Rotación de logs | docker-compose.yml | Evita llenar el disco |

### Observabilidad

| Práctica | Dónde | Para qué |
|----------|-------|----------|
| HEALTHCHECK | Dockerfile | Detección automática de fallos |
| Logs configurados | nginx.conf | Auditoría y debug |
| Labels en servicios | docker-compose.yml | Filtrado y organización |
| LABEL en imágenes | Dockerfile | Trazabilidad de la imagen |

---

## Comandos de referencia rápida

```bash
# ── Ciclo de vida ─────────────────────────────────────────────────────────
docker compose up -d              # Levantar en background
docker compose up -d --build      # Levantar Y reconstruir imagen
docker compose down               # Parar y borrar contenedores
docker compose stop               # Parar sin borrar
docker compose restart            # Reiniciar servicios

# ── Monitoreo ─────────────────────────────────────────────────────────────
docker compose ps                 # Estado de los servicios
docker compose logs               # Ver todos los logs
docker compose logs -f web        # Seguir logs del servicio "web"
docker stats                      # CPU y RAM en tiempo real

# ── Debug ─────────────────────────────────────────────────────────────────
docker compose exec web sh        # Shell en el contenedor
docker inspect <contenedor>       # Metadatos detallados
docker diff <contenedor>          # Cambios respecto a la imagen base

# ── Imágenes ──────────────────────────────────────────────────────────────
docker images                     # Listar imágenes locales
docker rmi <imagen>               # Borrar imagen
docker image prune                # Borrar imágenes no usadas (dangling)
docker system prune               # Limpieza general 🧹

# ── Red ──────────────────────────────────────────────────────────────────
docker network ls                 # Listar redes
docker network inspect <red>      # Ver detalles de la red
```

---

##  Flujo de trabajo recomendado

```
┌─────────────────────────────────────────────────────────┐
│                  CICLO DE DESARROLLO                    │
│                                                         │
│  1. Desarrollás con:                                    │
│     docker compose --profile dev up -d                  │
│     → Hot reload activo en http://localhost:8081        │
│                                                         │
│  2. Cuando terminás de desarrollar, validás con prod:   │
│     docker compose --profile prod up -d --build         │
│     → Imagen optimizada en http://localhost:8082        │
│                                                         │
│  3. Para producción real, pushás la imagen:             │
│     docker build -t mi-app:v1.0 .                       │
│     docker push mi-registry/mi-app:v1.0                 │
│                                                         │
│  4. En el servidor de producción:                       │
│     docker pull mi-registry/mi-app:v1.0                 │
│     docker run -p 80:8080 mi-registry/mi-app:v1.0       │
└─────────────────────────────────────────────────────────┘
```

## Experiencia Mujltistage

PASO 1 → Verificar que ambos contenedores están up
PASO 2 → Modifica src/index.html: v1.0.0 → v2.0.0
PASO 3 → Recargar http://localhost:8081 (DEV)  → cambia al instante ✅
PASO 4 → Recargar http://localhost:8082 (PROD) → no cambia ❌
PASO 5 → docker compose --profile prod up -d --build
PASO 6 → Recargar PROD → ahora sí cambia ✅
---

## ❓ Preguntas frecuentes

**¿Por qué no usar `latest` en la imagen base?**
Porque `latest` puede apuntar a versiones diferentes en distintos momentos.
Tu imagen de hoy puede fallar mañana si `latest` actualiza. Las versiones
fijas garantizan reproducibilidad.

**¿Qué diferencia hay entre `COPY` y `ADD` en Dockerfile?**
`COPY` solo copia archivos/directorios locales. `ADD` también puede descomprimir
tarballs y descargar URLs. Por claridad y seguridad, usá siempre `COPY` a menos
que necesites específicamente las funciones extra de `ADD`.

**¿Por qué ejecutar Nginx en el puerto 8080 y no en el 80?**
Los puertos menores a 1024 requieren privilegios de root. Para correr como
usuario `nginx` (no-root), necesitamos usar el puerto 8080 dentro del contenedor.
El mapeo de puertos de Compose (`8080:8080`) se encarga del resto.

**¿El bind mount es lo mismo que un volumen Docker nombrado?**
No. Un bind mount (`./html:/usr/share/nginx/html`) usa un directorio específico
del host. Un volumen nombrado (`my-data:/data`) es administrado por Docker y
vive en el filesystem de Docker. Para desarrollo se usa bind mount; para datos
persistentes de producción (bases de datos, etc.) se usan volúmenes nombrados.

---

*Dockerlab — Infraestructura IT | Lecturas adicionales: [docs.docker.com](https://docs.docker.com)*
