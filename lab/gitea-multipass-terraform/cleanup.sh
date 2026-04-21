#!/usr/bin/env bash
# cleanup.sh
# Destroys Multipass VMs via tofu and removes all generated files,
# leaving the repo in a clean state ready for the next pipeline run.
#
# Usage:
#   cd lab/gitea-multipass-terraform
#   ./cleanup.sh

set -euo pipefail

cd "$(dirname "$0")"

echo "==> Destroying Multipass VMs via tofu..."
if [[ -f terraform/terraform.tfstate ]]; then
  tofu -chdir=terraform destroy -auto-approve || echo "    WARNING: tofu destroy failed — VMs may need manual cleanup."
else
  echo "    No tfstate found — skipping tofu destroy."
fi

echo ""
echo "==> Deleting Multipass instances directly (in case tofu state is out of sync)..."
for INSTANCE in manager worker1 worker2; do
  if multipass info "$INSTANCE" &>/dev/null 2>&1; then
    multipass delete "$INSTANCE" && echo "    Deleted: $INSTANCE"
  fi
done
multipass purge && echo "    Purged all deleted instances."

echo ""
echo "==> Removing generated files..."
rm -f terraform/id_ed25519
rm -f terraform/id_ed25519.pub
rm -f terraform/cloud-init.rendered.yml
rm -f ansible/hosts.ini
rm -f ~/cloud-init.rendered.yml

echo ""
echo "==> Removing OpenTofu state and cache..."
rm -f terraform/terraform.tfstate
rm -f terraform/terraform.tfstate.backup
rm -f terraform/tfplan
rm -rf terraform/.terraform
rm -f terraform/.terraform.lock.hcl

echo ""
echo "==> Removing local git repo (canonical repo is on Gitea)..."
rm -rf .git

echo ""
echo "Done. The directory is clean — run setup-pipeline.sh and re-init git to start fresh."
