<p align="center"><img src=".github/gmfm-misc-icon.png" width="96" alt="GMFM-Misc"></p>

<h1 align="center">GMFM-Misc</h1>

<p align="center">
An unofficial fork of <a href="https://github.com/DikiyChuvak/GMFM">GM:FM — Garry's Mod Filmmaker</a>, for fixes and experiments.<br>
<b>Upstream b0.3, plus the few changes listed below.</b>
</p>

<p align="center">
<a href="https://github.com/DikiyChuvak/GMFM"><b>Upstream GM:FM</b></a> ·
<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3817852435">GM:FM on the Workshop</a> ·
<a href="https://github.com/T0bycat/GMFM-misc/issues">Issues (this fork)</a> ·
<a href="LICENSE">MIT</a>
</p>

## What's different from upstream b0.3

- **SFM models:** faces built for Source Filmmaker split many sliders into a right and a left half
  (`right_CloseLid` / `left_CloseLid`, sometimes `multi_CloseLid`). The Animation Set Editor now
  shows such a set under its shared name, right in red and left in green, and the timeline keeps
  the halves together. The face groups also know the HL2 / L4D slider names (`inner_raiser`,
  `lowerer`, `wrinkler`, `corner_puller`, …), which used to land in Other.
- **Help → How to use… → SFM models:** two ways to get SFM models into the game: copy them into an
  addon folder, or mount SFM's folders through `garrysmod/cfg/mount.cfg` (with the path to use
  under Proton).
- **Fix:** opening the File menu threw an error and left the menu half built. Sent upstream as
  [DikiyChuvak/GMFM#3](https://github.com/DikiyChuvak/GMFM/pull/3).

If you only want the stable release, **get GM:FM from the
[Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3817852435) or from
[DikiyChuvak/GMFM](https://github.com/DikiyChuvak/GMFM)**. Report problems with this fork's changes
in its [issues](https://github.com/T0bycat/GMFM-misc/issues).

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

## Already in upstream

Everything the fork added before is part of **GM:FM b0.3**. Thanks to DikiyChuvak for taking it in.

- **Linux:** SSAO and film grain no longer crash the native Linux game; `gmfm_shadertest` and
  `gmfm_rendertest`.
- **Timeline:** a track opens out into a row per bone, face slider or attribute, with bones grouped
  by body part; box-select keys, **X** to delete them, scrub on the frame numbers.
- **Auto key:** keys only what changed (bones, sliders, camera / light attributes), and the
  editors handle these partial keys.
- **Finger Poser:** in the controls when a hand or finger is selected, with Curl and presets; with
  IK on, a fingertip bends the whole finger.
- **Auto pose:** drag a hand, foot, the hips, chest or head and the body follows, with planted
  feet and hands staying put.
- **Performance:** playback of per-bone keys about 10× lighter on the server; `gmfm_prof` profiler.
- **Fixes:** the Secondary Viewport's camera can be flown; undo steps not split by a pause; Graph
  Editor keys of one bone no longer take the others'; the model browser no longer freezes on
  large models; the editor follows a change of resolution.

The fork's earlier release stays on the
[`b0.2.6-misc.1`](https://github.com/T0bycat/GMFM-misc/releases/tag/b0.2.6-misc.1) tag.

## Credits

GM:FM is made by [DikiyChuvak](https://github.com/DikiyChuvak). The Simplified Chinese
translation is by [fugui9527121](https://github.com/fugui9527121).

## Русский

GMFM-Misc — неофициальный форк [GM:FM](https://github.com/DikiyChuvak/GMFM) для исправлений и
экспериментов. Всё, что было в форке раньше, вошло в **GM:FM b0.3**. Сейчас поверх b0.3 здесь есть:
ползунки лица моделей SFM, сгруппированные по половинам (правая — красным, левая — зелёным),
справка «Модели SFM» (как добавить модели SFM в игру) и исправление ошибки при открытии меню
«Файл». Стабильную версию ставьте из [мастерской Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=3817852435)
или с [DikiyChuvak/GMFM](https://github.com/DikiyChuvak/GMFM).

## License / Лицензия

GM:FM's own code and content: [MIT](LICENSE). The bundled skins, sounds and Source Filmmaker
pictures of other authors keep their own terms: [THIRD_PARTY.md](THIRD_PARTY.md).

Собственный код и содержимое GM:FM — [MIT](LICENSE). Встроенные скины, звуки и картинки
Source Filmmaker других авторов остаются на своих условиях: [THIRD_PARTY.md](THIRD_PARTY.md).
