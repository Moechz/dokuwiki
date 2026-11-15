#!/bin/sh
# ===========================================================================
# DokuWiki entrypoint for a non-root container (TOS 7 requirement).
#
# The image runs Apache on port 80, which a non-root container cannot bind. This
# wrapper serves the same PHP application with the built-in PHP web server on
# port 8080 and keeps the wiki data on the mounted volume.
# ===========================================================================
set -e
set -u

DATA=/var/www/html/data
mkdir -p "$DATA" 2>/dev/null || true

if ! ( : > "$DATA/.write-test" ) 2>/dev/null; then
  echo "dokuwiki: $DATA is not writable by uid $(id -u)" >&2
  exit 1
fi
rm -f "$DATA/.write-test"

cd /var/www/html
exec php -S 0.0.0.0:8080 -t /var/www/html
