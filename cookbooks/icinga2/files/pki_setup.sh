#!/bin/bash
set -e

CN="$1"

mkdir -p /var/lib/icinga2/certs /var/lib/icinga2/ca

if [ ! -f "/var/lib/icinga2/certs/${CN}.crt" ]; then
  icinga2 pki new-cert \
    --cn "$CN" \
    --key "/var/lib/icinga2/certs/${CN}.key" \
    --cert "/var/lib/icinga2/certs/${CN}.crt"

  icinga2 pki save-cert \
    --key "/var/lib/icinga2/certs/${CN}.key" \
    --cert "/var/lib/icinga2/certs/${CN}.crt" \
    --trustedcert "/var/lib/icinga2/ca/ca.crt" \
    --host "$CN"
fi

chown -R icinga:icinga /var/lib/icinga2/certs /var/lib/icinga2/ca
chmod 0600 /var/lib/icinga2/certs/*.key