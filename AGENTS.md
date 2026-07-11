# AGENTS.md

## Project overview

L3MON (Node.js/Express Android management suite) bundled with Metasploit inside a Kali Linux Docker container. Git commit messages and METASPLOIT_GUIDE.md are in **Spanish** — the project language is Spanish.

## Architecture

- **`l3mon/`** — the Node.js app (Express + EJS + Socket.IO). Entry point: `l3mon/index.js`.
- **`l3mon/includes/const.js`** — all ports, paths, build commands, and message keys are defined here.
- **`l3mon/includes/databaseGateway.js`** — lowdb v1 flat-file JSON DB (`maindb.json`).
- **`l3mon/app/factory/`** — apktool.jar, sign.jar, pre-decompiled smali for APK building.
- **`Dockerfile`** — Kali Linux + Java 11 + Metasploit + Node 22 + the L3MON app.
- **`docker-compose.yml`** — single `kali` service, ports 8080 (web), 4444 (Socket.IO / MSF listener), 5555 (extra MSF).
- **`start.sh`** — container entrypoint: starts L3MON in background, starts Metasploit listener, then `tail -f /dev/null`.

## Developer commands

```bash
# Local development (no Docker)
cd l3mon && npm install && node index.js
# Server on http://localhost:8080, Socket.IO on 4444

# Docker
docker-compose up -d --build
docker-compose down
```

There are **no lint, typecheck, or test suites**. `npm test` in `l3mon/` just runs `node index.js`.

## Key gotchas

- **No test suite exists.** There is no way to run automated tests.
- **APK building requires Java 8 (1.8.0)** for apktool/sign, but the Dockerfile installs **Java 11** for Metasploit. This is a known tension in `l3mon/includes/apkBuilder.js` which checks for `1.8.0`.
- **`data/maindb.json`** is git-tracked (explicit exception in `.gitignore`). This contains the admin password hash. All other `data/*` is ignored.
- **`config/`** is gitignored — does not exist in the repo but the gitignore entry is present.
- **Socket.IO** listens on port 4444 with `origin: "*"` (open CORS).
- **Default admin password** is `12345` (MD5 hash `827ccb0eea8a706c4c34a16891f84e7b`).
- **Port 8080** is the web UI; **port 4444** is both Socket.IO for device connections and the Metasploit listener port.
- **Docker volumes** mount `./data:/data` and `./data/maindb.json:/root/L3MON-2/maindb.json` for persistence across container restarts.

## Files to watch when editing

- `l3mon/includes/const.js` — changing ports/paths affects both the app and Docker mapping.
- `l3mon/includes/expressRoutes.js` — all HTTP routes.
- `l3mon/includes/apkBuilder.js` — APK build logic, has hardcoded Java version checks.
- `docker-compose.yml` — port mappings and volume mounts must stay in sync with the app config.
- `METASPLOIT_GUIDE.md` — contains a hardcoded VPS IP (`194.163.135.124`); update if changing infrastructure.
