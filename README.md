# docker-caddy
Caddy docker image compiled with the following plugins:

- `github.com/mholt/caddy-dynamicdns`
- `github.com/mholt/caddy-webdav`
- `github.com/porech/caddy-maxmind-geolocation`

## Example
Imagine the scenario that you'd like to expose a Jellyfin instance on a dynamic IP (via HTTPS), and want to restrict clients only to ones originating from Poland. If you have a domain managed by Cloudflare, all this could be easily done using the following `Caddyfile` excerpt:
```Caddy
{
  dynamic_dns {
    provider cloudflare {$CLOUDFLARE_TOKEN}

    domains {
      example.org jellyfin
    }

    ip_source simple_http https://icanhazip.com
    ip_source simple_http https://api64.ipify.org

    check_interval 30m

    versions ipv4

    ttl 45m
  }
}

jellyfin.example.org {  
  tls {
    dns cloudflare {$CLOUDFLARE_TOKEN}
  }

  @geofilter {
    maxmind_geolocation {
      db_path "/usr/share/GeoIP/GeoLite2-Country.mmdb"
      allow_countries PL
    }
  }

  route {
    reverse_proxy @geofilter http://jellyfin:8096 {
      flush_interval -1
    }
    respond 403
  }
}
```