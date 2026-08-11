# Deployment: reverse-proxy requirements

> Any HTTPS-terminating proxy in front of this app **must** tell Rails that the public request was
> HTTPS. If it doesn't, clicking a search result breaks with a 422 and the date-range facets stop
> working. Diagnosed on the `dc.n0p.io` demo host, 2026-08-11.

---

## The one-line check

```bash
curl -sS https://<host>/catalog | grep -oE 'action="http[^"]*"' | head -3
```

- `action="https://…"` → correct.
- `action="http://…"` → **broken**, apply the fix below.

## What goes wrong when the scheme is lost

Rails derives `request.base_url` from the request scheme. Behind a proxy that terminates TLS and
forwards plain HTTP without a scheme header, `base_url` becomes `http://<host>` while the browser keeps
sending `Origin: https://<host>`. Two things follow:

1. **Every non-GET request fails CSRF.** Rails' origin check (`valid_request_origin?`) compares the two,
   they differ, and it raises `ActionController::InvalidAuthenticityToken` → **422**.
   The visible symptom is that clicking a search result stalls on Blacklight's search-context URL,
   `/catalog/<ark>/track?document_id=…&search_id=…`, instead of opening the item page. That POST is
   normal Blacklight behaviour (`link_to_document` → `data-context-href` → `handleSearchContextMethod`
   in `app/assets/javascripts/blacklight/blacklight.js`), and it is the first thing to break.
2. **All generated absolute URLs are `http://`,** so the browser blocks them as mixed content — the
   search form, the OpenSearch link, and the `/catalog/range_limit` XHRs behind the date-range facet
   sliders.

## What the proxy must send

Rack picks the scheme in this order, so **any one** of these is enough:

| Header | Notes |
| --- | --- |
| `X-Forwarded-Ssl: on` | Highest precedence, not set by Nginx Proxy Manager's `proxy.conf`, so it never collides |
| `X-Forwarded-Scheme: https` | |
| `X-Forwarded-Proto: https` | Lowest precedence of the three; the conventional one |

Send **one value per header** — a duplicated `proxy_set_header` makes nginx emit the header twice,
Rack reads `http,https` and the fix silently doesn't take.

## nginx gotcha

`proxy_set_header` is inherited from `server` into `location` **only if the location defines none of its
own**. Nginx Proxy Manager's default location does `include conf.d/include/proxy.conf`, which defines
five of them — so scheme headers added at server level (e.g. NPM's custom-config box, which is inserted
above the location block) are silently discarded. They must go **inside** the `location` block that
does the `proxy_pass`.

## Multi-hop chains

NPM maps an inbound `X-Forwarded-Proto` through (`map $http_x_forwarded_proto $x_forwarded_proto`,
`/etc/nginx/nginx.conf`), falling back to `$scheme`. So in a chain `edge (TLS) → NPM → app`, the fix
belongs at the **outermost** hop that terminates TLS; every inner hop only needs to preserve rather than
overwrite the header (`proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;`). Pinning the value
on the innermost hop works too, but only fixes that one host.

## Verifying the actual bug end to end

```bash
TOK=$(curl -sS -c /tmp/cj.txt https://<host>/catalog \
  | grep -oE 'name="csrf-token" content="[^"]*"' | sed 's/.*content="//;s/"//')
curl -sS -b /tmp/cj.txt -o /dev/null -w "HTTP %{http_code} -> %{redirect_url}\n" \
  -X POST -H "Origin: https://<host>" \
  --data-urlencode "authenticity_token=$TOK" \
  --data-urlencode "redirect=/catalog/ark:%2F21198%2Fz18w4z1w" \
  "https://<host>/catalog/ark:%2F21198%2Fz18w4z1w/track?document_id=ark%3A%2F21198%2Fz18w4z1w"
```

Expect `HTTP 303 -> https://<host>/catalog/ark:%2F21198%2Fz18w4z1w`. A `422` means the scheme header is
still not arriving. Add `-u <user>:<pass>` if the host is behind basic auth.
