#!/usr/bin/env bash

# Sleep Monitor - Executes commands before and after sleep
# Usage: ./sleep_monitor.sh "before_cmd" "after_cmd"

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 \"before_cmd\" \"after_cmd\""
  exit 1
fi

BEFORE_CMD="$1"
AFTER_CMD="$2"

# Monitor logind's PrepareForSleep signal
# Signal signature: b (boolean) - true = sleeping, false = waking
dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" | while read -r line; do
  # Look for the member line to confirm signal
  if echo "$line" | grep -q "member=PrepareForSleep"; then
    # Read the next line which contains the boolean argument
    read -r arg_line
    if echo "$arg_line" | grep -q "true"; then
      # Going to sleep
      eval "$BEFORE_CMD"
    elif echo "$arg_line" | grep -q "false"; then
      # Waking up
      eval "$AFTER_CMD"
    fi
  fi
done
