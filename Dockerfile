# ---------------------------
# 1) Node tabanlı bir imajdan başlıyoruz
# ---------------------------
FROM node:14

# ---------------------------
# 2) Stremio server.js versiyon ve build argümanları
#    Örnek olarak VERSION=v4.20.1 ve BUILD=desktop kullandık.
#    Dilerseniz docker build yaparken farklı değerlerle geçebilirsiniz:
#    docker build --build-arg VERSION=v4.20.1 --build-arg BUILD=desktop -t stremio-server:custom .
# ---------------------------
ARG VERSION=v4.20.1
ARG BUILD=desktop

# ---------------------------
# 3) Çalışma dizinini ayarla
# ---------------------------
WORKDIR /stremio

# ---------------------------
# 4) Gerekli bağımlılıkları yükle
#    - ffmpeg ve ffprobe burada yüklenir
#    - /root/.stremio-server dizini oluşturulur
#    - Basit bir server-settings.json eklenir (içerik şimdilik boş)
# ---------------------------
RUN apt-get update && apt-get install -y ffmpeg curl wget \
    && mkdir -p /root/.stremio-server \
    && echo '{}' > /root/.stremio-server/server-settings.json

# ---------------------------
# 5) ffmpeg ve ffprobe yollarını otomatik bul ve /etc/environment'a yaz
#    Bu sayede sonraki adımlarda bu yolları environment olarak kullanabiliriz
# ---------------------------
RUN FFMPEG_BIN=$(which ffmpeg) \
    && FFPROBE_BIN=$(which ffprobe) \
    && echo "FFMPEG_BIN=$FFMPEG_BIN" >> /etc/environment \
    && echo "FFPROBE_BIN=$FFPROBE_BIN" >> /etc/environment

# ---------------------------
# 6) ARG ile tanımlanan VERSION ve BUILD değerlerini ENV olarak atayarak
#    download_server.sh scripti içinde erişilebilir hale getiriyoruz
# ---------------------------
ENV VERSION=${VERSION}
ENV BUILD=${BUILD}

# ---------------------------
# 7) download_server.sh dosyasını kopyala ve çalıştır
#    Bu script, AWS'den belirtilen version/build'a göre server.js indirir
# ---------------------------
COPY download_server.sh ./download_server.sh
RUN chmod +x ./download_server.sh && ./download_server.sh

# ---------------------------
# 8) Gerekli diğer ortam değişkenleri
#    - APP_PATH: Stremio ayarları, sertifikalar vs.
#    - NO_CORS: 1 ise CORS devre dışı
#    - CASTING_DISABLED: 1 ise ağ üzerinde casting devre dışı
# ---------------------------
ENV APP_PATH=/root/.stremio-server \
    NO_CORS=1 \
    CASTING_DISABLED=1

# ---------------------------
# 9) Uygulamanın kullandığı portları aç
#    - 11470: HTTP
#    - 12470: HTTPS
# ---------------------------
EXPOSE 11470 12470

# ---------------------------
# 10) Container başlarken node server.js'yi başlatalım
# ---------------------------
ENTRYPOINT ["node", "server.js"]
