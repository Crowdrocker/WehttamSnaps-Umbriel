#!/usr/bin/env python3
"""
Generate a ready-to-import OBS Scene Collection JSON (OBS 30+ schema, version 2)
for the wehttamsnaps dual-PC stream (AM5 Linux Gaming PC -> Guermok HDMI Capture
Card -> AM4 Windows 11 Streaming PC).

  Scenes:  00 │ Starting Soon, 00 │ Stream Starting, 10 ─ Live,
           10 ─ Just Chatting, 20 ┊ BRB, 20 ┊ Tech Pause,
           30 ✦ Ending, 30 ✦ Offline, 40 ◆ Overlay Test,
           50 ⚙ Config / Never Air
  Sources: [Cam] webcam, [Game] Capture Card, [Background] <card>,
           [Overlay] StreamElements, [Overlay] logo bug,
           [Overlay] chat box, [Overlay] Now Playing,
           [Audio] Desktop / Alerts (WASAPI), Mic/Aux

Outputs: scene-collection/wehttamsnaps.json
"""
import json
import os
import uuid

OUT = os.path.dirname(os.path.abspath(__file__))


def uid():
    return str(uuid.uuid4())


def src(name, kind, settings=None, has_audio=False):
    """A global source definition (shared across scenes)."""
    return {
        "prev_ver": 500606723,
        "name": name,
        "uuid": uid(),
        "id": kind,
        "versioned_id": kind,
        "settings": settings or {},
        "mixers": 1 if has_audio else 0,
        "sync": 0,
        "flags": 0,
        "volume": 1.0,
        "balance": 0.5,
        "deinterlace_field_order": 0,
        "deinterlace_mode": 0,
        "monitoring_type": 0,
        "private_settings": {},
    }


def item(source_name, src_uuid, x, y, visible=True, locked=False, bounds=None,
         scale=None, name=None, align=0):
    """A scene item (placement of a source within a scene)."""
    it = {
        "name": name or source_name,
        "source_uuid": src_uuid,
        "visible": visible,
        "locked": locked,
        "rot": 0.0,
        "pos": {"x": float(x), "y": float(y)},
        "scale": scale or {"x": 1.0, "y": 1.0},
        "align": align,  # 0=top-left, 5=center
        "bounds_type": 0,
        "bounds": {"x": 0.0, "y": 0.0},
        "crop_left": 0,
        "crop_top": 0,
        "crop_right": 0,
        "crop_bottom": 0,
        "group_item_backup": False,
        "order_alignment": 0,
        "blend_method": "default",
        "blend_type": "normal",
        "show_transition": {"duration": 300},
        "hide_transition": {"duration": 300},
        "private_settings": {},
    }
    if bounds:
        it["bounds_type"] = bounds.get("type", 2)
        it["bounds"] = {"x": float(bounds["x"]), "y": float(bounds["y"])}
    return it


def scene(name, items):
    """A scene (a source of id 'scene' that holds scene_items)."""
    s_uuid = uid()
    return s_uuid, {
        "prev_ver": 500606723,
        "name": name,
        "uuid": s_uuid,
        "id": "scene",
        "versioned_id": "scene",
        "settings": {
            "id_counter": len(items),
            "items": items,
            "custom_size": False,
        },
        "mixers": 0,
        "sync": 0,
        "flags": 0,
        "volume": 1.0,
        "balance": 0.5,
        "deinterlace_field_order": 0,
        "deinterlace_mode": 0,
        "monitoring_type": 0,
        "private_settings": {},
    }


# ---- Shared / global sources ----
S = {}

# Scene background cards
S["bg_starting"] = src("[Background] Starting Soon card", "image_input", {
    "file": "../scene-cards/00-starting-soon.png"})
S["bg_streamstart"] = src("[Background] Stream Starting card", "image_input", {
    "file": "../scene-cards/00-stream-starting.png"})
S["bg_brb"] = src("[Background] BRB card", "image_input", {
    "file": "../scene-cards/20-brb.png"})
S["bg_techpause"] = src("[Background] Tech Pause card", "image_input", {
    "file": "../scene-cards/20-brb.png"})
S["bg_ending"] = src("[Background] Ending card", "image_input", {
    "file": "../scene-cards/30-ending.png"})
S["bg_offline"] = src("[Background] Offline card", "image_input", {
    "file": "../scene-cards/30-offline.png"})
S["bg_overlaytest"] = src("[Background] Overlay Test card", "image_input", {
    "file": "../scene-cards/10-live.png"})

# Windows DirectShow Webcam
S["cam"] = src("[Cam] webcam", "dshow_input", {
    "video_device_id": "REPLACE_ME_pick_webcam",
    "resolution": "1280x720",
    "frame_interval": 333333,  # 30 FPS
    "res_type": 1,
})

# Windows DirectShow Guermok USB 3.0 HDMI Capture Card (carries video + HDMI audio)
S["game"] = src("[Game] Capture Card", "dshow_input", {
    "video_device_id": "REPLACE_ME_pick_USB_Video_capture_card",
    "resolution": "1920x1080",
    "frame_interval": 166666,  # 60 FPS
    "res_type": 1,
    "audio_output_mode": 0,  # Capture audio only
    "use_custom_audio_device": True,
    "audio_device_id": "REPLACE_ME_pick_Digital_Audio_Interface",
}, has_audio=True)

# Browser Overlays (StreamElements / Streamlabs)
S["se_overlay"] = src("[Overlay] StreamElements", "browser_source", {
    "url": "REPLACE_ME_streamelements_overlay_url",
    "width": 1920,
    "height": 1080,
    "reroute_audio": False,
    "shutdown": False,
    "css": "",
})

S["chat_box"] = src("[Overlay] chat box", "browser_source", {
    "url": "REPLACE_ME_streamelements_chatbox_url",
    "width": 500,
    "height": 600,
    "reroute_audio": False,
    "shutdown": False,
    "css": "",
})

S["now_playing"] = src("[Overlay] Now Playing", "browser_source", {
    "url": "REPLACE_ME_streamelements_nowplaying_url",
    "width": 800,
    "height": 120,
    "reroute_audio": False,
    "shutdown": False,
    "css": "",
})

S["logo_bug"] = src("[Overlay] logo bug", "image_input", {
    "file": "../logo-overlay/wehttamsnaps-logo-cam-bug.png"})

# Windows WASAPI Audio Sources (Desktop/Alerts on Windows + Mic)
S["aud_desktop"] = src("[Audio] Windows Desktop & Alerts", "wasapi_output_capture", {
    "device_id": "default"}, has_audio=True)

S["mic"] = src("Mic/Aux", "wasapi_input_capture", {
    "device_id": "default"}, has_audio=True)


def cam_pos(size=320, margin=40, corner="bl"):
    x = margin if "l" in corner else 1920 - size - margin
    y = 1080 - size - margin
    return x, y


def logo_pos(cam_x, cam_y, cam_size, badge_size=80, pad=10):
    """Place an 80x80 logo badge inside the bottom-right corner of the webcam frame."""
    return cam_x + cam_size - badge_size - pad, cam_y + cam_size - badge_size - pad


# ---- Build scene item lists (ordered top-to-bottom in OBS source stack) ----
cam_size = 320
badge_size = 80
cx, cy = cam_pos(cam_size, margin=40, corner="bl")
lx, ly = logo_pos(cx, cy, cam_size, badge_size=badge_size, pad=10)

items_live = [
    item("StreamElements overlay", S["se_overlay"]["uuid"], 0, 0,
         bounds={"type": 2, "x": 1920, "y": 1080}),
    item("Now Playing", S["now_playing"]["uuid"], 1920 - 840, 1080 - 160,
         visible=False),
    item("chat box", S["chat_box"]["uuid"], 1920 - 540, 40, visible=False),
    item("logo bug", S["logo_bug"]["uuid"], lx, ly,
         bounds={"type": 2, "x": badge_size, "y": badge_size}),
    item("webcam", S["cam"]["uuid"], cx, cy,
         bounds={"type": 2, "x": cam_size, "y": cam_size}),
    item("Capture Card", S["game"]["uuid"], 0, 0,
         bounds={"type": 2, "x": 1920, "y": 1080}),
    item("Windows Desktop & Alerts", S["aud_desktop"]["uuid"], 0, 0, visible=True),
    item("Mic/Aux", S["mic"]["uuid"], 0, 0, visible=True),
]

cam_jc = 540
cx_jc, cy_jc = 40, 540 - cam_jc // 2
lx_jc, ly_jc = logo_pos(cx_jc, cy_jc, cam_jc, badge_size=100, pad=12)

items_justchat = [
    item("StreamElements overlay", S["se_overlay"]["uuid"], 0, 0,
         bounds={"type": 2, "x": 1920, "y": 1080}),
    item("Now Playing", S["now_playing"]["uuid"], 1920 - 840, 1080 - 160),
    item("chat box", S["chat_box"]["uuid"], 1280, 40),
    item("logo bug", S["logo_bug"]["uuid"], lx_jc, ly_jc,
         bounds={"type": 2, "x": 100, "y": 100}),
    item("webcam", S["cam"]["uuid"], cx_jc, cy_jc,
         bounds={"type": 2, "x": cam_jc, "y": cam_jc}),
    item("Windows Desktop & Alerts", S["aud_desktop"]["uuid"], 0, 0, visible=True),
    item("Mic/Aux", S["mic"]["uuid"], 0, 0, visible=True),
]


def card_scene_items(bg_src):
    return [
        item("background card", bg_src["uuid"], 0, 0,
             bounds={"type": 2, "x": 1920, "y": 1080}),
    ]


scene_order = [
    ("00 │ Starting Soon", card_scene_items(S["bg_starting"])),
    ("00 │ Stream Starting", card_scene_items(S["bg_streamstart"])),
    ("10 ─ Live", items_live),
    ("10 ─ Just Chatting", items_justchat),
    ("20 ┊ BRB", card_scene_items(S["bg_brb"])),
    ("20 ┊ Tech Pause", card_scene_items(S["bg_techpause"])),
    ("30 ✦ Ending", card_scene_items(S["bg_ending"])),
    ("30 ✦ Offline", card_scene_items(S["bg_offline"])),
    ("40 ◆ Overlay Test", card_scene_items(S["bg_overlaytest"])),
]

scene_objs = []
current_scene = "00 │ Starting Soon"
for nm, itms in scene_order:
    suuid, sc = scene(nm, itms)
    scene_objs.append((suuid, sc))

suuid_cfg, sc_cfg = scene("50 ⚙ Config / Never Air", [])
scene_objs.append((suuid_cfg, sc_cfg))

collection = {
    "current_scene": current_scene,
    "current_program_scene": current_scene,
    "scene_order": [nm for nm, _ in scene_order] + ["50 ⚙ Config / Never Air"],
    "sources": [s for s in S.values()] + [sc for _, sc in scene_objs],
    "groups": [],
    "transitions": [
        {
            "name": "wehttamsnaps stinger",
            "id": "obs_transition_stinger",
            "settings": {
                "path": "../stinger/wehttamsnaps-stinger.webm",
                "transition_point_type": "time",
                "transition_point": 1000,
                "volume": 1.0,
                "track_media": False,
                "track_media_size": 2,
            },
        },
        {"name": "Cut", "id": "cut_transition", "settings": {}},
        {"name": "Fade", "id": "fade_transition", "settings": {"duration": 500}},
    ],
    "name": "wehttamsnaps",
    "collection_paths": [],
}

top = {
    "version": "2.0",
    "name": "wehttamsnaps",
    "serialization": "OBS",
    "file_format_version": "2.0",
    "scene_collection": collection,
}

out_path = os.path.join(OUT, "wehttamsnaps.json")
with open(out_path, "w", encoding="utf-8") as f:
json.dump(top, f, indent=2, ensure_ascii=False)
with open(out_path, encoding="utf-8") as f:
chk = json.load(f)
print("wrote wehttamsnaps.json")
print(f"  scenes: {len(chk['scene_collection']['scene_order'])}")
print(f"  sources: {len(chk['scene_collection']['sources'])}")
print(f"  transitions: {len(chk['scene_collection']['transitions'])}")
print(f"  current scene: {chk['scene_collection']['current_scene']}")
