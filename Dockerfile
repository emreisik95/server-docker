FROM node:14

WORKDIR /stremio

# Install necessary dependencies
RUN apt-get update && apt-get install -y ffmpeg curl wget

# Set environment variables
ENV FFMPEG_BIN=/usr/bin/ffmpeg
ENV FFPROBE_BIN=/usr/bin/ffprobe
ENV APP_PATH=/root/.stremio-server
ENV NO_CORS=1

# Copy and set up application
COPY . .
RUN chmod +x ./download_server.sh && ./download_server.sh

# Expose ports
EXPOSE 11470
EXPOSE 12470

ENTRYPOINT ["node", "server.js"]
