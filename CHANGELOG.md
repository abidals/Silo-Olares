# Changelog — Silo Olares packaging

Packaging-only changes; server features follow upstream `main` (see
https://github.com/Silo-Server/silo-server).

## 0.1.6 — 2026-10-31
- Fixed: crash-loop on startup with the upstream "Silo omnibus" image
  (s6-overlay, Entrypoint `/init`). The chart no longer passes the legacy
  `args: ["server"]`, which rc.init treated as a nonexistent service name.
- Added `submitter` metadata.

## 0.1.5 — 2026-09-17
- Resource envelope raised to 8 cores / 8Gi (requests 1 core / 3Gi) so NVENC
  transcode, library scanning and in-app jellyfin-web builds don't starve each
  other in a single cgroup.

## 0.1.4 — 2026-09-11
- NVIDIA hardware transcoding: declares `cpu` + `nvidia` accelerator modes,
  gpu-inject annotation, `NVIDIA_VISIBLE_DEVICES` /
  `NVIDIA_DRIVER_CAPABILITIES=compute,video,utility`.

## 0.1.3 — 2026-09-11
- Resource envelope raise for real-time playback (previously 1 core / 2Gi,
  which starved software transcodes).

## 0.1.2 — 2026-09-09
- `imagePullPolicy: Always` to track upstream rolling `latest` builds.

## 0.1.1 — 2026-09-09
- Mounts the user's LarePass NAS / external storage share inside the container
  so libraries can point at NAS paths.

## 0.1.0 — 2026-08-24
- Initial packaging: PostgreSQL (pgvector) + Redis as system middleware, public
  web entrance on port 8080, Jellyfin (:8096) and Audiobookshelf (:13378)
  compatibility listeners, hardware-transcoding URLs intact.