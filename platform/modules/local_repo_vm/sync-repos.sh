#!/bin/bash
set -euo pipefail

BASE_DIR="/var/www/html/repos"
SNAPSHOT_DATE=$(date +%F)

SNAPSHOT_DIR="$BASE_DIR/snapshots/$SNAPSHOT_DATE"
CURRENT_LINK="$BASE_DIR/current"

mkdir -p "$SNAPSHOT_DIR"

echo "=== Creating snapshot: $SNAPSHOT_DATE ==="

# Repo layout
ALMA_DIR="$SNAPSHOT_DIR/almalinux/10"
EPEL_DIR="$SNAPSHOT_DIR/epel"
DOCKER_DIR="$SNAPSHOT_DIR/docker"
HASHICORP_DIR="$SNAPSHOT_DIR/hashicorp"
VECTOR_DIR="$SNAPSHOT_DIR/vector"
OPENBAO_DIR="$SNAPSHOT_DIR/openbao"

mkdir -p "$ALMA_DIR" "$EPEL_DIR" "$DOCKER_DIR" "$HASHICORP_DIR" "$VECTOR_DIR" "$OPENBAO_DIR"

echo "=== Syncing AlmaLinux 10 ==="
for repo in baseos appstream extras crb; do
  reposync \
    --repoid=$repo \
    --download-metadata \
    --downloadcomps \
    --delete \
    --norepopath \
    --arch=x86_64 \
    --newest-only \
    -p "$ALMA_DIR/$repo"

  createrepo_c "$ALMA_DIR/$repo"
done

echo "=== Syncing EPEL ==="
reposync \
  --repoid=epel \
  --download-metadata \
  --delete \
  --norepopath \
  --arch=x86_64 \
  --newest-only \
  -p "$EPEL_DIR"

createrepo_c "$EPEL_DIR"

echo "=== Syncing Docker repo ==="
reposync \
  --repoid=docker-ce-stable \
  --download-metadata \
  --delete \
  --norepopath \
  --arch=x86_64 \
  --newest-only \
  -p "$DOCKER_DIR"
createrepo_c "$DOCKER_DIR"

echo "=== Syncing HashiCorp repo ==="
reposync \
  --repoid=hashicorp \
  --download-metadata \
  --delete \
  --norepopath \
  --arch=x86_64 \
  --newest-only \
  -p "$HASHICORP_DIR"
createrepo_c "$HASHICORP_DIR"

echo "=== Syncing Vector repo ==="
reposync \
  --repoid=vector \
  --download-metadata \
  --delete \
  --norepopath \
  --arch=x86_64 \
  --newest-only \
  -p "$VECTOR_DIR"
createrepo_c "$VECTOR_DIR"

echo "=== Syncing OpenBao packages ==="
rm -f "$OPENBAO_DIR"/*.rpm
dnf download --resolve --alldeps --destdir "$OPENBAO_DIR" openbao
createrepo_c "$OPENBAO_DIR"

chmod +755 "$BASE_DIR"
chown nginx:nginx "$BASE_DIR"

echo "=== Updating current symlink ==="
ln -sfn "$SNAPSHOT_DIR" "$CURRENT_LINK"

echo "=== Cleanup old snapshots (keep last 7) ==="
mapfile -t old_snapshots < <(
  find "$BASE_DIR/snapshots" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' \
    | sort -nr \
    | awk 'NR > 7 { $1 = ""; sub(/^ /, ""); print }'
)

if [ "${#old_snapshots[@]}" -gt 0 ]; then
  rm -rf "${old_snapshots[@]}"
fi
