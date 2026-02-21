#!/bin/bash
set -euo pipefail

PACKAGE="${1:-}"
VERSION="${2:-}"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()  { echo -e "${CYAN}>${RESET} $*"; }
ok()    { echo -e "${GREEN}>${RESET} $*"; }
fail()  { echo -e "${RED}>${RESET} $*"; exit 1; }

# --- Validate package arg ---
if [ "$PACKAGE" != "snapclient" ] && [ "$PACKAGE" != "snapserver" ]; then
    echo ""
    echo -e "${BOLD}snapcast installer${RESET}"
    echo ""
    echo "Usage:"
    echo "  curl -fsSL <url>/install.sh | bash -s -- <snapclient|snapserver> [version]"
    echo ""
    exit 1
fi

# --- Detect architecture ---
ARCH=$(dpkg --print-architecture 2>/dev/null) || fail "dpkg not found. This script requires a Debian-based system."

# --- Detect distro ---
DISTRO=$(lsb_release -cs 2>/dev/null || source /etc/os-release 2>/dev/null && echo "${VERSION_CODENAME:-}" || true)
case "$DISTRO" in
    bookworm|bullseye|trixie) ;;
    *)
        info "Unknown distro '$DISTRO'. Defaulting to bookworm."
        DISTRO="bookworm"
        ;;
esac

# --- Resolve version ---
if [ -n "$VERSION" ]; then
    VERSION="${VERSION#v}"
else
    info "Fetching latest release..."
    VERSION=$(curl -fsSL "https://api.github.com/repos/snapcast/snapcast/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
    [ -z "$VERSION" ] && fail "Could not determine latest version."
fi

# --- Build download URL ---
DEB="${PACKAGE}_${VERSION}-1_${ARCH}_${DISTRO}_with-pipewire.deb"

URL="https://github.com/snapcast/snapcast/releases/download/v${VERSION}/${DEB}"

info "Installing ${BOLD}${PACKAGE} v${VERSION}${RESET} (${ARCH}, ${DISTRO})"

# --- Download and install ---
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

info "Downloading ${DEB}..."
curl -fSL --progress-bar -o "${TMPDIR}/${DEB}" "${URL}" || fail "Download failed. Check that a build exists for ${ARCH}/${DISTRO} at:\n  ${URL}"

info "Installing (requires sudo)..."
sudo apt-get install -y "${TMPDIR}/${DEB}" > /dev/null 2>&1 || sudo dpkg -i "${TMPDIR}/${DEB}" && sudo apt-get install -f -y > /dev/null 2>&1

ok "${BOLD}${PACKAGE} ${VERSION}${RESET} installed successfully."
echo ""
