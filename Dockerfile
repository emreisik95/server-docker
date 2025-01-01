FROM node:14

WORKDIR /stremio

# Install necessary dependencies
RUN apt update && apt install -y wget curl

# Define version and build arguments
ARG VERSION=v4.20.1
ARG BUILD=desktop
ENV VERSION=${VERSION}
ENV BUILD=${BUILD}

# Copy the download script and execute it
COPY download_server.sh download_server.sh
RUN chmod +x ./download_server.sh && ./download_server.sh

# Copy remaining application files
COPY . .

# Expose necessary ports
EXPOSE 11470
EXPOSE 12470

# Set environment variables
ENV FFMPEG_BIN=/usr/bin/ffmpeg
ENV FFPROBE_BIN=/usr/bin/ffprobe
ENV APP_PATH=/root/.stremio-server
ENV NO_CORS=1
ENV CASTING_DISABLED=1

# Start the application
ENTRYPOINT ["node", "server.js"]
