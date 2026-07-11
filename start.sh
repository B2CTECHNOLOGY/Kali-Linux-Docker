#!/bin/bash

# Iniciar L3MON en segundo plano
cd /root/L3MON-2
node index.js &

# Mantener el contenedor vivo
tail -f /dev/null
