#!/bin/bash -xe
# 
# Copyright 2021 Carnegie Mellon University.
# Released under a BSD (SEI)-style license, please see LICENSE.md in the
# project root or contact permission@sei.cmu.edu for full terms.


# Change to the current directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Generate root, intermediate and host certificates/keys
cfssl gencert -initca root-ca.json | cfssljson -bare root-ca
cfssl gencert -ca root-ca.pem -ca-key root-ca-key.pem -config config.json \
              -profile intca int-ca.json | cfssljson -bare int-ca
cfssl gencert -ca int-ca.pem -ca-key int-ca-key.pem -config config.json \
              -profile server host.json | cfssljson -bare host

# Create pkcs12 host bundle for identity signing key
openssl pkcs12 -export -out host.pfx -inkey host-key.pem -in host.pem \
               -passin pass:foundry -passout pass:foundry
sed -ri "s|(signer:) \"\"|\1 $(base64 -w0 host.pfx)|" ../identity.values.yaml
