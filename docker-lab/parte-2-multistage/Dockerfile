# =============================================================================
#  PARTE 2 — Dockerfile Multi-Stage: Build Optimizado + Live Reload
# =============================================================================
#
#  ¿Qué es un Multi-Stage Build?
#  ------------------------------
#  Es una técnica que usa MÚLTIPLES instrucciones FROM en un Dockerfile.
#  Cada FROM inicia una nueva etapa (stage) con su propia imagen base.
#
#  La clave: podés COPIAR artefactos de una etapa a otra.
#  La imagen final solo contiene lo que copiaste → imagen mínima y segura.
#
#  Analogía con construcción de un edificio:
#    🏗️ Stage "builder" = Obra en construcción (andamios, herramientas, polvo)
#    🏢 Stage "production" = Edificio terminado (solo lo que necesita el usuario)
#
#  Sin multi-stage: imagen final incluye compiladores, npm, etc. (~800MB)
#  Con multi-stage: imagen final solo tiene Nginx + tu web (~25MB) 🎯
#
#  Flujo de este Dockerfile:
#  -------------------------
#    [Stage 1: builder]
#    Node.js → instala dependencias → procesa/optimiza archivos
#         ↓ COPY --from=builder (solo los archivos finales)
#    [Stage 2: production]
#    Nginx:alpine → sirve los archivos ya procesados
#
# =============================================================================

# =============================================================================
#  STAGE 1: BUILDER
#  ─────────────────
#  En esta etapa simulamos un proceso de "build" realista:
#  como ocurre en proyectos React, Vue, o con preprocesadores CSS.
#
#  En tu proyecto real, aquí correrías:
#    npm install && npm run build
#    (o yarn, pnpm, etc.)
#
#  Para mantener el ejemplo simple con HTML puro, usamos Node para
#  copiar y procesar los archivos del directorio src/.
# =============================================================================

# El alias "AS builder" nombra a esta etapa para referenciarla después
FROM node:20-alpine AS builder

# ── Metadatos de la etapa ────────────────────────────────────────────────────
LABEL stage="builder"

# ── Directorio de trabajo ────────────────────────────────────────────────────
# WORKDIR crea el directorio si no existe y lo establece como CWD.
# Todos los comandos siguientes se ejecutan desde aquí.
# Buena práctica: usar /app como convención estándar.
WORKDIR /app

# ── Instalación de dependencias (cacheado eficientemente) ────────────────────
# Truco de optimización de capas Docker:
#
# Docker construye por CAPAS. Cada instrucción (RUN, COPY, ADD) crea
# una capa nueva. Docker cachea las capas y solo reconstruye desde la
# primera capa que cambió.
#
# ❌ MAL (ineficiente):
#   COPY . .
#   RUN npm install
#   → Cualquier cambio en el código invalida el caché de "npm install"
#
# ✅ BIEN (eficiente):
#   COPY package*.json ./     ← Esta capa cambia SOLO cuando cambian deps
#   RUN npm install           ← Se cachea si no cambiaron las deps
#   COPY . .                  ← Solo esta capa cambia con el código
#
# Resultado: npm install solo corre cuando cambias package.json, no
# en cada cambio de código. Builds mucho más rápidos. ⚡
# ────────────────────────────────────────────────────────────────────────────

# Primero copiamos SOLO los archivos de dependencias
COPY package*.json ./

# Instalamos dependencias
# --omit=dev → excluye devDependencies (solo lo necesario para el build)
# ci en vez de install → reproducible y más rápido en CI/CD
RUN npm ci --omit=dev 2>/dev/null || true

# Ahora copiamos el resto del código fuente
# (esta capa se invalida si cambia cualquier archivo fuente)
COPY src/ ./src/

# ── Paso de "build" ──────────────────────────────────────────────────────────
# En un proyecto real esto sería: npm run build
# Aquí procesamos los archivos: los copiamos al directorio dist/
# (simula lo que haría un bundler como Vite, Webpack o Parcel)
#
# Buenas prácticas en el RUN:
#   && encadena comandos en una sola capa (menos capas = imagen más pequeña)
#   mkdir -p crea directorios de forma segura
# ────────────────────────────────────────────────────────────────────────────
RUN mkdir -p dist && \
    cp -r src/. dist/ && \
    echo "✅ Build completado: $(date)" > dist/build-info.txt && \
    echo "   Archivos generados:" >> dist/build-info.txt && \
    ls -lh dist/ >> dist/build-info.txt

# =============================================================================
#  STAGE 2: PRODUCTION
#  ────────────────────
#  Esta etapa construye la imagen FINAL.
#  Parte desde cero con una imagen limpia de Nginx.
#  Solo copia los artefactos del stage "builder" — NADA MÁS.
#
#  La imagen final NO contiene:
#    ✗ Node.js
#    ✗ npm
#    ✗ Código fuente original
#    ✗ node_modules
#    ✗ Herramientas de desarrollo
#
#  Solo contiene:
#    ✔ Nginx (servidor web)
#    ✔ Los archivos HTML/CSS/JS ya procesados
#    ✔ Nuestra configuración de Nginx
# =============================================================================

FROM nginx:1.27-alpine AS production

# ── Metadatos ─────────────────────────────────────────────────────────────────
LABEL maintainer="docker-lab@example.com"
LABEL version="2.0"
LABEL description="Parte 2: Multi-stage build - Nginx optimizado para producción"
LABEL stage="production"

# ── Copia de artefactos del stage anterior ────────────────────────────────────
# --from=builder indica de qué stage copiar
# Copiamos SOLO el directorio dist/ (el build final)
# Los ~200MB de node_modules del builder quedan descartados
COPY --from=builder /app/dist /usr/share/nginx/html

# ── Configuración de Nginx ────────────────────────────────────────────────────
COPY nginx.conf /etc/nginx/nginx.conf

# ── Permisos de archivos ──────────────────────────────────────────────────────
# Aseguramos que el usuario nginx pueda leer los archivos copiados.
# También le damos acceso a los directorios de cache y logs que necesita.
#
# Hacemos todo en un RUN encadenado para:
#   1. Minimizar capas (menos tamaño de imagen)
#   2. No dejar rastros de operaciones intermedias en la imagen final
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

# ── Usuario no-root ───────────────────────────────────────────────────────────
USER nginx

# ── Puerto expuesto ───────────────────────────────────────────────────────────
EXPOSE 8080

# ── Healthcheck ───────────────────────────────────────────────────────────────
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1

# ── Comando de inicio ─────────────────────────────────────────────────────────
CMD ["nginx", "-g", "daemon off;"]

# =============================================================================
#  RESUMEN DEL RESULTADO:
#
#  Stage builder  (node:20-alpine)  → ~200MB  [descartado]
#  Stage production (nginx:alpine)  → ~25MB   [imagen final]
#
#  Reducción: ~87% menos de tamaño vs una imagen con Node incluido.
#  Además: sin Node.js en producción = menor superficie de ataque.
# =============================================================================
