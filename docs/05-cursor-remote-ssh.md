# 05 - Cursor Remote SSH

## Objetivo

Abrir los directorios de la VM Rocky desde Cursor en Windows usando Remote SSH.

Esto permite editar archivos de la VM y ejecutar terminales dentro de Rocky sin usar la consola de VirtualBox.

## Requisitos

- VM encendida
- SSH activo en Rocky
- Port forwarding configurado:

```text
Host port: 2222
Guest port: 22
```

- Poder entrar desde PowerShell:

```powershell
ssh root@localhost -p 2222
```

## Configurar archivo SSH en Windows

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

Probar desde PowerShell:

```powershell
ssh rocky-vm
```

## Conectar Cursor

En Cursor:

1. `Ctrl + Shift + P`
2. Buscar: `Remote-SSH: Connect to Host...`
3. Elegir: `rocky-vm`
4. Seleccionar Linux si pregunta el tipo de sistema.
5. Ingresar contraseña si la pide.

## Abrir carpeta remota

Una vez conectado:

```text
File → Open Folder
```

Abrir, por ejemplo:

```text
/root/dev
```

o:

```text
/root/trabajos-labs-IS
```

## Recomendación de estructura en la VM

```bash
mkdir -p ~/dev
cd ~/dev
git clone git@github.com:SantiTalavera/trabajos-labs-IS.git
```

Luego abrir:

```text
/root/dev/trabajos-labs-IS
```

## Local vs remoto

No conviene mezclar directamente la carpeta local de Windows con la carpeta remota de Rocky.

Recomendación:

- Windows: apuntes, documentación, material general.
- Rocky: laboratorios Linux/Docker/Node.
- GitHub: sincronización entre ambos.

## Ventajas de Remote SSH

- Copiar y pegar funciona desde la terminal de Cursor.
- Docker corre dentro de Rocky.
- Los comandos se ejecutan en Linux real.
- No se depende de la consola TTY de VirtualBox.
