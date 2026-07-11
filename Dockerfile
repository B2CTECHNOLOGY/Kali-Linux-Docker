FROM linuxserver/kali-linux:latest

# Instalar Node.js y PM2
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pm2 && \
    apt-get clean

# Copiar el código de L3MON (todo el contenido de l3mon/)
COPY l3mon /root/L3MON-2

# Establecer directorio de trabajo
WORKDIR /root/L3MON-2

# Instalar dependencias
RUN npm install

# Comando para iniciar con PM2
CMD ["pm2-runtime", "start", "index.js"]