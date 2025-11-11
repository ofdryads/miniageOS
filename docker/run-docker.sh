#!/bin/bash
docker run -it --rm \
  -v "${PWD}:/home/builder/miniageos" \
  -v "${PWD}/../lineage_src:/home/builder/android/lineage" \
  -v "${PWD}/../ccache:/ccache" \
  -e RUN_MODE=build \
  minidocker:test