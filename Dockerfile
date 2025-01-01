# Base image
FROM node:14

# Metadata
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="Stremio Server Dockerized"

# Set working directory
WORKDIR /stremio

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y ffmpeg wget \
    && mkdir -p /root/.stremio-server \
    && echo '{}' > /root/.stremio-server/server-settings.json

# Dynamically set environment variables for ffmpeg and ffprobe
RUN FFMPEG_BIN=$(which ffmpeg) && echo "FFMPEG_BIN=$FFMPEG_BIN" >> /etc/environment \
    && FFPROBE_BIN=$(which ffprobe) && echo "FFPROBE_BIN=$FFPROBE_BIN" >> /etc/environment

# Set environment variables
ENV APP_PATH=/root/.stremio-server
ENV NO_CORS=1
ENV CASTING_DISABLED=1

# Copy project files
COPY . .

# Expose ports
EXPOSE 11470 12470

# Start server
ENTRYPOINT ["node", "server.js"]
