#!/bin/bash
# Created by Jeremy, Newcold Digital, Aug 2025
# File: /usr/local/bin/node_exporter_patch_metrics.sh
# Purpose: Collect patch info for Node Exporter textfile collector
# Supports RHEL/CentOS/Rocky and Debian/Ubuntu

OUT_DIR="/var/lib/node_exporter/textfile_collector"
METRIC_FILE="$OUT_DIR/patch_info.prom"
TMP_FILE=$(mktemp)

LAST_PATCH_TS=0
AVAILABLE_UPDATES=0
SECURITY_UPDATES=0
AVAILABLE_UPDATES_LIST=""
SECURITY_UPDATES_LIST=""

if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
  # RHEL-based
  LAST_PATCH=$(grep -E 'Upgraded:|Updated:' /var/log/dnf.log /var/log/yum.log 2>/dev/null | tail -1 | awk '{print $1" "$2}')
  LAST_PATCH_TS=$(date -d "$LAST_PATCH" +%s 2>/dev/null || echo 0)

  AVAILABLE_UPDATES_LIST=$(dnf check-update --quiet 2>/dev/null | grep -E '^[a-zA-Z0-9]' | awk '{print $1":"$2}')
  AVAILABLE_UPDATES=$(echo "$AVAILABLE_UPDATES_LIST" | wc -l)

  if command -v dnf-plugins-core >/dev/null 2>&1 || rpm -q dnf-plugins-core >/dev/null 2>&1; then
    SECURITY_UPDATES_LIST=$(dnf check-update --security -q | awk 'NF {print $1}' | paste -sd "," -)
    SECURITY_UPDATES=$(echo "$SECURITY_UPDATES_LIST" | wc -l)
  else
    SECURITY_UPDATES_LIST=""
    SECURITY_UPDATES=0
  fi

elif command -v apt >/dev/null 2>&1; then
    # Debian-based
  LAST_PATCH=$(grep 'upgrade ' /var/log/dpkg.log | tail -1 | awk '{print $1" "$2}')
  LAST_PATCH_TS=$(date -d "$LAST_PATCH" +%s 2>/dev/null || echo 0)

  apt update -qq >/dev/null

  AVAILABLE_UPDATES_LIST=$(apt list --upgradable 2>/dev/null | grep -v Listing | awk -F/ '{print $1}')
  AVAILABLE_UPDATES=$(echo "$AVAILABLE_UPDATES_LIST" | wc -l)

  if command -v unattended-upgrades >/dev/null 2>&1; then
      SECURITY_UPDATES_LIST=$(unattended-upgrades --dry-run -d 2>/dev/null | grep "Inst " | awk '{print $2}')
      SECURITY_UPDATES=$(echo "$SECURITY_UPDATES_LIST" | wc -l)
  else
    SECURITY_UPDATES_LIST=""
    SECURITY_UPDATES=0
  fi

else
    echo "Unsupported OS"
    exit 1
fi

AVAILABLE_UPDATES_CSV=$(echo "$AVAILABLE_UPDATES_LIST" | paste -sd "," -)
SECURITY_UPDATES_CSV=$(echo "$SECURITY_UPDATES_LIST" | paste -sd "," -)

{
  echo "# HELP system_last_patch_time Unix timestamp of last patch applied"
  echo "# TYPE system_last_patch_time gauge"
  echo "system_last_patch_time $LAST_PATCH_TS"

  echo "# HELP system_available_updates Number of available updates"
  echo "# TYPE system_available_updates gauge"
  echo "system_available_updates $AVAILABLE_UPDATES"

  echo "# HELP system_available_updates_packages Comma-separated list of available updates"
  echo "# TYPE system_available_updates_packages gauge"
  echo "system_available_updates_packages{packages=\"$AVAILABLE_UPDATES_CSV\"} 1"

  echo "# HELP system_security_updates Number of available security updates"
  echo "# TYPE system_security_updates gauge"
  echo "system_security_updates $SECURITY_UPDATES"

  echo "# HELP system_security_updates_packages Comma-separated list of security updates"
  echo "# TYPE system_security_updates_packages gauge"
  echo "system_security_updates_packages{packages=\"$SECURITY_UPDATES_CSV\"} 1"
} > "$TMP_FILE"

mv "$TMP_FILE" "$METRIC_FILE"
