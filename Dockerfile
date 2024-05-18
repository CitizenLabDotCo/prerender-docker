FROM node:21.7.3-bookworm
MAINTAINER Magnet.me

EXPOSE 3000

# Install Chromium and dumb-init
# dumb-init is used to reap zombie Chromium processes
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y google-chrome-stable dumb-init=1.2.5-2 && \
  rm -rf /var/lib/apt/lists/* && \
  google-chrome-stable --no-sandbox --version > /opt/chromeVersion

RUN mkdir -p /usr/src/app
RUN groupadd -r prerender && useradd -r -g prerender -d /usr/src/app prerender
RUN chown prerender:prerender /usr/src/app

USER prerender
WORKDIR /usr/src/app

COPY yarn.lock /usr/src/app/
COPY package.json /usr/src/app/
RUN yarn --pure-lockfile install
COPY . /usr/src/app

CMD [ "dumb-init", "yarn", "prod" ]
