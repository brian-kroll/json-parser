#!/usr/bin/env bash

cd installer_payload
tar cjf payload.tar.bz2 *
cd ..
cp installer_linux.sh ../packaged/
cat installer_payload/payload.tar.bz2|base64 >> ../packaged/installer_linux.sh
rm installer_payload/payload.tar.bz2
echo "Find the installer at ../packaged/installer_linux.sh"
