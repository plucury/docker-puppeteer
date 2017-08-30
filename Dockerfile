FROM node:8-slim

LABEL maintainer="cheeaun@gmail.com"

RUN \
  apt-get update && \
  apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core fonts-freefont-ttf ttf-bitstream-vera && \
  rm -r /var/lib/apt/lists/* && \
  wget https://github.com/eosrei/emojione-color-font/releases/download/v1.3/EmojiOneColor-SVGinOT-Linux-1.3.tar.gz && \
  tar zxf EmojiOneColor-SVGinOT-Linux-1.3.tar.gz && \
  cd EmojiOneColor-SVGinOT-Linux-1.3 && \
  ./install.sh