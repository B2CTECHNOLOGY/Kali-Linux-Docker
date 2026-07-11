# AGENTS.md

## Project overview

L3MON (Node.js/Express Android management suite) bundled with Metasploit inside a Kali Linux Docker container. Git commit messages and METASPLOIT_GUIDE.md are in **Spanish** — the project language is Spanish.

## Architecture

- **`l3mon/`** — the Node.js app (Express + EJS + Socket.IO). Entry point: `l3mon/index.js`.
- **`l3mon/includes/const.js`** — all ports, paths, build commands, and message keys are defined here.
- **`l3mon/includes/databaseGateway.js`** — lowdb v1 flat-file JSON DB (`maindb.json`).
- **`l3mon/app/factory/`** — apktool.jar, debug.keystore, pre-decompiled smali for APK building.
- **`Dockerfile`** — Kali Linux + default-jdk + Metasploit + Node 22 + apksigner + L3MON.
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

## APK building

The APK is built from pre-decompiled smali in `l3mon/app/factory/decompiled/`:
1. **Patch** — `apkBuilder.js` replaces the server URI in `IOSocket.smali`
2. **Build** — `apktool.jar` (v2.4.0) rebuilds the APK → `build.apk`
3. **Sign** — `apksigner` (preferred) or `jarsigner` (fallback) → `build.s.apk`

The signed APK is served at `/build.s.apk`.

### APK manifest parameters (current)

| Parameter | Value | Reason |
|---|---|---|
| `targetSdkVersion` | 28 | apktool 2.4.0 corrupts APK with API > 28 |
| `minSdkVersion` | 21 | Android 5.0+ |
| `usesCleartextTraffic` | true | HTTP connections required on Android 9+ |
| `debuggable` | false (removed) | production safety |
| Signing | apksigner (v2+v3) | Android 14+ requires v2/v3 schemes |

### APK AndroidManifest permissions

Mandatory for modern Android: `POST_NOTIFICATIONS` (13+), `FOREGROUND_SERVICE` (9+).

All original spying permissions retained (CAMERA, RECORD_AUDIO, READ_SMS, etc.).

## Key gotchas

- **No test suite exists.** There is no way to run automated tests.
- **`apktool 2.4.0`** is old (2018). Setting `targetSdkVersion` > 28 produces a corrupt APK that won't install. This is a known limitation in `apktool.yml`.
- **`sign.jar`** (`sun.misc.BASE64Encoder`) is incompatible with Java 9+. Replaced by `apksigner` (Android SDK build-tools) with `jarsigner` fallback.
- **Port 4444 conflict**: Both Socket.IO and Metasploit listener try to bind port 4444. The msf listener will fail silently.
- **`data/maindb.json`** is git-tracked (exception in `.gitignore`). Contains the admin password hash. All other `data/*` is ignored.
- **`config/`** is gitignored — does not exist in the repo.
- **Socket.IO** listens on port 4444 with `origin: "*"` (open CORS).
- **Default admin password** is `12345` (MD5 `827ccb0eea8a706c4c34a16891f84e7b`).
- **Port 8080** = web UI; **port 4444** = Socket.IO + attempted Metasploit listener.
- **Docker volumes** mount `./data:/data` and `./data/maindb.json:/root/L3MON-2/maindb.json`.

## Files to watch when editing

- `l3mon/includes/const.js` — ports, paths, keystore, build/sign commands.
- `l3mon/includes/expressRoutes.js` — all HTTP routes.
- `l3mon/includes/apkBuilder.js` — APK build pipeline, Java version check.
- `l3mon/app/factory/decompiled/apktool.yml` — SDK version limits.
- `l3mon/app/factory/decompiled/AndroidManifest.xml` — permissions, cleartext, exported flags.
- `docker-compose.yml` — port mappings and volume mounts.
- `METASPLOIT_GUIDE.md` — contains hardcoded VPS IP (`194.163.135.124`).
