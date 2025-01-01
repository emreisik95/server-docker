# ---------------------------
# Dockerfile for Stremio Server
# ---------------------------

FROM node:14

# (A) Build arg: Stremio Server sürümü ve build tipini belirleyin (desktop vs.)
ARG VERSION=v4.20.1
ARG BUILD=desktop

# (B) Çalışma dizinini ayarla
WORKDIR /stremio

# (C) Gerekli paketleri yükle ve /root/.stremio-server klasörünü oluştur
RUN apt-get update && apt-get install -y ffmpeg wget curl \
    && mkdir -p /root/.stremio-server \
    && echo '{}' > /root/.stremio-server/server-settings.json

# (D) ffmpeg ve ffprobe yollarını otomatik bul ve /etc/environment içine kaydet
RUN FFMPEG_BIN=$(which ffmpeg) \
    && FFPROBE_BIN=$(which ffprobe) \
    && echo "FFMPEG_BIN=$FFMPEG_BIN" >> /etc/environment \
    && echo "FFPROBE_BIN=$FFPROBE_BIN" >> /etc/environment

# (E) Konteyner içindeki değişkenlere ARG değerlerini ENV olarak aktar
ENV VERSION=${VERSION}
ENV BUILD=${BUILD}

# (F) download_server.sh scriptini kopyala ve çalıştırarak server.js indir
COPY download_server.sh ./download_server.sh
RUN chmod +x ./download_server.sh && ./download_server.sh

# (G) Diğer ortam değişkenlerini ayarla
#     - NO_CORS ve CASTING_DISABLED set ederseniz, CORS ve Casting kapatılacak
ENV APP_PATH=/root/.stremio-server \
    NO_CORS=1 \
    CASTING_DISABLED=1

# (H) Portları aç
EXPOSE 11470 12470

# (I) Konteyner başlarken node server.js'yi çalıştır
ENTRYPOINT ["node", "server.js"]
