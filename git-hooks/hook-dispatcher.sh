#!/bin/sh
# Copyright 2026 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

HOOK_NAME="${HOOK_NAME:-$(basename "$0")}"

GIT_HOOKS_DIR="$(git rev-parse --git-path hooks 2>/dev/null)"
if [ -n "$GIT_HOOKS_DIR" ] && [ -d "$GIT_HOOKS_DIR" ]; then
  GIT_HOOKS_DIR="$(cd "$GIT_HOOKS_DIR" && pwd)"
else
  GIT_HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

HOOK_D="${GIT_HOOKS_DIR}/${HOOK_NAME}.d"
# Fallback to location next to dispatcher script if not found in GIT_HOOKS_DIR
if [ ! -d "${HOOK_D}" ]; then
  DISPATCHER_DIR="$(cd "$(dirname "$0")" && pwd)"
  if [ -d "${DISPATCHER_DIR}/${HOOK_NAME}.d" ]; then
    HOOK_D="${DISPATCHER_DIR}/${HOOK_NAME}.d"
  fi
fi

if [ -d "${HOOK_D}" ]; then
  LC_COLLATE=C
  export LC_COLLATE
  for script in "${HOOK_D}"/*; do
    [ -f "${script}" ] || continue
    case "${script}" in
      *~ | *.bak | *.bak.* | *.tmp | *.swp | *.swo | *.swn | *.orig | *.rej | *.sample | *.disabled | *# | */#*# | */.#*)
        continue
        ;;
    esac
    if [ -x "${script}" ]; then
      "${script}" "$@" || exit $?
    elif [ -f "${script}" ]; then
      sh "${script}" "$@" || exit $?
    fi
  done
fi

# Legacy single-file hook fallback (.dev)
LEGACY_DEV="${GIT_HOOKS_DIR}/${HOOK_NAME}.dev"
if [ -x "${LEGACY_DEV}" ]; then
  "${LEGACY_DEV}" "$@" || exit $?
elif [ -f "${LEGACY_DEV}" ]; then
  sh "${LEGACY_DEV}" "$@" || exit $?
fi

exit 0
