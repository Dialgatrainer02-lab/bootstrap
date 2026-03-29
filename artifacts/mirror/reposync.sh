#!/bin/bash
set -euo pipefail

# =========================
# Config (ENV)
# =========================
ARCH="${ARCH:-x86_64}"
RELEASEVER="${RELEASEVER:-9}"

REPOS="${REPOS:-baseos appstream extras crb}"
EXTRA_REPOS="${EXTRA_REPOS:-}"

# Parallelism
MAX_PARALLEL="${MAX_PARALLEL:-4}"

# Feature flags
ENABLE_SBOM="${ENABLE_SBOM:-false}"
ENABLE_DELTA="${ENABLE_DELTA:-false}"

OUTPUT_DIR="/sync/output"
REPO_DIR="$OUTPUT_DIR/repos"
WORK_DIR="$OUTPUT_DIR/work"
SBOM_FILE="$OUTPUT_DIR/sbom.json"
PREV_SBOM_FILE="$OUTPUT_DIR/prev-sbom.json"
DELTA_FILE="$OUTPUT_DIR/delta.json"

# =========================
# Load Custom Repo Files
# =========================
CUSTOM_REPO_DIR="${CUSTOM_REPO_DIR:-/custom}"

TAR_FILE="$OUTPUT_DIR/almalinux-repos.tar.gz"
LOG_DIR="$OUTPUT_DIR/logs"
echo $LOG_DIR

mkdir -p "$REPO_DIR" "$WORK_DIR"
mkdir -p "$LOG_DIR"

ALL_REPOS="$REPOS $EXTRA_REPOS"

echo "====================================="
echo "Release:        $RELEASEVER"
echo "Arch:           $ARCH"
echo "Repos:          $ALL_REPOS"
echo "Parallel Jobs:  $MAX_PARALLEL"
echo "SBOM Enabled:   $ENABLE_SBOM"
echo "Delta Enabled:  $ENABLE_DELTA"
echo "====================================="

# =========================
# Repo Sync (Parallel)
# =========================
sync_repo() {
	repo="$1"
	log_file="$LOG_DIR/${repo}.log"

	echo "➡️ Syncing $repo (log: $log_file)"

	{
		echo "===== START $(date) ====="
		echo "Repo: $repo"
		echo "Release: $RELEASEVER"
		echo "Arch: $ARCH"
		echo "-------------------------------------"

		reposync \
			--repoid="$repo" \
			--releasever="$RELEASEVER" \
			--arch="$ARCH" \
			--download-metadata \
			--download-path="$REPO_DIR" \
			--newest-only \
			--delete

		echo "-------------------------------------"
		echo "✅ SUCCESS $repo"
		echo "===== END $(date) ====="
	} >"$log_file" 2>&1 || {
		{
			echo "❌ FAILED $repo (see $log_file)"
			echo "-------------------------------------"
			echo "❌ FAILED $repo"
			echo "===== END $(date) ====="
		} >>"$log_file"
	}
}

export -f sync_repo
export REPO_DIR ARCH RELEASEVER

if [ -d "$CUSTOM_REPO_DIR" ]; then
	echo "📥 Loading custom repo files from $CUSTOM_REPO_DIR"

	find "$CUSTOM_REPO_DIR" -name "*.repo" | while read -r repo_file; do
		echo "➕ Adding repo file: $repo_file"
		cp "$repo_file" /etc/yum.repos.d/
	done
	dnf repolist
fi

echo "🔄 Parallel syncing..."
# shellcheck disable=SC2086
printf "%s\n" $ALL_REPOS | parallel -j "$MAX_PARALLEL" sync_repo {}

# =========================
# SBOM Generation (optional)
# =========================
if [ "$ENABLE_SBOM" = "true" ]; then
	echo "📦 Generating SBOM..."

	syft dir:"$REPO_DIR" -o cyclonedx-json >"$SBOM_FILE"

	echo "✅ SBOM generated: $SBOM_FILE"
fi

# =========================
# Delta Detection (optional)
# =========================
if [ "$ENABLE_DELTA" = "true" ] && [ -f "$PREV_SBOM_FILE" ] && [ -f "$SBOM_FILE" ]; then
	echo "🔍 Calculating delta from previous SBOM..."

	jq -s '
        def to_map:
            .components
            | map({key: (.name + "-" + .version), value: .})
            | from_entries;

        (.[0] | to_map) as $old
        | (.[1] | to_map) as $new
        | {
            added: ($new - $old | keys),
            removed: ($old - $new | keys)
        }
    ' "$PREV_SBOM_FILE" "$SBOM_FILE" >"$DELTA_FILE"

	echo "✅ Delta written: $DELTA_FILE"
fi

# =========================
# Archive
# =========================
echo "📦 Creating tar archive..."
tar -czf "$TAR_FILE" -C "$OUTPUT_DIR" .

echo "✅ Done!"
