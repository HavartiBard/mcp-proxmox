# Container Build & Publish Rules

Purpose
- Provide a consistent, repeatable process for building and publishing container images from this repo (and across other repos).

Scope
- Applies to all repositories where images are built and published to registries (GHCR, Docker Hub, etc.).

Rules
1. Repository preparation
   - Ensure `Dockerfile` lives at the repository root or document its path.
   - Add `build.sh` (or equivalent) to encapsulate `docker build` options and tagging.

2. Local environment prerequisites
   - Docker (or Podman) installed and user permitted to access the daemon (or use `sudo`).
   - A personal access token (PAT) for the target registry available in env var `GHCR_TOKEN` (or `DOCKER_TOKEN`) with `write:packages` or equivalent scope.
   - Export `GITHUB_USER` (lowercase for image tags) or configure `build.sh` to use a lowercase registry path.

3. Build steps
   - Run `./build.sh` from repo root. `build.sh` should:
     - Read `GITHUB_USER` and `VERSION` env vars (fall back to defaults if unset).
     - Run `docker build -t ${IMAGE}:${VERSION} -t ${IMAGE}:latest .`.

4. Authentication & push
   - Login non-interactively: `echo "$GHCR_TOKEN" | docker login ghcr.io -u <user> --password-stdin`.
   - Push version and latest: `docker push ${IMAGE}:${VERSION}` and `docker push ${IMAGE}:latest`.

5. Release documentation
   - After a successful push, add a release note entry under `RELEASES/${VERSION}.md` including: image tags, digest (optional), build branch, and date.
   - Commit and push the release note to the same branch used for the build.
   - Create an annotated git tag `v${VERSION}` and push the tag: `git tag -a v${VERSION} -m "Release v${VERSION}" && git push origin v${VERSION}`.

6. Security
   - Never commit tokens to the repo. Use environment variables or CI secrets.
   - If a token is ever printed/leaked, rotate/revoke it immediately.

7. CI integration
   - Mirror the local steps in CI jobs, using repository secrets for auth and only running push steps from protected branches or when releases are created.

8. Reproducibility
   - Pin base images (`node:20-alpine@sha256:...`) where possible to ensure deterministic builds.

9. Troubleshooting
   - If Docker socket permission denied: add user to `docker` group or run build with `sudo`.
   - If registry `denied`: check token scope and username casing (must be lowercase for image names).

10. Ownership
   - Document who is the image publisher and which GitHub org/user is used for image names.

Usage example
1. Locally set env vars:
   - `export GITHUB_USER=havartibard`
   - `export GHCR_TOKEN=<token>`
   - `./build.sh`
   - `echo "$GHCR_TOKEN" | docker login ghcr.io -u $GITHUB_USER --password-stdin`
   - `docker push ghcr.io/$GITHUB_USER/mcp-proxmox:1.0.0`
   - Commit `RELEASES/1.0.0.md`, tag and push.
