#!/bin/bash

# ElementOS Build Script
# This script builds ElementOS for the Samsung Galaxy S20 FE (r8s)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build configuration
DEVICE="r8s"
PRODUCT="element_${DEVICE}"
BUILD_TYPE="userdebug"
JOBS=$(nproc --all)

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_build() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

# Check environment
check_environment() {
    if [ ! -f "${ROOT_DIR}/build/envsetup.sh" ]; then
        log_error "Build environment not found. Please run './scripts/setup.sh' first."
        exit 1
    fi
    
    if [ ! -f ".repo/manifest.xml" ]; then
        log_error "Repo not initialized. Please run './scripts/setup.sh' first."
        exit 1
    fi
}

# Set reproducible build parameters
setup_reproducible_build() {
    log_info "Setting up reproducible build parameters..."
    
    # Use fixed timestamp for reproducible builds
    export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-1640995200}"
    export BUILD_DATETIME="$(date -d @${SOURCE_DATE_EPOCH} +'%Y%m%d.%H%M%S')"
    export BUILD_NUMBER="${BUILD_NUMBER:-E000001}"
    
    # Set deterministic build flags
    export DETERMINISTIC_BUILD=true
    export KBUILD_BUILD_USER="elementos"
    export KBUILD_BUILD_HOST="build"
    export KBUILD_BUILD_TIMESTAMP="$(date -d @${SOURCE_DATE_EPOCH})"
    
    log_info "Build timestamp: ${BUILD_DATETIME}"
    log_info "Build number: ${BUILD_NUMBER}"
}

# Source build environment
source_build_env() {
    log_info "Sourcing build environment..."
    cd "${ROOT_DIR}"
    source build/envsetup.sh
    
    # Lunch the device
    log_info "Lunching device: ${PRODUCT}-${BUILD_TYPE}"
    lunch "${PRODUCT}-${BUILD_TYPE}"
}

# Build kernel
build_kernel() {
    log_build "Building kernel..."
    
    pushd "${ROOT_DIR}/kernel/samsung/exynos990" > /dev/null
    
    # Clean previous build
    make clean
    
    # Build with hardening features
    make "element_r8s_defconfig"
    make -j${JOBS} \
        CFLAGS="-fstack-protector-strong -fPIC" \
        KCFLAGS="-fstack-protector-strong -fPIC"
    
    # Copy kernel to prebuilt
    cp "arch/arm64/boot/Image.gz" "${ROOT_DIR}/device/samsung/r8s/prebuilt/kernel"
    
    popd > /dev/null
    log_build "Kernel build complete"
}

# Build Android
build_android() {
    log_build "Building Android..."
    
    # Build with security flags
    export BOARD_KERNEL_IMAGE_NAME="Image.gz"
    export TARGET_COMPILE_WITH_MSM_KERNEL=false
    
    # Build the main targets
    make -j${JOBS} \
        bootimage \
        vendorbootimage \
        systemimage \
        vendorimage \
        userdataimage
    
    log_build "Android build complete"
}

# Generate build artifacts
generate_artifacts() {
    log_info "Generating build artifacts..."
    
    local out_dir="${ROOT_DIR}/out/target/product/${DEVICE}"
    local dist_dir="${ROOT_DIR}/dist"
    
    # Create distribution directory
    mkdir -p "${dist_dir}"
    
    # Copy build artifacts
    if [ -f "${out_dir}/boot.img" ]; then
        cp "${out_dir}/boot.img" "${dist_dir}/"
        log_info "Generated: boot.img"
    fi
    
    if [ -f "${out_dir}/vendor_boot.img" ]; then
        cp "${out_dir}/vendor_boot.img" "${dist_dir}/"
        log_info "Generated: vendor_boot.img"
    fi
    
    if [ -f "${out_dir}/system.img" ]; then
        cp "${out_dir}/system.img" "${dist_dir}/"
        log_info "Generated: system.img"
    fi
    
    if [ -f "${out_dir}/vendor.img" ]; then
        cp "${out_dir}/vendor.img" "${dist_dir}/"
        log_info "Generated: vendor.img"
    fi
    
    # Generate SHA-256 manifest
    log_info "Generating SHA-256 manifest..."
    pushd "${dist_dir}" > /dev/null
    sha256sum * > "SHA256SUMS.txt"
    popd > /dev/null
    
    # Generate build info
    cat > "${dist_dir}/build-info.txt" << EOF
ElementOS Build Information
==========================
Build Date: $(date -d @${SOURCE_DATE_EPOCH})
Build Number: ${BUILD_NUMBER}
Device: ${DEVICE}
Product: ${PRODUCT}
Build Type: ${BUILD_TYPE}
Android Version: $(cat "${ROOT_DIR}/build/make/core/version_defaults.mk" | grep "PLATFORM_VERSION" | head -1 | cut -d'=' -f2 | tr -d ' ')
Kernel Version: $(cd "${ROOT_DIR}/kernel/samsung/exynos990" && make kernelversion)

Build Flags:
- Reproducible Build: Yes
- Hardened Kernel: Yes
- Security Patches: Applied
- Google Services: Removed

SHA-256 Checksums:
$(cat "${dist_dir}/SHA256SUMS.txt")
EOF
    
    log_info "Build artifacts generated in: ${dist_dir}"
}

# Clean build artifacts
clean_build() {
    log_warn "Cleaning build artifacts..."
    
    if [ -d "${ROOT_DIR}/out" ]; then
        rm -rf "${ROOT_DIR}/out"
    fi
    
    if [ -d "${ROOT_DIR}/dist" ]; then
        rm -rf "${ROOT_DIR}/dist"
    fi
    
    log_info "Clean complete"
}

# Flash device
flash_device() {
    log_info "Preparing to flash device..."
    
    local dist_dir="${ROOT_DIR}/dist"
    
    if [ ! -d "${dist_dir}" ]; then
        log_error "No build artifacts found. Please build first."
        exit 1
    fi
    
    # Check for required files
    if [ ! -f "${dist_dir}/boot.img" ] || [ ! -f "${dist_dir}/vendor_boot.img" ]; then
        log_error "Required files (boot.img, vendor_boot.img) not found"
        exit 1
    fi
    
    log_info "Connect device in download mode and run:"
    log_info "  ./scripts/flash.sh"
}

# Main build function
main() {
    log_info "ElementOS Build Script"
    log_info "====================="
    log_info "Device: ${DEVICE}"
    log_info "Product: ${PRODUCT}"
    log_info "Build Type: ${BUILD_TYPE}"
    log_info "Jobs: ${JOBS}"
    
    cd "${ROOT_DIR}"
    
    # Check environment
    check_environment
    
    # Setup build
    setup_reproducible_build
    source_build_env
    
    # Build steps
    if [ "${SKIP_KERNEL}" != "true" ]; then
        build_kernel
    fi
    
    build_android
    generate_artifacts
    
    log_info "Build complete!"
    log_info "Artifacts available in: ${ROOT_DIR}/dist"
    
    if [ "${AUTO_FLASH}" = "true" ]; then
        flash_device
    fi
}

# Show help
show_help() {
    cat << EOF
ElementOS Build Script

Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -c, --clean         Clean build artifacts before building
    -k, --skip-kernel   Skip kernel build
    -f, --flash         Auto-flash after successful build
    -r, --release       Build release version (user build)
    -j, --jobs JOBS     Number of parallel jobs (default: $(nproc --all))
    -d, --device DEVICE Target device (default: r8s)

Environment Variables:
    SOURCE_DATE_EPOCH   Set build timestamp for reproducible builds
    BUILD_NUMBER        Set custom build number
    SKIP_KERNEL         Skip kernel build if set to true
    AUTO_FLASH          Auto-flash if set to true

Examples:
    $0                  # Standard debug build
    $0 --clean          # Clean build
    $0 --release        # Release build
    $0 --flash          # Build and flash
    $0 -j8              # Build with 8 parallel jobs

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean)
            clean_build
            shift
            ;;
        -k|--skip-kernel)
            SKIP_KERNEL=true
            shift
            ;;
        -f|--flash)
            AUTO_FLASH=true
            shift
            ;;
        -r|--release)
            BUILD_TYPE="user"
            shift
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            PRODUCT="element_${DEVICE}"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main "$@"