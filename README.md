<p align="center"><img src=".github/gmfm-misc-icon.png" width="96" alt="GMFM-Misc"></p>

<h1 align="center">GMFM-Misc</h1>

<p align="center">
An unofficial fork of <a href="https://github.com/DikiyChuvak/GMFM">GM:FM — Garry's Mod Filmmaker</a>, for fixes and experiments.<br>
<b>Right now it is the same as upstream b0.3.</b>
</p>

<p align="center">
<a href="https://github.com/DikiyChuvak/GMFM"><b>Upstream GM:FM</b></a> ·
<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3817852435">GM:FM on the Workshop</a> ·
<a href="https://github.com/T0bycat/GMFM-misc/issues">Issues (this fork)</a> ·
<a href="LICENSE">MIT</a>
</p>

## Nothing different right now

Everything GMFM-Misc added is now part of **GM:FM b0.3**. Thanks to DikiyChuvak for taking it in.

What came from this fork:

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

This branch has the same code as upstream b0.3, so there is no reason to install it instead of the
real thing. **Get GM:FM from the [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3817852435)
or from [DikiyChuvak/GMFM](https://github.com/DikiyChuvak/GMFM)**, and report problems with it there.

**Check back from time to time.** New fixes and experiments will show up here first, and this page
will list what differs from upstream when there is something.

The fork's earlier release stays on the
[`b0.2.6-misc.1`](https://github.com/T0bycat/GMFM-misc/releases/tag/b0.2.6-misc.1) tag.

## Credits

GM:FM is made by [DikiyChuvak](https://github.com/DikiyChuvak). The Simplified Chinese
translation is by [fugui9527121](https://github.com/fugui9527121).

## Русский

GMFM-Misc — неофициальный форк [GM:FM](https://github.com/DikiyChuvak/GMFM) для исправлений и
экспериментов. Всё, что было в форке, вошло в **GM:FM b0.3**, и сейчас эта ветка совпадает с ней.
Ставьте GM:FM из [мастерской Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=3817852435)
или с [DikiyChuvak/GMFM](https://github.com/DikiyChuvak/GMFM). Загляните сюда позже: новые
исправления и эксперименты появятся здесь.

## License / Лицензия

GM:FM's own code and content: [MIT](LICENSE). The bundled skins, sounds and Source Filmmaker
pictures of other authors keep their own terms: [THIRD_PARTY.md](THIRD_PARTY.md).

Собственный код и содержимое GM:FM — [MIT](LICENSE). Встроенные скины, звуки и картинки
Source Filmmaker других авторов остаются на своих условиях: [THIRD_PARTY.md](THIRD_PARTY.md).
