FROM node:14

WORKDIR /stremio

# Install necessary dependencies
RUN apt-get update && apt-get install -y wget curl

# Set environment variables
ARG VERSION=v4.20.1
ARG BUILD=desktop
ENV VERSION=${VERSION}
ENV BUILD=${BUILD}

# Download server.js manually
RUN curl -L -o /stremio/server.js https://dl.strem.io/server/${VERSION}/${BUILD}/server.js

# Expose ports
EXPOSE 11470
EXPOSE 12470

# Default environment variables
ENV FFMPEG_BIN=/usr/bin/ffmpeg
ENV FFPROBE_BIN=/usr/bin/ffprobe
ENV APP_PATH=/root/.stremio-server
ENV NO_CORS=1

# Start the server
ENTRYPOINT ["node", "server.js"]
