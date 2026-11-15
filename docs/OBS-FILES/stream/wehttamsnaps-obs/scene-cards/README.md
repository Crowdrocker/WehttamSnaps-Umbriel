# wehttamsnaps Scene Cards

Six 1920×1080 scene cards for OBS, all sharing the locked purple→cyan gradient, the camera-aperture logo motif, and the `@wehttamsnaps` footer (with the twitch/youtube/tiktok/x line). No `@yourname` placeholders — every card reads `@wehttamsnaps`.

## Files

| File | Use | Suggested OBS scene |
|------|-----|---------------------|
| `00-starting-soon.png`    | Pre-stream holding screen           | `00 │ Starting Soon` |
| `00-stream-starting.png`  | Alt pre-stream / countdown backdrop | `00 │ Stream Starting` |
| `10-live.png`             | Live ident / "just chatting" bg     | `10 ─ Just Chatting` |
| `20-brb.png`              | Mid-stream break                    | `20 ┊ BRB` |
| `30-ending.png`           | Outro                               | `30 ✦ Ending` |
| `30-offline.png`          | Stream-ended / offline screen       | `30 ✦ Offline` |
| `scene-cards-contact-sheet.png` | 6-up preview (not for broadcast) | — |

## Import into OBS

Each card is used as the **bottom-most image source** in its scene so it sits behind everything else:

1. Open the target scene (e.g. `00 │ Starting Soon`).
2. Add source → **Image**. Name it `[Background] Starting Soon card`.
3. Browse to `00-starting-soon.png`.
4. In the source's Transform (Ctrl+E or right-click → Transform), choose **Fit to screen** so it fills 1920×1080.
5. Drag it to the bottom of the Sources list so overlays/cam render on top.

The included `../scene-collection/wehttamsnaps.json` already wires each card into its scene as the background image source, so if you import the scene collection you do not need to add them manually.

## Consistency note

These cards use the **same** gradient and aperture motif as the stinger (`../stinger/`) and the lower-thirds (`../lower-thirds/`), so a scene switch from a card → live gameplay → stinger → card reads as one coherent brand. The aperture "open fraction" varies per card (more closed = "starting", fully open = "offline") as a subtle visual cue.
