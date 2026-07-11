FROM linuxserver/kali-linux:latest

# Instalar Node.js
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Copiar código y script
COPY l3mon /root/L3MON-2
COPY start.sh /start.sh

WORKDIR /root/L3MON-2
RUN npm install

# Ejecutar el script personalizado (sobrescribe el /init original)
ENTRYPOINT ["/bin/bash", "/start.sh"]