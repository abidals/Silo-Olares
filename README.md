# Silo for Olares

[![Release](https://img.shields.io/github/v/release/abidals/Silo-Olares)](../../releases)
[![License](https://img.shields.io/badge/license-AGPL--3.0--or--later-blue)](#license)

**Silo** is a self-hosted media streaming server for films, series, audiobooks, ebooks, podcasts, and manga — packaged as a native **Olares** application.

This repository hosts the Olares chart (packaging) for the upstream project [Silo-Server/silo-server](https://github.com/Silo-Server/silo-server). It ships:

- A Go backend + React web UI, PostgreSQL (pgvector) and Redis as always-on system middleware
- Built-in **Jellyfin-compatible** (`:8096`) and **Audiobookshelf-compatible** (`:13378`) APIs, so existing Jellyfin / ABS clients can connect
- **Hardware-accelerated transcoding** (NVIDIA NVENC via Olares GPU binding; Intel/AMD VAAPI handled by the upstream image where device passthrough exists)
- Direct play, remuxing, and full-library search (Meilisearch optional off by default)

> **Silo** هو خادم وسائط ذاتي الاستضافة للأفلام والمسلسلات والكتب الصوتية والكتب الإلكترونية والبودكاست والمانجا، مع واجهة متوافقة مع تطبيقات Jellyfin/Audiobookshelf، ودعم تسريع عتادي للترميز (NVENC) على Olares.

---

## Requirements

| Requirement | Notes |
|---|---|
| Olares | 1.12.6 or newer (system PostgreSQL + Redis middleware must be present — they ship by default) |
| Architecture | `amd64` node only (the upstream server image is amd64) |
| Resources | ~3 Gi RAM request / 8 Gi limit, 1-core request / 8-core limit, 1 Gi disk |
| GPU (optional) | An NVIDIA GPU enables \`NVENC\` hardware transcoding; without one, Silo transcodes on CPU |
| Media storage | A NAS / share mounted where you'll point Silo's libraries (e.g. the "External storage" area) |

## Install

### Option A — install the release package (recommended)

1. Download the latest `silo-<version>.tgz` from the [Releases](../../releases) page.
2. On your Olares:

   ```sh
   olares-cli market upload silo-<version>.tgz
   olares-cli market install silo -s upload --version <version> --watch
   ```

   Omit `--version` to install the newest uploaded chart.
3. Olares will show Silo in **Market → My Apps**. Open it and complete the onboarding (admin account, libraries, providers).

### Option B — build and upload yourself

```sh
git clone https://github.com/abidals/Silo-Olares.git
cd Silo-Olares
olares-cli chart lint silo
olares-cli chart package silo
olares-cli market upload silo-<version>.tgz
olares-cli market install silo -s upload --version <version> --watch
```

### NVIDIA GPU binding

If your Olares node has an NVIDIA GPU and you install this chart, the platform selects a **compute mode** at install time. To pin the GPU at install:

```sh
olares-cli market install silo -s upload --compute-mode nvidia --watch
```

On Olares 1.12.6+, apps already installed in `cpu` mode **cannot be re-bound** without a re-install — supply `--compute-binding <node>:<device>[:<mem>]` when resuming a stopped GPU-bound app:

```sh
olares-cli market resume silo --compute-binding <node>:<device-id>:2 --watch
```

(Camera device list via `olares-cli settings compute list`.)

## First configuration

1. Open Silo from the Olares desktop → create your admin account.
2. **Storage → Public Assets**: Silo stores generated artwork / chapter thumbnails in an S3-compatible bucket (any endpoint works; self-host Garage or MinIO if you don't have one).
3. **Libraries**: add folders — Silo reads your Olares "External storage" area (LarePass-connected SMB/NFS shares) and any paths you mount into `/mnt/media` .
4. Enable TMDB/TVDB metadata providers in **Admin → Settings → Providers**.
5. Optional: **Admin → Settings → Compatibility → Jellyfin web UI → Install Web UI** — downloads and builds the official Jellyfin web player locally so the compatibility endpoint can serve a familiar UI to Jellyfin apps (first build takes several minutes; it parks at 60% during the vite build).

## Updating the server version

The chart tracks upstream rolling builds (`ghcr.io/silo-server/silo-server:latest` with `imagePullPolicy: Always`), so **every container restart re-pulls the latest build** — upstream publishes multiple builds per day. To refresh:

```sh
olares-cli cluster pod restart -n <namespace>/<pod> --yes
```

To *pin* a known-good version instead of riding rolling builds, change the image tag in `silo/templates/deployment.yaml` to an explicit `build-N` tag with a digest, then re-package and upgrade.

## Uninstalling

Market → My Apps → Silo → Uninstall. Silo keeps its application database in the Olares system PostgreSQL and its media on your storage; uninstalling removes the app workload, and (as with all Olares apps) `--delete-data` clears the app's private Data folder.

## Troubleshooting

- **App stuck `stopped` after a GPU change** — GPU IDs change when hardware changes; rebind:
  `olares-cli market resume silo --compute-binding <node>:<device-id>:2 --watch`
- **"Wait until the media is ready" on TV/mobile clients** — the Android/iOS clients are alpha; try the web UI, or install the built-in Jellyfin web player (Admin → Settings → Compatibility) and connect with official Jellyfin apps via the `:8096` entrance.
- **CrashLoop with `"server: not found"` in logs** — you are running a chart older than v0.1.6 against the new omnibus image; upgrade the chart (args are no longer accepted).
- **Slow HD transcodes** — raise the envelope in `OlaresManifest.yaml` and keep at minimum 4 CPU cores available.
- Logs: `olares-cli cluster pod logs -n <namespace> <pod> -c silo --follow`.

See also the upstream docs: <https://siloserver.org/docs/>.

## License

- This Olares packaging (chart, manifests, docs) is released under **AGPL-3.0-or-later**, matching the upstream project.
- Upstream Silo: [github.com/Silo-Server/silo-server](https://github.com/Silo-Server/silo-server) — AGPL-3.0-or-later, © Silo-Server contributors.
- Bundled components (upstream image) include FFmpeg / jellyfin-web and respective licenses; see the upstream repository's `THIRD_PARTY_NOTICES.md`.

Submitter of this packaging: **abidals**

## Disclaimers

- Silo is pre-1.0 software; expect API/UI changes between builds ("latest" tracks `main`).
- This is an unofficial community packaging; for official docs and support visit <https://siloserver.org/>.