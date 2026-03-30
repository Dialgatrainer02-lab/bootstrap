#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-images.txt}"
OUTPUT_DIR="${2:-output}"
ARCHIVE_NAME="${3:-bundle.tar}"

# Platform config
ARCH="${ARCH:-amd64}"
OS="${OS:-linux}"

# Parallelism
PARALLEL_COPY="${PARALLEL_COPY:-4}"
PARALLEL_SBOM="${PARALLEL_SBOM:-2}"

# Feature gates
ENABLE_COPY="${ENABLE_COPY:-true}"
ENABLE_SBOM="${ENABLE_SBOM:-true}"
ENABLE_REFERRERS="${ENABLE_REFERRERS:-true}"
ENABLE_OCI_ARTIFACTS="${ENABLE_OCI_ARTIFACTS:-true}"

OCI_DIR="${OUTPUT_DIR}/oci-layout"
SBOM_DIR="${OUTPUT_DIR}/sboms"
META_FILE="${OUTPUT_DIR}/digests.txt"

mkdir -p "$OCI_DIR" "$SBOM_DIR"
: > "$META_FILE"

echo "📥 Input: $INPUT_FILE"
echo "⚙️  Arch=$ARCH OS=$OS"
echo "🚀 Parallel: copy=$PARALLEL_COPY sbom=$PARALLEL_SBOM"
echo "🧩 Features: copy=$ENABLE_COPY sbom=$ENABLE_SBOM referrers=$ENABLE_REFERRERS"

normalize_ref() {
    local REF="$1"
    if [[ "$REF" == oci://* ]]; then
        echo "${REF#oci://}"
    else
        echo "$REF"
    fi
}

resolve_digest() {
    local REF="$1"
    skopeo inspect docker://"$REF" --format '{{.Digest}}'
}

copy_artifact() {
    local REF="$1"

    [[ "$ENABLE_COPY" != "true" ]] && return 0

    echo "⬇️  Copying $REF"

    skopeo copy \
        --retry-times 3 \
        --override-arch="$ARCH" \
        --override-os="$OS" \
        docker://"$REF" \
        oci:"$OCI_DIR"

    echo "✅ Copied $REF"
}

generate_sbom() {
    local REF="$1"
    local DIGEST="$2"

    [[ "$ENABLE_SBOM" != "true" ]] && return 0

    SAFE_NAME
    SAFE_NAME=$(echo "$REF" | sed 's|/|_|g; s|:|_|g')

    SBOM_FILE="${SBOM_DIR}/${SAFE_NAME}.cdx.json"

    echo "🧾 SBOM for $REF"

    syft "$REF" -o cyclonedx-json > "$SBOM_FILE"

    if [[ "$ENABLE_REFERRERS" == "true" ]]; then
        echo "📦 Attaching SBOM (referrer)"

        oras attach \
            --artifact-type application/vnd.cyclonedx+json \
            "$OCI_DIR@$DIGEST" \
            "$SBOM_FILE:application/json"
    fi

    echo "✅ SBOM done $REF"
}

process_ref() {
    local INPUT_REF="$1"
    [[ -z "$INPUT_REF" ]] && return 0

    REF=$(normalize_ref "$INPUT_REF")

    echo "🔍 Resolving $REF"
    DIGEST=$(resolve_digest "$REF")

    echo "$REF@$DIGEST" >> "$META_FILE"

    copy_artifact "$REF"

    echo "$REF|$DIGEST"
}

export -f normalize_ref resolve_digest copy_artifact generate_sbom process_ref
export OCI_DIR SBOM_DIR META_FILE ARCH OS ENABLE_COPY ENABLE_SBOM ENABLE_REFERRERS

# Step 1: Resolve + copy
RESULTS=$(grep -vE '^\s*#|^\s*$' "$INPUT_FILE" | \
    xargs -I {} -P "$PARALLEL_COPY" bash -c 'process_ref "$@"' _ {})

# Step 2: SBOMs (separate controlled parallelism)
echo "$RESULTS" | while IFS='|' read -r REF DIGEST; do
    echo "$REF|$DIGEST"
done | xargs -I {} -P "$PARALLEL_SBOM" bash -c '
    IFS="|" read -r REF DIGEST <<< "{}"
    generate_sbom "$REF" "$DIGEST"
'

echo "📦 Creating bundle: $ARCHIVE_NAME"
tar -cvf "$ARCHIVE_NAME" -C "$OUTPUT_DIR" .

echo "🎉 Done: $ARCHIVE_NAME"