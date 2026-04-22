# 🐳 Parte 0 — La Naturaleza Efímera de los Contenedores

> **Objetivo:** Entender con las manos qué es un contenedor, por qué los datos
> desaparecen y cómo los volúmenes resuelven ese problema.
> Cada comando lo vas a tipear vos. Sin copiar y pegar. Sin scripts.

---

## Antes de empezar — conceptos mínimos

Un **contenedor** no es una máquina virtual. Es un **proceso** que corre
aislado del resto del sistema. Tiene su propio filesystem, su propia red,
sus propios recursos — pero cuando ese proceso termina, el contenedor
desaparece y se lleva todo con él.

Tres piezas clave:

```
IMAGEN       →  la plantilla (receta, inmutable, compartida)
CONTENEDOR   →  la instancia viva (efímera, aislada)
VOLUMEN      →  el almacenamiento externo (persistente)
```

Ahora vamos a probarlo. Abrí una terminal y seguí cada paso.

---
# Primer Paso - Script automatizado con guia interactiva

## Cómo correr la demo

```bash
cd parte-0-efimero
chmod +x demo-efimero.sh
./demo-efimero.sh
```

La demo es **interactiva**: espera que el alumno presione Enter entre cada
experimento para que pueda leer, preguntar y reflexionar.

---

## Comandos clave aprendidos

```bash
# Correr un contenedor y borrarlo al terminar
docker run --rm alpine echo "Hola"

# Correr en background (detached)
docker run -d --name mi-app nginx:alpine

# Ejecutar un comando en un contenedor corriendo
docker exec mi-app sh -c "ls /etc"

# Montar un volumen nombrado
docker run -v mi-volumen:/datos alpine sh -c "echo 'hola' > /datos/f.txt"

# Montar una carpeta local (bind mount)
docker run -v $(pwd)/html:/usr/share/nginx/html nginx:alpine

# Ver todos los contenedores (incluyendo detenidos)
docker ps -a

# Borrar un contenedor a la fuerza
docker rm -f mi-app

# Ver volúmenes
docker volume ls
docker volume inspect mi-volumen
docker volume rm mi-volumen
```

---

# Segundo Paso - Hazlo tu mismo 

Abri una terminal y "tipea" estos comandos

---

##  Experimento 1 — El contenedor más simple del mundo

Un contenedor nace, ejecuta su tarea y muere. Vamos a verlo en tiempo real.

**Tipeá esto:**

```bash
docker run alpine:latest echo "Hola desde adentro de un contenedor"
```

Deberías ver el mensaje impreso en pantalla. El contenedor ya murió.

**Ahora verificá que no quedó ningún rastro:**

```bash
docker ps
```

`docker ps` muestra los contenedores **en ejecución**. No hay ninguno porque
el nuestro terminó. Pero el contenedor detenido sí quedó registrado:

```bash
docker ps -a
```

El flag `-a` (all) muestra **todos**, incluyendo los detenidos. Vas a ver
el contenedor con estado `Exited`.

**Borralo manualmente:**

```bash
docker rm <pegá aquí el CONTAINER ID o NAME que apareció en el paso anterior>
```

**Truco:** la próxima vez que no te importe conservar el contenedor,
usá `--rm` y Docker lo borra solo cuando termina:

```bash
docker run --rm alpine:latest echo "Este contenedor se autodestruye"
docker ps -a
```

Esta vez no aparece en la lista. Nació y murió sin dejar rastro.

> 💡 **Lección:** Un contenedor vive mientras vive su proceso principal.
> Cuando el proceso termina, el contenedor termina. `--rm` limpia el registro.

---

##  Experimento 2 — El filesystem es temporal

Vamos a crear un archivo dentro de un contenedor y luego probar que
desaparece cuando el contenedor se destruye.

**Paso A — Creá un contenedor con nombre y escribí un archivo adentro:**

```bash
docker run --name caja alpine:latest sh -c "echo 'mi secreto' > /tmp/archivo.txt && cat /tmp/archivo.txt"
```

El comando hace dos cosas encadenadas con `&&`:
1. Crea `/tmp/archivo.txt` con el texto `mi secreto`
2. Lo imprime para que veas que existe

**Paso B — El contenedor terminó, pero todavía existe (detenido). Borralo:**

```bash
docker rm caja
```

**Paso C — Corré un contenedor nuevo e intentá leer el archivo:**

```bash
docker run --rm alpine:latest cat /tmp/archivo.txt
```

Vas a ver un error: `cat: can't open '/tmp/archivo.txt': No such file or directory`

El archivo no existe porque este contenedor arranca desde la imagen limpia,
sin ningún dato de ejecuciones anteriores.

> 💡 **Lección:** Cada contenedor arranca con el filesystem **limpio** de su
> imagen. Lo que escribís dentro de un contenedor muere con ese contenedor.

---

##  Experimento 3 — Dos contenedores son mundos separados

Si corrés dos contenedores de la misma imagen, cada uno tiene su propio
filesystem completamente aislado. Los cambios en uno no afectan al otro.

**Levantá dos contenedores en background con el flag `-d` (detached):**

```bash
docker run -d --name contenedor-A alpine:latest sleep 120
docker run -d --name contenedor-B alpine:latest sleep 120
```

`sleep 120` es el proceso principal: mantiene el contenedor vivo 2 minutos.

**Verificá que ambos están corriendo:**

```bash
docker ps
```

**Escribí un archivo diferente en cada uno con `docker exec`:**

```bash
docker exec contenedor-A sh -c "echo 'Soy A 🔵' > /tmp/quien-soy.txt"
docker exec contenedor-B sh -c "echo 'Soy B 🔴' > /tmp/quien-soy.txt"
```

`docker exec` ejecuta un comando dentro de un contenedor que ya está corriendo.

**Leé el archivo desde cada contenedor:**

```bash
docker exec contenedor-A cat /tmp/quien-soy.txt
docker exec contenedor-B cat /tmp/quien-soy.txt
```

Mismo archivo, misma imagen, contenidos completamente diferentes.
Cada contenedor es un mundo aislado.

**Limpiá:**

```bash
docker rm -f contenedor-A contenedor-B
```

El flag `-f` (force) borra el contenedor aunque esté corriendo, sin necesidad
de detenerlo primero.

> 💡 **Lección:** La imagen es el molde. El contenedor es el objeto fabricado
> con ese molde. Podés tener 100 contenedores de la misma imagen y cada uno
> vive en su propio mundo aislado.

---

##  Experimento 4 — El contenedor muere con su proceso

El proceso que le pasás a `docker run` es el proceso principal (PID 1).
Si ese proceso muere, el contenedor muere. Vamos a comprobarlo.

**Levantá Nginx y publicá su puerto 80 en tu puerto 9999:**

```bash
docker run -d --name nginx-test -p 9999:80 nginx:alpine
```

La sintaxis de `-p` es siempre `PUERTO_HOST:PUERTO_CONTENEDOR`.

**Verificá que responde:**

```bash
curl -I http://localhost:9999
```

Deberías ver `HTTP/1.1 200 OK`. Nginx está vivo.

**Ahora matá el proceso principal desde adentro:**

```bash
docker exec nginx-test kill 1
```

`kill 1` envía la señal SIGTERM al proceso con PID 1 (el proceso principal).

**Verificá el estado del contenedor:**

```bash
docker ps -a
```

El contenedor ahora figura como `Exited`. Nginx murió → el contenedor murió.

```bash
curl -I http://localhost:9999
```

`Connection refused`. Ya no hay nadie escuchando.

**Limpiá:**

```bash
docker rm nginx-test
```

> 💡 **Lección:** PID 1 es el corazón del contenedor. Si ese proceso termina,
> el contenedor termina. Por eso en producción usamos `restart: unless-stopped`
> en Compose: si el proceso falla, Docker lo resucita automáticamente.

---

##  Experimento 5 — La solución: volúmenes nombrados

Los datos se pierden porque viven dentro del contenedor. La solución es
guardarlos **fuera** del contenedor, en un volumen que Docker administra.

**Creá un volumen nombrado:**

```bash
docker volume create mis-datos
```

**Verificá que existe:**

```bash
docker volume ls
```

**Corré un contenedor que escribe en ese volumen:**

```bash
docker run --rm -v mis-datos:/datos alpine:latest sh -c "echo 'entrada 1: $(date)' >> /datos/registro.txt && cat /datos/registro.txt"
```

La sintaxis de `-v` es `NOMBRE_VOLUMEN:RUTA_DENTRO_DEL_CONTENEDOR`.
El contenedor terminó y fue borrado (`--rm`). Pero el volumen sigue existiendo.

**Corré un segundo contenedor completamente diferente, usando el mismo volumen:**

```bash
docker run --rm -v mis-datos:/datos alpine:latest sh -c "echo 'entrada 2: $(date)' >> /datos/registro.txt && cat /datos/registro.txt"
```

El archivo tiene entradas de ambos contenedores. Los datos sobrevivieron.

**Inspeccioná el volumen para ver dónde vive en tu máquina:**

```bash
docker volume inspect mis-datos
```

Buscá el campo `Mountpoint`. Ese es el directorio real en tu disco donde
Docker guarda los datos del volumen.

**Limpiá el volumen:**

```bash
docker volume rm mis-datos
```

> 💡 **Lección:** Un volumen nombrado vive fuera de cualquier contenedor.
> Sobrevive a reinicios, actualizaciones y recreaciones del contenedor.
> Es la forma correcta de persistir datos en producción (bases de datos, etc).

---

##  Experimento 6 — Bind mount: tu carpeta dentro del contenedor

Un bind mount conecta una carpeta **de tu máquina** directamente con
el contenedor. Es diferente a un volumen nombrado: vos elegís exactamente
qué directorio usar y podés ver y editar los archivos con tu editor.

Este es el mecanismo que usa Nginx en el modo DEV de la Parte 2 para
el hot reload.

**Creá una carpeta local y un archivo adentro:**

```bash
mkdir -p /tmp/mi-web
echo "<h1>Versión 1</h1>" > /tmp/mi-web/index.html
cat /tmp/mi-web/index.html
```

**Montá esa carpeta dentro de un contenedor y leé el archivo:**

```bash
docker run --rm -v /tmp/mi-web:/app alpine:latest cat /app/index.html
```

La sintaxis es `RUTA_ABSOLUTA_EN_HOST:RUTA_EN_CONTENEDOR`.

**Modificá el archivo desde tu terminal (sin tocar el contenedor):**

```bash
echo "<h1>Versión 2 — modificada desde el host</h1>" > /tmp/mi-web/index.html
```

**Corré un nuevo contenedor con el mismo bind mount:**

```bash
docker run --rm -v /tmp/mi-web:/app alpine:latest cat /app/index.html
```

El contenedor lee la versión actualizada. No hubo ningún rebuild, no hubo
ningún `docker cp`, no hubo nada especial. El contenedor ve tu disco.

**Probalo con Nginx para verlo en el navegador:**

```bash
docker run -d --name web-local -p 7777:80 -v /tmp/mi-web:/usr/share/nginx/html:ro nginx:alpine
```

Abrí `http://localhost:7777` en el navegador.

Ahora modificá el archivo:

```bash
echo "<h1>¡Cambio en vivo! $(date '+%H:%M:%S')</h1>" > /tmp/mi-web/index.html
```

Recargá el navegador. El cambio aparece **inmediatamente**.
Este es exactamente el hot reload de la Parte 2.

**Limpiá todo:**

```bash
docker rm -f web-local
rm -rf /tmp/mi-web
```

> 💡 **Lección:** El bind mount hace tu disco visible desde el contenedor.
> Los cambios son bidireccionales e instantáneos. Ideal para desarrollo.
> Para producción se prefiere embeber el código en la imagen (multi-stage).

---

## 📋 Resumen de comandos aprendidos

```bash
# ── Ciclo de vida básico ───────────────────────────────────────────────────
docker run <imagen> <comando>           # crear y ejecutar un contenedor
docker run --rm <imagen> <comando>      # igual pero se autodestruye al terminar
docker run -d --name <nombre> <imagen>  # correr en background con nombre
docker ps                               # contenedores en ejecución
docker ps -a                            # todos los contenedores (incluso detenidos)
docker rm <nombre o id>                 # borrar contenedor detenido
docker rm -f <nombre o id>              # borrar contenedor aunque esté corriendo

# ── Interacción con contenedores corriendo ─────────────────────────────────
docker exec <nombre> <comando>          # ejecutar un comando dentro del contenedor
docker exec -it <nombre> sh             # abrir una shell interactiva

# ── Puertos ────────────────────────────────────────────────────────────────
docker run -p 8080:80 <imagen>          # publicar puerto (host:contenedor)

# ── Volúmenes nombrados ────────────────────────────────────────────────────
docker volume create <nombre>           # crear un volumen
docker volume ls                        # listar volúmenes
docker volume inspect <nombre>          # ver detalles (dónde vive en el disco)
docker volume rm <nombre>               # eliminar volumen
docker run -v <volumen>:/ruta <imagen>  # usar un volumen en un contenedor

# ── Bind mounts ────────────────────────────────────────────────────────────
docker run -v /ruta/host:/ruta/contenedor <imagen>     # lectura/escritura
docker run -v /ruta/host:/ruta/contenedor:ro <imagen>  # solo lectura (recomendado)

# ── Limpieza general ───────────────────────────────────────────────────────
docker system prune                     # borrar todo lo que no se está usando
```

---

## 🗺️ El mapa mental completo

```
                        ┌─────────────────┐
                        │  IMAGEN Docker  │  ← plantilla inmutable
                        │  nginx:alpine   │     descargada del registry
                        └────────┬────────┘
                                 │
                    docker run (podés crear N instancias)
                                 │
              ┌──────────────────┼──────────────────┐
              ▼                  ▼                  ▼
        [contenedor-1]    [contenedor-2]    [contenedor-3]
         filesystem         filesystem        filesystem
          efímero            efímero           efímero
              │
              │  -v (bind mount o volumen nombrado)
              ▼
     ┌─────────────────┐
     │    VOLUMEN      │  ← persiste aunque el contenedor muera
     │  (fuera del     │
     │   contenedor)   │
     └─────────────────┘
```

---

## ✅ Checklist — ¿Completaste todo?

Antes de pasar a la Parte 1, verificá que pudiste:

- [ ] Correr un contenedor con `docker run` y ver cómo termina solo
- [ ] Usar `--rm` para que se borre automáticamente
- [ ] Crear un archivo dentro de un contenedor y comprobar que desaparece
- [ ] Correr dos contenedores en paralelo con `-d` y ver que están aislados
- [ ] Usar `docker exec` para ejecutar comandos en un contenedor corriendo
- [ ] Comprobar que el contenedor muere cuando muere su proceso (PID 1)
- [ ] Persistir datos entre dos contenedores usando un volumen nombrado
- [ ] Montar una carpeta local con bind mount y ver cambios en tiempo real

Si pudiste marcar todos los ítems, estás listo para la Parte 1. 🚀

---

*Siguiente paso → [Parte 1: Nginx + Volumen Local con Docker Compose](../parte-1-volumen/)*
