#!/bin/bash

# ElementOS Flash Script
# This script flashes ElementOS to the Samsung Galaxy S20 FE (r8s)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DEVICE="r8s"
DIST_DIR="${ROOT_DIR}/dist"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_flash() {
    echo -e "${BLUE}[FLASH]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if heimdall is available
    if ! command -v heimdall >/dev/null 2>&1; then
        log_error "heimdall not found. Please install heimdall for Samsung devices."
        log_error "Ubuntu/Debian: sudo apt-get install heimdall-flash"
        log_error "Fedora: sudo dnf install heimdall"
        log_error "macOS: brew install heimdall"
        exit 1
    fi
    
    # Check if build artifacts exist
    if [ ! -d "${DIST_DIR}" ]; then
        log_error "Build artifacts not found. Please run './scripts/build.sh' first."
        exit 1
    fi
    
    if [ ! -f "${DIST_DIR}/boot.img" ]; then
        log_error "boot.img not found in ${DIST_DIR}"
        exit 1
    fi
    
    if [ ! -f "${DIST_DIR}/vendor_boot.img" ]; then
        log_error "vendor_boot.img not found in ${DIST_DIR}"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Detect device
detect_device() {
    log_info "Detecting device..."
    
    # Check if device is in download mode
    if ! heimdall detect --no-reboot; then
        log_error "No device detected in download mode"
        log_error "Please put your device in download mode:"
        log_error "  1. Power off the device"
        log_error "  2. Press and hold Volume Down + Volume Up"
        log_error "  3. Connect USB cable while holding buttons"
        log_error "  4. Press Volume Up when warning screen appears"
        exit 1
    fi
    
    log_info "Device detected in download mode"
}

# Flash partitions
flash_partitions() {
    log_flash "Flashing partitions..."
    
    local boot_img="${DIST_DIR}/boot.img"
    local vendor_boot_img="${DIST_DIR}/vendor_boot.img"
    
    # Flash boot partition
    log_flash "Flashing boot partition..."
    heimdall flash --BOOT "${boot_img}" --no-reboot
    
    # Flash vendor_boot partition
    log_flash "Flashing vendor_boot partition..."
    heimdall flash --VENDOR_BOOT "${vendor_boot_img}" --no-reboot
    
    # Optional: Flash system and vendor if they exist
    if [ -f "${DIST_DIR}/system.img" ]; then
        log_flash "Flashing system partition..."
        heimdall flash --SYSTEM "${DIST_DIR}/system.img" --no-reboot
    fi
    
    if [ -f "${DIST_DIR}/vendor.img" ]; then
        log_flash "Flashing vendor partition..."
        heimdall flash --VENDOR "${DIST_DIR}/vendor.img" --no-reboot
    fi
    
    log_flash "Partition flashing complete"
}

# Flash via fastboot (alternative method)
flash_fastboot() {
    log_info "Preparing for fastboot flash..."
    
    # Check if fastboot is available
    if ! command -v fastboot >/dev/null 2>&1; then
        log_error "fastboot not found. Please install android-tools."
        exit 1
    fi
    
    log_warn "Fastboot method requires:"
    log_warn "  1. Unlocked bootloader"
    log_warn "  2. Fastboot mode (not download mode)"
    log_warn "  3. OEM unlocking enabled in developer options"
    
    read -p "Is your bootloader unlocked? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log_error "Bootloader must be unlocked for fastboot flashing"
        exit 1
    fi
    
    log_flash "Flashing via fastboot..."
    
    # Wait for device
    log_info "Waiting for fastboot device..."
    fastboot devices
    
    # Flash images
    fastboot flash boot "${DIST_DIR}/boot.img"
    fastboot flash vendor_boot "${DIST_DIR}/vendor_boot.img"
    
    if [ -f "${DIST_DIR}/system.img" ]; then
        fastboot flash system "${DIST_DIR}/system.img"
    fi
    
    if [ -f "${DIST_DIR}/vendor.img" ]; then
        fastboot flash vendor "${DIST_DIR}/vendor.img"
    fi
    
    # Reboot
    log_flash "Flashing complete, rebooting..."
    fastboot reboot
}

# Flash via Odin (Windows method)
flash_odin() {
    log_info "Preparing Odin package..."
    
    local odin_dir="${DIST_DIR}/odin"
    mkdir -p "${odin_dir}"
    
    # Create Odin-compatible tar.md5
    pushd "${DIST_DIR}" > /dev/null
    
    # Create tar archive
    tar -cf "${odin_dir}/elementos_${DEVICE}.tar" boot.img vendor_boot.img
    
    # Generate md5
    md5sum "${odin_dir}/elementos_${DEVICE}.tar" > "${odin_dir}/elementos_${DEVICE}.tar.md5"
    rm "${odin_dir}/elementos_${DEVICE}.tar"
    
    popd > /dev/null
    
    log_info "Odin package created: ${odin_dir}/elementos_${DEVICE}.tar.md5"
    log_info ""
    log_info "To flash with Odin:"
    log_info "  1. Put device in download mode"
    log_info "  2. Open Odin on Windows PC"
    log_info "  3. Load the tar.md5 file in AP slot"
    log_info "  4. Uncheck 'Auto Reboot'"
    log_info "  5. Click Start"
    log_info "  6. After flashing, reboot to recovery and wipe data"
}

# Wipe data/cache
wipe_data() {
    log_warn "Data wipe is required on first install"
    log_warn "Please boot into recovery and wipe data/cache"
    log_warn ""
    log_warn "Steps:"
    log_warn "  1. Boot into recovery (Volume Up + Power)"
    log_warn "  2. Select 'Wipe data/factory reset'"
    log_warn "  3. Select 'Wipe cache partition'"
    log_warn "  4. Reboot system"
}

# Main flash function
main() {
    log_info "ElementOS Flash Tool"
    log_info "===================="
    log_info "Device: Samsung Galaxy S20 FE (${DEVICE})"
    log_info "Method: ${METHOD}"
    
    # Check prerequisites
    check_prerequisites
    
    case "${METHOD}" in
        "heimdall")
            detect_device
            flash_partitions
            wipe_data
            ;;
        "fastboot")
            flash_fastboot
            ;;
        "odin")
            flash_odin
            ;;
        *)
            log_error "Unknown flash method: ${METHOD}"
            exit 1
            ;;
    esac
    
    log_info "Flash process complete!"
    log_info "Please reboot your device"
}

# Show help
show_help() {
    cat << EOF
ElementOS Flash Script

Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -m, --method METHOD Flash method: heimdall, fastboot, odin (default: heimdall)
    -d, --device DEVICE Target device (default: r8s)
    -n, --no-wipe       Skip data wipe prompt
    -f, --force         Force flash without confirmation

Flash Methods:
    heimdall    Use heimdall (Linux/macOS, requires download mode)
    fastboot    Use fastboot (requires unlocked bootloader)
    odin        Create Odin package (Windows)

Examples:
    $0                  # Flash using heimdall with confirmation
    $0 --method fastboot # Flash using fastboot
    $0 --method odin     # Create Odin package
    $0 --force          # Force flash without confirmation

Prerequisites:
    - Device in download mode (heimdall/odin)
    - Unlocked bootloader (fastboot)
    - USB debugging enabled
    - ElementOS build artifacts available

EOF
}

# Parse arguments
METHOD="heimdall"
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--method)
            METHOD="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -n|--no-wipe)
            NO_WIPE=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Confirm flash
if [ "${FORCE}" != "true" ]; then
    log_warn "This will flash ElementOS to your device"
    log_warn "Make sure your device is in the correct mode"
    log_warn "All data will be wiped!"
    echo
    read -p "Continue? (y/N): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log_info "Flash cancelled"
        exit 0
    fi
fi

# Run main function
main "$@"