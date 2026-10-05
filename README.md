# 🖥️ WebUI3d2d

![](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/media/background.png)

### WebUI3d2d is a library to spawn dynamic and usable WebUIs in the 3D world on nanos world!

## 📘 Docs
[Click here to access the documentation](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/docs.md)

## 🐛 Bug report/Feature request
[If you find a bug or have a feature request you can add it here](https://github.com/Timmy-the-nobody/WebUI3d2d/issues/new/choose)

## 💡 Pull Requests
Your PRs are welcome!
<br> However, in order to keep a clean code base, please follow the [coding conventions](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/coding_conventions.md) that are applied in this resource

## 📑 Features

#### 🔍 Trace control
  - 🖱️ Cursor trace control  
    - If enabled, (and if the cursor is also enabled) the cursor location is translated into a local mouse position on the UI
  - 🎥 Camera trace control
    - If enabled, the camera location and direction are used to emulate a cursor in the 3d space
    - If enabled, a cursor decal is projected on the UI mesh at the trace hit location for easier navigation

#### 🖱️ Mouse input support
  - Mouse move events are sent to the UI
  - LMB/RMB/MMB press and release events are sent to the UI
  - Support simple and multiple (double and triple) clicks
  - Prevent inputs sent to the UI from firing key events not related to a targeted `WebUI3d2d` (can be disabled if needed)

#### 🔠 Key input support
  - Seamless input of characters in text fields
  - Many ASCII chars filtering, allowing for a seamless navigation
  - AZERTY keys support
  - Supports CTRL/Alt/Shift/... CEF key modifiers
  - Uppercase support with Caps lock and Shift modifiers (for A to Z letters)
  - Prevent inputs sent to the UI from firing key events not related to a targeted `WebUI3d2d` (can be disabled if needed)

#### 📜 Scroll support
  - Mouse scroll wheel up/down
  - Middle mouse button drag
  - Page up/down

#### 🔊 Attached 3D sound
  - If used, sounds emitted by the UI will play in the 3d space

#### 🧱 Allows to override the StaticMesh plane used as `WebUI3d2d` parent
  - For instance, you can create a curved UI depending on the mesh you use
  - Optionnaly, you can change the material index used for texture projection on the mesh
  - Automatic interaction range: a WebUI3d2d takes input once it spans a quarter of the view, whatever its scale, distance or the lens
  - On the default plane, the cursor position comes from the hit point when nanos returns no hit UV; other meshes need nanos' hit UVs

#### 🚀 Optimized target lookup
  - The "target lookup" is what handles 3D UI targetting, the cursor location on a targetted UI, and so on..
  - The maximum target lookup calls are made when an UI is already targetted (12 calls per second), otherwise there's only 4 calls per second

#### 🧊 Automatic freezing of the CEF loop work, and the CEF painting
  - This greatly optimizes the game experience when no WebUI3d2d is targeted (or in a decent range)
  - Freeze the page when the mesh stops being rendered
  - Freeze the page when the mesh is out of range from the camera
  - `SetKeepAwake` keeps a page rendering through both, for a page used from further than the freeze range
