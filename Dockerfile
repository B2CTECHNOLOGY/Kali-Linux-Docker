FROM kalilinux/kali-rolling:latest

RUN apt-get update && \
    apt-get install -y curl wget unzip && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y default-jdk && \
    apt-get install -y metasploit-framework && \
    apt-get clean

# Install Android SDK build-tools for apksigner (proper APK v2/v3 signing)
RUN wget -q https://dl.google.com/android/repository/build-tools_r34-linux.zip -O /tmp/build-tools.zip 2>/dev/null; \
    if [ -f /tmp/build-tools.zip ]; then \
      unzip -q /tmp/build-tools.zip -d /opt/android-sdk && \
      APKSIGNER=$(find /opt/android-sdk -name apksigner -type f 2>/dev/null | head -1) && \
      if [ -n "$APKSIGNER" ]; then \
        chmod +x "$APKSIGNER" && \
        ln -sf "$APKSIGNER" /usr/local/bin/apksigner; \
      fi && \
      rm /tmp/build-tools.zip; \
    fi

COPY l3mon /root/L3MON-2
WORKDIR /root/L3MON-2
RUN npm install

EXPOSE 8080 4444

# Copiar scripts
COPY start.sh /start.sh
COPY generate_apk.sh /generate_apk.sh
COPY start_listener.sh /start_listener.sh
RUN chmod +x /start.sh /generate_apk.sh /start_listener.sh

CMD ["/start.sh"]
