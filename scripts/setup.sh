#!/bin/bash

# ElementOS Environment Setup Script
# This script sets up the build environment for ElementOS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running in Docker
if [ ! -f /.dockerenv ]; then
    log_error "This script must be run inside the ElementOS Docker container"
    log_error "Please run: docker run -it -v $(pwd):/elementos elementos/build:latest"
    exit 1
fi

# Set up environment variables
setup_environment() {
    log_info "Setting up build environment..."
    
    # Source the build environment
    source build/envsetup.sh
    
    # Set reproducible build parameters
    export SOURCE_DATE_EPOCH="1640995200"  # 2022-01-01 00:00:00 UTC
    export BUILD_DATETIME="20220101.000000"
    export BUILD_NUMBER="E000001"
    
    # Set build paths
    export OUT_DIR="${ROOT_DIR}/out"
    export DIST_DIR="${ROOT_DIR}/dist"
    
    # Create necessary directories
    mkdir -p "${OUT_DIR}" "${DIST_DIR}"
    
    log_info "Environment setup complete"
}

# Initialize repo if not already done
init_repo() {
    if [ ! -d ".repo" ]; then
        log_info "Initializing repo..."
        repo init -u https://gitlab.com/elementos/manifest.git -b master -m default.xml
        
        # Apply privacy manifest
        cp "${ROOT_DIR}/manifest/remove_google.xml" .repo/local_manifests/
        
        log_info "Repo initialized successfully"
    else
        log_info "Repo already initialized"
    fi
}

# Sync repositories
sync_repos() {
    log_info "Syncing repositories..."
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
    log_info "Repository sync complete"
}

# Main execution
main() {
    log_info "ElementOS Build Environment Setup"
    log_info "================================="
    
    cd "${ROOT_DIR}"
    
    # Check dependencies
    if ! command -v repo >/dev/null 2>&1; then
        log_error "repo not found. Please install repo."
        exit 1
    fi
    
    if ! command -v java >/dev/null 2>&1; then
        log_error "Java not found. Please install OpenJDK 17."
        exit 1
    fi
    
    # Setup steps
    setup_environment
    init_repo
    sync_repos
    
    log_info "Setup complete! You can now run './scripts/build.sh' to build ElementOS"
}

# Show help
show_help() {
    cat << EOF
ElementOS Setup Script

Usage: $0 [OPTIONS]

Options:
    -h, --help      Show this help message
    -s, --skip-sync Skip repository sync
    -f, --force     Force re-initialization

Environment Variables:
    SOURCE_DATE_EPOCH   Set build timestamp for reproducible builds
    BUILD_NUMBER        Set custom build number
    OUT_DIR             Output directory (default: out/)
    DIST_DIR            Distribution directory (default: dist/)

Examples:
    $0                  # Standard setup with sync
    $0 --skip-sync      # Setup without syncing repositories
    $0 --force          # Force re-initialization

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--skip-sync)
            SKIP_SYNC=true
            shift
            ;;
        -f|--force)
            FORCE_INIT=true
            shift
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