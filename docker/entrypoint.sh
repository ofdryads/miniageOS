#!/bin/bash
set -e
cd "$LINEAGE_ROOT"

if [ ! -d ".repo" ]; then
  echo "[+] Initializing repo..."
  repo init -u https://github.com/LineageOS/android.git -b lineage-"${LINEAGE_VERSION}" --git-lfs --no-clone-bundle
fi

if [ "${RUN_MODE}" = "build" ]; then
  echo "[+] Syncing and building..."
  repo sync --force-sync
  bash /home/builder/miniageos/docker/build-mini.sh
elif [ "${RUN_MODE}" = "shell" ]; then
  exec /bin/bash
else
  echo "[+] No mode specified. Use RUN_MODE=build or RUN_MODE=shell."
  exec /bin/bash
fi