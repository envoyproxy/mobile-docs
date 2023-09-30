#!/bin/bash -e

set -o pipefail

BAZEL="${BAZEL:-bazel}"
OUTPUT_DIR="${1:-_site}"

if  [[ -e "$OUTPUT_DIR" ]]; then
    echo "Path to build the website (${OUTPUT_DIR}) exists, removing contents"
    rm -rf "${OUTPUT_DIR:?}"/*
fi

mkdir -p "${OUTPUT_DIR}"

$BAZEL build //site

echo "Extracting website -> ${OUTPUT_DIR}"

$BAZEL run \
    @envoy//tools/zstd -- \
        -cd "${PWD}/bazel-bin/site/site_html.tar.zst" \
    | tar -x -C "${OUTPUT_DIR}"

if [[ -n "$CI" ]]; then
    $BAZEL shutdown || :
fi

echo "Website built (${ENVOY_COMMIT}) in ${OUTPUT_DIR}"
