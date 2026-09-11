#!/bin/bash
# Regenerates python3-ssh-mitm.json for a new ssh-mitm release.
#
# Usage: ./update-dependencies.sh <ssh-mitm-version>
#
# Requires the runtime referenced in at.ssh_mitm.server.yml to be installed
# locally (flatpak install flathub org.freedesktop.Sdk//<version>), so
# platform wheels are resolved for the same Python/glibc the build will
# actually use.

set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:?Usage: update-dependencies.sh <ssh-mitm-version>}"
GENERATOR_COMMIT="dda10aa5949811589747e6e485da6ae2e86b5d2b"
RUNTIME="org.freedesktop.Sdk//$(grep -oP "runtime-version: '\K[^']+" at.ssh_mitm.server.yml)"

# packages that ship compiled C-extension wheels (no pure-python fallback);
# everything else in the dependency tree resolves to a universal wheel
PLATFORM_PACKAGES="bcrypt,cryptography,cffi,PyNaCl,aiohttp,lxml,PyYAML"

curl -sL -o /tmp/flatpak-pip-generator.py \
  "https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/${GENERATOR_COMMIT}/pip/flatpak-pip-generator.py"

python3 -m pip install --quiet --user 'requirements-parser<1.0.0,>=0.11.0' 'packaging>=23.0'

python3 /tmp/flatpak-pip-generator.py \
  --runtime "$RUNTIME" \
  --prefer-wheels "$PLATFORM_PACKAGES" \
  --checker-data \
  --output python3-ssh-mitm \
  "ssh-mitm==${VERSION}"

# paramiko is pinned exactly in ssh-mitm's own requirements.in (it relies on
# paramiko private internals) - don't let the checker bot auto-bump it here
python3 -c "
import json
with open('python3-ssh-mitm.json') as f:
    manifest = json.load(f)
for source in manifest['sources']:
    if source.get('x-checker-data', {}).get('name') == 'paramiko':
        del source['x-checker-data']
with open('python3-ssh-mitm.json', 'w') as f:
    json.dump(manifest, f, indent=4)
    f.write('\n')
"

echo "Wrote python3-ssh-mitm.json for ssh-mitm ${VERSION}. Review the diff, then update"
echo "the <release> entry in at.ssh_mitm.server.metainfo.xml by hand."
