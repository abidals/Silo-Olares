# Security notes

## What this chart sends where
- The server image is pulled from `ghcr.io/silo-server/silo-server:latest` (public).
- Metadata/artwork providers (TMDB, TVDB, …) are contacted outbound by the app itself
  (as documented upstream); no telemetry endpoints are added by this packaging.
- PostgreSQL and Redis are the Olares system middleware services, wired with
  platform-injected credentials via environment variables — no secrets are stored in
  this repository.

## Reporting
Please open an issue in this repository for packaging problems. For vulnerabilities in
the application itself, use the upstream project's security policy:
https://github.com/Silo-Server/silo-server/security

## Known limitations
- The image tag is a rolling `latest`; pin a digest if you need reproducibility.
- The in-app "Install Web UI" (jellyfin-web) builds locally inside the container;
  it requires outbound network access to github.com and npmjs at build time.