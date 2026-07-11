FROM kalilinux/kali-rolling:latest

RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y default-jdk && \
    apt-get install -y metasploit-framework && \
    apt-get clean

COPY l3mon /root/L3MON-2
WORKDIR /root/L3MON-2
RUN npm install

EXPOSE 8080 4444

# Copiar scripts
COPY start.sh /start.sh
COPY generate_apk.sh /generate_apk.sh
COPY start_listener.sh /start_listener.sh
RUN chmod +x /start.sh /generate_apk.sh /start_listener.sh

# Usar el script como CMD
CMD ["/start.sh"]