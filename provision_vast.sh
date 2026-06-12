#!/bin/bash
# Provisioning script for vast.ai instances (PyTorch (Vast) template).
# Point the template's PROVISIONING_SCRIPT environment variable at the raw
# URL of this file:
#   https://raw.githubusercontent.com/EEstevanell/NLPAICS-2026-summer-school/main/provision_vast.sh
# It runs once on first boot: clones the repo into /workspace (so it is
# visible in Jupyter) and sets up every lesson's environment and kernel.
set -eo pipefail

REPO_URL="https://github.com/EEstevanell/NLPAICS-2026-summer-school.git"
REPO_DIR="/workspace/NLPAICS-2026-summer-school"
LOG="/workspace/nlpaics_setup.log"

cd /workspace

if [ ! -d "$REPO_DIR/.git" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
else
    git -C "$REPO_DIR" pull --ff-only || true
fi

cd "$REPO_DIR"
# To provision only some lessons, list them: ./setup.sh 04 06 07
./setup.sh 2>&1 | tee "$LOG"
