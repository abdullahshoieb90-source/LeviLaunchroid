#!/usr/bin/env bash
# Applies the Hotbar Slots port onto a BedrockToolsPlus- checkout.
#
# Run this on YOUR machine (the agent session that prepared this package is
# pinned to its own branch and cannot push to other repos/branches):
#
#   ./apply.sh /path/to/BedrockToolsPlus- [branch-name]
#
# It creates the branch, applies bedrocktoolsplus-hotbarslots.patch sitting
# next to this script, and runs the host test suite.
set -euo pipefail

target="${1:-}"
branch="${2:-feature/hotbar-slots}"

if [[ -z "${target}" ]]; then
    echo "usage: $0 /path/to/BedrockToolsPlus- [branch-name]" >&2
    exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
patch="${script_dir}/bedrocktoolsplus-hotbarslots.patch"

[[ -f "${patch}" ]] || { echo "patch not found: ${patch}" >&2; exit 1; }
[[ -d "${target}/.git" ]] || { echo "not a git repo: ${target}" >&2; exit 1; }

cd "${target}"
git checkout -b "${branch}"
git apply --check "${patch}"
git apply "${patch}"
./scripts/run_tests.sh

echo ""
echo "Done. Review with: git status && git diff --stat"
echo "Then: git add -A && git commit -m \"Add Hotbar Slots module (native port of LeviLauncher Hotbar Slot)\" && git push -u origin ${branch}"
