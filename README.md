<p align="center"><img src="materials/speditor/icon128.png" width="96" alt="GM:FM"></p>

<h1 align="center">GMFM-Misc</h1>

<p align="center">
Random improvements to <a href="https://github.com/DikiyChuvak/GMFM">GM:FM — Garry's Mod Filmmaker</a>.<br>
An unofficial fork of DikiyChuvak/GMFM, based on b0.2.6. Current version: <b>b0.2.6-misc.1</b>.
</p>

<p align="center">
<a href="https://github.com/T0bycat/GMFM-misc/issues"><b>Issues (this fork)</b></a> ·
<a href="https://github.com/DikiyChuvak/GMFM">Upstream GM:FM</a> ·
<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3817852435">Original on the Workshop</a> ·
<a href="LICENSE">MIT</a>
</p>

<p align="center"><img src="materials/speditor/help/overview.jpg" alt="GM:FM editor"></p>

GM:FM is DikiyChuvak's scene, animation and film editor for Garry's Mod, close to a full port
of Source Filmmaker. GMFM-Misc takes it as a base and adds fixes and features as they come
up: Linux support, the timeline, auto key, posing. It is **not** the Workshop version, and the
upstream author doesn't support it. Report problems with it
[here](https://github.com/T0bycat/GMFM-misc/issues), not upstream.

How to use the editor is explained inside the game: **Help → How to use**.

## What's different from upstream

### Linux

> **On Linux, we recommend running Garry's Mod through Proton.** In Steam, right-click Garry's
> Mod → Properties → Compatibility → *Force the use of a specific Steam Play compatibility tool*,
> and pick a Proton version. The game then runs its Windows build, and GM:FM's effects look as
> they do on Windows. The native Linux game works with the fixes below, but small rendering
> differences remain that make some shots look off.

- SSAO and film grain no longer close the game. The shaders were rebuilt without the branches
  the Linux shader translation refused.
- The render targets the Linux game can't draw to were replaced: SSAO reads depth packed into
  8-bit passes, and the shaders also ship under a second name that the Linux game loads.
- SSAO depth on Linux is smoothed without banding on most surfaces. Floors seen at a grazing
  angle can still show faint bands.
- `gmfm_shadertest` and `gmfm_rendertest` test the editor's shaders and render targets one by one.
- On native Linux the editor says once, when it opens, that Proton looks best (OK / Don't warn me
  again; `gmfm_linux_notice 0` turns it off).

### Timeline
- Double-click a track to open it out into a row per moving bone, face slider, or camera /
  light / effect attribute (FOV, colour…). A key dragged on one of those rows moves only that part.
- Drag over empty space to box-select keys (no Shift needed). **X** deletes the selected keys.
- Press and drag on the frame numbers to scrub the playhead.

### Auto key
- Keys only what you changed: the moved bones, the edited face sliders, the camera's or
  light's edited attribute.
- A slider is keyed as soon as you let it go. A camera field edit is no longer lost to the next
  edit, and an edit is keyed at its own frame even if you scrub right after it.
- A camera's **Record moves** no longer sets a key when playback pauses.
- The editors work with these partial keys: the Graph Editor draws and edits each channel
  between the keys that hold it, and the Motion Editor, presets and Camera Smooth handle them too.
- The Bone keys toggle is gone: **K** always keys the whole pose. A single bone's key is on its
  row's right-click menu.

### Fingers
- Select a hand or a finger bone and the Finger Poser shows at the top of the controls: GMod's
  hand picture and values, a Curl slider, and presets (Flat, Point, Fist, Thumbs up, mirror,
  other hand). Hands are found by GMod Finger Poser's bone names (HL2, TF2 / SFM, Portal…) or by
  the bone tree.
- With IK on, moving a finger's last joint bends the whole finger; several finger joints selected
  bend together.

### Auto pose
- **Auto pose** (the button next to IK on the viewport bar, or `gmfm_autopose`): pull a ragdoll's hand past the arm's reach and the
  body follows. The torso bends and turns toward the hand, then the body steps along the floor
  or down into a crouch. Planted feet and hands stay where they are.
- `gmfm_autopose_follow 0..1` sets how much the body follows. Right-click IK or Auto pose for
  one menu with IK, Auto pose, feet planted and hands planted.

### Viewports
- Right / middle / Alt navigation in the Secondary Viewport flies the camera it shows, keyed
  as in the Primary.

### Fixes
- A pause in the middle of a drag no longer splits one edit into two undo steps.
- Graph Editor: deleting or moving a key on one bone's curves no longer takes every bone's key
  at that frame.
- Lights and effects edited by their sliders: auto key keys only the attributes that changed.
- A scene keeps the map's sounds muted; the gizmo's World button no longer looks off at first.
- Help → Report a problem and the About window lead to this fork's GitHub, not upstream.

## Install

1. Unsubscribe from GM:FM on the Workshop. Two copies of the addon clash.
2. Clone this repository into `garrysmod/addons/` as a folder called **`speditor`**. The name
   matters, because the shaders and themes are looked for there:

   ```
   cd "<Steam>/steamapps/common/GarrysMod/garrysmod/addons"
   git clone https://github.com/T0bycat/GMFM-misc.git speditor
   ```

3. Start Garry's Mod. In Sandbox: C menu → GM:FM, or `gmfm_toggle`. For the gamemode: Start New
   Game → **GM:FM**.

Lua autorefresh works for the files in `lua/`. A new file is picked up after
`lua/autorun/speditor_init.lua` is touched.

## What is where

| Path | What |
|---|---|
| `lua/autorun/speditor_init.lua` | loads everything: the lists `SHARED`, `SERVER_FILES`, `CLIENT_FILES` |
| `lua/speditor/sh_*.lua` | shared: settings (`sh_config`), languages (`sh_lang`), errors and reports, components |
| `lua/speditor/sv_*.lua` | server: objects, scenes, adopting map objects, PAC3, the Environment, the gamemode |
| `lua/speditor/cl_*.lua` | client: camera, gizmo, IK and auto pose, rig, render (`cl_render`, `cl_export`, `cl_ssao`, `cl_postfx`), lights, effects, the interface (`cl_ui_*`), guides, self-test |
| `lua/speditor/saeditor/` | SAeditor, the animation component: tracks and keys, timeline, graph editor, sounds and lip sync, recorder, video |
| `lua/speditor/skins/` | Derma skins of the themes (GM:FM UI is `sfm.lua`) |
| `lua/entities/` | the editor's lights, cameras and effects |
| `gamemodes/gmfm/` | the GM:FM gamemode |
| `materials/`, `sound/`, `data_static/` | pictures, interface sounds, example scenes |
| `shaders_src/` → `shaders/fxc/` | HLSL sources of the SSAO, grain and colour correction shaders and their compiled `.vcs` (`shaders_src/build_vcs.py`; compile with `fxc /T ps_2_b`) |
| `tools/` | `build_gma.py` (the addon package), picture generators |

### Build a package

`python3 tools/build_gma.py out.gma` writes the GMA itself (the game's Linux `gmad` refuses
`shaders/fxc/*.vcs`), skipping what `addon.json` → `ignore` lists.

## Contributing

Issues and pull requests for this fork go to
[T0bycat/GMFM-misc](https://github.com/T0bycat/GMFM-misc). For the official GM:FM, see
[DikiyChuvak/GMFM](https://github.com/DikiyChuvak/GMFM) and its
[Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3817852435).

## Credits

GM:FM is made by [DikiyChuvak](https://github.com/DikiyChuvak). The Simplified Chinese
translation is by [fugui9527121](https://github.com/fugui9527121). GMFM-Misc only adds to their work.

## Русский

GMFM-Misc — неофициальный форк [GM:FM](https://github.com/DikiyChuvak/GMFM) (на основе
b0.2.6) с разными исправлениями и дополнениями. Это не версия из мастерской Steam. Об ошибках
этого форка пишите [сюда](https://github.com/T0bycat/GMFM-misc/issues), а не автору GM:FM.
Полное описание на русском — в [README оригинала](https://github.com/DikiyChuvak/GMFM#русский).

## License / Лицензия

GM:FM's own code and content: [MIT](LICENSE). The bundled skins, sounds and Source Filmmaker
pictures of other authors keep their own terms: [THIRD_PARTY.md](THIRD_PARTY.md).

Собственный код и содержимое GM:FM — [MIT](LICENSE). Встроенные скины, звуки и картинки
Source Filmmaker других авторов остаются на своих условиях: [THIRD_PARTY.md](THIRD_PARTY.md).
