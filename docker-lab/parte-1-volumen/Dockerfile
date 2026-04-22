# =============================================================================
#  PARTE 1 — Dockerfile: Nginx + Volumen Local
# =============================================================================
#
#  ¿Qué es un Dockerfile?
#  ----------------------
#  Un Dockerfile es un archivo de texto con instrucciones para construir
#  una imagen Docker, paso a paso. Es como una "receta" que Docker sigue
#  para crear un entorno reproducible.
#
#  ¿Qué hace este Dockerfile?
#  --------------------------
#  Construye una imagen liviana de Nginx lista para servir contenido
#  estático. El contenido HTML NO se copia dentro de la imagen;
#  se sirve desde un VOLUMEN LOCAL (tu carpeta html/ en la máquina host).
#
# =============================================================================

# -----------------------------------------------------------------------------
# 1. IMAGEN BASE
# -----------------------------------------------------------------------------
# Versión fija (-alpine): reproducibilidad y mínima superficie de ataque.
# -----------------------------------------------------------------------------
FROM nginx:1.27-alpine

# -----------------------------------------------------------------------------
# 2. METADATOS
# -----------------------------------------------------------------------------
LABEL maintainer="docker-lab@example.com"
LABEL version="1.1"
LABEL description="Parte 1: Nginx sirviendo HTML desde un volumen local"

# -----------------------------------------------------------------------------
# 3. CONFIGURACIÓN DE NGINX
# -----------------------------------------------------------------------------
COPY nginx.conf /etc/nginx/nginx.conf

# -----------------------------------------------------------------------------
# 4. PERMISOS DE DIRECTORIOS  ← Corrección del error Permission denied
# -----------------------------------------------------------------------------
#  Nginx necesita escribir en estos directorios en tiempo de ejecución:
#
#    /var/cache/nginx   → archivos temporales (client_temp, proxy_temp, etc.)
#    /var/log/nginx     → logs de acceso y errores
#    /var/run/nginx.pid → PID del proceso master
#
#  Por defecto pertenecen a ROOT. Al correr como usuario "nginx" (no-root),
#  Nginx falla con:
#    "mkdir() /var/cache/nginx/client_temp failed (13: Permission denied)"
#
#  ⚠️  REGLA: chown debe ejecutarse ANTES del "USER nginx"
#      Solo root puede cambiar dueños. Una vez que usamos USER nginx,
#      perdemos ese privilegio para siempre en el build.
#
#  Encadenamos en un solo RUN para minimizar capas y tamaño de imagen.
# -----------------------------------------------------------------------------
RUN chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx \
    && touch /var/run/nginx.pid \
    && chown nginx:nginx /var/run/nginx.pid

# -----------------------------------------------------------------------------
# 5. USUARIO NO-ROOT  ← Seguridad: principio de mínimo privilegio
# -----------------------------------------------------------------------------
#  A partir de aquí, todo corre como "nginx" (no-root).
#  Si Nginx fuera comprometido, el atacante solo tiene permisos de "nginx".
#  Por eso usamos el puerto 8080 en nginx.conf: los puertos < 1024
#  requieren root en Linux.
# -----------------------------------------------------------------------------
USER nginx

# -----------------------------------------------------------------------------
# 6. PUERTO EXPUESTO (documentación)
# -----------------------------------------------------------------------------
#  EXPOSE documenta el puerto interno. No abre nada en el host.
#  El mapeo host:contenedor lo hace Compose con "ports".
# -----------------------------------------------------------------------------
EXPOSE 8080

# -----------------------------------------------------------------------------
# 7. HEALTHCHECK
# -----------------------------------------------------------------------------
#  Docker verifica automáticamente si el contenedor está sano.
#  3 fallos consecutivos → contenedor marcado "unhealthy".
# -----------------------------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1

# -----------------------------------------------------------------------------
# 8. COMANDO DE INICIO
# -----------------------------------------------------------------------------
#  Forma JSON: Nginx recibe SIGTERM directamente (apagado graceful).
#  "daemon off" → corre en foreground, requerido por Docker.
# -----------------------------------------------------------------------------
CMD ["nginx", "-g", "daemon off;"]
