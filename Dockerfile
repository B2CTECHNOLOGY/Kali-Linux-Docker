FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y curl gnupg2 git build-essential libssl-dev libreadline-dev zlib1g-dev && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y python3 python3-pip ruby ruby-dev && \
    apt-get clean

# Instalar Metasploit desde GitHub
RUN git clone https://github.com/rapid7/metasploit-framework.git /opt/metasploit-framework && \
    cd /opt/metasploit-framework && \
    gem install bundler && \
    bundle install && \
    ln -s /opt/metasploit-framework/msfconsole /usr/local/bin/msfconsole && \
    ln -s /opt/metasploit-framework/msfvenom /usr/local/bin/msfvenom

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