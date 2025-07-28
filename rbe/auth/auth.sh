#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

seconds_in_future() {
  local value="$1"; shift
  local unit="$1"; shift

  if date --version 2>&1 | grep -q "GNU"; then
    date -d "+${value} ${unit}" +"%s"
  else
    # BSD/macOS date
    case "${unit}" in
      s|sec|second|seconds) d_expr="+${value}S" ;;
      m|min|minute|minutes) d_expr="+${value}M" ;;
      h|hr|hour|hours)      d_expr="+${value}H" ;;
      d|day|days)           d_expr="+${value}d" ;;
      w|week|weeks)         d_expr="+$((value * 7))d" ;; # emulate weeks
      M|month|months)       d_expr="+${value}m" ;;
      y|year|years)         d_expr="+${value}y" ;;
      *) echo "Unsupported unit: ${unit}" >&2; return 1 ;;
    esac
    date -v"${d_expr}" +"%s"
  fi
}

gen_keys() {
    step crypto jwk create \
        --type "OKP" \
        --curve "Ed25519" \
        pub.json priv.json
}

gen_token() {
    local username="$1"; shift
    local value="${1-12}"
    local unit="${2-months}"

    local expiration
    expiration="$(seconds_in_future "${value}" "${unit}")"

    step crypto jwt sign \
        --key priv.json \
        --issuer "auth@rbe.monogres.dev" \
        --audience "auth@rbe.monogres.dev" \
        --subject "${username}@rbe.monogres.dev" \
        --expiration "${expiration}"
}

cd "${SCRIPT_DIR}"

"$@"
