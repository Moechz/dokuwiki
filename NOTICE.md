# Third-party notices — DokuWiki for TerraMaster TOS

This repository contains **packaging only**. It does not redistribute DokuWiki
source code. The application archive (`dokuwikidocker.tar.gz`) consists of four
files written for TerraMaster TOS 7 and a reference to an unmodified upstream
container image.

## Upstream application

| | |
|---|---|
| Project | DokuWiki — <https://github.com/dokuwiki/dokuwiki> |
| Version | 2026-07-14c "Mort" (release tag `release-2026-07-14c`, published 2026-09-02, release no. 57.3) |
| Copyright | © 2004-2026 Andreas Gohr and the DokuWiki contributors |
| Licence | **GNU General Public License, version 2** (GPL-2.0) — full text: <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html> |
| Website | <https://www.dokuwiki.org> |

DokuWiki is used **unmodified** and is **not** redistributed here: the package
pulls the official image from Docker Hub at install time. No upstream file is
patched, rebuilt or re-licensed by this repository.

## Container image

| | |
|---|---|
| Reference | `dokuwiki/dokuwiki:2026-07-14c` (Docker Hub, the official image maintained by the DokuWiki project) |
| Digest (multi-arch index) | `sha256:a289deab45e2d4cbc8b6db1c228955d4dccac0d78da9dcf482adfa12e6641ed1` |
| Image build date | 2026-11-06 |
| Upstream Dockerfile | <https://github.com/dokuwiki/docker> |
| Architectures offered by the tag | `linux/amd64` (x86_64) and `linux/arm64` (aarch64) |
| Local image inspection | Debian 13.7 base, PHP 8.4.27 (NTS, Apache module), Apache httpd 2.4.69-1~deb13u1, DokuWiki 2026-07-14c |

The image bundles the following components, each under its own licence. They are
**not** modified by this package:

| Component | Licence |
|---|---|
| DokuWiki 2026-07-14c | GPL-2.0 |
| Apache HTTP Server 2.4.69 (Debian package) | Apache License 2.0 |
| PHP 8.4.27 and its bundled extensions (Debian/PHP builds) | PHP License 3.01 |
| Debian 13 "trixie" base system libraries | various free licences (GPL, LGPL, BSD, MIT, Apache-2.0, …) |

The authoritative texts are inside the image (`/usr/share/doc/*/copyright`,
`/var/www/html/COPYING`) and at <https://github.com/dokuwiki/dokuwiki/blob/master/COPYING>.

## What this repository adds

The four files in the application archive, the build scripts (`scripts/`), the
self-check (`tools/verify.py`), the test script (`test/`) and the documentation
in this repository are original work by the packager **Moechz**, licensed under
the MIT licence in [`LICENSE`](LICENSE).

`TOSAppSelfTestingTool` is the official TerraMaster package checker,
redistributed here unmodified so that a local build can be validated. It is
TerraMaster's file, not ours, and is not part of the application archive.

## Trademarks and affiliation

- **DokuWiki** and the DokuWiki logo are the trademarks / brand of the DokuWiki
  project and its authors. They are used here descriptively, to name the
  software this package installs.
- **TerraMaster**, **TOS** and **App Center** are trademarks of TerraMaster.
- This is an **independent community package**. It is not produced, endorsed,
  sponsored or supported by the DokuWiki project or by TerraMaster.

## Security scanning note (review item T1)

The review reported a high/critical CVE for the container image. The image is
the newest build the upstream project publishes: the `2026-07-14c` tag — and
`stable`, which resolves to the same digest — was last built on 2026-11-06
(Debian 13.7, PHP 8.4.27 built 2026-11-05, Apache httpd 2.4.69-1~deb13u1), and
2026-07-14c is the current DokuWiki release (2026-09-02). No newer upstream
release or image build exists as of 2026-11-22, so the packager cannot upgrade
the base packages without forking and republishing the image, which is outside
the scope of a packaging submission.

Measured facts about this image, relevant to the most severe CVE class in
Apache httpd at this version (mod_http2 RCE):

- **mod_http2 is not enabled.** `apache2ctl -M` lists no `http2_module`, so the
  vulnerable module is not loaded and h2/h2c requests are not served.
- **mod_proxy_html is not enabled** either (`proxy_html_module` is absent), so
  the CVE in that module cannot be reached.
- The service is reachable only over plain HTTP/1.1 on port 8179, runs as
  uid 1000 without extra capabilities, and has no TLS endpoint.

Mitigation and follow-up are recorded in [`CHANGELOG.md`](CHANGELOG.md) and in
the release note of `2026.7.14-2`; the app will pick up a fixed base image as
soon as the upstream project rebuilds `dokuwiki/dokuwiki`.
