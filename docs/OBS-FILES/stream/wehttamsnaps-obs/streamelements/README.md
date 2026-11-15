# wehttamsnaps — StreamElements Overlay Package

A self-contained, brand-themed overlay package for OBS. Two ways to use it:

1. **Self-hosted (this package)** — point OBS Browser sources at the local HTML
   files. No StreamElements account needed. Good for offline tests and full
   control.
2. **StreamElements-hosted** — upload `theme.css` + the widget HTML to
   StreamElements as Custom Widgets, then paste the SE widget URLs into OBS.
   Good for live alert logic (follow/sub/tip events) without writing a backend.

Either way, the look is identical: purple→cyan neon gradient, magenta accent,
`@wehttamsnaps` tag, aperture-disc motifs, Orbitron type.

## Files

| File | What | OBS source size |
|------|------|-----------------|
| `index.html` | All-in-one overlay scene (alerts + chat + now playing + follow + logo). Use as a single Browser source. | 1920×1080 |
| `alerts.html` | Follow / Sub / Tip alert (demo-cycles; wire to SE events for live). | 800×200 |
| `chat-box.html` | Themed chat box (demo messages; skin SE's live chat widget with the CSS). | 520×600 |
| `now-playing.html` | Now Playing bar with spinning aperture disc. `?track=...&sub=...` or SE data. | 1000×100 |
| `dock.html` | **Custom dock** — Twitch popout chat + live viewer/uptime stats. Load via View → Docks → Custom Browser Docks. | (docked) |
| `theme.css` | Shared brand variables + `.neon-bar` / `.tag` helpers. | — |
| `overlay.js` | Brand helper + StreamElements event bridge (`window.SE_EVENT`). | — |

## OBS import — quick start (self-hosted)

1. Keep the `wehttamsnaps-obs/` folder in one place (e.g.
   `~/stream/wehttamsnaps-obs/`). All HTML uses **relative** links to
   `theme.css`, `overlay.js`, and the rendered PNGs, so don't split the folder.
2. In your `10 ─ Live` scene: Sources → **+ → Browser** → name
   `[Overlay] StreamElements` → **Local file** → browse to
   `streamelements/index.html` → width `1920`, height `1080`.
3. Done — you'll see alerts, chat, now playing, the follow CTA, and the logo
   bug all positioned. Remove the `preview` class on `<body>` in `index.html`
   to hide the faint zone labels.
4. For finer control, use the **individual** widget files as separate Browser
   sources instead of the all-in-one `index.html`. (The Scene Collection JSON
   already wires separate sources — see `scene-collection/README.md`.)

## Custom dock (the "OBS has no custom dock" answer)

OBS **does** have custom docks — they're called **Browser Docks**:

1. OBS → **View → Docks → Custom Browser Docks**.
2. Click **+**, name it `wehttamsnaps Chat`, URL = the absolute path to
   `dock.html` (e.g. `file:///home/you/stream/wehttamsnaps-obs/streamelements/dock.html`).
3. A dockable panel appears with the Twitch popout chat for
   `wehttamsnaps` + live viewer count and uptime. Drag it anywhere — tab it
   with the Chat/Stats docks, snap it to the side, float it on a second monitor.
4. To change the channel, edit the `<iframe src="...">` in `dock.html`.

`dock.html` embeds `https://www.twitch.tv/popout/wehttamsnaps/chat?popout=` —
the canonical Twitch popout chat URL. Viewer count / uptime come from DecAPI
(best-effort; if CORS blocks it the chat still works and the stats read "—").
For guaranteed-accurate stats, call obs-websocket `GetStreamStatus` from the
`scene-switcher.sh status` command instead.

## Going live with StreamElements (real alerts)

1. Create a StreamElements account, link your Twitch.
2. **My Overlays → New Overlay → Blank**. Add widgets:
   - **Alert Box** (follow/sub/tip/raid) → paste `theme.css` into its Custom CSS.
   - **Chat Box** → paste the `#chat .msg` CSS from `chat-box.html`.
   - **Now Playing** (Spotify/Last.fm) → paste `theme.css`.
3. Each widget has a **widget URL** like
   `https://streamelements.com/overlay/abc123/...`. Copy those URLs.
4. In OBS, replace the Local-file Browser sources with those URLs (or paste
   them into the Scene Collection JSON's `REPLACE_ME_streamelements_*` fields).

`overlay.js` exposes `window.SE_EVENT(data)` and `WS.on(type, fn)` so if you
upload these files as a **Custom Widget**, SE fires alert events into the
bridge and `alerts.html`'s `.type/.who/.msg` spans get populated live.

## Theming

All colours live in `theme.css` `:root`:

```css
--purple:  #8A2BE2;
--cyan:    #00E5FF;
--magenta: #FF46B4;
```

Change those three lines and every widget updates. The `.neon-bar` class gives
any element the purple→cyan gradient bar with a magenta top accent; `.tag`
gives the glowing `@wehttamsnaps` style.
