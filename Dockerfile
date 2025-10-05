# git config - these can stay default since no commits will be made
ARG GIT_USER_EMAIL=you@example.com
ARG GIT_USER_NAME="Your Name"

# could be any similar version probably, but build guide is tested with 20.04
FROM ubuntu:20.04 

# avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# set caching variables
ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/ccache

# deps from lineageOS build guide for Ubuntu 20.04 and LineageOS 22
RUN apt-get update && apt-get install -y \
  bc \
  bison \
  build-essential \
  ccache \
  curl \
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
  python-is-python3

# ~/android/lineage will be lineage root
RUN mkdir -p ~/bin && mkdir -p ~/android/lineage

# Install repo tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo && chmod a+x ~/bin/repo
ENV PATH="$HOME/bin:$PATH"

# set up Git + Git Large File Storage
RUN git config --global user.email "${GIT_USER_EMAIL}" && \
    git config --global user.name "${GIT_USER_NAME}" && \
    git lfs install

# cache for future builds
RUN ccache -M 50G && ccache -o compression=true

WORKDIR "$HOME/android/lineage"

RUN repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs --no-clone-bundle 

RUN repo sync

CMD ["/bin/bash"]