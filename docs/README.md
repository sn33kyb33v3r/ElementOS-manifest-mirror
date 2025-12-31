# ElementOS

A privacy-first, hardened AOSP-based operating system for the Samsung Galaxy S20 FE Exynos (SM-G780F).

## Features

- **Privacy-Focused**: Complete removal of Google services and telemetry
- **Security-Hardened**: Linux-hardened kernel with CFI, RAP, and stack protection
- **Reproducible Builds**: Deterministic build process with pinned timestamps
- **Minimal Bloat**: Only essential proprietary components included
- **Open Source**: Fully open source with transparent build process

## Quick Start

### One-Line Build Command

```bash
docker run -it -v $(pwd):/elementos elementos/build:latest ./scripts/build.sh
```

### Prerequisites

- Docker installed and running
- At least 200GB free disk space
- 16GB+ RAM recommended
- Linux/macOS host system

## Building ElementOS

### Method 1: Docker Build (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://gitlab.com/elementos/elementos.git
   cd elementos
   ```

2. **Build the Docker container:**
   ```bash
   docker build -t elementos/build:latest .
   ```

3. **Run the build:**
   ```bash
   docker run -it -v $(pwd):/elementos elementos/build:latest ./scripts/build.sh
   ```

### Method 2: Manual Build

1. **Install dependencies:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y git-core gnupg flex bison build-essential zip curl \
       zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5-dev \
       x11proto-core-dev libx11-dev libreadline6-dev libgl1-mesa-glx \
       libgl1-mesa-dev g++-multilib tofrodos python3-markdown \
       libxml2-utils xsltproc unzip fontconfig
   ```

2. **Set up environment:**
   ```bash
   ./scripts/setup.sh
   ```

3. **Build ElementOS:**
   ```bash
   ./scripts/build.sh
   ```

## Flashing ElementOS

### Prerequisites

- Samsung Galaxy S20 FE Exynos (SM-G780F)
- Unlocked bootloader
- USB cable
- Heimdall (Linux/macOS) or Odin (Windows)

### Flashing Instructions

#### Method 1: Heimdall (Linux/macOS)

1. **Put device in download mode:**
   - Power off the device
   - Press and hold Volume Down + Volume Up
   - Connect USB cable while holding buttons
   - Press Volume Up when warning screen appears

2. **Flash ElementOS:**
   ```bash
   ./scripts/flash.sh --method heimdall
   ```

#### Method 2: Fastboot (Requires unlocked bootloader)

1. **Put device in fastboot mode:**
   - Power off the device
   - Press and hold Volume Down + Power
   - Connect USB cable

2. **Flash ElementOS:**
   ```bash
   ./scripts/flash.sh --method fastboot
   ```

#### Method 3: Odin (Windows)

1. **Create Odin package:**
   ```bash
   ./scripts/flash.sh --method odin
   ```

2. **Flash with Odin:**
   - Put device in download mode
   - Open Odin on Windows PC
   - Load the generated tar.md5 file in AP slot
   - Uncheck "Auto Reboot"
   - Click Start
   - After flashing, reboot to recovery and wipe data

### Post-Installation

1. **Boot into recovery:**
   - Press and hold Volume Up + Power
   - Wipe data/factory reset
   - Wipe cache partition
   - Reboot system

2. **First boot may take 5-10 minutes**

## Project Structure

```
elementos/
├── manifest/           # Repo manifests
│   ├── default.xml    # Main AOSP manifest
│   └── remove_google.xml # Privacy manifest
├── scripts/           # Build and automation scripts
│   ├── setup.sh      # Environment setup
│   ├── build.sh      # Main build script
│   └── flash.sh      # Flashing utility
├── device/samsung/r8s/ # Device tree
│   ├── BoardConfig.mk # Board configuration
│   ├── element_r8s.mk # Product makefile
│   ├── Android.bp    # Soong build blueprint
│   └── prebuilt/     # Prebuilt binaries
├── kernel/samsung/exynos990/ # Hardened kernel
│   ├── element_r8s_defconfig # Kernel config
│   ├── hardening/    # Security patches
│   └── AndroidKernel.mk # Kernel build makefile
├── vendor_elementos/  # Custom vendor additions
├── vendor/samsung/r8s/ # Samsung vendor files
├── .gitlab-ci.yml     # CI/CD pipeline
├── Dockerfile         # Build environment
└── docs/             # Documentation
```

## Security Features

- **Linux-hardened kernel** with stack protection and ASLR
- **Control Flow Integrity (CFI)** to prevent code reuse attacks
- **Return Address Protection (RAP)** for additional security
- **SELinux** in enforcing mode
- **No Google services** or telemetry
- **Minimal proprietary blobs** only for essential hardware

## Privacy Features

- **No Google Play Services**
- **F-Droid** as default app store
- **Privacy Dashboard** for permission management
- **No telemetry or analytics**
- **Hardened network stack**
- **Secure default settings**

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

### Code Style

- Follow AOSP coding standards
- Use 4 spaces for indentation
- Add appropriate comments
- Include license headers

### Testing

```bash
# Run tests
./scripts/build.sh --test

# Run lint checks
./scripts/build.sh --lint

# Security scan
./scripts/build.sh --security
```

## Troubleshooting

### Common Issues

**Build fails with "out of memory":**
- Increase available RAM or swap
- Use fewer parallel jobs: `./scripts/build.sh -j4`

**Device won't boot after flashing:**
- Ensure you wiped data/cache after flashing
- Try flashing again with fresh build
- Check device model compatibility

**Kernel build fails:**
- Ensure all dependencies are installed
- Check kernel configuration
- Apply hardening patches manually if needed

### Getting Help

- **Documentation**: https://docs.elementos.dev
- **Issues**: https://gitlab.com/elementos/elementos/issues
- **Discussions**: https://forum.elementos.dev
- **Matrix**: #elementos:matrix.org

## License

ElementOS is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Credits

- **AOSP**: Android Open Source Project
- **linux-hardened**: Kernel hardening patches
- **F-Droid**: Free and open source app store
- **Samsung**: Device firmware and drivers

## Disclaimer

ElementOS is provided as-is, without warranty. Flashing custom ROMs may void your warranty and carries inherent risks. Always backup your data before proceeding.

## Donations

If you find ElementOS useful, consider supporting the project:
- **Bitcoin**: bc1qelementos123456789
- **Monero**: 4Aelementos123456789
- **GitHub Sponsors**: https://github.com/sponsors/elementos

---

**Build Status**: [![Build Status](https://gitlab.com/elementos/elementos/badges/master/pipeline.svg)](https://gitlab.com/elementos/elementos/pipelines)

**Latest Release**: [![Release](https://img.shields.io/gitlab/v/release/elementos/elementos?sort=semver)](https://gitlab.com/elementos/elementos/-/releases)

**License**: [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)