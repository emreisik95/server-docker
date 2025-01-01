# Base Node.js image
ARG NODE_VERSION=14
FROM node:$NODE_VERSION

ARG VERSION=master
ARG BUILD=desktop

LABEL com.stremio.vendor="Smart Code Ltd."
LABEL version=${VERSION}
LABEL description="Stremio's streaming Server"

WORKDIR /stremio

# Install dependencies and ffmpeg
ARG JELLYFIN_VERSION=4.4.1-4
RUN apt -y update && apt -y install wget \
    && wget https://repo.jellyfin.org/archive/ffmpeg/debian/4.4.1-4/jellyfin-ffmpeg_4.4.1-4-buster_$(dpkg --print-architecture).deb -O jellyfin-ffmpeg_4.4.1-4-buster.deb \
    && apt -y install ./jellyfin-ffmpeg_4.4.1-4-buster.deb \
    && rm jellyfin-ffmpeg_4.4.1-4-buster.deb

COPY download_server.sh download_server.sh
RUN chmod +x ./download_server.sh && ./download_server.sh

COPY . .

# Expose ports for HTTP and HTTPS
EXPOSE 11470
EXPOSE 12470

# ENV variables for ffmpeg and ffprobe
ENV FFMPEG_BIN=/usr/bin/ffmpeg
ENV FFPROBE_BIN=/usr/bin/ffprobe
ENV APP_PATH=/root/.stremio-server
ENV NO_CORS=1
ENV CASTING_DISABLED=1

# Default command to run the server
ENTRYPOINT ["node", "server.js"]
