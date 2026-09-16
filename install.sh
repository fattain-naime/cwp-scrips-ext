#!/bin/bash
# CWP Scripts Extended - Auto Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/fattain-naime/cwp-scrips-ext/main/install.sh | bash

set -euo pipefail

REPO_OWNER="fattain-naime"
REPO_NAME="cwp-scrips-ext"
BRANCH="main"
TARGET_DIR="/usr/local/cwpsrv/htdocs/resources/scripts"
BACKUP_DIR="${TARGET_DIR}.bak.$(date +%F_%H%M%S)"
RAW_BASE="https://raw.githubusercontent.com/fattain-naime/cwp-scrips-ext/main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_err() { echo -e "${RED}[ERR]${NC} $*"; }

# Check root
if [ "$EUID" -ne 0 ]; then
    log_err "This script must be run as root"
    exit 1
fi

# Check CWP installation
if [ ! -d "/usr/local/cwpsrv" ]; then
    log_err "CWP not found at /usr/local/cwpsrv"
    exit 1
fi

log_info "CWP Scripts Extended Installer"
log_info "==============================="
log_info "Target: $TARGET_DIR"
log_info "Backup: $BACKUP_DIR"

# Backup existing scripts
if [ -d "$TARGET_DIR" ]; then
    log_info "Backing up existing scripts to $BACKUP_DIR"
    mv "$TARGET_DIR" "$BACKUP_DIR"
    log_ok "Backup complete"
fi

# Create target directory
mkdir -p "$TARGET_DIR"

# Get script list from GitHub API
log_info "Fetching script list from GitHub..."
SCRIPTS_JSON=$(curl -fsSL "https://api.github.com/repos/fattain-naime/cwp-scrips-ext/contents?ref=main" 2>/dev/null)

if [ -z "$SCRIPTS_JSON" ] || [ "$SCRIPTS_JSON" = "[]" ]; then
    log_err "Failed to fetch script list from GitHub"
    log_info "Restoring backup..."
    mv "$BACKUP_DIR" "$TARGET_DIR"
    exit 1
fi

# Extract script filenames (excluding .gitignore, README.md, docs/, install.sh)
SCRIPT_NAMES=$(echo "$SCRIPTS_JSON" | grep -o '"name": "[^"]*"' | cut -d'"' -f4 | grep -vE '^\.gitignore$|^README\.md$|^docs$|^install\.sh$' | sort -u)

if [ -z "$SCRIPT_NAMES" ]; then
    log_err "No scripts found in repository"
    mv "$BACKUP_DIR" "$TARGET_DIR"
    exit 1
fi

TOTAL=$(echo "$SCRIPT_NAMES" | wc -l)
log_info "Found $TOTAL scripts to download"

# Download each script
SUCCESS=0
FAILED=0

while IFS= read -r script; do
    if [ -z "$script" ]; then
        continue
    fi

    # Validate script name against a safe pattern (blocks argv flag smuggling
    # and path traversal from untrusted API-supplied filenames)
    if ! [[ "$script" =~ ^[a-zA-Z0-9._-]+$ ]] || [[ "$script" == -* ]]; then
        log_warn "Skipping unsafe script name: $script"
        ((FAILED++))
        continue
    fi

    log_info "Downloading $script ..."
    if curl -fsSL "$RAW_BASE/$script" -o -- "$TARGET_DIR/$script"; then
        chmod +x -- "$TARGET_DIR/$script"
        # Syntax check
        if bash -n -- "$TARGET_DIR/$script" 2>/dev/null; then
            log_ok "$script"
            ((SUCCESS++))
        else
            log_warn "$script - syntax check failed (kept but may have issues)"
            ((FAILED++))
        fi
    else
        log_err "$script - download failed"
        ((FAILED++))
    fi
done <<< "$SCRIPT_NAMES"

log_info "==============================="
log_info "Installation Summary:"
log_ok "Successful: $SUCCESS"
if [ $FAILED -gt 0 ]; then
    log_warn "Failed: $FAILED"
fi
log_info "Total: $TOTAL"

# Verify critical scripts exist
CRITICAL_SCRIPTS="clean_logs centos7_fix_repository generate_hostname_ssl cwp_api"
for s in $CRITICAL_SCRIPTS; do
    if [ ! -f "$TARGET_DIR/$s" ]; then
        log_warn "Critical script $s not found"
    fi
done

log_info "Restoring ownership..."
chown -R root:root "$TARGET_DIR"

log_info "==============================="
log_ok "Installation complete!"
log_info "Backup stored at: $BACKUP_DIR"
log_info ""
log_info "To restore originals:"
log_info "  rm -rf $TARGET_DIR && mv $BACKUP_DIR $TARGET_DIR"
log_info ""
log_info "Test a script:"
log_info "  $TARGET_DIR/clean_logs --help"
log_info "  $TARGET_DIR/centos7_fix_repository"

exit 0