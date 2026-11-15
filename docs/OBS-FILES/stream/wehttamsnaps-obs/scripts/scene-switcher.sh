#!/usr/bin/env bash
# ============================================================================
#  wehttamsnaps — scene-switcher.sh
#  Wayland-native scene switching for OBS via obs-websocket, with a terminal
#  banner that fires the section-4 separator + scene name so you SEE the switch
#  land in Konsole.
#
#  Requires:  obs-websocket plugin enabled in OBS (Tools → obs-websocket
#             settings), curl, jq. (Both are on CachyOS already.)
#
#  Usage:
#    scene-switcher.sh <command>
#
#  Commands (match the MangoWM binds in the guide):
#    starting       -> 00 │ Starting Soon
#    streamstart    -> 00 │ Stream Starting
#    live           -> 10 ─ Live
#    justchatting   -> 10 ─ Just Chatting
#    brb            -> 20 ┊ BRB
#    techpause      -> 20 ┊ Tech Pause
#    ending         -> 30 ✦ Ending
#    offline        -> 30 ✦ Offline
#    overlaytest    -> 40 ◆ Overlay Test
#    config         -> 50 ⚙ Config / Never Air
#    toggle-record  -> start/stop recording
#    toggle-stream  -> start/stop streaming
#    status         -> print current scene + record/stream state
#    list           -> list all scenes OBS knows about
#
#  Bind in MangoWM input.conf:
#    bind=SUPER+F1,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh starting
#    bind=SUPER+F2,spawn,~/.config/wehttamsnaps/scripts/scene-switcher.sh live
#    ...etc (see docs/WEHTTAMSNAPS-OBS-GUIDE.md section "Useful keybinds")
# ============================================================================

set -euo pipefail

# ---- config (override via env or ~/.config/wehttamsnaps/scene-switcher.conf) ----
OBS_WS_HOST="${OBS_WS_HOST:-127.0.0.1}"
OBS_WS_PORT="${OBS_WS_PORT:-4455}"
OBS_WS_PASS="${OBS_WS_PASS:-}"   # set if you enabled a password in OBS

CONF="${XDG_CONFIG_HOME:-$HOME/.config}/wehttamsnaps/scene-switcher.conf"
[ -f "$CONF" ] && . "$CONF"

# ---- colour palette (matches brand) ----
C_PURPLE='\033[38;5;93m'
C_CYAN='\033[38;5;51m'
C_MAGENTA='\033[38;5;199m'
C_DIM='\033[2m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

# ---- scene name table: short command -> exact OBS scene name ----
declare -A SCENES=(
  [starting]="00 │ Starting Soon"
  [streamstart]="00 │ Stream Starting"
  [live]="10 ─ Live"
  [justchatting]="10 ─ Just Chatting"
  [brb]="20 ┊ BRB"
  [techpause]="20 ┊ Tech Pause"
  [ending]="30 ✦ Ending"
  [offline]="30 ✦ Offline"
  [overlaytest]="40 ◆ Overlay Test"
  [config]="50 ⚙ Config / Never Air"
)

# ---- obs-websocket helper ----
ws_call() {
  # ws_call <request-type> [json-args]
  local rtype="$1"; local args="${2:-{}}"
  local id="$RANDOM"
  local payload
  if [ -n "$OBS_WS_PASS" ]; then
    payload=$(cat <<JSON
{"op":1,"d":{"rpcVersion":1,"authentication":"$OBS_WS_PASS"}}
JSON
    )
    # NOTE: obs-websocket v5 uses salt+challenge hashing for auth. If you set a
    # password, the simplest path is to leave OBS auth OFF on localhost, OR use
    # the python obs-websocket client (pip install obs-websocket-py). This shell
    # version assumes no password on loopback (the common home setup).
    :
  fi
  # We use a single curl + raw websocket frame via a tiny python helper so we
  # don't need websocat installed. Falls back to curl + python3.
  python3 - "$OBS_WS_HOST" "$OBS_WS_PORT" "$rtype" "$args" "$id" <<'PY'
import sys, json, socket, struct, os, base64, time

host, port, rtype, args, rid = sys.argv[1:6]
port = int(port)

# --- build the minimal websocket handshake + one framed JSON-RPC message ---
sock = socket.create_connection((host, port), timeout=3)
key = base64.b64encode(os.urandom(16)).decode()
hs = (
    f"GET / HTTP/1.1\r\nHost: {host}:{port}\r\nUpgrade: websocket\r\n"
    f"Connection: Upgrade\r\nSec-WebSocket-Key: {key}\r\n"
    "Sec-WebSocket-Version: 13\r\n\r\n"
)
sock.sendall(hs.encode())
# read the HTTP handshake response headers
buf = b""
while b"\r\n\r\n" not in buf:
    chunk = sock.recv(4096)
    if not chunk:
        break
    buf += chunk

# Identify + send the request. obs-websocket v5 op codes:
#   0 Hello, 1 Identify, 2 Identified, 6 Request
def send_json(op, d):
    msg = json.dumps({"op": op, "d": d}).encode()
    # text frame, masked (client must mask)
    header = bytearray([0x81])
    n = len(msg)
    if n < 126:
        header.append(0x80 | n)
    elif n < 65536:
        header.append(0x80 | 126)
        header += struct.pack(">H", n)
    else:
        header.append(0x80 | 127)
        header += struct.pack(">Q", n)
    mask = os.urandom(4)
    header += mask
    masked = bytearray(b ^ mask[i % 4] for i, b in enumerate(msg))
    sock.sendall(bytes(header) + bytes(masked))

def recv_json(timeout=3):
    sock.settimeout(timeout)
    # read a single frame (we don't handle fragmentation — OBS sends small frames)
    hdr = b""
    while len(hdr) < 2:
        hdr += sock.recv(2 - len(hdr))
    b1, b2 = hdr[0], hdr[1]
    plen = b2 & 0x7F
    if plen == 126:
        ext = b""
        while len(ext) < 2: ext += sock.recv(2 - len(ext))
        plen = struct.unpack(">H", ext)[0]
    elif plen == 127:
        ext = b""
        while len(ext) < 8: ext += sock.recv(8 - len(ext))
        plen = struct.unpack(">Q", ext)[0]
    payload = b""
    while len(payload) < plen:
        payload += sock.recv(plen - len(payload))
    return json.loads(payload)

# 1) Hello
hello = recv_json(3)            # op 0
# 2) Identify (no auth for the common localhost-no-password case)
send_json(1, {"rpcVersion": 1})
ident = recv_json(3)            # op 2 Identified
# 3) Request
send_json(6, {"requestType": rtype, "requestId": rid,
              "requestData": json.loads(args) if args and args != "{}" else {}})
# read frames until we get a RequestResponse (op 7)
deadline = time.time() + 5
while time.time() < deadline:
    msg = recv_json(5)
    if msg.get("op") == 7 and msg.get("d", {}).get("requestId") == rid:
        print(json.dumps(msg["d"]))
        break
    if msg.get("op") == 5:  # Event — ignore but keep reading
        continue
sock.close()
PY
}

# ---- banner printer ----
banner() {
  # banner <symbol> <scene-name> <status-line>
  local sym="$1" name="$2" status="$3"
  local bar="${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  printf '\n%s\n' "$bar"
  printf '  %s%s %s%s%s  %s\n' "$C_BOLD" "$C_MAGENTA" "$sym" "$C_CYAN" "$name" "$C_RESET"
  printf '  %s%s%s\n' "$C_DIM" "$status" "$C_RESET"
  printf '%s\n\n' "$bar"
}

# ---- scene switch ----
switch_scene() {
  local cmd="$1"
  local name="${SCENES[$cmd]:-}"
  if [ -z "$name" ]; then
    printf '%serror:%s unknown scene command "%s"\n' "$C_MAGENTA" "$C_RESET" "$cmd" >&2
    printf 'known: %s\n' "${!SCENES[*]}" >&2
    exit 2
  fi
  local sym="${name%% *}"   # first token is the symbol+number? no — name starts with "NN │ ..."
  # symbol is the 2nd whitespace token (e.g. "00 │ Starting Soon" -> "│")
  sym=$(awk '{print $2}' <<<"$name")
  local pretty=$(cut -d' ' -f3- <<<"$name")
  # fire the OBS request
  local resp rc
  resp=$(ws_call "SetCurrentProgramScene" "{\"sceneName\":\"$name\"}" 2>&1) && rc=0 || rc=$?
  if [ $rc -ne 0 ] || [ -z "$resp" ]; then
    printf '%serror:%s could not reach obs-websocket at %s:%s — is OBS running with the plugin enabled?\n' \
      "$C_MAGENTA" "$C_RESET" "$OBS_WS_HOST" "$OBS_WS_PORT" >&2
    [ -n "$resp" ] && printf '%s\n' "$resp" >&2
    exit 3
  fi
  local ok
  ok=$(printf '%s' "$resp" | jq -r '.requestStatus.result // false' 2>/dev/null || echo false)
  if [ "$ok" = "true" ]; then
    banner "$sym" "$pretty" "switched ✓   ($name)   $(date '+%H:%M:%S')"
  else
    printf '%serror:%s OBS rejected the scene switch — does a scene named "%s" exist?\n' \
      "$C_MAGENTA" "$C_RESET" "$name" >&2
    printf 'response: %s\n' "$resp" >&2
    exit 4
  fi
}

# ---- toggle record / stream ----
toggle_record() {
  # GetRecordStatus -> ToggleRecord is simplest (no state needed)
  local resp
  resp=$(ws_call "ToggleRecord" "{}") || {
    printf '%serror:%s could not reach obs-websocket\n' "$C_MAGENTA" "$C_RESET" >&2; exit 3; }
  local ok
  ok=$(printf '%s' "$resp" | jq -r '.requestStatus.result // false' 2>/dev/null || echo false)
  if [ "$ok" = "true" ]; then
    banner "●" "RECORD" "toggle sent ✓   $(date '+%H:%M:%S')"
  else
    printf '%serror:%s record toggle failed: %s\n' "$C_MAGENTA" "$C_RESET" "$resp" >&2; exit 4; fi
}

toggle_stream() {
  local resp
  resp=$(ws_call "ToggleStream" "{}") || {
    printf '%serror:%s could not reach obs-websocket\n' "$C_MAGENTA" "$C_RESET" >&2; exit 3; }
  local ok
  ok=$(printf '%s' "$resp" | jq -r '.requestStatus.result // false' 2>/dev/null || echo false)
  if [ "$ok" = "true" ]; then
    banner "▶" "STREAM" "toggle sent ✓   $(date '+%H:%M:%S')"
  else
    printf '%serror:%s stream toggle failed: %s\n' "$C_MAGENTA" "$C_RESET" "$resp" >&2; exit 4; fi
}

# ---- status ----
show_status() {
  local cur
  cur=$(ws_call "GetCurrentProgramScene" "{}") || {
    printf '%serror:%s could not reach obs-websocket\n' "$C_MAGENTA" "$C_RESET" >&2; exit 3; }
  local scene
  scene=$(printf '%s' "$cur" | jq -r '.responseData.currentProgramSceneName // "?"' 2>/dev/null)
  local rec stream
  rec=$(ws_call "GetRecordStatus" "{}" | jq -r '.responseData.outputActive // false' 2>/dev/null || echo false)
  stream=$(ws_call "GetStreamStatus" "{}" | jq -r '.responseData.outputActive // false' 2>/dev/null || echo false)
  banner "ⓘ" "STATUS" "scene: $scene   record: $rec   stream: $stream   $(date '+%H:%M:%S')"
}

# ---- list ----
list_scenes() {
  local resp
  resp=$(ws_call "GetSceneList" "{}") || {
    printf '%serror:%s could not reach obs-websocket\n' "$C_MAGENTA" "$C_RESET" >&2; exit 3; }
  printf '\n%sScenes OBS knows about:%s\n' "$C_BOLD" "$C_RESET"
  printf '%s' "$resp" | jq -r '.responseData.scenes[] | "  \(.sceneName)"' 2>/dev/null | sort
  printf '\n'
}

# ---- main ----
[ $# -lt 1 ] && { printf 'usage: %s <command>\ncommands: %s\n' "$0" "${!SCENES[*]} toggle-record toggle-stream status list" >&2; exit 1; }

cmd="$1"
case "$cmd" in
  starting|streamstart|live|justchatting|brb|techpause|ending|offline|overlaytest|config)
    switch_scene "$cmd" ;;
  toggle-record|rec)        toggle_record ;;
  toggle-stream|stream)     toggle_stream ;;
  status)                   show_status ;;
  list)                     list_scenes ;;
  *)
    printf '%serror:%s unknown command "%s"\n' "$C_MAGENTA" "$C_RESET" "$cmd" >&2
    printf 'commands: %s\n' "${!SCENES[*]} toggle-record toggle-stream status list" >&2
    exit 2 ;;
esac
