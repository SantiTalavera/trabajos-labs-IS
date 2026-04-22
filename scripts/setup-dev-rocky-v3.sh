#!/usr/bin/env bash
set -euo pipefail

echo "==> Actualizando sistema"
sudo dnf update -y

echo "==> Instalando plugins base"
sudo dnf install -y dnf-plugins-core

echo "==> Habilitando CRB y EPEL"
sudo dnf config-manager --set-enabled crb || true
sudo dnf install -y epel-release

echo "==> Actualizando metadata"
sudo dnf update -y

echo "==> Instalando Development Tools"
sudo dnf groupinstall -y "Development Tools"

echo "==> Instalando herramientas generales"
sudo dnf install -y \
  git curl wget nano vim unzip zip tar gzip bzip2 xz which \
  htop tree jq rsync \
  make cmake gcc gcc-c++ gdb \
  openssl-devel readline-devel zlib-devel libffi-devel \
  pkgconf-pkg-config \
  python3 python3-pip python3-virtualenv \
  java-17-openjdk java-17-openjdk-devel \
  maven \
  postgresql \
  net-tools bind-utils lsof telnet nc nmap \
  ripgrep

echo "==> Configurando JAVA_HOME"
JAVA_BIN="$(readlink -f /usr/bin/java || true)"
if [ -n "${JAVA_BIN}" ]; then
  JAVA_HOME_DIR="$(dirname "$(dirname "${JAVA_BIN}")")"
  if ! grep -q 'JAVA_HOME=' "$HOME/.bashrc"; then
    {
      echo ""
      echo "# Java"
      echo "export JAVA_HOME=${JAVA_HOME_DIR}"
      echo 'export PATH=$JAVA_HOME/bin:$PATH'
    } >> "$HOME/.bashrc"
  fi
fi

echo "==> Agregando repo oficial de Docker"
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

echo "==> Instalando Docker y plugins"
sudo dnf install -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

echo "==> Habilitando e iniciando Docker"
sudo systemctl enable --now docker

echo "==> Agregando usuario actual al grupo docker"
sudo usermod -aG docker "$USER" || true

echo "==> Instalando nvm"
export NVM_VERSION="v0.40.4"
if [ ! -d "$HOME/.nvm" ]; then
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

echo "==> Instalando Node.js LTS"
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

echo "==> Activando Corepack y pnpm"
corepack enable
corepack use pnpm@latest-10

echo "==> Instalando utilidades globales de Node"
npm install -g \
  typescript \
  ts-node \
  nodemon \
  prisma

echo "==> Instalando Gradle"
GRADLE_VERSION="9.4.1"
cd /tmp
wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
sudo mkdir -p /opt/gradle
sudo unzip -q -o "gradle-${GRADLE_VERSION}-bin.zip" -d /opt/gradle
rm -f "gradle-${GRADLE_VERSION}-bin.zip"

if ! grep -q 'GRADLE_HOME=' "$HOME/.bashrc"; then
  {
    echo ""
    echo "# Gradle"
    echo "export GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}"
    echo 'export PATH=$GRADLE_HOME/bin:$PATH'
  } >> "$HOME/.bashrc"
fi

echo "==> Creando carpeta base de workspace"
mkdir -p "$HOME/dev"

echo "==> Verificaciones rápidas"
git --version || true
python3 --version || true
pip3 --version || true
java -version || true
mvn -version || true
docker --version || true
docker compose version || true
psql --version || true

if command -v node >/dev/null 2>&1; then
  node --version || true
  npm --version || true
  pnpm --version || true
  tsc --version || true
  prisma --version || true
fi

echo
echo "Listo."
echo "IMPORTANTE:"
echo "1) Cerrá sesión y volvé a entrar."
echo "2) Luego probá:"
echo "   docker run hello-world"
echo "   node -v && npm -v && pnpm -v"
echo "   tsc -v && prisma -v"
echo "   psql --version"
echo "   mvn -version && gradle -v"
