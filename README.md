* Get matching files mentioned in SHA256SUMS

* Run `$ docker build --progress plain --no-cache .`

* Observe segmentation fault at `RUN sh -c 'openssl list -all-algorithms --verbose >/dev/null' || true` step

* Observe failure to fetch algorithms at `openssl speed -seconds 1`
