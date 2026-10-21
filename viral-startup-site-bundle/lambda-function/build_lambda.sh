#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HERE/package"
rm -rf "$HERE/package"/*
python3 -m pip install --platform manylinux2014_x86_64 --only-binary=:all: --implementation cp --python-version 3.12 --abi cp312 -r "$HERE/requirements.txt" -t "$HERE/package"
cp "$HERE/handler.py" "$HERE/package/handler.py"
(cd "$HERE/package" && zip -qr "$HERE/lambda-deployment.zip" .)
echo "Created $HERE/lambda-deployment.zip"
