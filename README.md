# dokuwiki-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [DokuWiki](https://github.com/dokuwiki/dokuwiki), the file-based wiki.

## What this is

A four-file TOS Docker application archive (`dokuwikidocker.tar.gz`) that installs
DokuWiki on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `dokuwikidocker`)
- `dokuwikidocker.lang` — 23-language superset (TOS requires 14)
- `dokuwikidocker.svg` — application icon (SVG, 24 elements, 10264 bytes)
- `docker-compose.yml` — one non-root service, image `dokuwiki/dokuwiki:2026-07-14c`

The repository contains the complete source of the package: the `src/` templates,
the deterministic build scripts, the review-standards self-check and the isolated
staging test.

## How it works

| | |
|---|---|
| Container image | `dokuwiki/dokuwiki:2026-07-14c` — the **official multi-arch upstream image**, pinned to a fixed tag (never `:latest`), used unmodified |
| Open | `http://<NAS-IP>:8179/` (container port 8080) |
| Runs as | non-root, `user: "1000:1000"` |
| Pages & attachments | `/Volume1/DockerAppData/dokuwikidocker/data/` → `/storage/data` |
| Accounts, ACL, settings | `/Volume1/DockerAppData/dokuwikidocker/conf/` → `/storage/conf` |
| Plugins & templates | `/Volume1/DockerAppData/dokuwikidocker/lib/` → `/storage/lib` |
| Logs | `docker logs dokuwikidocker` (stdout/stderr) + `.../data/log/` |
| Health check | container's own `/health.php` (boots DokuWiki) |

DokuWiki is a wiki that keeps everything as plain files: no database server, no
external service. You write pages in DokuWiki's own markup, organise them in
namespaces, upload images and files through the Media Manager, and every save
keeps a revision. User accounts, groups and per-page/per-namespace ACL rules are
built in, and the Extension Manager installs plugins and templates from
dokuwiki.org/GitHub.

**First run:** open the app, the installer (`/install.php`) asks for the wiki
title, the administrator account and the ACL policy, then it configures itself
and refuses to run again. Pretty URLs (`http://<NAS-IP>:8179/start`) are enabled
by the image; search, RSS/ATOM feeds, the sidebar and the page history work out
of the box.

The image's own entrypoint is used unchanged: it prepares `/storage` (copies the
core data on every start so that an image update also refreshes the bundled
help pages, and symlinks the bundled plugins/templates) and then starts Apache on
the unprivileged port 8080.

## Repository layout

```text
.
├── README.md                  this file
├── CHANGELOG.md               every published version and its review fixes
├── PRIVACY.md                 privacy policy (also the package `help` target)
├── NOTICE.md                  upstream licence, image digests, trademarks, T1 note
├── LICENSE                    MIT licence for this packaging
├── tosapp.json                app spec read by the build (id, version, image,
│                              ports, volumes, translations, licences)
├── src/
│   ├── config.ini             TOS metadata template (@@VERSION@@ / @@PLATFORM@@)
│   ├── docker-compose.yml     one non-root service, fixed image tag, 3 volumes
│   ├── dokuwikidocker.lang    23-language descriptions
│   └── dokuwikidocker.svg     store icon
├── scripts/
│   ├── build.sh               stage → verify → deterministic tar.gz + sha256
│   └── build-dual.sh          build both architectures and run the official -c
├── test/
│   └── install-and-verify.sh  on-device install / runtime verification
├── tools/
│   └── verify.py              review-standards self-check (runs in build.sh)
├── TOSAppSelfTestingTool      official TerraMaster package checker
└── .gitignore
```

## Architecture support

The package is built twice, once per architecture, from the same source: only
`config.ini.platform` and the archive name differ
(`dokuwikidocker_x86_64.tar.gz`, `dokuwikidocker_aarch64.tar.gz`). The upstream
image is a multi-arch OCI index with `linux/amd64` and `linux/arm64` manifests,
so the same fixed tag works on x86_64 and aarch64 NAS models. There is no
`exec format error` class of failure: the platform pulls the matching manifest.

## Data, uninstall and reinstall

Everything persistent is under `/Volume1/DockerAppData/dokuwikidocker/`:

```text
data/    pages/, attic/ (revisions), media/, media_attic/, meta/, index/,
         cache/, locks/, tmp/, log/
conf/    local.php, users.auth.php, groups.auth.php, acl.auth.php,
         plugins.local.php
lib/     plugins/, tpl/     (core extensions are symlinks into the image)
```

- **Uninstall** in App Center. Docker applications have no uninstall hook: if you
  keep the data, the three directories above stay on disk and are reused when you
  reinstall the app. If you choose to delete the application data during
  uninstallation, the wiki is gone.
- **Manual removal:** stop the app and delete
  `/Volume1/DockerAppData/dokuwikidocker/`.
- **Backup:** copy `/Volume1/DockerAppData/dokuwikidocker/` while the container is
  stopped. That is a complete, self-contained backup (pages, attachments,
  revisions, accounts, ACL, plugins).
- **Upgrade from 2026.7.14-1:** your pages and attachments are kept (the host
  path `.../dokuwikidocker/data` is now mounted at `/storage/data`, exactly where
  DokuWiki expects them). That older build kept `conf/` **inside the container**,
  so its administrator account and ACL rules could not survive; after upgrading,
  run the installer once and recreate the accounts. Version `2026.7.14-2` stores
  them on the NAS, so this cannot happen again.

## Privacy

The short version: this package runs entirely on your NAS, contains no analytics,
telemetry or advertising code, and sends nothing to the packager. Like every
DokuWiki, it checks for updates at `update.dokuwiki.org` (version string only,
24-hour cache, can be disabled in the admin Configuration) and the Extension
Manager contacts dokuwiki.org/GitHub when an administrator installs an extension.

The complete policy — what is stored where, retention periods, the third-party
endpoint table, your data rights and the deletion channels — is
[`PRIVACY.md`](PRIVACY.md). It is also the `help` target of the package, so the
App Center "Help" button opens it:
<https://github.com/Moechz/dokuwiki/blob/main/PRIVACY.md>

## Notices and licences

| Part | Licence |
|---|---|
| This packaging (`src/`, `scripts/`, `tools/`, `test/`, docs) | MIT — [`LICENSE`](LICENSE) |
| DokuWiki 2026-07-14c | GPL-2.0 |
| `dokuwiki/dokuwiki:2026-07-14c` image (Debian 13.7, Apache 2.4.69, PHP 8.4.27) | GPL-2.0 app, Apache-2.0 / PHP-3.01 / Debian free licences for the base |
| `TOSAppSelfTestingTool` | TerraMaster, redistributed unmodified |

The image is used unmodified and is **not** redistributed in this repository; no
upstream source is patched or repackaged. Image digest, component list, trademark
ownership and the security-scan (T1) note are in [`NOTICE.md`](NOTICE.md).

This is an independent community package by Moechz. It is not affiliated with the
DokuWiki project or with TerraMaster.

## Build

```bash
scripts/build.sh 2026.7.14-2            # -> out/dokuwikidocker.tar.gz + .sha256
scripts/build.sh 2026.7.14-2 aarch64    # one architecture
scripts/build-dual.sh 2026.7.14-2       # both, plus the official -c check
./TOSAppSelfTestingTool -c out/dokuwikidocker_x86_64.tar.gz
./TOSAppSelfTestingTool -c out/dokuwikidocker_aarch64.tar.gz
```

`build.sh` stages the four files, substitutes the version/platform placeholders,
removes CRLF/BOM/AppleDouble, then runs `tools/verify.py`, a review-standards
self-check (archive layout, JSON validity, required fields, 14+ language
coverage, version consistency, Docker-Hub-only images, fixed tag, reserved and
recommended host ports, non-root user, per-service healthcheck/TZ/restart, data
paths below the application data root, never the `/Volume*` wildcard,
comment-free sequence blocks, `x-app-meta` position, no literal secrets and the
SVG size/element limits), and finally packs a deterministic `tar.gz`
(uid/gid 0, zeroed mtimes, gzip without timestamp).

There is no wrapper script to escape: the container runs the upstream
entrypoint, so `docker-compose.yml` contains no `$`-interpolated shell code.

## Local verification

```bash
./TOSAppSelfTestingTool -c out/dokuwikidocker.tar.gz   # official spec check
python3 ../stage.py . --timeout 300                    # isolated runtime test
bash test/install-and-verify.sh                        # on-device E2E (needs root)
```

The isolated runtime test unpacks the package, rebinds the port on `127.0.0.1`,
points the three volumes at a temporary directory, starts the container and
asserts: container running, healthcheck healthy, HTTP answer on the web port,
`user=1000:1000`. It never touches `/Volume1/DockerAppData`.

Behavior verified for this version on real hardware (2026-11-22, isolated
instance, uid 1000):

- `/health.php` → `ok`, `/` → `200`; installer creates the admin account and the
  wiki is usable (login, page creation, revision created in `attic/`).
- `GET /data/pages/<page>.txt` and `GET /data/media/<file>` → **403**;
  `GET /conf/users.auth.php` returns only the file's comment guard, no hashes.
- After recreating the container from scratch on the same volumes: the page, the
  login and the ACL settings are still there.

## Review remediation map (2026.7.14-2)

| Code | What changed |
|---|---|
| C3 / C4 / C5 | New complete [`PRIVACY.md`](PRIVACY.md); the package `help` (`config.ini` and `tosapp.json`) points to its public URL |
| C7 | Access / rectification / erasure channels described in `PRIVACY.md` §6 and §7, per data type, including accounts and ACL |
| C8 | Third-party endpoint disclosure table with the data sent, the destination and the off switch (DokuWiki update check, Extension Manager, Docker Hub) |
| C9 / F5 / F7 | Description rewritten to the features actually delivered; the container now uses the upstream entrypoint with Apache on 8080 instead of `php -S` (see `CHANGELOG.md` for the two defects that caused) |
| C10 | Complete README (this file), `PRIVACY.md`, `NOTICE.md`, full source layout in a public repository |
| T1 | Newest available upstream image documented, report on the enabled/disabled vulnerable modules, follow-up plan — [`NOTICE.md`](NOTICE.md) and `CHANGELOG.md` |

## Limitations

- The UI is plain HTTP. Put a TLS reverse proxy (or a VPN) in front of port 8179
  before exposing the wiki to the internet.
- You must run the installer once to create the administrator account.
- The Extension Manager needs outgoing HTTPS to dokuwiki.org and the extension's
  host; on an offline NAS, install plugins manually into
  `/Volume1/DockerAppData/dokuwikidocker/lib/plugins/`.
- DokuWiki keeps every revision forever; purge `attic/` if you need to reclaim
  space or delete old content.
- A wiki is only as private as its ACL: check *Admin → Access Control List
  Management* before publishing pages.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
