# ElementOS Build Instructions

This document provides detailed instructions for building ElementOS from source.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Building the Kernel](#building-the-kernel)
4. [Building Android](#building-android)
5. [Creating a Release](#creating-a-release)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Options](#advanced-options)

## Prerequisites

### Hardware Requirements

- **CPU**: 64-bit processor with at least 8 cores
- **RAM**: 16GB minimum, 32GB recommended
- **Storage**: 200GB+ free space on fast storage (SSD recommended)
- **Network**: Stable internet connection (100GB+ download)

### Software Requirements

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y \
    git-core gnupg flex bison build-essential zip curl zlib1g-dev \
    gcc-multilib g++-multilib libc6-dev-i386 libncurses5-dev \
    x11proto-core-dev libx11-dev libreadline6-dev libgl1-mesa-glx \
    libgl1-mesa-dev g++-multilib tofrodos python3-markdown \
    libxml2-utils xsltproc unzip fontconfig
```

#### Fedora
```bash
sudo dnf install -y \
    git gnupg flex bison gcc gcc-c++ zip curl zlib-devel \
    gcc-multilib g++-multilib glibc-devel.i686 libstdc++-devel.i686 \
    ncurses-devel libX11-devel readline-devel mesa-libGL-devel \
    mesa-libGLU-devel gperf libxml2-devel libxslt python3-markdown \
    fontconfig-devel
```

#### macOS
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install git gnupg flex bison gcc curl zlib ncurses readline \
    libxml2 libxslt python3 gperf
```

### Java Requirements

ElementOS requires OpenJDK 17:

```bash
# Ubuntu/Debian
sudo apt-get install openjdk-17-jdk

# Fedora
sudo dnf install java-17-openjdk-devel

# macOS
brew install openjdk@17
```

### Python Requirements

```bash
pip3 install --user \
    setuptools wheel \
    git+https://github.com/akhilkedia/gitlab-ci-android.git
```

## Environment Setup

### 1. Clone ElementOS Repository

```bash
git clone https://gitlab.com/elementos/elementos.git
cd elementos
```

### 2. Set Up Build Environment

```bash
./scripts/setup.sh
```

This script will:
- Initialize the repo tool
- Sync all repositories
- Apply privacy patches
- Set up build environment

### 3. Configure Build Settings

Create a `local.properties` file:

```properties
# Build configuration
source.date.epoch=1640995200
build.datetime=20220101.000000
build.number=E000001
build.type=userdebug
device=r8s
product=element_r8s

# Build flags
deterministic.build=true
ccache.enabled=true
ccache.size=50G

# Security flags
kbuild.build.user=elementos
kbuild.build.host=build
kbuild.build.timestamp=Sat Jan  1 00:00:00 UTC 2022
```

## Building the Kernel

### Prerequisites

Ensure you have the Samsung cross-compiler:

```bash
# Download Samsung toolchain
wget https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu.tar.xz
tar -xf gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu.tar.xz
export PATH=$PATH:$(pwd)/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu/bin
```

### Build Process

1. **Apply hardening patches:**
   ```bash
   cd kernel/samsung/exynos990
   git apply hardening/*.patch
   cd ../..
   ```

2. **Build the kernel:**
   ```bash
   source build/envsetup.sh
   lunch element_r8s-userdebug
   cd kernel/samsung/exynos990
   make clean
   make element_r8s_defconfig
   make -j$(nproc) CFLAGS="-fstack-protector-strong -fPIC"
   ```

3. **Install kernel:**
   ```bash
   cp arch/arm64/boot/Image.gz device/samsung/r8s/prebuilt/kernel
   ```

### Kernel Configuration

The hardened kernel includes:

- **Stack protection**: Strong stack protector
- **CFI**: Control Flow Integrity
- **RAP**: Return Address Protection
- **SLAB_FREELIST_RANDOM**: Randomized slab allocation
- **Knox disabled**: Samsung Knox security disabled
- **RKP disabled**: Real-time Kernel Protection disabled

## Building Android

### 1. Source Environment

```bash
source build/envsetup.sh
lunch element_r8s-userdebug
```

### 2. Set Build Flags

```bash
export SOURCE_DATE_EPOCH=1640995200
export BUILD_DATETIME=20220101.000000
export BUILD_NUMBER=E000001
export DETERMINISTIC_BUILD=true
export KBUILD_BUILD_USER="elementos"
export KBUILD_BUILD_HOST="build"
export KBUILD_BUILD_TIMESTAMP="Sat Jan  1 00:00:00 UTC 2022"
```

### 3. Build Images

#### Build boot and vendor_boot images:
```bash
make -j$(nproc) bootimage vendorbootimage
```

#### Build full system:
```bash
make -j$(nproc) systemimage vendorimage userdataimage
```

### 4. Verify Build

```bash
# Check build artifacts
ls -la out/target/product/r8s/

# Verify signatures
sha256sum out/target/product/r8s/*.img

# Check file sizes
du -h out/target/product/r8s/*.img
```

## Creating a Release

### 1. Package Artifacts

```bash
# Create distribution directory
mkdir -p dist

# Copy build artifacts
cp out/target/product/r8s/boot.img dist/
cp out/target/product/r8s/vendor_boot.img dist/
cp out/target/product/r8s/system.img dist/
cp out/target/product/r8s/vendor.img dist/

# Generate checksums
cd dist
sha256sum * > SHA256SUMS.txt
```

### 2. Create Release Archive

```bash
# Create compressed archive
tar -czf elementos-r8s-$(date +%Y%m%d).tar.gz *

# Generate metadata
cat > build-info.txt << EOF
ElementOS Build Information
==========================
Build Date: $(date -d @1640995200)
Build Number: E000001
Device: r8s
Product: element_r8s
Build Type: userdebug
Android Version: 13
Kernel Version: $(make -C kernel/samsung/exynos990 kernelversion)

Build Flags:
- Reproducible Build: Yes
- Hardened Kernel: Yes
- Security Patches: Applied
- Google Services: Removed

SHA-256 Checksums:
$(cat SHA256SUMS.txt)
EOF
```

### 3. Sign Release (Optional)

```bash
# Sign with GPG
gpg --detach-sign --armor elementos-r8s-$(date +%Y%m%d).tar.gz

# Verify signature
gpg --verify elementos-r8s-$(date +%Y%m%d).tar.gz.asc
```

## Troubleshooting

### Common Build Errors

#### "Out of memory" error
- Reduce parallel jobs: `make -j4`
- Increase swap space
- Use ccache to reduce memory usage

#### "Java heap space" error
- Increase Java heap size:
  ```bash
  export _JAVA_OPTIONS="-Xmx8g -Xms4g"
  ```

#### "No space left on device" error
- Clean build artifacts: `make clean`
- Use ccache compression
- Check disk space: `df -h`

#### "Permission denied" error
- Ensure proper file permissions
- Run as regular user (not root)
- Check SELinux context

### Kernel Build Issues

#### "Invalid kernel configuration"
- Regenerate config: `make element_r8s_defconfig`
- Check for missing dependencies
- Verify toolchain path

#### "Hardening patch fails"
- Check kernel version compatibility
- Apply patches manually
- Review patch conflicts

### Android Build Issues

#### "Missing dependencies"
- Run `repo sync` to sync repositories
- Check manifest files
- Verify branch/tag versions

#### "Build fails at 99%"
- Check available disk space
- Increase Java heap size
- Reduce parallel jobs

## Advanced Options

### Custom Build Configuration

Create `userconfig.mk`:

```makefile
# Custom build configuration
BUILD_WITH_GAPPS := false
BUILD_WITH_SU := false
BUILD_WITH_MAGISK := false
BUILD_WITH_MICROG := false

# Performance tuning
USE_CCACHE := true
CCACHE_SIZE := 50G
CCACHE_COMPRESS := true

# Security options
ENABLE_CFI := true
ENABLE_RAP := true
ENABLE_STACK_PROTECTOR := strong
```

### Debug Build

```bash
# Enable debug flags
export DEBUG=1
export WITH_DEBUG_SYMBOLS=true

# Build with debug info
./scripts/build.sh --debug
```

### Release Build

```bash
# Build release version
./scripts/build.sh --release
```

### Clean Build

```bash
# Clean all build artifacts
./scripts/build.sh --clean

# Clean specific targets
make clean
make clobber
```

### Performance Tuning

```bash
# Enable ccache
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
ccache -M 50G

# Use faster compression
export CCACHE_COMPRESS=1
export CCACHE_COMPRESSLEVEL=6

# Parallel builds
export JOBS=$(nproc)
```

### Security Hardening

```bash
# Enable additional security features
export ENABLE_CFI=1
export ENABLE_RAP=1
export ENABLE_STACK_PROTECTOR=strong
export ENABLE_FORTIFY=3

# Apply security patches
cd kernel/samsung/exynos990
for patch in hardening/*.patch; do
    git apply "$patch"
done
```

### Network Proxy

```bash
# Configure proxy (if needed)
export http_proxy=http://proxy.example.com:8080
export https_proxy=https://proxy.example.com:8080
export no_proxy=localhost,127.0.0.1

# Configure Git proxy
git config --global http.proxy http://proxy.example.com:8080
git config --global https.proxy https://proxy.example.com:8080
```

### Custom Kernel

```bash
# Build custom kernel
cd kernel/samsung/exynos990
make menuconfig  # Interactive configuration
make savedefconfig
cp defconfig element_r8s_defconfig
```

### Signing Builds

```bash
# Generate signing keys
./scripts/generate-keys.sh

# Sign build
./scripts/sign-build.sh --key keys/releasekey
```

## Build Verification

### Checksums

```bash
# Verify build integrity
sha256sum -c SHA256SUMS.txt

# Compare with official builds
diff <(sha256sum out/target/product/r8s/*.img) <(curl -s https://elementos.dev/checksums.txt)
```

### Binary Analysis

```bash
# Analyze kernel security features
./scripts/analyze-kernel.sh out/target/product/r8s/boot.img

# Check for hardening features
./scripts/check-hardening.sh out/target/product/r8s/system.img
```

### Runtime Verification

```bash
# Verify running system
adb shell getprop ro.elementos.version
adb shell getprop ro.elementos.security.patch
adb shell getprop ro.privacy.droidguard
```

## Support

For additional help:
- Check the [troubleshooting guide](TROUBLESHOOTING.md)
- Join our [Matrix channel](https://matrix.to/#/#elementos:matrix.org)
- Report issues on [GitLab](https://gitlab.com/elementos/elementos/issues)

## License

This document is part of ElementOS and is licensed under the Apache License 2.0.