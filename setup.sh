#!/usr/bin/env bash
# NLPAICS 2026 Summer School — general setup.
# For each lesson: creates an isolated virtualenv (inheriting the base
# image's torch/CUDA stack via --system-site-packages), runs the lesson's
# setup.sh inside it, and registers a Jupyter kernel for that lesson.
# Safe to re-run.
# Usage:
#   ./setup.sh              # set up all lessons
#   ./setup.sh 07 04        # set up only the given lessons (by number prefix)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# Base interpreter: on vast.ai images the ML stack (torch/CUDA) lives in
# /venv/main, not in the system python — prefer it when present.
if [[ -z "${PYTHON:-}" ]]; then
    if [[ -x /venv/main/bin/python ]]; then
        PYTHON=/venv/main/bin/python
    else
        PYTHON=python3
    fi
fi

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

setup_lesson() {
    local dir="$1"
    local num="${dir%%-*}"
    local venv="$ROOT/$dir/.venv"

    # 1. Per-lesson venv inheriting system site-packages (torch/CUDA etc.).
    if [[ ! -x "$venv/bin/python" ]]; then
        "$PYTHON" -m venv --system-site-packages "$venv" || return 1
    fi

    # 1b. If the base interpreter is itself a venv (e.g. /venv/main on
    # vast.ai images), --system-site-packages only exposes the *real*
    # system python, not the base venv's packages. Chain to the base
    # venv's site-packages via a .pth file so torch & friends are
    # visible. Lesson-installed packages still take precedence.
    local base_site venv_site
    base_site="$("$PYTHON" -c 'import sys, sysconfig; print(sysconfig.get_paths()["purelib"] if sys.prefix != sys.base_prefix else "")')"
    if [[ -n "$base_site" ]]; then
        venv_site="$("$venv/bin/python" -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
        echo "$base_site" > "$venv_site/_nlpaics_base_env.pth" || return 1
    fi

    # 2. Ensure pip and ipykernel inside the venv.
    "$venv/bin/python" -m pip install --quiet --upgrade pip ipykernel || return 1

    # 3. Run the lesson's setup.sh with the venv activated, so its plain
    #    `pip install` calls land in the lesson env.
    (
        export VIRTUAL_ENV="$venv"
        export PATH="$venv/bin:$PATH"
        unset PYTHONHOME
        cd "$dir" && bash setup.sh
    ) || return 1

    # 4. Register the Jupyter kernel for this lesson.
    "$venv/bin/python" -m ipykernel install --user \
        --name "nlpaics-$num" \
        --display-name "NLPAICS $num" || return 1
}

failed=()
for dir in "${lessons[@]}"; do
    echo
    echo "=== Setting up: $dir ==="
    if setup_lesson "$dir"; then
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
echo "All ${#lessons[@]} lesson(s) ready."
echo "In Jupyter, open a lesson notebook and select its 'NLPAICS NN' kernel."
