FROM linuxserver/kali-linux:latest

# Instalar Node.js
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Copiar código de L3MON
COPY l3mon /root/L3MON-2

# Establecer directorio de trabajo
WORKDIR /root/L3MON-2

# Instalar dependencias
RUN npm install

# --- ANULAR COMPLETAMENTE EL ENTRYPOINT DE LA IMAGEN BASE ---
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["node index.js"]