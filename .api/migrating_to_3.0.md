[ᐊ Return to docs](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/docs.md)

[`WebUI3d2dTargeting`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#webui3d2dtargeting
[`WebUI3d2dInput`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#webui3d2dinput
[`WebUI3d2dKeyboardCapture`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#webui3d2dkeyboardcapture

# Migrating from 2.x to 3.0

3.0 renames the input settings after who gets the input, and replaces pairs of switches with enums. The 2.x methods are removed: a script still calling one fails with `attempt to call a nil value` when that line runs, so search your scripts for every 2.x name below.

## Constructor
The constructor takes what the page needs at creation; the plane's size moved to a method, and the 3D sound to your script:

| 2.x | 3.0
| - |:-
| `WebUI3d2d(sPath, bTransparent, iW, iH, tScale, bAttach3DSound, sMesh, iMatIndex)` | `WebUI3d2d(sURL, tResolution, bTransparent, sMesh, iMaterialIndex)`
| `iW`, `iH` | `tResolution`, a `Vector2D` (`1920`, `1080` is `Vector2D(1920, 1080)`)
| `tScale` on the default plane | `SetPlaneSize(tSize)`, in centimetres (`Vector(1.92, 1.08, 1)` is `Vector2D(192, 108)`)
| `tScale` on another mesh | `SetScale(tScale)`
| `bAttach3DSound` | WebUI's own `SpawnSound`, attached to the mesh (below)

Without a size, the default plane is sized from the resolution, 10 pixels per centimetre, so the page isn't stretched (2.x made a 240 x 240 page when it got no resolution). The mesh can also change later, in place, with `SetMesh(sMesh, iMaterialIndex)`.

2.x's `bAttach3DSound` played the page's audio from the mesh, at full volume within the mesh's size and silent at 8 times it. Your script now spawns that sound itself, so it picks 2D or 3D and the ranges. The 2.x behaviour:
```lua
local fRadius = my_webui:GetBounds().BoxExtent:Size()
local my_sound = my_webui:SpawnSound(Vector(), false, 1, fRadius, (fRadius * 8))
my_sound:AttachTo(my_webui:GetStaticMesh(), AttachmentRule.SnapToTarget, "", 0, false)
```

The `0` in `AttachTo` destroys the sound along with the mesh, as 2.x did on its own: without it, every destroyed WebUI3d2d leaves its sound behind. For a page heard like a menu instead (by the player holding a handheld screen, say), pass `true` as `SpawnSound`'s second argument for a 2D sound, and keep the `AttachTo` line for the cleanup. [`SpawnSound`](https://docs.nanos-world.com/docs/scripting-reference/classes/webui#function-spawnsound) lists its other parameters: volume, ranges and attenuation.

## Renamed methods

| 2.x | 3.0
| - |:-
| `SetCursorTraceControl(b)`, `SetCameraTraceControl(b)` | `SetTargeting(iTargeting)`
| `IsCursorTraceControlEnabled()`, `IsCameraTraceControlEnabled()` | `GetTargeting()`
| `SetKeyboardEventsEnabled(b)`, `SetMouseEventsEnabled(b)` | `SetBlockedGameInput(iInputs)`
| `IsKeyboardEventsEnabled()`, `IsMouseEventsEnabled()` | `GetBlockedGameInput()`
| `SetKeyboardInputEnabled(b)` | `SetKeyboardCapture(iMode)`
| `IsKeyboardInputEnabled()` | `GetKeyboardCapture()`
| `SetCursorSize(f)`, `GetCursorSize()` | `SetCursorDecalSize(f)`, `GetCursorDecalSize()`
| `SetReloadOnFail(b)`, `ShouldReloadOnFail()` | `SetReloadOnFailEnabled(b)`, `IsReloadOnFailEnabled()`
| `GetAttachedSound()` | Removed: keep the Sound `SpawnSound` returns (see Constructor)
| `OnFail`, `OnReady`, `OnDestroy`, `ReloadPage` | Removed. Subscribe to the WebUI's own `Fail`, `Ready` and `Destroy` events, and call `LoadURL` to reload

## Targeting
The two trace controls are now one [`WebUI3d2dTargeting`] flags value:

| 2.x | 3.0
| - |:-
| Both on (default) | `SetTargeting(WebUI3d2dTargeting.All)` (default)
| `SetCameraTraceControl(false)` | `SetTargeting(WebUI3d2dTargeting.Cursor)`
| `SetCursorTraceControl(false)` | `SetTargeting(WebUI3d2dTargeting.Camera)`
| Both off | `SetTargeting(WebUI3d2dTargeting.None)`

A WebUI3d2d the cursor can target only while it's usable:
```lua
my_webui:SetTargeting(bUsable and WebUI3d2dTargeting.Cursor or WebUI3d2dTargeting.None)
```

## Game input
The 2.x "events" switches said what the game still gets while a WebUI3d2d is targeted. `SetBlockedGameInput` takes the opposite, what the game loses, as [`WebUI3d2dInput`] flags. A call has to be flipped, not just renamed:

| 2.x | 3.0
| - |:-
| Neither (default) | `SetBlockedGameInput(WebUI3d2dInput.All)` (default)
| `SetKeyboardEventsEnabled(true)` | `SetBlockedGameInput(WebUI3d2dInput.Mouse)`
| `SetMouseEventsEnabled(true)` | `SetBlockedGameInput(WebUI3d2dInput.Keyboard)`
| Both | `SetBlockedGameInput(WebUI3d2dInput.None)`

## Keyboard
In 2.x, a WebUI3d2d took the keyboard as soon as it was targeted, so looking at one while walking past swallowed the movement keys. In 3.0 it captures the keyboard from a click on it until it's untargeted or Escape is pressed, and game keys are only blocked while it does ([`WebUI3d2dKeyboardCapture`]):

| 2.x | 3.0
| - |:-
| `SetKeyboardInputEnabled(true)` (default) | `SetKeyboardCapture(WebUI3d2dKeyboardCapture.OnClick)` (default), or `WebUI3d2dKeyboardCapture.Always` to keep the 2.x behaviour
| `SetKeyboardInputEnabled(false)` | `SetKeyboardCapture(WebUI3d2dKeyboardCapture.Off)`

## Cursor decal
- It's now a small plane laid on the mesh rather than a decal: nanos' WebUI material takes no decals, so the 2.x decal doesn't show on a page. `GetCursorDecal()` returns a StaticMesh
- The cursor no longer hides itself while the mouse is enabled. Call `SetCursorDecalEnabled(false)` on a WebUI3d2d used with the mouse, whose cursor already marks the spot
- It's created on the first cursor move over the targeted WebUI3d2d, so `GetCursorDecal()` returns `nil` until then

## Other changes
- Instance fields are internal now, prefixed with `__` (`my_webui.mesh` is `my_webui.__mesh`). Read them through the methods: `GetStaticMesh()`, `GetCursorDecal()` and the other getters, nanos' own `IsReady()` and `GetSize()` for `ready`, `width` and `height`, and the new `GetURL()` (`path`), `GetMaterialIndex()` (`material_index`) and `GetCursorPosition()` (`cursor_x`, `cursor_y`)
- A WebUI3d2d takes input once its `GetScreenPercentage()` reaches 0.5, about a quarter of the view at a 90° FOV. nanos scales it with the lens angle, so with a narrow lens it asks a little more than 2.x's quarter of the view
- Pages now get key-up events. 2.x only sent them when the WebUI3d2d was untargeted, so a page listening for `keyup` missed most keys
- The mesh's material parameters default to Roughness `0` (2.x: `1`) and Emissive `0` (2.x: `0.2`). `my_webui:GetStaticMesh():SetMaterialScalarParameter("Roughness", 1)` and `SetMaterialColorParameter("Emissive", Color(0.2))` restore them
- The mesh no longer casts shadows. `my_webui:GetStaticMesh():SetCastShadow(true)` restores it
- New event `OnWebUI3d2dFreezeChange(oWebUI, bFrozen)`: a frozen page keeps running its JavaScript, so a script can forward this to its page to pause animations and timers
