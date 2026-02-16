#!/usr/bin/env bash
# Ambxst CLI — Forked to Ubuntu (fully functional rewrite)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# QuickShell binary
QS_BIN="${AMBXST_QS:-qs}"

# hyprctl for DPMS and screen control
HYPRCTL="hyprctl"

# PID cache file
PID_CACHE="/tmp/ambxst.pid"
BRIGHTNESS_SAVE="/tmp/ambxst_brightness_saved.txt"

# Colors
GREEN="\033[0;32m" YELLOW="\033[1;33m" RED="\033[0;31m" NC="\033[0m"

log()    { printf "%b%s%b\n" "${YELLOW}" "$1" "${NC}"; }
success() { printf "%b%s%b\n" "${GREEN}" "$1" "${NC}"; }
fail()    { printf "%b%s%b\n" "${RED}" "$1" "${NC}"; }

# Help output
show_help() {
cat <<EOF
Ambxst CLI - Desktop Environment Control (Ubuntu Fork)

Usage: ambxst [COMMAND]

Commands:
  (none)                          Launch Ambxst
  help, -h, --help                Show this help message
  version, -v, --version          Show version
  update                          Update Ambxst & restart
  lock                            Lock screen (DPMS off)
  reload                          Restart Ambxst
  quit                            Stop Ambxst
  suspend                         System suspend
  screen on|off                   Screen DPMS control
  brightness <value> [monitor]    Set/adjust brightness
  brightness -s [monitor]         Save brightness
  brightness -r [monitor]         Restore brightness
  brightness -l                  List monitors (hyprctl)
  run <cmd> [args...]            Send IPC to Ambxst
  goodbye                        Uninstall reminder
EOF
}

# Find running Ambxst via process search
find_pid() {
  pgrep -f "qs.*${SCRIPT_DIR}/shell.qml" 2>/dev/null || \
  pgrep -f "quickshell.*${SCRIPT_DIR}/shell.qml" 2>/dev/null || \
  pgrep -f "qs.*shell.qml" 2>/dev/null || \
  pgrep -f "quickshell.*shell.qml" 2>/dev/null
}

cached_pid() {
  if [[ -f "$PID_CACHE" ]]; then
    local p
    p=$(<"$PID_CACHE")
    if kill -0 "$p" 2>/dev/null; then
      echo "$p"
      return
    fi
    rm -f "$PID_CACHE"
  fi
  local pid
  pid=$(find_pid)
  [[ -n "$pid" ]] && echo "$pid" > "$PID_CACHE"
  echo "$pid"
}

restart_ambxst() {
  local pid
  pid="$(cached_pid)"
  if [[ -n "$pid" ]]; then
    log "Stopping Ambxst (PID $pid)…"
    kill "$pid"
    while kill -0 "$pid" 2>/dev/null; do sleep 0.1; done
  fi
  log "Restarting Ambxst…"
  nohup "$0" >/dev/null 2>&1 &
  success "Ambxst restarted"
}

# Command Implementations

do_update() {
  log "Updating Ambxst & reinstalling…"
  curl -fsSL https://raw.githubusercontent.com/Me7war/Ambxst/refs/heads/main/boot.sh | bash
  restart_ambxst
}

do_lock() {
  log "Locking screen (DPMS off)…"
  if command -v "$HYPRCTL" >/dev/null 2>&1; then
    "$HYPRCTL" dispatch dpms off
  else
    fail "hyprctl not installed"
    exit 1
  fi
}

do_reload() {
  restart_ambxst
}

do_quit() {
  local pid
  pid="$(cached_pid)"
  if [[ -n "$pid" ]]; then
    log "Stopping Ambxst (PID $pid)…"
    kill "$pid"
  else
    log "Ambxst is not running"
  fi
}

do_suspend() {
  log "Suspending system…"
  if command -v systemctl >/dev/null; then
    sudo systemctl suspend
  else
    fail "systemctl missing"
    exit 1
  fi
}

do_screen() {
  local mode="$1"
  if [[ "$mode" == "on" ]]; then
    "$HYPRCTL" dispatch dpms on
  elif [[ "$mode" == "off" ]]; then
    "$HYPRCTL" dispatch dpms off
  else
    fail "Usage: ambxst screen [on|off]"
    exit 1
  fi
}

do_brightness() {
  local pid
  pid=$(cached_pid)
  if [[ -z "$pid" ]]; then
    fail "Ambxst not running"
    exit 1
  fi

  local arg="$1" mon="${2:-}"

  if [[ "$arg" == "-l" ]]; then
    if command -v "$HYPRCTL" >/dev/null 2>&1; then
      "$HYPRCTL" monitors -j | jq -r '.[] | "  \(.name)"'
    else
      fail "hyprctl not installed"
    fi
    return
  fi

  if [[ "$arg" == "-s" ]]; then
    log "Saving brightness…"
    if [[ -n "$mon" ]]; then
      bash "${SCRIPT_DIR}/scripts/brightness_list.sh" 2>/dev/null | grep "^$mon:" > "$BRIGHTNESS_SAVE"
    else
      bash "${SCRIPT_DIR}/scripts/brightness_list.sh" 2>/dev/null > "$BRIGHTNESS_SAVE"
    fi
    success "Brightness saved"
    return
  fi

  if [[ "$arg" == "-r" ]]; then
    log "Restoring brightness…"
    if [[ ! -f "$BRIGHTNESS_SAVE" ]]; then
      fail "No saved brightness"
      exit 1
    fi
    while IFS=: read -r nm val; do
      local norm
      norm=$(awk "BEGIN {printf \"%.2f\", $val/100}")
      "$QS_BIN" ipc --pid "$pid" call brightness set "$norm" "$nm" 2>/dev/null
    done < "$BRIGHTNESS_SAVE"
    success "Brightness restored"
    return
  fi

  if [[ "$arg" =~ ^[+-]?[0-9]+$ ]]; then
    local norm
    norm=$(awk "BEGIN {printf \"%.2f\", $arg/100}")
    "$QS_BIN" ipc --pid "$pid" call brightness set "$norm" "$mon" 2>/dev/null
    success "Brightness $arg%"
    return
  fi

  fail "Invalid brightness"
  exit 1
}

do_run() {
  local cmd="$1"; shift
  local pid
  pid=$(cached_pid)
  if [[ -z "$pid" ]]; then
    fail "Ambxst not running"
    exit 1
  fi

  if [[ -p "/tmp/ambxst_ipc.pipe" ]]; then
    echo "$cmd $*" > /tmp/ambxst_ipc.pipe &
  else
    "$QS_BIN" ipc --pid "$pid" call ambxst run "$cmd" "$@" 2>/dev/null
  fi
}

# Main dispatcher

case "${1:-}" in
  "" )
    # Launch Ambxst
    log "Launching Ambxst…"
    bash "${SCRIPT_DIR}/scripts/daemon_priority.sh" &>/dev/null &
    echo $$ > "$PID_CACHE"
    exec "$QS_BIN" -p "${SCRIPT_DIR}/shell.qml"
    ;;
  help|-h|--help )
    show_help
    ;;
  version|-v|--version )
    if [[ -f "${SCRIPT_DIR}/version" ]]; then
      cat "${SCRIPT_DIR}/version"
    else
      echo "unknown"
    fi
    ;;
  update )
    do_update
    ;;
  lock )
    do_lock
    ;;
  reload )
    do_reload
    ;;
  quit )
    do_quit
    ;;
  suspend )
    do_suspend
    ;;
  screen )
    shift; do_screen "$@"
    ;;
  brightness )
    shift; do_brightness "$@"
    ;;
  run )
    shift; do_run "$@"
    ;;
  goodbye )
    log "Uninstall available via installer (boot.sh)"
    ;;
  * )
    fail "Unknown command: $1"
    show_help
    exit 1
    ;;
esac
