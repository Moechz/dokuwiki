# Privacy policy — DokuWiki for TerraMaster TOS (`dokuwikidocker`)

**Last updated:** 2026-11-22
**Applies to:** DokuWiki package version `2026.7.14-2` and later, published by
Moechz in the TerraMaster App Center.
**Upstream project:** <https://github.com/dokuwiki/dokuwiki>
**Contact / data requests:** <https://github.com/Moechz/dokuwiki/issues>

This policy explains what the DokuWiki application package stores, where it is
stored, how long it is kept, when anything leaves your NAS, and how you (and the
users of your wiki) can access, correct or delete it.

DokuWiki is a **self-hosted** application. It runs entirely on your TerraMaster
NAS in a Docker container. The packager does not operate a server, does not
receive your wiki content, accounts or logs, and has no way to access your NAS.
The "data controller" for everything you put into the wiki is **you**, the
owner/administrator of the NAS.

---

## 1. What the application stores

DokuWiki stores the wiki content you create and the account data needed to run
it. Nothing else.

| Data | Where it is stored | Why |
|---|---|---|
| **Page content** (wiki text of every page) | `/Volume1/DockerAppData/dokuwikidocker/data/pages/**/*.txt` | The wiki itself. One plain-text file per page, in DokuWiki markup. |
| **Page revision history** (`attic`) | `.../data/attic/**/*.txt.gz` | DokuWiki keeps every saved revision so old versions can be viewed and restored. |
| **Page metadata and edit history** | `.../data/meta/**/*.changes`, `.../data/meta/**/*.meta` | Last editor, last modification time, edit summary, page relations, backlinks. |
| **Attachments / media** (uploaded images, PDFs, any file) | `.../data/media/**` | Files you upload through the Media Manager or attach to pages. |
| **Attachment history and metadata** | `.../data/media_attic/**`, `.../data/media_meta/**` | Old versions of replaced files, MIME type, size, references. |
| **User accounts** | `.../conf/users.auth.php` | Login name, display name, e-mail address (optional), **bcrypt password hash**, group membership, and the "disabled" flag. |
| **Groups** | `.../conf/groups.auth.php` | Group names and members, used for permissions. |
| **Access control rules (ACL)** | `.../conf/acl.auth.php` | Which user or group may read/edit/upload/delete which page or namespace. |
| **Wiki and plugin configuration** | `.../conf/local.php`, `.../conf/plugins.local.php`, `.../conf/plugin/*.conf` | Title, language, ACL switch, superuser group, per-plugin settings. |
| **Installed plugins and templates** | `.../lib/plugins/**`, `.../lib/tpl/**` | Code you install through the Extension Manager or copy in yourself. |
| **Search index, caches, locks, temp files** | `.../data/index/**`, `.../data/cache/**`, `.../data/locks/**`, `.../data/tmp/**` | Derived data: rebuilt automatically, safe to delete while the container is stopped. |
| **DokuWiki log files** | `.../data/log/{error,deprecated,debug}/YYYY-MM-DD.log` | Date-stamped error/warning logs written by DokuWiki itself (PHP errors, failed logins, plugin warnings). |
| **Web-server access and error log** | Docker's log store for the container (`docker logs dokuwikidocker`) | Every HTTP request: client IP address, timestamp, requested URL, status, User-Agent. Kept on the NAS, rotated according to your Docker logging configuration. |
| **Login session** | Browser cookie `DokuWiki` + PHP session files inside the container | Keeps you logged in. The cookie holds a random session id, valid until the browser closes or the session expires (PHP session idle limit: 24 minutes). Session files live in the container and are discarded when it is recreated. |

The package itself contains **no analytics, telemetry, crash-reporting,
advertising or tracking code**, no third-party JavaScript and no external fonts
or CDNs: all UI assets are served by the container.

DokuWiki does not ask for any data beyond what you type into the wiki. Whether a
page, an attachment or an account contains personal data is decided by you and
your wiki users.

## 2. Where the data is stored

Everything persistent lives below **one** directory on the NAS:

```text
/Volume1/DockerAppData/dokuwikidocker/
├── data/    -> /storage/data    pages/, attic/, media/, media_attic/, media_meta/,
│                                meta/, index/, cache/, locks/, tmp/, log/
├── conf/    -> /storage/conf    local.php, users.auth.php, groups.auth.php,
│                                acl.auth.php, plugins.local.php
└── lib/     -> /storage/lib     plugins/, tpl/  (core extensions are symlinks into
                                 the image; extensions you install are real dirs)
```

Inside the container these appear as `/storage/data`, `/storage/conf` and
`/storage/lib`; the image links `/var/www/html/data`, `/var/www/html/conf` and
`/var/www/html/lib/plugins` to them. Because `conf/` and `lib/` live on the NAS
(not inside the container), **accounts, passwords, groups, ACL rules and
installed extensions survive container updates and reinstalls**.

The application writes nothing outside those three directories. The container's
own filesystem (`/var/www/html`, `/tmp`, Apache logs) is disposable and is
recreated from the image.

## 3. Does data leave the NAS?

**Nothing about you or your users is sent to the packager — ever.** There is no
account with the packager, no licence check, no usage statistics and no
"phone home".

Network connections do happen in the following cases. All of them are listed in
the disclosure table below, and all but the image download can be turned off.

1. **Installing / updating the container** — Docker pulls
   `dokuwiki/dokuwiki:2026-07-14c` from Docker Hub. As with any registry
   download, Docker Hub sees the NAS's IP address, the image name and tag.
2. **DokuWiki update check (on by default)** — DokuWiki asks
   `https://update.dokuwiki.org/check/<version>` for release/security notices
   and caches the answer for 24 hours. The only thing transmitted is the
   **DokuWiki version string in the URL path** (plus the usual HTTP metadata:
   source IP, User-Agent). No content, no account data. Turn it off in
   *Admin → Configuration → `updatecheck`* (or in `conf/local.php`:
   `$conf['updatecheck'] = 0;`).
3. **Extension Manager (manual, administrator only)** — when an administrator
   opens *Admin → Extension Manager* and searches or installs an extension,
   DokuWiki contacts `https://www.dokuwiki.org/lib/plugins/pluginrepo/api.php`
   (the search term / extension name is sent) and downloads the chosen
   extension from the URL its repository declares — in practice usually
   `github.com` / `codeload.github.com` / `raw.githubusercontent.com`, but it can
   be any host the extension author uses. Nothing is contacted until an
   administrator clicks Search or Install.
4. **Content that embeds remote resources** — a wiki page you write may embed an
   external image (`{{https://…/x.png}}`), an RSS/ATOM feed (`{{rss>…}}`) or a
   link. Then your **browser** loads the image/link from that host, and for feed
   includes the **server** fetches the feed when the page is rendered. The
   receiving host sees the NAS's or the reader's IP address. You control this by
   what you put on the pages.
5. **An optional proxy you configure** (`$conf['proxy']`) — off by default.

DokuWiki has **no** feature that reports page content, page titles, user names,
e-mail addresses, IP addresses or statistics to the packager or to the upstream
project.

## 4. Third-party endpoints (disclosure table)

| Endpoint | Data sent | Destination | Trigger / default | Can it be disabled? |
|---|---|---|---|---|
| `registry-1.docker.io`, `auth.docker.io`, `production.cloudflare.docker.com` (Docker Hub) | Image name + tag, NAS IP address | Docker Hub (Docker, Inc., USA) | App install and every container update | No — it is how the app is installed. On an offline NAS you can pre-pull the image. |
| `https://update.dokuwiki.org/check/<version>` | DokuWiki version string (in the URL), source IP, User-Agent | dokuwiki.org (DokuWiki project, Germany) | Update/security notice check, at most once per 24 h; with ACL enabled only manager accounts trigger it | Yes — *Configuration → `updatecheck` = off* |
| `https://www.dokuwiki.org/lib/plugins/pluginrepo/api.php` | Search term / extension name, source IP, User-Agent | dokuwiki.org | Administrator opens the Extension Manager and searches/browses | Yes — do not use the Extension Manager (or block the host) |
| Extension download URL declared by the extension (usually `github.com`, `codeload.github.com`, `raw.githubusercontent.com`; may be any HTTPS host) | Extension name/version, source IP | That host (typically GitHub, Inc., USA) | Administrator clicks *Install/Update* in the Extension Manager | Yes — install extensions manually from the NAS instead |
| Remote images, feeds or links placed in wiki pages (any host you choose) | HTTP request for that resource (source IP, Referer for browser requests) | The host you embedded | When a page containing them is viewed | Yes — remove the embed from the page |
| Optional HTTP proxy configured in `$conf['proxy']` | The traffic above, routed through your proxy | Your proxy | Only if you configure it | Off by default |

There is no other outbound traffic: no analytics, no telemetry, no advertising,
no crash reporting, no third-party JavaScript, no CDN-loaded assets.

## 5. Retention period

- **Pages, attachments and accounts do not expire automatically.** DokuWiki has
  no time-to-live and no scheduled deletion. They stay on the NAS until they are
  deleted (§7) or until the application data directory is removed.
- **Revisions do not expire either.** Every save keeps the previous version in
  `data/attic/` (compressed) and, with the default `mediarevisions = 1`, every
  replaced attachment in `data/media_attic/`. An administrator can remove old
  revisions page by page (*Old revisions → delete*) or by deleting the files
  below `attic/` after stopping the container.
- **DokuWiki log files** are date-stamped and never deleted by the application.
  You can delete `data/log/*/*.log` at any time (stop the container first for a
  clean delete).
- **Container logs** (HTTP access log, PHP/Apache errors) are kept in Docker's
  log store according to your Docker daemon's log driver and rotation settings.
  The package does not configure an unlimited log policy; set one in the Docker
  settings if the NAS is short on space.
- **Login sessions** end when the browser closes or after 24 minutes of
  inactivity (PHP `session.gc_maxlifetime = 1440`). Session files are discarded
  with the container.
- **Caches and search index** are derived data and may be rebuilt at any time.
- **Backups:** if you back up the NAS (or the
  `/Volume1/DockerAppData/dokuwikidocker/` folder), copies of the wiki content
  and of `conf/users.auth.php` may exist in those backups under your backup
  tool's retention rules. The package creates no backups itself.
- **Deleted users:** deleting an account removes it from `users.auth.php`
  immediately. Pages the user wrote stay (with their name in the history) until
  they are deleted or the page history is purged, unless you remove those
  revisions as well.

## 6. Your rights and how to exercise them

Because the data is on your own NAS and the packager never receives it, rights
are exercised directly, on the NAS:

- **Access / portability** — read everything with the tools you already have:
  - wiki content: the web UI, or the plain files below
    `/Volume1/DockerAppData/dokuwikidocker/data/`;
  - account data (login name, display name, e-mail, groups, password hash) and
    ACL rules: `/Volume1/DockerAppData/dokuwikidocker/conf/users.auth.php`,
    `groups.auth.php`, `acl.auth.php` (PHP-array text files), or the admin pages
    *User Manager* and *Access Control List Management*.
- **Rectification** — correct pages with the normal editor (every change is a
  new revision); correct a user's name, e-mail, group membership or password in
  *Admin → User Manager* (or in `users.auth.php` while the container is
  stopped); change permissions in *Admin → Access Control List Management*.
- **Erasure** — see §7.
- **Restriction / objection** — stop the container, do not publish the wiki to
  the LAN/Internet, disable the update check (§3), or uninstall the app.
- **Withdraw consent** — there is no consent to withdraw: the packager processes
  nothing, and the wiki only stores what you enter.
- **Automated decisions / profiling** — none. DokuWiki does not profile users,
  does not score them and makes no automated decisions about them.
- **Complaint** — contact the packager through
  <https://github.com/Moechz/dokuwiki/issues>; you also have the right to
  contact your local data-protection authority.

**Rights of wiki users (not the NAS owner).** Accounts in the wiki are created by
the wiki administrator. A user who wants their account data (name, e-mail,
password, group membership) or their contributions exported, corrected or
deleted should contact **their wiki administrator** — that is the only party with
access. The packager cannot read, change or delete anything in your wiki. If the
administrator does not react, the NAS owner can always perform the deletion
directly on the files (§7) — no third party is involved.

## 7. Deletion channel

Three supported ways, all available to the NAS owner:

1. **From the wiki UI (administrator):**
   - *Admin → User Manager* → delete a user (removes the account from
     `users.auth.php` immediately);
   - *Old revisions* of a page → delete revisions; *Media Manager* → delete
     files and their old versions;
   - edit a page and blank it, or use a namespace-delete plugin, to remove
     content.
2. **From the NAS file system** (TOS File Manager or SSH), with the container
   stopped for a consistent delete:
   - one page: delete
     `/Volume1/DockerAppData/dokuwikidocker/data/pages/<ns>/<page>.txt`
     (and the matching `attic/`, `meta/` entries);
   - one attachment: delete `.../data/media/<ns>/<file>` and its
     `media_attic/`, `media_meta/` entries;
   - one account: remove its line from `.../conf/users.auth.php`;
   - everything: delete the whole
     `/Volume1/DockerAppData/dokuwikidocker/` folder.
3. **Uninstall the app with its data:** in App Center, uninstall DokuWiki and
   choose the option to delete the application data. If you uninstall and keep
   the data, the wiki content, accounts and ACL are still there and are reused
   when you reinstall.

Deletion is immediate and final from the application's point of view: there is
no recycle bin and the package keeps no hidden copy. Copies may still exist in
NAS snapshots or backups until those are rotated out under your own policy, and
in the container log until Docker rotates it.

## 8. Security measures

- **Non-root container.** The service runs as uid/gid `1000:1000`
  (`user: "1000:1000"`), never as root, without `privileged`, without
  `network_mode: host`, without added capabilities, and **without the Docker
  socket**. It cannot touch other containers or the NAS outside its own data
  directories.
- **The data directory is not web-readable.** Apache serves the application from
  the document root and the image's rules deny `data/` and `conf/`; verified:
  `GET /data/pages/<page>.txt` and `GET /data/media/<file>` return **403**, and
  `conf/*.php` executes its `exit()` guard (no output, no password hashes), so
  pages and attachments can only be read through DokuWiki's authentication and
  ACL. (This was broken in 2026.7.14-1, which served those paths as static files
  — fixed in this version by using the upstream entrypoint.)
- **Accounts and ACL survive updates.** `conf/` and `lib/` are on the NAS, so an
  image update or container recreate does not reset accounts, passwords, groups,
  ACL rules or installed extensions.
- **Passwords are stored as bcrypt hashes** (`users.auth.php`), never in clear
  text. Login failures are logged to `data/log/error/`.
- **ACL is enforced by DokuWiki** on every read, edit, upload and delete, per
  page and per namespace, for users and groups. Public registration is disabled
  in the installer's default configuration (`disableactions = register`); only
  an administrator creates accounts.
- **Plain HTTP on the LAN.** The package ships no TLS certificate: the UI is
  served over HTTP on port 8179. Put a TLS reverse proxy (or a VPN) in front of
  it before exposing it to the internet, otherwise passwords and session cookies
  travel in clear text over that network.
- **Least data.** The image is used unmodified from Docker Hub and pinned to a
  fixed tag (`2026-07-14c`, never `:latest`), so an unexpected upstream change
  cannot silently alter the running service. The package contains no secrets,
  no API keys and no embedded credentials.
- **Health check** on the container's own `/health.php` (which boots DokuWiki),
  so a broken installation is reported instead of staying silently "up".
- **Updates.** The update check (§3) alerts administrators to new DokuWiki
  security releases; keep the NAS, Docker Engine and the app updated. Report
  packaging vulnerabilities through <https://github.com/Moechz/dokuwiki/issues>.

No system is perfectly secure. The wiki is exactly as private as the ACL you
configure and the network you expose it to.

## 9. Children

DokuWiki is a general-purpose documentation tool. It is not directed at
children, and the packager collects no data at all — from children or anyone
else.

## 10. Changes to this policy

This policy is versioned together with the application in the public repository
<https://github.com/Moechz/dokuwiki>. Material changes are described in
[`CHANGELOG.md`](CHANGELOG.md), and the current version is always available at:

<https://github.com/Moechz/dokuwiki/blob/main/PRIVACY.md>

The package's `help` link (`config.ini` → `help`, and the App Center "Help"
button) points to this document, so it can be opened from the application
without any other material.
