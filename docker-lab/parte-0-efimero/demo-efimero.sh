#!/usr/bin/env bash
# =============================================================================
#  PARTE 0 — Demo: Lo Efímero de los Contenedores Docker
#  Ejecutar desde: parte-0-efimero/
# =============================================================================
#
#  CONCEPTO CENTRAL:
#  Un contenedor Docker es como una máquina virtual muy liviana que
#  NACE y MUERE con su proceso principal. Todo lo que escribís dentro
#  (archivos, datos, configuraciones) desaparece cuando el contenedor
#  se destruye... A MENOS que uses volúmenes.
#
#  Esta demo lo prueba de forma práctica con 6 experimentos.
#
# =============================================================================

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m';    GREEN='\033[0;32m';  YELLOW='\033[1;33m'
CYAN='\033[0;36m';   BOLD='\033[1m';      RESET='\033[0m'
BLUE='\033[0;34m';   MAGENTA='\033[0;35m'; DIM='\033[2m'

# ── Helpers ───────────────────────────────────────────────────────────────────
header() {
  echo ""
  echo -e "${BOLD}${CYAN}"
  echo    "  ╔══════════════════════════════════════════════════════╗"
  printf  "  ║  %-52s  ║\n" "$1"
  echo    "  ╚══════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
}

experimento() {
  echo ""
  echo -e "${BOLD}${YELLOW}  🧪 EXPERIMENTO $1: $2${RESET}"
  echo -e "${DIM}  ──────────────────────────────────────────────────────${RESET}"
  echo ""
}

cmd() {
  # Muestra el comando con formato de terminal y lo ejecuta
  echo -e "  ${DIM}\$${RESET} ${GREEN}$*${RESET}"
  eval "$*"
  echo ""
}

cmd_show() {
  # Solo muestra el comando, no lo ejecuta (para explicar antes de correr)
  echo -e "  ${DIM}\$${RESET} ${GREEN}$*${RESET}"
}

ok()     { echo -e "  ${GREEN}✅  $1${RESET}"; }
fail()   { echo -e "  ${RED}❌  $1${RESET}"; }
info()   { echo -e "  ${BLUE}ℹ   $1${RESET}"; }
lesson() { echo -e "\n  ${BOLD}${MAGENTA}💡 LECCIÓN: $1${RESET}\n"; }
ask()    { echo -e "\n  ${BOLD}  👉  $1${RESET}"; read -p "     Presioná ENTER para continuar..." _; echo ""; }
warn()   { echo -e "  ${YELLOW}⚠️   $1${RESET}"; }

# ─────────────────────────────────────────────────────────────────────────────
#  BIENVENIDA
# ─────────────────────────────────────────────────────────────────────────────
clear
echo ""
echo -e "${BOLD}${CYAN}"
echo "   ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗ "
echo "   ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗"
echo "   ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝"
echo "   ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗"
echo "   ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║"
echo "   ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo -e "${RESET}"
echo -e "${BOLD}   PARTE 0 — La Naturaleza Efímera de los Contenedores${RESET}"
echo ""
echo -e "   Docker no es una máquina virtual tradicional."
echo -e "   Un contenedor es un ${BOLD}proceso aislado${RESET} con su propio"
echo -e "   filesystem, red y recursos — pero es ${RED}${BOLD}temporal${RESET}."
echo ""
echo -e "   Vamos a probarlo con 6 experimentos prácticos."
echo ""
ask "¿Listos? Comenzamos."

# =============================================================================
#  EXPERIMENTO 1: El contenedor más simple del mundo
# =============================================================================
experimento 1 "Corriendo nuestro primer contenedor"

info "El comando 'docker run' crea Y ejecuta un contenedor."
info "Sintaxis básica:"
echo ""
echo -e "    ${CYAN}docker run [opciones] <imagen> [comando]${RESET}"
echo ""
info "Vamos a correr un contenedor Alpine Linux que imprime un mensaje:"
echo ""

cmd docker run --rm alpine:latest echo "¡Hola desde adentro de un contenedor!"

ok "El contenedor corrió, imprimió el mensaje y se destruyó."
info "Duración de vida: menos de 1 segundo."
info "El flag --rm borra el contenedor automáticamente al terminar."

lesson "Un contenedor vive mientras vive su proceso principal.
         Cuando el proceso termina, el contenedor muere."

ask "¿Viste el mensaje? Seguimos."

# =============================================================================
#  EXPERIMENTO 2: El filesystem es temporal
# =============================================================================
experimento 2 "Creamos un archivo dentro de un contenedor"

info "Vamos a crear un archivo dentro de un contenedor y luego"
info "verificar que desaparece cuando el contenedor se destruye."
echo ""
info "PASO A: Creamos un archivo dentro del contenedor:"
echo ""

cmd docker run --name contenedor-escritura alpine:latest \
    sh -c "echo 'Archivo secreto 🔐' > /tmp/mi-archivo.txt && cat /tmp/mi-archivo.txt"

ok "El archivo existe DENTRO del contenedor mientras corre."
echo ""
info "PASO B: Ahora BORRAMOS el contenedor:"
echo ""

cmd docker rm contenedor-escritura

info "PASO C: Intentamos recuperar el archivo corriendo un nuevo contenedor:"
echo ""

cmd docker run --rm alpine:latest sh -c "cat /tmp/mi-archivo.txt 2>&1 || echo '>>> ARCHIVO NO ENCONTRADO <<<'"

fail "El archivo desapareció. El nuevo contenedor empieza desde cero."

lesson "Cada contenedor arranca con el filesystem LIMPIO de su imagen.
         Nada persiste entre ejecuciones. El disco es efímero."

ask "¿Quedó claro? Continuamos con el experimento 3."

# =============================================================================
#  EXPERIMENTO 3: Contenedores son instancias independientes
# =============================================================================
experimento 3 "Múltiples contenedores de la misma imagen son independientes"

info "Si corremos 2 contenedores de la misma imagen, cada uno tiene"
info "su propio filesystem AISLADO. Los cambios en uno no afectan al otro."
echo ""
info "Levantamos dos contenedores en segundo plano (flag -d = detached):"
echo ""

cmd docker run -d --name contenedor-A alpine:latest sleep 60
cmd docker run -d --name contenedor-B alpine:latest sleep 60

info "Escribimos un archivo diferente en cada uno:"
echo ""

cmd docker exec contenedor-A sh -c "echo 'Soy el contenedor A 🔵' > /tmp/identidad.txt"
cmd docker exec contenedor-B sh -c "echo 'Soy el contenedor B 🔴' > /tmp/identidad.txt"

info "Leemos el archivo desde cada contenedor:"
echo ""

echo -e "  ${DIM}\$${RESET} ${GREEN}docker exec contenedor-A cat /tmp/identidad.txt${RESET}"
docker exec contenedor-A cat /tmp/identidad.txt
echo ""

echo -e "  ${DIM}\$${RESET} ${GREEN}docker exec contenedor-B cat /tmp/identidad.txt${RESET}"
docker exec contenedor-B cat /tmp/identidad.txt
echo ""

ok "Mismo archivo, misma imagen, contenidos completamente diferentes."
echo ""
info "Limpiamos los contenedores:"
echo ""

cmd docker rm -f contenedor-A contenedor-B

lesson "La imagen es la plantilla. El contenedor es la instancia.
         Podés tener 100 contenedores de la misma imagen, todos aislados."

ask "Entendido. Vamos al experimento 4."

# =============================================================================
#  EXPERIMENTO 4: ¿Qué pasa si el proceso dentro falla?
# =============================================================================
experimento 4 "El contenedor muere cuando muere su proceso"

info "Corremos Nginx (servidor web) y luego matamos el proceso:"
echo ""

cmd docker run -d --name nginx-test -p 9999:80 nginx:alpine

info "Nginx está corriendo. Hacemos un request:"
echo ""
sleep 1

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9999)
ok "Nginx responde: HTTP $HTTP_CODE"
echo ""

info "Ahora matamos el proceso nginx dentro del contenedor:"
echo ""

cmd docker exec nginx-test sh -c "kill 1" || true
sleep 1

STATUS=$(docker inspect --format='{{.State.Status}}' nginx-test 2>/dev/null || echo "removed")
echo -e "  Estado del contenedor: ${RED}${BOLD}$STATUS${RESET}"
echo ""

fail "El contenedor se detuvo porque su proceso principal murió."
echo ""
info "Si hubiéramos usado '--restart unless-stopped' en Compose,"
info "Docker lo hubiera reiniciado automáticamente."
echo ""

cmd docker rm -f nginx-test 2>/dev/null || true

lesson "El proceso principal es el 'corazón' del contenedor.
         PID 1 muere → contenedor muere. Por eso Docker monitorea PID 1."

ask "¡Interesante! Experimento 5."

# =============================================================================
#  EXPERIMENTO 5: La solución — Volúmenes
# =============================================================================
experimento 5 "La solución: persistir datos con volúmenes"

info "Los volúmenes viven FUERA del contenedor, en el sistema de Docker."
info "Sobreviven aunque el contenedor sea destruido."
echo ""
info "PASO A: Creamos un volumen nombrado:"
echo ""

cmd docker volume create mi-primer-volumen

info "PASO B: Corremos un contenedor que escribe en el volumen:"
echo ""

cmd docker run --rm \
    -v mi-primer-volumen:/datos \
    alpine:latest \
    sh -c "echo 'Dato persistido: \$(date)' >> /datos/registro.txt && cat /datos/registro.txt"

ok "El contenedor terminó y fue destruido (--rm)."
echo ""
info "PASO C: Corremos un NUEVO contenedor diferente, mismo volumen:"
echo ""

cmd docker run --rm \
    -v mi-primer-volumen:/datos \
    alpine:latest \
    sh -c "echo 'Segundo contenedor: \$(date)' >> /datos/registro.txt && cat /datos/registro.txt"

ok "¡El archivo tiene entradas de AMBOS contenedores!"
echo ""
info "PASO D: El volumen existe aunque no haya ningún contenedor:"
echo ""

cmd docker volume inspect mi-primer-volumen

info "Limpiamos el volumen:"
cmd docker volume rm mi-primer-volumen

lesson "Volumen = almacenamiento que vive fuera del contenedor.
         Persiste entre reinicios, actualizaciones y recreaciones."

ask "Clarísimo. Último experimento."

# =============================================================================
#  EXPERIMENTO 6: Bind mount — tu disco como volumen
# =============================================================================
experimento 6 "Bind mount: tu carpeta local dentro del contenedor"

info "Un bind mount conecta una carpeta de TU máquina con el contenedor."
info "Este es exactamente el mecanismo que usa la Parte 1 del lab"
info "para el Hot Reload de los archivos HTML."
echo ""
info "PASO A: Creamos una carpeta local con un archivo:"
echo ""

mkdir -p /tmp/docker-demo-bindmount
echo "Versión 1 — $(date '+%H:%M:%S')" > /tmp/docker-demo-bindmount/mensaje.txt

cmd cat /tmp/docker-demo-bindmount/mensaje.txt

info "PASO B: Montamos la carpeta dentro de un contenedor:"
echo ""

cmd docker run --rm \
    -v /tmp/docker-demo-bindmount:/app:ro \
    alpine:latest \
    cat /app/mensaje.txt

info "PASO C: Modificamos el archivo desde el HOST (sin tocar el contenedor):"
echo ""

echo "Versión 2 — $(date '+%H:%M:%S') ← ¡Cambio desde el host!" > /tmp/docker-demo-bindmount/mensaje.txt
cmd cat /tmp/docker-demo-bindmount/mensaje.txt

info "PASO D: El MISMO contenedor (nueva ejecución) ya ve el cambio:"
echo ""

cmd docker run --rm \
    -v /tmp/docker-demo-bindmount:/app:ro \
    alpine:latest \
    cat /app/mensaje.txt

ok "¡El contenedor leyó el archivo actualizado sin ningún rebuild!"
echo ""
info "Esto es exactamente lo que hace Nginx en modo DEV:"
info "lee los archivos HTML de TU disco en cada request HTTP."
echo ""

rm -rf /tmp/docker-demo-bindmount

lesson "Bind mount = tu disco visible desde dentro del contenedor.
         Perfecto para desarrollo. Para producción se prefieren volúmenes
         nombrados o datos embebidos en la imagen."

# =============================================================================
#  RESUMEN FINAL
# =============================================================================
header "RESUMEN: Lo que aprendimos"

echo -e "  ${BOLD}Los contenedores son efímeros por diseño:${RESET}"
echo ""
echo -e "  ${RED}❌  Sin volumen${RESET}  → datos desaparecen al destruir el contenedor"
echo -e "  ${GREEN}✅  Volumen nombrado${RESET} → datos persisten, independientes del contenedor"
echo -e "  ${GREEN}✅  Bind mount${RESET}      → tu disco, visible desde el contenedor (hot reload)"
echo ""
echo -e "  ${BOLD}Mapa mental:${RESET}"
echo ""
echo -e "    Imagen   →  Plantilla (inmutable, compartida)"
echo -e "    Contenedor → Instancia viva (efímera, aislada)"
echo -e "    Volumen  →  Almacenamiento (persistente, externo)"
echo ""
echo -e "  ${BOLD}docker run vs docker compose:${RESET}"
echo ""
echo -e "    ${YELLOW}docker run${RESET}  → útil para probar, explorar, correr algo rápido"
echo -e "    ${CYAN}docker compose${RESET} → para aplicaciones con configuración, redes,"
echo -e "                      volúmenes y múltiples servicios definidos en YAML"
echo ""
echo -e "  ${DIM}Próximo paso → Parte 1: Nginx + Volumen Local con Docker Compose${RESET}"
echo ""
echo -e "${BOLD}${GREEN}  🎉 Demo completada. ¡Bienvenidos al mundo de los contenedores!${RESET}"
echo ""
