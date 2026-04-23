# 01 - VirtualBox: red, NAT, port forwarding y SSH

## Objetivo

Permitir que Windows se conecte a la VM Rocky por SSH y que servicios levantados dentro de la VM sean accesibles desde el host.

## Configuración de red en VirtualBox

Con la VM apagada:

1. Abrir VirtualBox.
2. Seleccionar la VM.
3. Ir a **Configuración**.
4. Entrar en **Red**.
5. En **Adaptador 1**, seleccionar:

```text
Conectado a: NAT
```

6. Desplegar **Avanzadas**.
7. Entrar en **Redirección de puertos**.

## Reglas de port forwarding usadas

### SSH

```text
Nombre: ssh
Protocolo: TCP
IP anfitrión: vacío
Puerto anfitrión: 2222
IP invitado: vacío
Puerto invitado: 22
```

Esto permite conectarse desde Windows con:

```powershell
ssh root@localhost -p 2222
```

o con un alias configurado:

```powershell
ssh rocky-vm
```

### Nginx / pruebas Docker

```text
Nombre: nginx
Protocolo: TCP
IP anfitrión: vacío
Puerto anfitrión: 8080
IP invitado: vacío
Puerto invitado: 8080
```

Esto permite abrir desde Windows:

```text
http://localhost:8080
```

## Instalar y habilitar SSH en Rocky

Dentro de Rocky:

```bash
sudo dnf install -y openssh-server
sudo systemctl enable --now sshd
sudo systemctl status sshd
```

Verificar que SSH escuche:

```bash
ss -tulpn | grep sshd
```

## Conectarse desde Windows

En PowerShell:

```powershell
ssh root@localhost -p 2222
```

La primera vez puede preguntar si se confía en el host. Responder:

```text
yes
```

## Configurar alias SSH en Windows

Editar:

```text
C:\Users\santi\.ssh\config
```

Agregar:

```sshconfig
Host rocky-vm
    HostName localhost
    User root
    Port 2222
```

Luego se puede entrar con:

```powershell
ssh rocky-vm
```

## Nota sobre root

Para laboratorio se usó `root`. En un entorno más prolijo conviene crear un usuario normal:

```bash
useradd -m santi
passwd santi
usermod -aG wheel santi
```

Y luego cambiar el config de Windows:

```sshconfig
Host rocky-vm
    HostName localhost
    User santi
    Port 2222
```
