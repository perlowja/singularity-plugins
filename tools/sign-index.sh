#!/bin/sh
set -eu
key=${1:?usage: sign-index.sh PRIVATE_KEY.pem [index.json]}
index=${2:-index.json}
openssl pkeyutl -sign -rawin -inkey "$key" -in "$index" | base64 -w0 > "$index.sig"
echo >> "$index.sig"
