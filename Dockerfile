ARG CADDY_VERSION=2.7.4
ARG ALPINE_VERSION=3.18.3

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/mholt/caddy-dynamicdns \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-webdav \
    --with github.com/porech/caddy-maxmind-geolocation

FROM alpine:${ALPINE_VERSION}

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

RUN apk add --no-cache ca-certificates mailcap

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
ADD https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb /usr/share/GeoIP/

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /srv

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]