#!/bin/bash
set -e

CN="$1"

mkdir -p /var/lib/icinga2/certs
chown -R nagios:nagios /var/lib/icinga2/certs

if [ ! -f "/var/lib/icinga2/certs/${CN}.crt" ]; then
  icinga2 pki new-cert \
    --cn "$CN" \
    --key "/var/lib/icinga2/certs/${CN}.key" \
    --cert "/var/lib/icinga2/certs/${CN}.crt"

  icinga2 pki save-cert \
    --key "/var/lib/icinga2/certs/${CN}.key" \
    --cert "/var/lib/icinga2/certs/${CN}.crt" \
    --trustedcert "/var/lib/icinga2/certs/ca.crt" \
    --host "$CN"
fi

chmod 0600 /var/lib/icinga2/certs/*.key