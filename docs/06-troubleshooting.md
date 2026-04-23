# 06 - Troubleshooting

## Docker instalado pero `docker.service` no existe

Síntoma:

```text
Failed to enable unit: Unit file docker.service does not exist.
```

Causa probable: se instaló `docker-ce-cli` y Compose, pero no `docker-ce`.

Solución:

```bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

## `docker --version` funciona pero Docker no corre

Verificar servicio:

```bash
systemctl status docker
```

Iniciar:

```bash
sudo systemctl enable --now docker
```

## `docker run hello-world` funciona

Si aparece:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Docker está OK.

## No puedo acceder a Nginx desde Windows

Si dentro de la VM funciona:

```bash
curl http://localhost:8080
```

pero en Windows falla:

```text
http://localhost:8080
```

entonces el problema no es Docker, sino VirtualBox.

Solución: port forwarding NAT:

```text
Host port: 8080
Guest port: 8080
```

## No puedo copiar y pegar en la consola de VirtualBox

En Linux sin entorno gráfico, el portapapeles compartido de VirtualBox no siempre funciona bien en TTY.

Solución recomendada: usar SSH desde Windows.

```powershell
ssh root@localhost -p 2222
```

o con alias:

```powershell
ssh rocky-vm
```

## Guest Additions no compila

Síntomas:

```text
modprobe: FATAL: Module vboxguest not found
```

o errores en `/var/log/vboxadd-setup.log`.

Causa que ocurrió: versión vieja de Guest Additions no compatible con el kernel de Rocky 9.7.

Solución aplicada:

1. Actualizar VirtualBox en Windows.
2. Insertar nuevamente la ISO de Guest Additions.
3. Instalar dentro de Rocky:

```bash
sudo dnf install -y gcc make perl dkms kernel-devel kernel-headers elfutils-libelf-devel bzip2
sudo mkdir -p /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom
sudo sh /mnt/cdrom/VBoxLinuxAdditions.run
sudo reboot
```

Verificar:

```bash
lsmod | grep vbox
```

## GitHub rechaza usuario y contraseña

Error:

```text
Password authentication is not supported for Git operations.
```

Causa: GitHub no permite push con contraseña normal.

Solución recomendada: usar SSH.

```bash
ssh-keygen -t ed25519 -C "santiago.talavera@alu.frlp.utn.edu.ar"
cat ~/.ssh/id_ed25519.pub
```

Agregar la clave pública en GitHub y cambiar remoto:

```bash
git remote set-url origin git@github.com:SantiTalavera/trabajos-labs-IS.git
git push
```

## Cursor no muestra el host SSH

El archivo `C:\Users\santi\.ssh\config` no debe contener:

```sshconfig
ssh root@localhost -p 2222
```

Debe contener:

```sshconfig
Host rocky-vm
    HostName localhost
    User root
    Port 2222
```

Luego probar:

```powershell
ssh rocky-vm
```

## `pnpm`, `prisma` o `gradle` no encontrados

Corrección rápida:

```bash
source ~/.bashrc
source ~/.bash_profile 2>/dev/null || true
hash -r
```

Si siguen faltando:

```bash
corepack enable
corepack prepare pnpm@latest --activate
npm install -g prisma typescript ts-node nodemon
```

Gradle:

```bash
cat >> ~/.bash_profile <<'EOF'

export GRADLE_HOME=/opt/gradle/gradle-9.4.1
export PATH=$GRADLE_HOME/bin:$PATH
EOF

source ~/.bash_profile
gradle -v
```
