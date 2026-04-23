# Setup de VM Rocky 9.7 para desarrollo

Este repositorio documenta cómo dejar una VM Rocky Linux 9.7 lista para prácticas de desarrollo con Docker, Docker Compose, Git, Node, Java, Maven, PostgreSQL client, SSH y conexión desde Cursor/Windows.

La idea es que si se borra la VM actual, se pueda reconstruir el entorno sin dudas.

## Estructura sugerida

```text
.
├── README.md
├── scripts/
│   └── setup-dev-rocky-v3.sh
└── docs/
    ├── 01-virtualbox-red-y-ssh.md
    ├── 02-instalacion-base-rocky.md
    ├── 03-docker-y-compose.md
    ├── 04-git-github-ssh.md
    ├── 05-cursor-remote-ssh.md
    └── 06-troubleshooting.md
```

## Orden recomendado

1. Crear la VM en VirtualBox con Rocky Linux 9.7.
2. Configurar NAT y port forwarding.
3. Instalar y habilitar SSH en Rocky.
4. Conectarse desde Windows por SSH.
5. Ejecutar `scripts/setup-dev-rocky-v3.sh`.
6. Configurar Git y GitHub SSH.
7. Clonar el repo dentro de la VM.
8. Abrir la VM desde Cursor usando Remote SSH.

## Estado final esperado

Al finalizar, estos comandos deberían funcionar dentro de Rocky:

```bash
docker --version
docker compose version
docker run hello-world

git --version
node -v
npm -v
pnpm -v
tsc -v
prisma -v
psql --version
mvn -version
gradle -v
```

## Nota importante

La VM es una máquina independiente. Si se crea una VM nueva desde cero, hay que reinstalar todo. Si se clona una VM ya preparada o se usa un snapshot, se conserva la configuración.
