FROM ubuntu:20.04 

# git config - these can stay default since no commits will be made
ARG GIT_USER_EMAIL=you@example.com
ARG GIT_USER_NAME="Your Name"

ENV GIT_USER_EMAIL=${GIT_USER_EMAIL}
ENV GIT_USER_NAME=${GIT_USER_NAME}

ENV DEBIAN_FRONTEND=noninteractive
# 23.0 is newest
ENV LINEAGE_VERSION="23.0"
ENV LINEAGE_ROOT="/home/builder/android/lineage"
ENV PATH="/home/builder/bin:$PATH"
ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/ccache
# can change this
ENV NINJA_ARGS="-j10"
# change if different
ENV CODENAME="lynx"
ENV MANUFACTURER="google"
ENV DISABLE_SETTINGS_SEARCHES=true
ENV PATH_TO_ORIGINAL="${LINEAGE_ROOT}/packages/apps/SettingsIntelligence/src/com/android/settings/intelligence/search/savedqueries/SavedQueryRecorder.java"

# create builder user
RUN useradd -ms /bin/bash builder && mkdir -p /home/builder/bin /ccache

# deps from lineageOS build guide for Ubuntu 20.04 and LineageOS 22
RUN apt-get update && apt-get install -y \
  bc \
  bison \
  build-essential \
  ccache \
  curl \
  wget \
  nano \
  flex \
  g++-multilib \
  gcc-multilib \
  git \
  git-lfs \
  gnupg \
  gperf \
  imagemagick \
  protobuf-compiler \
  python3-protobuf \
  lib32readline-dev \
  lib32z1-dev \
  libdw-dev \
  libelf-dev \
  lz4 \
  libsdl1.2-dev \
  libssl-dev \
  libxml2 \
  libxml2-utils \
  lzop \
  pngcrush \
  rsync \
  schedtool \
  squashfs-tools \
  xsltproc \
  zip \
  zlib1g-dev \
  lib32ncurses5-dev \
  libncurses5 \
  libncurses5-dev \
  python-is-python3 \
  && rm -rf /var/lib/apt/lists/*

# Install repo tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /home/builder/bin/repo && chmod a+x /home/builder/bin/repo

# set up Git + Git Large File Storage
# cache for future builds
RUN git config --global user.email "${GIT_USER_EMAIL}" && \
  git config --global user.name "${GIT_USER_NAME}" && \
  git lfs install && \
  ccache -M 30G && ccache -o compression=true

WORKDIR /home/builder/android/lineage

COPY entrypoint.sh /home/builder/entrypoint.sh
RUN chmod +x /home/builder/entrypoint.sh
ENTRYPOINT ["/home/builder/entrypoint.sh"]