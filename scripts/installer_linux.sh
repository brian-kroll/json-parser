#!/usr/bin/env bash

TMPDIR=$(mktemp -d /tmp/json-parser.XXX)
INSTALLER_EXIT_CODE=1
{
    SKIP_LINES=$(awk '/^__TAR/ {print NR + 1; exit 0; }' "${0}");
    tail -n+${SKIP_LINES} "${0}"|base64 --decode|tar xj -C ${TMPDIR};
    cd ${TMPDIR};
    (./install_linux.sh) && INSTALLER_EXIT_CODE=0;
}
rm -rf ${TMPDIR}
exit ${INSTALLER_EXIT_CODE}

__TAR
