#!/bin/sh

set -eo pipefail

# Move to workspace
cd /workspace

# Test if package.json file is found
elif [ -f /workspace/package.json ]; then
  # Install node_modules
  npm install
fi
