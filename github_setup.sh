#!/usr/bin/env bash
# Interactive GitHub SSH setup for HISE IDE environments.
# Run with: bash github_setup.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
header()  { echo -e "\n${BOLD}=== $* ===${NC}"; }
prompt()  { echo -e "${YELLOW}>>>${NC} $*"; }

# ---------------------------------------------------------------------------
# Step 0 – Check OS / package manager
# ---------------------------------------------------------------------------
header "Step 1 of 5 — System check"

if ! command -v apt-get &>/dev/null; then
    error "apt-get not found. This script expects a Debian/Ubuntu system."
    exit 1
fi

prompt "Update apt package lists? This may take a moment. [Y/n]"
read -r ans
if [[ "${ans:-Y}" =~ ^[Yy]$ ]]; then
    info "Running apt-get update…"
    apt-get update -qq
fi

# ---------------------------------------------------------------------------
# Step 1 – Ensure git and openssh-client are installed
# ---------------------------------------------------------------------------
header "Step 2 of 5 — Check required tools"

MISSING=()
command -v git &>/dev/null && info "git found: $(git --version)" || MISSING+=(git-all)
command -v ssh &>/dev/null && info "ssh found: $(ssh -V 2>&1)" || MISSING+=(openssh-client)

if [[ ${#MISSING[@]} -gt 0 ]]; then
    warn "Missing packages: ${MISSING[*]}"
    prompt "Install them now? [Y/n]"
    read -r ans
    if [[ "${ans:-Y}" =~ ^[Yy]$ ]]; then
        apt-get install -y -qq "${MISSING[@]}"
        info "Packages installed."
    else
        error "Cannot continue without git and openssh-client. Exiting."
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Step 2 – Collect user email
# ---------------------------------------------------------------------------
header "Step 3 of 5 — Generate SSH key"

while true; do
    prompt "Enter your Allen Institute email address (e.g. first.last@alleninstitute.org):"
    read -r EMAIL
    if [[ "$EMAIL" =~ ^[^@]+@alleninstitute\.org$ ]]; then
        break
    fi
    warn "That doesn't look like an @alleninstitute.org address. Try again."
done

KEY_DIR="$HOME/ssh_keys"
KEY_PATH="$KEY_DIR/ed25519"

if [[ -f "$KEY_PATH" ]]; then
    warn "An SSH key already exists at $KEY_PATH."
    prompt "Overwrite it? [y/N]"
    read -r ans
    if [[ ! "${ans:-N}" =~ ^[Yy]$ ]]; then
        info "Keeping existing key. Skipping key generation."
    else
        mkdir -p "$KEY_DIR"
        info "Generating new ED25519 key for $EMAIL…"
        ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH"
    fi
else
    mkdir -p "$KEY_DIR"
    info "Generating ED25519 key for $EMAIL…"
    info "When prompted for a file path, press Enter to accept the default: $KEY_PATH"
    info "Then enter a secure passphrase (recommended) or press Enter twice to skip."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH"
fi

# ---------------------------------------------------------------------------
# Step 3 – Add key to ssh-agent
# ---------------------------------------------------------------------------
header "Step 4 of 5 — Add key to ssh-agent"

info "Starting ssh-agent…"
eval "$(ssh-agent -s)"

info "Adding $KEY_PATH to agent…"
ssh-add "$KEY_PATH"
info "Key added to agent."

# ---------------------------------------------------------------------------
# Step 4 – Display public key
# ---------------------------------------------------------------------------
header "Step 5 of 5 — Add your public key to GitHub"

PUB_KEY_PATH="${KEY_PATH}.pub"
PUB_KEY=$(cat "$PUB_KEY_PATH")

echo ""
echo -e "${BOLD}Your public key is:${NC}"
echo "────────────────────────────────────────────────────────────────"
echo "$PUB_KEY"
echo "────────────────────────────────────────────────────────────────"
echo ""
info "Next steps:"
echo "  1. Open https://github.com/settings/keys in your browser."
echo "  2. Click 'New SSH Key'."
echo "  3. Give it a title describing this environment (e.g. 'HISE IDE - <project name>')."
echo "  4. Paste the public key above into the 'Key' field, then click 'Add SSH key'."
echo ""

prompt "Press Enter once you have added the key to GitHub to test the connection…"
read -r _

# ---------------------------------------------------------------------------
# Step 5 – Test connection
# ---------------------------------------------------------------------------
info "Testing connection to github.com…"
# ssh -T exits with code 1 even on success ("Hi <user>! You've authenticated…")
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    info "Connection successful!"
else
    OUTPUT=$(ssh -T git@github.com 2>&1 || true)
    if echo "$OUTPUT" | grep -qi "successfully authenticated\|Hi "; then
        info "Connection successful! GitHub says: $OUTPUT"
    else
        error "Connection test failed. GitHub responded with:"
        echo "$OUTPUT"
        echo ""
        echo "Double-check that you copied the full public key and saved it on GitHub."
    fi
fi

echo ""
info "Setup complete. You can now clone AIFI repositories with:"
echo "  git clone git@github.com:AllenInstitute/<repo-name>.git"
