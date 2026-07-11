#!/bin/bash

# Iniciar L3MON en segundo plano
cd /root/L3MON-2
node index.js &

# Guardar el PID del proceso
NODE_PID=$!

# Función para manejar señales de terminación
cleanup() {
    echo "Recibida señal de terminación, deteniendo L3MON..."
    kill $NODE_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Esperar a que el proceso termine o mantener el contenedor vivo
while kill -0 $NODE_PID 2>/dev/null; do
    sleep 1
done

echo "L3MON se ha detenido inesperadamente, reiniciando..."
node index.js &
NODE_PID=$!

# Mantener el contenedor vivo
tail -f /dev/null
