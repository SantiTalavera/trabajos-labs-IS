# 04 - Git y GitHub por SSH desde la VM

## Objetivo

Poder hacer `git clone`, `git pull`, `git commit` y `git push` desde Rocky hacia GitHub sin usar contraseña de GitHub.

GitHub no permite push con contraseña normal por HTTPS. Hay que usar SSH o token.

## Instalar Git

```bash
sudo dnf install -y git
git --version
```

## Configurar identidad global

```bash
git config --global user.name "Santiago Talavera"
git config --global user.email "santiago.talavera@alu.frlp.utn.edu.ar"
```

Verificar:

```bash
git config --global --list
```

## Generar clave SSH en la VM

```bash
ssh-keygen -t ed25519 -C "santiago.talavera@alu.frlp.utn.edu.ar"
```

Presionar Enter en las opciones por defecto.

## Mostrar clave pública

```bash
cat ~/.ssh/id_ed25519.pub
```

Copiar toda la línea. Debe empezar con:

```text
ssh-ed25519
```

y terminar con el email.

## Agregar clave a GitHub

En GitHub:

```text
Settings → SSH and GPG keys → New SSH key
```

Pegar la clave pública en `Key`.

## Probar autenticación

En la VM:

```bash
ssh -T git@github.com
```

La primera vez pregunta:

```text
Are you sure you want to continue connecting?
```

Responder:

```text
yes
```

Resultado esperado:

```text
Hi <usuario>! You've successfully authenticated...
```

## Cambiar remoto de HTTPS a SSH

Ver remoto actual:

```bash
git remote -v
```

Si aparece algo como:

```text
https://github.com/SantiTalavera/trabajos-labs-IS.git
```

cambiarlo a SSH:

```bash
git remote set-url origin git@github.com:SantiTalavera/trabajos-labs-IS.git
```

Verificar:

```bash
git remote -v
```

Debe quedar:

```text
origin  git@github.com:SantiTalavera/trabajos-labs-IS.git (fetch)
origin  git@github.com:SantiTalavera/trabajos-labs-IS.git (push)
```

## Flujo normal

```bash
git status
git add .
git commit -m "mensaje"
git push
```

## Si aparece este error

```text
Password authentication is not supported for Git operations.
```

Significa que el remoto está usando HTTPS. Cambiarlo a SSH como se indicó arriba.

## Si GitHub rechaza la clave

El contenido pegado debe ser la clave pública completa:

```text
ssh-ed25519 AAAA... email
```

No copiar la clave privada. La pública termina en `.pub`.
