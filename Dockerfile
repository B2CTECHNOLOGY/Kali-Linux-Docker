FROM linuxserver/kali-linux:latest

# Instalar Node.js
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Copiar código
COPY l3mon /root/L3MON-2
WORKDIR /root/L3MON-2
RUN npm install

# Comando que inicia node en segundo plano y mantiene el contenedor vivo
CMD ["/bin/bash", "-c", "node index.js & tail -f /dev/null"]