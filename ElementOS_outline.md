# ElementOS Project Outline

## Project Structure
```
ElementOS/
├── manifest/                 # Repo manifests
│   ├── default.xml          # Main manifest without Google remotes
│   └── remove_google.xml    # Manifest removing Google services
├── scripts/                 # Build and automation scripts
│   ├── setup.sh            # Environment setup script
│   ├── build.sh            # Main build script
│   └── flash.sh            # Flashing utility
├── device/samsung/r8s/      # Device tree for SM-G780F
│   ├── BoardConfig.mk      # Board configuration
│   ├── element_r8s.mk      # Device product makefile
│   ├── Android.bp          # Soong build blueprint
│   ├── init.recovery.r8s.rc # Recovery init script
│   └── prebuilt/           # Prebuilt binaries
│       └── kernel          # Placeholder for prebuilt kernel
├── kernel/samsung/exynos990/ # Hardened Exynos 990 kernel
│   ├── element_r8s_defconfig # Hardened kernel config
│   ├── hardening/          # Kernel hardening patches
│   └── AndroidKernel.mk    # Kernel build makefile
├── vendor_elementos/        # Custom vendor additions
│   ├── config/             # Vendor configuration
│   └── overlays/           # Resource overlays
├── vendor/samsung/r8s/     # Samsung vendor files
│   ├── proprietary-files.txt # List of required blobs
│   └── BoardConfigVendor.mk # Vendor board config
├── .gitlab-ci.yml          # CI/CD pipeline
├── Dockerfile              # Hermetic build environment
├── docs/                   # Documentation
│   └── README.md          # Build and usage instructions
└── LICENSE                # Project license
```

## Key Features
- Privacy-first AOSP fork without Google services
- Hardened kernel with linux-hardened patches
- Samsung Galaxy S20 FE Exynos (r8s) support
- Hermetic build environment via Docker
- Reproducible builds with pinned timestamps
- GitLab-based CI/CD pipeline

## Technical Specifications
- Target Device: Samsung Galaxy S20 FE Exynos (SM-G780F)
- Board: r8s
- Kernel: Exynos 990 with linux-hardened patches
- Build System: AOSP with custom manifests
- Security Features: CFI, RAP, SLAB_FREELIST_RANDOM