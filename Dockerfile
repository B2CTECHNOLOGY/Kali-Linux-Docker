FROM ubuntu:22.04

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

# Exponer puertos
EXPOSE 8080 4445

# Comando principal (en primer plano)
CMD ["node", "index.js"]