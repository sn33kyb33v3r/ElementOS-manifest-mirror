#
# Copyright (C) 2024 ElementOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ElementOS Build Environment
# Hermetic Docker container for reproducible builds

FROM ubuntu:22.04

# Kernel build arguments
ARG TARGET_KERNEL_DEFCONFIG=element_r8s_defconfig
ARG TARGET_KERNEL_SOURCE=kernel/samsung/exynos990
ARG TARGET_KERNEL_ARCH=arm64
ARG TARGET_KERNEL_CLANG_COMPILE=true

# Install Samsung cross-compiler toolchain (if not already present)
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    libssl-dev \
    bc \
    flex \
    bison \
    device-tree-compiler

# Set kernel build environment
ENV KBUILD_BUILD_USER=elementos
ENV KBUILD_BUILD_HOST=build
ENV ARCH=arm64
ENV CROSS_COMPILE=aarch64-linux-gnu-
ENV PATH="/elementos/prebuilts/clang/host/linux-x86/clang-r487747/bin:${PATH}"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
ENV SOURCE_DATE_EPOCH=1640995200
ENV BUILD_DATETIME=20220101.000000
ENV BUILD_NUMBER=E000001
ENV DETERMINISTIC_BUILD=true

# Set working directory
WORKDIR /elementos

# Install base dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    gcc \
    g++ \
    g++-multilib \
    gcc-multilib \
    make \
    cmake \
    pkg-config \
    autoconf \
    automake \
    libtool \
    flex \
    bison \
    # Java
    openjdk-17-jdk \
    openjdk-17-jre \
    # Python
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    # Git and version control
    git \
    git-lfs \
    subversion \
    mercurial \
    # Archive tools
    unzip \
    zip \
    gzip \
    bzip2 \
    xz-utils \
    # Network tools
    curl \
    wget \
    rsync \
    # Text processing
    gawk \
    sed \
    grep \
    diffstat \
    diffutils \
    patchutils \
    # Development tools
    ccache \
    cscope \
    ctags \
    vim \
    nano \
    less \
    # SSL/TLS
    libssl-dev \
    libgnutls28-dev \
    # Compression
    zlib1g-dev \
    liblz4-dev \
    liblzma-dev \
    # Graphics
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    # XML/HTML
    libxml2-dev \
    libxslt1-dev \
    # Miscellaneous
    bc \
    time \
    gperf \
    dpkg-dev \
    elfutils \
    libelf-dev \
    # Android specific
    android-sdk \
    android-sdk-platform-tools \
    # Samsung specific
    heimdall-flash \
    # Debugging
    gdb \
    gdb-multiarch \
    strace \
    ltrace \
    valgrind \
    # Documentation
    doxygen \
    graphviz \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install repo tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && \
    chmod a+x /usr/local/bin/repo

# Install specific tool versions for reproducibility
RUN pip3 install --no-cache-dir \
    setuptools==65.5.1 \
    wheel==0.38.4 \
    pip==22.3.1

# Set up Java environment
RUN update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

# Install specific GCC toolchain for Samsung
RUN apt-get update && apt-get install -y \
    gcc-arm-linux-gnueabi \
    gcc-arm-linux-gnueabihf \
    gcc-aarch64-linux-gnu \
    g++-arm-linux-gnueabi \
    g++-arm-linux-gnueabihf \
    g++-aarch64-linux-gnu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Clang/LLVM
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-15 main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    clang-15 \
    lldb-15 \
    lld-15 \
    clangd-15 \
    clang-tidy-15 \
    clang-format-15 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up Clang symlinks
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 100 && \
    update-alternatives --install /usr/bin/llc llc /usr/bin/llc-15 100 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-15 100

# Install specific Android NDK components
RUN mkdir -p /opt/android-ndk && \
    cd /opt/android-ndk && \
    wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip && \
    unzip android-ndk-r25c-linux.zip && \
    rm android-ndk-r25c-linux.zip

# Set NDK environment
ENV ANDROID_NDK_HOME=/opt/android-ndk/android-ndk-r25c
ENV PATH=$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin

# Install specific Android SDK components
RUN mkdir -p /opt/android-sdk && \
    cd /opt/android-sdk && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip && \
    rm commandlinetools-linux-9477386_latest.zip

# Accept licenses and install SDK components
RUN yes | /opt/android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android-sdk --licenses && \
    /opt/android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android-sdk \
        "platform-tools" \
        "platforms;android-33" \
        "build-tools;33.0.2"

# Create non-root user for builds
RUN useradd -m -s /bin/bash -u 1000 -g 1000 elementos && \
    usermod -aG sudo elementos && \
    echo "elementos ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up user environment
USER elementos
ENV HOME=/home/elementos
ENV USER=elementos

# Create build directories
RUN mkdir -p /home/elementos/.ccache && \
    mkdir -p /home/elementos/.android && \
    mkdir -p /home/elementos/build && \
    mkdir -p /home/elementos/out && \
    mkdir -p /home/elementos/dist

# Configure ccache
RUN ccache --max-size=50G && \
    ccache --set-config=compression=true && \
    ccache --set-config=compression_level=6 && \
    ccache --set-config=sloppiness=file_macro,include_file_mtime,time_macros && \
    ccache --set-config=hash_dir=false && \
    ccache --set-config=run_second_cpp=true

# Set up Git configuration
RUN git config --global user.name "ElementOS Build" && \
    git config --global user.email "build@elementos.dev" && \
    git config --global init.defaultBranch master && \
    git config --global core.autocrlf false && \
    git config --global core.safecrlf false && \
    git config --global core.filemode false && \
    git config --global core.logallrefupdates false

# Set up reproducible build environment
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONHASHSEED=0
ENV GIT_AUTHOR_DATE="2022-01-01T00:00:00Z"
ENV GIT_COMMITTER_DATE="2022-01-01T00:00:00Z"
ENV SOURCE_DATE_EPOCH=1640995200
ENV BUILDDIR=/home/elementos/build
ENV OUTDIR=/home/elementos/out
ENV DISTDIR=/home/elementos/dist

# Create entrypoint script
USER root
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo 'cd /elementos' >> /entrypoint.sh && \
    echo 'exec "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Switch back to elementos user
USER elementos

# Set working directory
WORKDIR /elementos

# Entry point
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

# Labels
LABEL maintainer="ElementOS Project"
LABEL description="ElementOS Build Environment - Hermetic container for reproducible Android builds"
LABEL version="1.0"
LABEL build.date="2022-01-01"
LABEL build.number="E000001"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD java -version && python3 --version && git --version && echo "Build environment ready"

# Expose volumes
VOLUME ["/elementos", "/home/elementos/.ccache", "/home/elementos/out", "/home/elementos/dist"]

# End of Dockerfile
