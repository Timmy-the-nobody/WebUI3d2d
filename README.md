# 🖥️ WebUI3d2d

![](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/media/background.png)

### WebUI3d2d is a library to spawn dynamic WebUIs in world space on nanos world!

## 📘 Docs
[Click here to access the documentation](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/docs.md)

## 🐛 Bug report/Feature request
[If you find a bug or have a feature request you can add it here](https://github.com/Timmy-the-nobody/WebUI3d2d/issues/new/choose)

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
  - Prevent inputs sent to the UI from firing key events not related to a targeted `WebUI3d2d`

#### 🔠 Key input support
  - Seamless input of characters in text fields
  - Many ASCII chars filtering, allowing for a seamless navigation
  - AZERTY keys support
  - Supports CTRL/Alt/Shift/... CEF key modifiers
  - Uppercase support with Caps lock and Shift modifiers (for A to Z letters)
  - Prevent inputs sent to the UI from firing key events not related to a targeted `WebUI3d2d`

#### 📜 Scroll support
  - Mouse scroll wheel up/down
  - Middle mouse button drag
  - Page up/down

#### 🎥 Camera focus
  - You can make the player camera focus a WebUI3d2d, and make navigation even easier

#### 🔊 Attached 3D sound
  - If used, sounds emitted by the UI will play in the 3d space

#### 🧱 Allows to override the plane StaticMesh used as `WebUI3d2d` parent
  - For instance, you can create a curved UI depending on the mesh you use
  - Optionnaly, you can change the material index used for texture projection on the mesh
  - Automatic interract distance, depending on the WebUI3d2d mesh scale

#### 🚀 Optimized target lookup
  - The "target lookup" is what handles 3D UI targetting, the cursor location on a targetted UI, and so on..
  - The maximum target lookup call are made when an UI is already targetted (12FPS), otherwise there's only 2 calls per second

#### 🧊 Automatic freezing of the CEF loop work, and the CEF painting
  - This greatly optimizes the game experience when no WebUI3d2d is targeted (or in a decent range)
  - Freeze the page when the mesh stops being rendered
  - Freeze the page when the mesh is out of range from the camera
