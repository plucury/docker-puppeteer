FROM node:8-slim

LABEL maintainer="cheeaun@gmail.com"

RUN \
  apt-get update && \
  apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core fonts-freefont-ttf

RUN cd "$(mktemp -d)" && \
  wget https://noto-website.storage.googleapis.com/pkgs/NotoColorEmoji-unhinted.zip && \
  unzip NotoColorEmoji-unhinted.zip && \
  wget https://github.com/notwaldorf/ama/files/1049784/libcairo2_1.14.6-1_amd64.deb.zip && \
  unzip libcairo2_1.14.6-1_amd64.deb.zip && \
  sudo dpkg -i libcairo2_1.14.6-1_amd64.deb && \
  mkdir -p ~/.fonts && mv *.ttf ~/.fonts && \
  mkdir -p ~/.config/fontconfig && cat > ~/.config/fontconfig/fonts.conf <<EOF \
  <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"> \
  <fontconfig> \
  <match> \
  <test name="family"><string>sans-serif</string></test> \
  <edit name="family" mode="prepend" binding="strong"> \
    <string>Noto Color Emoji</string> \
  </edit> \
  </match> \
  <match> \
  <test name="family"><string>monospace</string></test> \
  <edit name="family" mode="prepend" binding="strong"> \
    <string>Noto Color Emoji</string> \
  </edit> \
  </match> \
  <match> \
  <test name="family"><string>serif</string></test> \
  <edit name="family" mode="prepend" binding="strong"> \
    <string>Noto Color Emoji</string> \
  </edit> \
  </match> \
  <match> \
  <test name="family"><string>Apple Color Emoji</string></test> \
  <edit name="family" mode="prepend" binding="strong"> \
    <string>Noto Color Emoji</string> \
  </edit> \
  </match> \
  </fontconfig> \
  EOF && \
  fc-cache -f -v
