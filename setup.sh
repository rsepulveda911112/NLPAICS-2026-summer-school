#!/usr/bin/env bash
# NLPAICS 2026 Summer School — general setup.
# Runs every lesson's setup.sh in order. Safe to re-run.
# Usage:
#   ./setup.sh              # set up all lessons
#   ./setup.sh 07 04        # set up only the given lessons (by number prefix)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# Collect lesson dirs: NN-* with a setup.sh, optionally filtered by args.
lessons=()
for dir in [0-9][0-9]-*/; do
    dir="${dir%/}"
    [[ -f "$dir/setup.sh" ]] || continue
    if [[ $# -gt 0 ]]; then
        match=false
        for want in "$@"; do
            [[ "$dir" == "$want"* ]] && match=true && break
        done
        $match || continue
    fi
    lessons+=("$dir")
done

if [[ ${#lessons[@]} -eq 0 ]]; then
    echo "No matching lessons found." >&2
    exit 1
fi

failed=()
for dir in "${lessons[@]}"; do
    echo
    echo "=== Setting up: $dir ==="
    if (cd "$dir" && bash setup.sh); then
        echo "=== OK: $dir ==="
    else
        echo "=== FAILED: $dir ===" >&2
        failed+=("$dir")
    fi
done

echo
if [[ ${#failed[@]} -gt 0 ]]; then
    echo "Done with errors. Failed lessons:" >&2
    printf '  - %s\n' "${failed[@]}" >&2
    exit 1
fi
echo "All ${#lessons[@]} lesson(s) set up successfully."
