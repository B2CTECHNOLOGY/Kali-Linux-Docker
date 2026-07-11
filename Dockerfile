FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

COPY l3mon /root/L3MON-2
WORKDIR /root/L3MON-2
RUN npm install

EXPOSE 8080 4444

# CMD con ruta completa para que siempre funcione
CMD ["node", "/root/L3MON-2/index.js"]