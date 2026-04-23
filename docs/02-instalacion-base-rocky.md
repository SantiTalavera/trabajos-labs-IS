# 02 - Instalación base de Rocky para desarrollo

## Objetivo

Dejar Rocky Linux 9.7 con herramientas necesarias para desarrollo y administración.

## Paquetes base

El script de setup instala:

- `dnf-plugins-core`
- repositorio CRB
- EPEL
- Development Tools
- Git
- curl / wget
- nano / vim
- unzip / zip / tar
- htop / tree / jq / rsync
- gcc / g++ / make / cmake / gdb
- Python 3 / pip / virtualenv
- Java 17
- Maven
- PostgreSQL client
- herramientas de red
- Docker
- Docker Compose
- nvm
- Node.js LTS
- pnpm
- TypeScript
- Prisma CLI
- Gradle

## Ejecutar el script

Desde la VM:

```bash
chmod +x scripts/setup-dev-rocky-v3.sh
./scripts/setup-dev-rocky-v3.sh
```

Si el script está en otro lugar:

```bash
chmod +x setup-dev-rocky-v3.sh
./setup-dev-rocky-v3.sh
```

## Cerrar sesión después del setup

Al finalizar, cerrar sesión y volver a entrar:

```bash
exit
```

Esto es importante para que se apliquen:

- grupo `docker`
- variables de entorno
- PATH de herramientas
- configuración de `nvm`

## Verificaciones esperadas

```bash
git --version
python3 --version
pip3 --version
java -version
mvn -version
psql --version
node -v
npm -v
pnpm -v
tsc -v
prisma -v
gradle -v
docker --version
docker compose version
```

## Si pnpm, Prisma o Gradle no aparecen

Puede ser un problema de PATH o de instalación parcial.

Corrección rápida:

```bash
source ~/.bashrc
source ~/.bash_profile 2>/dev/null || true
hash -r
```

Verificar:

```bash
pnpm -v
prisma -v
gradle -v
```

Si sigue faltando:

```bash
corepack enable
corepack prepare pnpm@latest --activate
npm install -g prisma typescript ts-node nodemon
```

Para Gradle:

```bash
ls /opt/gradle
```

Si existe una carpeta tipo `gradle-9.4.1`, agregar al shell:

```bash
cat >> ~/.bash_profile <<'EOF'

export GRADLE_HOME=/opt/gradle/gradle-9.4.1
export PATH=$GRADLE_HOME/bin:$PATH
EOF

source ~/.bash_profile
gradle -v
```
