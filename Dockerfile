FROM linuxserver/kali-linux:latest

RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pm2 && \
    apt-get clean

WORKDIR /root/L3MON-2
CMD ["/bin/bash", "-c", "npm install && pm2-runtime start index.js"]
