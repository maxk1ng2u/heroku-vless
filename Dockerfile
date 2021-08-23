FROM caddy:builder-alpine AS builder

RUN xcaddy build \
        --with github.com/mholt/caddy-l4 \
        --with github.com/ueffel/caddy-brotli \
        --with github.com/casbin/caddy-authz \
        --with github.com/greenpau/caddy-auth-portal \
        --with github.com/greenpau/caddy-auth-jwt \
        --with github.com/ss098/certmagic-s3 \
        --with github.com/silinternational/certmagic-storage-dynamodb \
        --with github.com/pteich/caddy-tlsconsul \
        --with github.com/mholt/caddy-dynamicdns \
        --with github.com/caddy-dns/openstack-designate \
        --with github.com/caddy-dns/azure \
        --with github.com/caddy-dns/vultr \
        --with github.com/caddy-dns/hetzner \
        --with github.com/caddy-dns/digitalocean \
        --with github.com/caddy-dns/alidns \
        --with github.com/caddy-dns/gandi \
        --with github.com/caddy-dns/duckdns \
        --with github.com/caddy-dns/dnspod \
        --with github.com/caddy-dns/lego-deprecated \
        --with github.com/caddy-dns/route53 \
        --with github.com/caddy-dns/cloudflare
        
FROM caddy:builder-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk update && \
    apk add --no-cache --virtual .build-deps ca-certificates curl unzip wget nss-tools && \
    mkdir /tmp/xray && \
    curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/download/v1.4.2/Xray-linux-64.zip && \
    unzip /tmp/xray/xray.zip -d /tmp/xray && \
    install -m 755 /tmp/xray/xray /usr/local/bin/xray && \
    xray -version && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/xray && \
    apk del .build-deps

ENV XDG_CONFIG_HOME /etc/caddy
ENV XDG_DATA_HOME /usr/share/caddy

COPY etc/Caddyfile /conf/Caddyfile
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
