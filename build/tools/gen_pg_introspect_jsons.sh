#!/bin/bash

set -euo pipefail

_make_comparable() {
    local json="$1"; shift

    local pg_version
    pg_version="$(echo "${json}" | cut -d~ -f2)"

    sed -E "
        s;/[a-z]+/.cache/bazel/_bazel_[a-z]+/[a-f0-9]+;<BAZEL_CACHE>;g
        s;<BAZEL_CACHE>/sandbox/[a-z]+-sandbox/[0-9]+/execroot/_main;<BAZEL_CACHE>/<SANDBOX>/<BAZEL-BUILD>;g
        s;<BAZEL_CACHE>/execroot/_main;<BAZEL_CACHE>/<BAZEL-BUILD>;g
        s;${pg_version};<PG_VERSION>;g
        s;postgres~<PG_VERSION>~[a-z]+;<PG_TARGET>;g
        s;aarch64;{arch};g
        s;x86_64;{arch};g
        s;amd64;{arch};g
        s;k8;{arch};g
    " "${json}"
}
export -f _make_comparable

_make_comparable_all() {
    local json_dir="postgres/introspect/json"

    bazel query 'filter("postgres~.*--introspect$", //postgres/...)' |
        xargs bazel build

    rm -rf "${json_dir}"/postgres~*.json

    # shellcheck disable=SC2016
    find bazel-bin/postgres/postgres~*--introspect -name "*.json" -print0 |
        xargs -0 -I@ /bin/bash -c '
            _make_comparable "@" >| "'"${json_dir}"'/$(basename @)"
        '
    chmod 444 "${json_dir}"/*.json
}

_make_comparable_all
