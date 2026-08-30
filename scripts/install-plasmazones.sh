#!/usr/bin/env bash
# Build and install PlasmaZones from source against the system's Qt/KWin.
#
# Why source, not the GitHub .deb / OBS apt repo:
#   PlasmaZones is a KWin effect. The plugin IID and Qt private ABI are locked
#   to the exact Qt/KWin it was compiled against. Upstream's prebuilt .deb is
#   built on Debian unstable (Qt 6.10.x) and hard-pins qt6-*-private-abi
#   (= 6.10.x). KDE Neon ships *newer* Qt (6.11.x) and KWin 6.7.x, so no Debian
#   binary will ever install/load here. Building against the system libraries is
#   the only reliable route on Neon, and it re-links to whatever KWin is current.
#
# Idempotent: skips work when the installed version already matches the latest
# upstream tag. Re-run after a KWin/Qt update to rebuild the effect plugin.
set -euo pipefail

REPO="fuddlesworth/PlasmaZones"
BINARY="plasmazones"

# --- logging: mirror everything to a log file for post-mortem debugging -----
# dottie only surfaces the exit code, so on failure the build output is lost.
# Anchor the log next to this script (independent of dottie's cwd) and tee all
# stdout+stderr into it. The log is truncated per run and gitignored.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/install-plasmazones.log"
: > "${LOG_FILE}"
exec > >(tee -a "${LOG_FILE}") 2>&1
printf '=== install-plasmazones.sh run: %s ===\n' "$(date -Is 2>/dev/null || date)"

log()  { printf '  %s\n' "$*"; }
ok()   { printf '\xe2\x9c\x93 %s\n' "$*"; }
warn() { printf '\xe2\x9a\xa0 %s\n' "$*"; }
err()  { printf '\xe2\x9c\x97 %s\n' "$*" >&2; }

# On any failure, point the operator at the full log before exiting.
on_err() {
    local code=$?
    err "install-plasmazones.sh failed (exit ${code}). Full log: ${LOG_FILE}"
}
trap on_err ERR

# --- sudo handling (matches scripts/setup-libvirt.sh) -----------------------
if [[ $EUID -ne 0 ]]; then
    if ! sudo -n true 2>/dev/null; then
        # Allow an interactive prompt, but fail cleanly if none is available.
        if ! sudo -v 2>/dev/null; then
            err "This script needs sudo privileges to install build deps and the plugin."
            exit 1
        fi
    fi
    SUDO="sudo"
else
    SUDO=""
fi

# --- determine latest upstream tag ------------------------------------------
echo "Checking latest PlasmaZones release..."
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
if [[ -z "${LATEST_TAG}" ]]; then
    err "Could not determine latest release tag for ${REPO}"
    exit 1
fi
LATEST_VER="${LATEST_TAG#v}"
log "Latest release: ${LATEST_TAG}"

# --- skip if already at the latest version ----------------------------------
# The KWin effect plugin IID is locked to the KWin it was built against, so we
# also rebuild when the running KWin differs from what we last built with.
KWIN_VER=$(kwin_wayland --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -1 || true)
STAMP="${HOME}/.local/share/plasmazones/.built-against"
if command -v "${BINARY}" &>/dev/null; then
    INSTALLED_VER=$("${BINARY}" --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -1 || true)
    BUILT_KWIN=""
    [[ -f "${STAMP}" ]] && BUILT_KWIN=$(cat "${STAMP}" 2>/dev/null || true)
    if [[ "${INSTALLED_VER}" == "${LATEST_VER}" && "${BUILT_KWIN}" == "${KWIN_VER}" ]]; then
        ok "PlasmaZones ${INSTALLED_VER} already installed (built against KWin ${KWIN_VER})"
        exit 0
    fi
    log "Installed: ${INSTALLED_VER:-none} (KWin ${BUILT_KWIN:-unknown}) -> rebuilding for ${LATEST_VER} (KWin ${KWIN_VER})"
fi

# --- guard: KWin dev headers must match the running KWin --------------------
# If kwin-dev is a different major.minor than the running compositor, the effect
# plugin will build but refuse to load. Warn loudly rather than silently break.
KWIN_DEV_VER=$(dpkg-query -W -f='${Version}' kwin-dev 2>/dev/null \
    | grep -oE '[0-9]+(\.[0-9]+)+' | head -1 || true)

# --- install build dependencies ---------------------------------------------
echo "Installing build dependencies..."
DEPS=(
    build-essential
    cmake
    ninja-build
    extra-cmake-modules
    pkg-config
    # Qt6 (incl. private ABIs the KWin effect + shaders need)
    qt6-base-dev
    qt6-base-private-dev
    qt6-declarative-dev
    qt6-declarative-private-dev
    qt6-shadertools-dev
    qt6-svg-dev
    qt6-wayland-dev
    qt6-wayland-dev-tools
    # KDE Frameworks 6 (settings KCM + global shortcuts + color scheme)
    kf6-kcmutils-dev
    kf6-kglobalaccel-dev
    kf6-kcolorscheme-dev
    # KWin effect development (must match the running KWin)
    kwin-dev
    # Wayland layer-shell
    libwayland-dev
    wayland-protocols
    libepoxy-dev
    # Optional: activity-based layouts
    plasma-activities-dev
)
$SUDO apt-get update -qq
# Install best-effort: optional deps (e.g. plasma-activities-dev) shouldn't abort.
if ! $SUDO apt-get install -y --no-install-recommends "${DEPS[@]}"; then
    warn "Some optional build deps failed; retrying with required deps only"
    REQUIRED=(build-essential cmake ninja-build extra-cmake-modules pkg-config
        qt6-base-dev qt6-base-private-dev qt6-declarative-dev qt6-declarative-private-dev
        qt6-shadertools-dev qt6-svg-dev qt6-wayland-dev qt6-wayland-dev-tools
        kf6-kcmutils-dev kf6-kglobalaccel-dev kf6-kcolorscheme-dev kwin-dev
        libwayland-dev wayland-protocols libepoxy-dev)
    $SUDO apt-get install -y --no-install-recommends "${REQUIRED[@]}"
fi
ok "Build dependencies installed"

if [[ -n "${KWIN_DEV_VER}" && -n "${KWIN_VER}" ]]; then
    if [[ "${KWIN_DEV_VER%.*}" != "${KWIN_VER%.*}" ]]; then
        warn "kwin-dev ${KWIN_DEV_VER} differs from running KWin ${KWIN_VER};"
        warn "the effect plugin may fail to load until they match."
    fi
fi

# --- clone at the pinned tag -------------------------------------------------
BUILD_ROOT=$(mktemp -d)
trap 'rm -rf "${BUILD_ROOT}"' EXIT
SRC="${BUILD_ROOT}/PlasmaZones"

echo "Cloning ${REPO} @ ${LATEST_TAG}..."
git clone --depth 1 --branch "${LATEST_TAG}" \
    "https://github.com/${REPO}.git" "${SRC}" 2>&1 | grep -vE '^(Cloning|remote:|Receiving|Resolving)' || true

# --- configure, build, install ----------------------------------------------
echo "Building PlasmaZones (this can take several minutes)..."
cmake -S "${SRC}" -B "${SRC}/build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr
cmake --build "${SRC}/build" -j"$(nproc)"

echo "Installing..."
$SUDO cmake --install "${SRC}/build"
ok "PlasmaZones ${LATEST_VER} installed to /usr"

# Record the KWin version we linked against so we know when to rebuild.
mkdir -p "$(dirname "${STAMP}")"
printf '%s\n' "${KWIN_VER}" > "${STAMP}"

# --- enable the user daemon + refresh KDE service cache ---------------------
if command -v systemctl &>/dev/null && systemctl --user show-environment &>/dev/null; then
    systemctl --user daemon-reload 2>/dev/null || true
    if systemctl --user enable --now plasmazones.service 2>/dev/null; then
        ok "plasmazones.service enabled and started"
    else
        warn "Could not enable plasmazones.service automatically."
        warn "Run: systemctl --user enable --now plasmazones.service"
    fi
else
    warn "No user systemd session detected (headless?)."
    warn "Enable later with: systemctl --user enable --now plasmazones.service"
fi

command -v kbuildsycoca6 &>/dev/null && kbuildsycoca6 --noincremental 2>/dev/null || true

echo ""
ok "PlasmaZones ready. Confirm the effect under:"
log "System Settings -> Window Management -> Desktop Effects -> PlasmaZones"
log "(Requires KWin on Wayland with OpenGL compositing.)"
