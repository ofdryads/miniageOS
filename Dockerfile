# git config - these can stay default since no commits will be made
ARG GIT_USER_EMAIL=you@example.com
ARG GIT_USER_NAME="Your Name"

# could be any similar version probably, but build guide is tested with 20.04
FROM ubuntu:20.04 

ENV LINEAGE_VERSION="23.0"

# avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# to avoid running as root:
RUN useradd -ms /bin/bash builder
USER builder
WORKDIR /home/builder

# set env variables
ENV PATH="/home/builder/bin:$PATH"
ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/ccache

# /home/builder/android/lineage will be the lineage root directory
RUN mkdir -p /home/builder/bin && mkdir -p /home/builder/android/lineage

# Switch to root temporarily for installing dependencies
USER root
RUN mkdir -p /ccache && chown -R builder:builder /ccache

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

USER builder

# Install repo tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /home/builder/bin/repo && chmod a+x /home/builder/bin/repo

# set up Git + Git Large File Storage
RUN git config --global user.email "${GIT_USER_EMAIL}" && \
  git config --global user.name "${GIT_USER_NAME}" && \
  git lfs install

# cache for future builds
RUN ccache -M 50G && ccache -o compression=true

WORKDIR "/home/builder/android/lineage"

RUN repo init -u https://github.com/LineageOS/android.git -b lineage-"${LINEAGE_VERSION}" --git-lfs --no-clone-bundle 

RUN repo sync

CMD ["/bin/bash"]