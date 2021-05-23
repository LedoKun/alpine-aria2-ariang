FROM alpine:3

LABEL maintainer="Rom Luengwattanapong"

WORKDIR /aria2web

# aria2 downloads & config directory
VOLUME [ "/aria2web/downloads", "/aria2web/config" ]

# env
ENV PORT=8888
ENV UID=1000
ENV GID=1000

ARG GO111MODULE=on
ARG GOPROXY=https://goproxy.io
ARG ARIANG_URL="https://github.com/mayswind/AriaNg/releases/download/1.2.1/AriaNg-1.2.1.zip"

# ports
EXPOSE 6800
EXPOSE 8888

# add files
ADD root/ /

# install aria2c
RUN apk add --no-cache \
    aria2 \
    bash \
    busybox-extras \
    tini \
    ca-certificates

# install build deps
RUN apk add --no-cache --virtual .build-deps \
    go \
    git \
    wget

# install goreman & gosu
RUN go get -v github.com/mattn/goreman \
    && go get -v github.com/tianon/gosu

# web ui install
RUN wget ${ARIANG_URL} -O /tmp/webui.zip \
    && unzip /tmp/webui.zip -d /aria2web/webui \
    && rm -rf /tmp/*

# goreman setup
RUN echo "web: /root/go/bin/gosu ${UID}:${GID} /bin/busybox-extras httpd -f -p ${PORT} -h /aria2web/webui" > /aria2web/Procfile \
    && echo "backend: /root/go/bin/gosu ${UID}:${GID} /usr/bin/aria2c --conf-path /aria2web/config/aria2.conf" >> /aria2web/Procfile

# clean up
RUN apk del .build-deps

ENTRYPOINT ["/sbin/tini", "-g", "--"]

CMD [ "/bin/bash", "/aria2web/entrypoint.sh" ]
