#!/usr/bin/env bash
# setup-repo.sh — create the Gitea repo and upload SSH key secrets.
#
# Prerequisites:
#   - Gitea running at http://localhost:3000 (lab/gitea-setup/install-gitea.sh)
#   - act_runner registered with --labels self-hosted,linux,multipass
#   - SSH key pair in terraform/:
#       ssh-keygen -t ed25519 -f terraform/id_ed25519 -N ""
#
# Usage:
#   GITEA_TOKEN=<personal-access-token> ./setup-repo.sh
#
# Get a PAT at: Gitea UI → avatar → Settings → Applications
#   Required scopes: repository (Read/Write), user (Read/Write)

set -euo pipefail

GITEA_URL="http://localhost:3000"
REPO_NAME="k8s-infra"
WORK_DIR="${HOME}/${REPO_NAME}"

# ── Guard: warn if we are inside another git repository ──────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if git -C "$SCRIPT_DIR" rev-parse --git-dir &>/dev/null 2>&1; then
  PARENT_GIT=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null)
  if [[ "$PARENT_GIT" != "$SCRIPT_DIR" ]]; then
    echo "⚠️  WARNING: This directory is inside another git repo:"
    echo "             ${PARENT_GIT}"
    echo ""
    echo "   Running 'git init' here would create a nested repo and may"
    echo "   corrupt the outer repository's index."
    echo ""
    echo "   This script will copy the lab files to: ${WORK_DIR}"
    echo "   and print push instructions from there."
    echo ""
  fi
fi
SSH_PRIVATE_KEY_FILE="${SCRIPT_DIR}/terraform/id_ed25519"
SSH_PUBLIC_KEY_FILE="${SCRIPT_DIR}/terraform/id_ed25519.pub"

if [[ -z "${GITEA_TOKEN:-}" ]]; then
  echo "ERROR: GITEA_TOKEN is not set."
  echo "       Create a Personal Access Token at: ${GITEA_URL}/user/settings/applications"
  exit 1
fi

if [[ ! -f "$SSH_PRIVATE_KEY_FILE" || ! -f "$SSH_PUBLIC_KEY_FILE" ]]; then
  echo "SSH key pair not found — generating..."
  ssh-keygen -t ed25519 -f "${SCRIPT_DIR}/terraform/id_ed25519" -N ""
  echo "Keys generated."
fi

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required. Install with: sudo apt install jq"
  exit 1
fi

API="${GITEA_URL}/api/v1"
AUTH=(-H "Authorization: token ${GITEA_TOKEN}" -H "Content-Type: application/json")

# ── 1. Verify token ───────────────────────────────────────────────────────────
echo "==> Checking Gitea API..."
HTTP=$(curl -s -o /dev/null -w "%{http_code}" "${AUTH[@]}" "${API}/user")
if [[ "$HTTP" != "200" ]]; then
  echo "ERROR: Cannot reach Gitea API (HTTP ${HTTP}). Is Gitea running?"
  exit 1
fi
GITEA_USER=$(curl -s "${AUTH[@]}" "${API}/user" | jq -r '.login')
echo "    Authenticated as: ${GITEA_USER}"

# ── 2. Create repository ──────────────────────────────────────────────────────
echo "==> Creating repository '${REPO_NAME}'..."
HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
  "${AUTH[@]}" \
  -X POST "${API}/user/repos" \
  -d "{\"name\":\"${REPO_NAME}\",\"private\":false,\"auto_init\":false}")

if [[ "$HTTP" == "201" ]]; then
  echo "    Created: ${GITEA_URL}/${GITEA_USER}/${REPO_NAME}"
elif [[ "$HTTP" == "409" ]]; then
  echo "    Repository already exists — skipping."
else
  echo "ERROR: HTTP ${HTTP} when creating repository."
  exit 1
fi

# ── 3. Enable Actions ─────────────────────────────────────────────────────────
echo "==> Enabling Actions on '${REPO_NAME}'..."
curl -sSf "${AUTH[@]}" \
  -X PATCH "${API}/repos/${GITEA_USER}/${REPO_NAME}" \
  -d '{"has_actions":true}' > /dev/null
echo "    Done."

# ── 4. Set SSH_PRIVATE_KEY secret ────────────────────────────────────────────
echo "==> Setting secret SSH_PRIVATE_KEY..."
curl -sSf "${AUTH[@]}" \
  -X PUT "${API}/repos/${GITEA_USER}/${REPO_NAME}/actions/secrets/SSH_PRIVATE_KEY" \
  -d "{\"data\":$(cat "$SSH_PRIVATE_KEY_FILE" | jq -Rs .)}" > /dev/null
echo "    Done."

# ── 5. Set SSH_PUBLIC_KEY secret ─────────────────────────────────────────────
echo "==> Setting secret SSH_PUBLIC_KEY..."
curl -sSf "${AUTH[@]}" \
  -X PUT "${API}/repos/${GITEA_USER}/${REPO_NAME}/actions/secrets/SSH_PUBLIC_KEY" \
  -d "{\"data\":$(cat "$SSH_PUBLIC_KEY_FILE" | jq -Rs .)}" > /dev/null
echo "    Done."

# ── 6. Next steps ─────────────────────────────────────────────────────────────
cat <<EOF

==> Setup complete!

Copy the lab directory to a clean location outside this repo, then push:

  rsync -a --exclude='.git' ${SCRIPT_DIR}/ ${WORK_DIR}/
  cd ${WORK_DIR}
  git init && git branch -M main
  git remote add gitea ${GITEA_URL}/${GITEA_USER}/${REPO_NAME}.git
  git add .
  git commit -m "feat: initial k8s cluster setup"
  git push gitea main

Monitor the pipeline:
  ${GITEA_URL}/${GITEA_USER}/${REPO_NAME}/actions

After the infra pipeline completes, verify the cluster:
  KUBECONFIG=~/k8s-config kubectl get nodes

Deploy the example workload by pushing a change to k8s/:
  # (pipeline triggers automatically on push to k8s/**)
  KUBECONFIG=~/k8s-config kubectl get svc nginx   # NodePort 30080

EOF
