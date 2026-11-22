# Changelog

All notable user-visible changes to the DokuWiki TOS application package.

## 2026.7.14-2 — 2026-11-22

Remediation of the App Center listing review for `2026.7.14-1` (x86_64 and
aarch64). Upstream base unchanged: DokuWiki 2026-07-14c (`dokuwiki/dokuwiki:2026-07-14c`,
digest `sha256:a289deab…41ed1`). Host port unchanged: **8179**.

### Fixed — install and web interface (F5, F7)

Two defects in `2026.7.14-1` made the delivered features unusable:

- **The installer could not finish.** The package replaced the image entrypoint
  with `php -S`, so the image's storage setup never ran, `/storage/conf` did not
  exist and `install.php` stopped with
  `Setup Error — The datadir ('pages') at /storage/data/pages is not found, isn't accessible or writable`.
  The image's own entrypoint is now used: it prepares `/storage`, then starts
  Apache on the unprivileged port 8080 as uid 1000.
- **Page sources and attachments were downloadable without login.** `php -S`
  serves the document root as static files, so `GET /data/pages/<page>.txt` and
  `GET /data/media/<file>` returned **200** with the raw content, bypassing the
  wiki ACL. With Apache the same requests return **403** (the image's rules deny
  `data/` and `conf/`), and `conf/*.php` only emits its `exit()` guard.
- **Accounts, ACL and settings were lost on every container recreate.** They
  lived in the container-local `/storage/conf` because the setup never ran and
  that path was not mounted. The volume is now split into the three directories
  the image anchors in `/storage` — `data/`, `conf/`, `lib/` — so pages,
  attachments, revisions, accounts, ACL rules and installed plugins all live on
  the NAS and survive updates.
- Health check changed from "is port 8080 listening" (`/proc/net/tcp` grep) to
  the image's own `GET /health.php`, which boots DokuWiki — a broken
  installation now reports unhealthy instead of "up".
- Verified on hardware: installer completes, login works, a page is created and
  rendered, the revision appears in `attic/`, and page, login and ACL survive a
  full container recreate (`docker rm` + `run` on the same volumes).

### Privacy and data protection (C3, C4, C5, C7, C8)

- New [`PRIVACY.md`](PRIVACY.md) covering page content, revision history,
  attachments, user accounts (bcrypt hashes), groups, ACL, configuration,
  plugins, logs and sessions — with exact storage paths.
- Retention periods (nothing expires automatically; revisions and date-stamped
  logs are kept until deleted; Docker log rotation; 24-minute session idle
  timeout).
- User rights: access, rectification, erasure, restriction/objection and
  complaint — both for the NAS owner and for wiki users (who go through their
  wiki administrator), with the file paths for each data type.
- Deletion channels: admin UI (*User Manager*, old revisions, Media Manager), the
  NAS file system, or uninstall with data removal.
- Third-party endpoint disclosure table (C8): Docker Hub, the DokuWiki update
  check at `update.dokuwiki.org` (version string only, 24 h cache), the
  Extension Manager (`www.dokuwiki.org/pluginrepo` + the extension's own
  download host, usually GitHub), remote images/feeds embedded in pages, and the
  optional proxy — each with the data sent, destination and how to switch it
  off.
- Package `help` (`config.ini` and `tosapp.json`) now points to
  <https://github.com/Moechz/dokuwiki/blob/main/PRIVACY.md> (verified HTTP 200),
  so the policy opens from the App Center as well.

### Description (C9, F5)

- `descript` / `important` / `release_note` rewritten in all 23 language
  sections (English, `zh-cn`, `zh-hk` translated; the rest English, as the
  platform allows) to describe exactly what the package delivers: page editing
  in DokuWiki markup, namespaces, attachments, revisions, search, feeds,
  templates, accounts + groups + ACL, and the Extension Manager. Removed the
  claim that the app is served by the PHP built-in server.
- The `zh-cn` / `zh-hk` texts are DokuWiki-specific (not inherited from another
  application) and match the English meaning.

### Repository (C10)

- README rewritten: what the package is, how it works, full repository layout,
  architecture support, data paths, uninstall/reinstall/backup, privacy and
  notices sections, build and verification commands, review remediation map and
  limitations.
- Added [`NOTICE.md`](NOTICE.md) (upstream licence GPL-2.0, image tag + digest,
  component licences, trading names, T1 note) and the complete package source
  (`src/`, `scripts/`, `tools/`, `test/`) in a public repository.

### Security (T1)

- No newer upstream release or image build exists: `2026-07-14c` is the current
  DokuWiki release (2026-09-02) and `dokuwiki/dokuwiki:2026-07-14c` — the same
  digest as `stable` — was last built 2026-11-06 on Debian 13.7 with PHP 8.4.27
  and Apache 2.4.69-1~deb13u1. The packager cannot patch base-image packages
  without forking and republishing the upstream image, which is out of scope for
  a packaging submission.
- Recorded in `NOTICE.md` what was measured on this exact image: **mod_http2 is
  not enabled** (`apache2ctl -M` has no `http2_module`) and **mod_proxy_html is
  not enabled**, so the RCE class reported for Apache httpd 2.4.69/2.4.70 in
  those modules is not reachable; the service is plain HTTP/1.1 on 8179, non-root,
  no extra capabilities.
- Follow-up: pick up the fixed base image as soon as the upstream project
  rebuilds `dokuwiki/dokuwiki`; the pinned tag makes the upgrade a single-line
  change plus a rebuild.

### Removed

- `src/entrypoint.sh` and the embedded `command:` block in
  `docker-compose.yml` (the wrapper that caused F5/F7). The spec is now
  `mode: plain`.
- Stale `probe` data (it described the removed `php -S` wrapper).

## 2026.7.14-1 — 2026-11-15

### Added
- First release. DokuWiki (`dokuwiki/dokuwiki:2026-07-14c`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8179 and running
  as a non-root user (1000:1000).
- Persistent data kept under `/Volume1/DockerAppData/dokuwikidocker/`.
