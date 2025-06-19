#!/bin/bash
set -e

CN="$1"

mkdir -p /etc/icinga2/pki

if [ ! -f "/etc/icinga2/pki/${CN}.crt" ]; then
  icinga2 pki new-cert \
    --cn "$CN" \
    --key "/etc/icinga2/pki/${CN}.key" \
    --cert "/etc/icinga2/pki/${CN}.crt"

  icinga2 pki save-cert \
    --key "/etc/icinga2/pki/${CN}.key" \
    --cert "/etc/icinga2/pki/${CN}.crt" \
    --trustedcert "/etc/icinga2/pki/ca.crt" \
    --host "$CN"
fi