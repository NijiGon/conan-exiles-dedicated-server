FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV STEAMAPPID=443030
ENV SERVER_DIR=/opt/conan
ENV STEAMCMD_DIR=/opt/steamcmd

# Install dependencies, Wine, SteamCMD
RUN dpkg --add-architecture i386 && \
    apt update && \
    apt install -y \
    curl \
    wget \
    ca-certificates \
    software-properties-common \
    xvfb \
    lib32gcc-s1 \
    lib32stdc++6 \
    wine64 \
    wine32 \
    winetricks \
    unzip \
    tini && \
    rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p ${STEAMCMD_DIR} ${SERVER_DIR}

# Install SteamCMD
WORKDIR ${STEAMCMD_DIR}
RUN curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz
RUN chmod +x ${STEAMCMD_DIR}/steamcmd.sh

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/opt/conan"]

# Expose default Conan Exiles ports
EXPOSE 7777/udp 7778/udp 27015/udp 27015/tcp

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/entrypoint.sh"]
