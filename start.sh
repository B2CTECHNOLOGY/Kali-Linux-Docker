#!/bin/bash

echo "Iniciando L3MON..."

# Iniciar L3MON en foreground para que los logs sean visibles en Dokploy
cd /root/L3MON-2
exec node index.js
