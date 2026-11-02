[ᐊ Return to docs](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/docs.md)

[boolean]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#boolean
[number]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#number
[string]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#string
[table]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#table
[integer]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#integer
[float]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#float
[Vector]:https://docs.nanos.world/docs/scripting-reference/structs/vector
[Rotator]:https://docs.nanos.world/docs/scripting-reference/structs/rotator
[Vector2D]:https://docs.nanos.world/docs/scripting-reference/structs/vector2d
[HTML Path]:https://docs.nanos.world/docs/next/scripting-reference/classes/webui#html-path-searchers
[HTML File Path]:https://docs.nanos.world/docs/scripting-reference/classes/webui#html-path-searchers
[Decal]:https://docs.nanos.world/docs/scripting-reference/classes/decal
[Sound]:https://docs.nanos.world/docs/scripting-reference/classes/sound
[StaticMesh]:https://docs.nanos.world/docs/scripting-reference/classes/static-mesh
[WebUI3d2d]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md

# 🖥️ WebUI3d2d
The WebUI3d2d class allows you to create a dynamic 3D web browser with which you can interact in the world space.

<br>

> #### 💂 Authority
> This class can only be spawned on [🟧 Client](https://docs.nanos.world/docs/core-concepts/scripting/authority-concepts#client-side)

> #### 👪 Inheritance
> This class shares methods and events from [WebUI](https://docs.nanos.world/docs/scripting-reference/classes/webui)

<br>

- [🎒 Examples](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#-examples)
- [🛠 Constructor](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#-constructor)
- [Enums](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#enums)
- [🦠 Methods](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#-methods)
- [🚀 Events](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#-events)

---

## 🎒 Examples
#### Spawning a simple WebUI3d2d
```lua
local my_webui = WebUI3d2d(
    "file://"..Package.GetName().."/Client/my_cool_ui/index.html",      -- URL
    Vector2D(1920, 1080)                                                -- Page resolution: the plane is sized from it, 192 x 108 cm
)

my_webui:SetPlaneSize(Vector2D(160, 90))                                -- Or any size, in centimetres
```

#### Playing the page's audio in 3D
> WebUI3d2d leaves the page's audio to your script: spawn it with WebUI's own `SpawnSound`, 2D or 3D with the ranges you want, and attach it to the mesh
```lua
-- Plays the page's audio in 3D from the mesh: full volume within 2 m, silent at 16 m, destroyed with the mesh
local my_sound = my_webui:SpawnSound(Vector(), false, 1, 200, 1600)
my_sound:AttachTo(my_webui:GetStaticMesh(), AttachmentRule.SnapToTarget, "", 0, false)
```

#### Painting the WebUI3d2d on another mesh
> This can have unforeseen consequences depending on the mesh and the material index used
```lua
local my_webui = WebUI3d2d(
    "https://www.google.com/",                                          -- URL
    Vector2D(1920, 1080),                                               -- Page resolution
    false,                                                              -- Transparent?
    "nanos-world::SM_TV_Hanging",                                       -- Mesh
    1                                                                   -- Material slot the page is painted on
)

-- The mesh can also change later, in place
my_webui:SetMesh("nanos-world::SM_Plane")
```

---

## 🛠 Constructor
```lua
local my_webui = WebUI3d2d(sURL, tResolution, bTransparent, sMesh, iMaterialIndex)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [HTML Path]           | `sURL`                | `""`                      | Web URL or [HTML File Path] as `file://my_file.html`
| [Vector2D]            | `tResolution`         | `Vector2D(1920, 1080)`    | Page resolution in pixels, brought within 240 and 8192 on each side keeping its ratio. Past a 34:1 ratio both can't hold, and the short side's 240 wins
| [boolean]             | `bTransparent`        | `false`                   | Should the page's transparent parts show through
| [string]              | `sMesh`               | `"nanos-world::SM_Plane"` | Mesh the page is painted on. The default plane is sized from the resolution, 10 pixels per centimetre (see [`SetPlaneSize`]); another mesh keeps a scale of 1 (see [`SetScale`])
| [integer]             | `iMaterialIndex`      | `-1`                      | Material slot of the mesh the page is painted on, `-1` for every slot

---

## Enums
[`WebUI3d2dTargeting`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#webui3d2dtargeting
[`WebUI3d2dInput`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#webui3d2dinput
[`WebUI3d2dKeyboardCapture`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#webui3d2dkeyboardcapture

> `WebUI3d2dTargeting` and `WebUI3d2dInput` are flags: combine values with `|`, e.g. `WebUI3d2dInput.Keyboard | WebUI3d2dInput.Mouse` (which is `WebUI3d2dInput.All`)

#### `WebUI3d2dTargeting`
> Controls a WebUI3d2d can be targeted with, see [`SetTargeting`]

| Name          | Value | Description
| -             |:-     |:-
| `None`        | `0`   | Can't be targeted
| `Cursor`      | `1`   | The mouse cursor, while the mouse is enabled
| `Camera`      | `2`   | Aiming the camera (the center of the view), while the mouse is disabled
| `All`         | `3`   | Both (default)

#### `WebUI3d2dInput`
> Game inputs, see [`SetBlockedGameInput`]

| Name          | Value | Description
| -             |:-     |:-
| `None`        | `0`   | No input
| `Keyboard`    | `1`   | Keys, only while the WebUI3d2d captures the keyboard (see [`SetKeyboardCapture`])
| `Mouse`       | `2`   | Mouse clicks and scroll
| `All`         | `3`   | Keyboard and mouse (default of [`SetBlockedGameInput`])

#### `WebUI3d2dKeyboardCapture`
> When a targeted WebUI3d2d captures the keyboard, taking keys from the game, see [`SetKeyboardCapture`]

| Name          | Value | Description
| -             |:-     |:-
| `Off`         | `0`   | Never, keys always reach the game
| `OnClick`     | `1`   | From a click on the WebUI3d2d until it's untargeted or Escape is pressed (default)
| `Always`      | `2`   | Whenever the WebUI3d2d is targeted, even by just looking at it

---

## 🦠 Methods

#### WebUI3d2d methods
[`GetBlockedGameInput`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getblockedgameinput
[`GetCursorDecal`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getcursordecal
[`GetCursorDecalSize`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getcursordecalsize
[`GetCursorPosition`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getcursorposition
[`GetKeyboardCapture`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getkeyboardcapture
[`GetMaterialIndex`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getmaterialindex
[`GetPlaneSize`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getplanesize
[`GetStaticMesh`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getstaticmesh
[`GetTargeting`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#gettargeting
[`GetURL`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#geturl
[`IsCursorDecalEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#iscursordecalenabled
[`IsInteractable`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#isinteractable
[`IsKeptAwake`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#iskeptawake
[`IsReloadOnFailEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#isreloadonfailenabled
[`LoadURL`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#loadurl
[`MakeNoSignal`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#makenosignal
[`SetBlockedGameInput`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setblockedgameinput
[`SetCursorDecalEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setcursordecalenabled
[`SetCursorDecalSize`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setcursordecalsize
[`SetFreeze`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setfreeze
[`SetKeepAwake`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setkeepawake
[`SetKeyboardCapture`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setkeyboardcapture
[`SetMesh`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setmesh
[`SetPlaneSize`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setplanesize
[`SetReloadOnFailEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setreloadonfailenabled
[`SetTargeting`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#settargeting

[`AddMouseAliasKey`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#addmousealiaskey
[`RemoveMouseAliasKey`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#removemousealiaskey
[`GetAllMouseAliasKeys`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getallmousealiaskeys
[`GetMouseAliasKey`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getmousealiaskey

> The following methods can be called on any [WebUI3d2d] instance

| Returns               | Name                                  | Description
| -                     |:-                                     |:-
| [`WebUI3d2dInput`]    | [`GetBlockedGameInput`]               | Returns the game inputs kept from firing while the WebUI3d2d is targeted
| [StaticMesh]          | [`GetCursorDecal`]                    | Returns the 3D cursor
| [float]               | [`GetCursorDecalSize`]                | Returns the 3D cursor size
| [Vector2D]            | [`GetCursorPosition`]                 | Returns the cursor's position on the page, in pixels
| [`WebUI3d2dKeyboardCapture`] | [`GetKeyboardCapture`]                | Returns when the WebUI3d2d captures the keyboard
| [integer]             | [`GetMaterialIndex`]                  | Returns the material index the page is painted on
| [Vector2D]            | [`GetPlaneSize`]                      | Returns the default plane's size in centimetres
| [StaticMesh]          | [`GetStaticMesh`]                     | Get the WebUI3d2d parent mesh
| [`WebUI3d2dTargeting`] | [`GetTargeting`]                      | Returns the controls the WebUI3d2d can be targeted with
| [string]              | [`GetURL`]                            | Returns the URL the WebUI3d2d last loaded
| [boolean]             | [`IsCursorDecalEnabled`]              | Returns whether the 3D cursor decal is enabled
| [boolean]             | [`IsInteractable`]                    | Returns whether the WebUI3d2d can be targeted with the current control
| [boolean]             | [`IsKeptAwake`]                       | Returns whether the WebUI3d2d is kept awake
| [boolean]             | [`IsReloadOnFailEnabled`]             | Returns whether the page reloads when it fails to load
|                       | [`LoadURL`]                           | Load a URL in the page
|                       | [`MakeNoSignal`]                      | Set the WebUI3d2d to a "no signal" state
|                       | [`SetBlockedGameInput`]               | Set the game inputs kept from firing while the WebUI3d2d is targeted
|                       | [`SetCursorDecalEnabled`]             | Enable or disable the 3D cursor decal
|                       | [`SetCursorDecalSize`]                | Set the 3D cursor size
|                       | [`SetFreeze`]                         | Freeze or resume the page's rendering
|                       | [`SetKeepAwake`]                      | Keep the WebUI3d2d rendering whatever its distance or view
|                       | [`SetKeyboardCapture`]                | Set when the WebUI3d2d captures the keyboard
|                       | [`SetMesh`]                           | Change the mesh the page is painted on
|                       | [`SetPlaneSize`]                      | Set the default plane's size in centimetres
|                       | [`SetReloadOnFailEnabled`]            | Enable or disable reloading the page when it fails to load
|                       | [`SetTargeting`]                      | Set the controls the WebUI3d2d can be targeted with
|                       | [`AddMouseAliasKey`]                  | Add a key to the mouse aliases
|                       | [`RemoveMouseAliasKey`]               | Remove a key from the mouse aliases
| [table]               | [`GetAllMouseAliasKeys`]              | Get the mouse aliases table
| [string]              | [`GetMouseAliasKey`]                  | Get the mouse button aliased to a key

#### Wrapper methods
[`AttachTo`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-attachto
[`Detach`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-detach
[`GetAttachedTo`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-getattachedto
[`GetBounds`]:https://docs.nanos.world/docs/next/scripting-reference/classes/base-classes/actor#function-getbounds
[`GetLocation`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-getlocation
[`GetRotation`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-getrotation
[`GetScale`]:https://docs.nanos.world/docs/next/scripting-reference/classes/base-classes/actor#function-getscale
[`GetScreenPercentage`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-getscreenpercentage
[`SetLifeSpan`]:https://docs.nanos.world/docs/next/scripting-reference/classes/base-classes/actor#function-setlifespan
[`SetLocation`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-setlocation
[`SetRotation`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-setrotation
[`SetRelativeLocation`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-setrelativelocation
[`SetRelativeRotation`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-setrelativerotation
[`SetScale`]:https://docs.nanos.world/docs/next/scripting-reference/classes/base-classes/actor#function-setscale
[`RotateTo`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-rotateto
[`TranslateTo`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-translateto
[`WasRecentlyRendered`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-wasrecentlyrendered

> The following methods are wrappers for `my_webui:GetStaticMesh():SM_METHOD_NAME()` and can be called on any [WebUI3d2d] instance
```lua
-- You can call
my_webui:GetLocation()

-- Instead of
my_webui:GetStaticMesh():GetLocation()
```

| Returns               | Name                                  | Description
| -                     |:-                                     |:-
|                       | [`AttachTo`]                          | Attaches this WebUI3d2d to any other Actor, optionally at a specific bone
|                       | [`Detach`]                            | Detaches this WebUI3d2d from AttachedTo Actor
| Actor                 | [`GetAttachedTo`]                     | Returns the Actor this WebUI3d2d is attached to
| [table]               | [`GetBounds`]                         | Returns this WebUI3d2d bounds
| [Vector]              | [`GetLocation`]                       | Returns this WebUI3d2d location in the game world
| [Rotator]             | [`GetRotation`]                       | Returns this WebUI3d2d rotation in the game world
|                       | [`SetLifeSpan`]                       | Sets the time (in seconds) before this WebUI3d2d is destroyed
| [Vector]              | [`GetScale`]                          | Returns this WebUI3d2d scale
| [number]              | [`GetScreenPercentage`]               | Returns how much of the screen this WebUI3d2d fills
|                       | [`RotateTo`]                          | Smoothly rotates this WebUI3d2d to a rotation over time
|                       | [`SetLocation`]                       | Set this WebUI3d2d location in the game world
|                       | [`SetRotation`]                       | Set this WebUI3d2d rotation in the game world
|                       | [`SetRelativeLocation`]               | Set this WebUI3d2d location relative to the Actor it's attached to
|                       | [`SetRelativeRotation`]               | Set this WebUI3d2d rotation relative to the Actor it's attached to
|                       | [`SetScale`]                          | Set this WebUI3d2d scale
|                       | [`TranslateTo`]                       | Smoothly moves this WebUI3d2d to a location over time
| [boolean]             | [`WasRecentlyRendered`]               | Returns `true` if this WebUI3d2d was recently rendered on screen

##
#### `GetBlockedGameInput`
> Returns the game inputs kept from firing while the WebUI3d2d is targeted
>
> Returns [`WebUI3d2dInput`] flags
```lua
local ret = my_webui:GetBlockedGameInput()
```

##
#### `GetCursorDecal`
> Returns the 3D cursor, a small plane laid on the WebUI3d2d's mesh (a decal wouldn't draw on a WebUI), `nil` until the cursor first moves on the targeted WebUI3d2d
>
> Returns [StaticMesh]
```lua
local ret = my_webui:GetCursorDecal()
```

##
#### `GetCursorDecalSize`
> Returns the 3D cursor size: half its width, in cm
>
> Returns [float]
```lua
local ret = my_webui:GetCursorDecalSize()
```

##
#### `GetCursorPosition`
> Returns the cursor's position on the page, in pixels: `(0, 0)` while the WebUI3d2d isn't targeted
>
> Returns [Vector2D]
```lua
local ret = my_webui:GetCursorPosition()
```

##
#### `GetKeyboardCapture`
> Returns when the WebUI3d2d captures the keyboard while it's targeted
>
> Returns [`WebUI3d2dKeyboardCapture`]
```lua
local ret = my_webui:GetKeyboardCapture()
```

##
#### `GetMaterialIndex`
> Returns the material index of the mesh the page is painted on (`-1` for every slot)
>
> Returns [integer]
```lua
local ret = my_webui:GetMaterialIndex()
```

##
#### `GetPlaneSize`
> Returns the default plane's size in centimetres, `nil` on another mesh
>
> Returns [Vector2D]
```lua
local ret = my_webui:GetPlaneSize()
```

##
#### `GetStaticMesh`
> Get the StaticMesh on which the WebUI3d2d is painted
>
> Returns [StaticMesh]
```lua
local ret = my_webui:GetStaticMesh()
```

##
#### `GetTargeting`
> Returns the controls the WebUI3d2d can be targeted with
>
> Returns [`WebUI3d2dTargeting`] flags
```lua
local ret = my_webui:GetTargeting()
```

##
#### `GetURL`
> Returns the URL the WebUI3d2d last loaded
>
> Returns [string]
```lua
local ret = my_webui:GetURL()
```

##
#### `IsCursorDecalEnabled`
> Returns whether the 3D cursor decal is enabled
>
> Returns [boolean]
```lua
local ret = my_webui:IsCursorDecalEnabled()
```

##
#### `IsInteractable`
> Returns whether the WebUI3d2d can be targeted with the current control
>> While the mouse is enabled it checks `WebUI3d2dTargeting.Cursor` in [`GetTargeting`], otherwise `WebUI3d2dTargeting.Camera`
<br> To take input, the WebUI3d2d must also fill enough of the view: a [`GetScreenPercentage`] of `0.5` or more, about a quarter of the view's width at a 90° FOV (its size, distance and the lens all count, not its page resolution)
>
> Returns [boolean]
```lua
local ret = my_webui:IsInteractable()
```

##
#### `IsKeptAwake`
> Returns wether the WebUI3d2d is kept awake, by [`SetKeepAwake`] or its release delay
>
> Returns [boolean]
```lua
local ret = my_webui:IsKeptAwake()
```

##
#### `IsReloadOnFailEnabled`
> Returns whether the WebUI3d2d reloads its page when it fails to load
>
> Returns [boolean]
```lua
local ret = my_webui:IsReloadOnFailEnabled()
```

##
#### `LoadURL`
> Load a URL in the page. Only local pages (`file://`) and web URLs (`http://`, `https://` or `www.`) load; anything else shows the "no signal" noise. A page that fails to load reloads this URL (see [`SetReloadOnFailEnabled`])
```lua
my_webui:LoadURL(sURL)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [string]              | `sURL`                |                           | Web URL, or local page as `file://my_page.html`

##
#### `MakeNoSignal`
> Set the WebUI3d2d to a "no signal" state
```lua
my_webui:MakeNoSignal()
```

##
#### `SetBlockedGameInput`
> Set the game inputs kept from firing while the WebUI3d2d is targeted; the others reach the game as well as the WebUI3d2d (`WebUI3d2dInput.All` by default). Keys are only kept from the game while the WebUI3d2d captures the keyboard, see [`SetKeyboardCapture`]
```lua
my_webui:SetBlockedGameInput(iInputs)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [`WebUI3d2dInput`]    | `iInputs`             |                           | Flags, e.g. `WebUI3d2dInput.Mouse` to let keys through

##
#### `SetCursorDecalEnabled`
> Enable or disable the 3D cursor decal (enabled by default). It shows with either targeting control, so turn it off where the mouse cursor already marks the spot. Turned off, the decal goes at once; turned on, it shows on the next cursor move
```lua
my_webui:SetCursorDecalEnabled(bEnabled)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bEnabled`            |                           | Should the 3D cursor decal be enabled or not

##
#### `SetCursorDecalSize`
> Set the 3D cursor size: half its width, in cm (`1.2` by default)
```lua
my_webui:SetCursorDecalSize(fSize)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [float]               | `fSize`               |                           | Half the 3D cursor's width, in cm

##
#### `SetFreeze`
> Freeze or resume the page's rendering to the mesh; its JavaScript keeps running either way. Calls [`OnWebUI3d2dFreezeChange`] when the state changes. WebUI3d2d freezes pages out of view or out of range, and resumes them, on its own: use [`SetKeepAwake`] to keep one rendering
```lua
my_webui:SetFreeze(bFreeze)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bFreeze`             |                           | Should the rendering be frozen

##
#### `SetKeepAwake`
> Keep the WebUI3d2d rendering whatever its distance or view (WebUI3d2d otherwise freezes pages that are out of view or far from the camera). Use it for a page in use, or one finishing an animation in sight: on release, `iReleaseDelay` keeps it awake a little longer so the frame left on the mesh once it freezes is the final one
```lua
my_webui:SetKeepAwake(bAwake, iReleaseDelay)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bAwake`              |                           | Should the WebUI3d2d stay awake
| [integer]             | `iReleaseDelay`       | `0`                       | On release, milliseconds before it may freeze again

##
#### `SetKeyboardCapture`
> Set when the WebUI3d2d captures the keyboard while it's targeted, taking keys from the game (`WebUI3d2dKeyboardCapture.OnClick` by default): with `OnClick`, looking at or pointing at a WebUI3d2d never captures the keyboard, a click on it does, until it's untargeted or Escape is pressed
```lua
my_webui:SetKeyboardCapture(iMode)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [`WebUI3d2dKeyboardCapture`] | `iMode`               |                           | When the WebUI3d2d captures the keyboard

##
#### `SetMesh`
> Change the mesh the page is painted on. The mesh changes in place, keeping its location, its attachment and what's attached to it; its scale resets: the default plane to its size from the page resolution, another mesh to 1
```lua
my_webui:SetMesh(sMesh, iMaterialIndex)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [string]              | `sMesh`               | `"nanos-world::SM_Plane"` | Mesh asset, `nil` for the default plane
| [integer]             | `iMaterialIndex`      | `-1`                      | Material slot of the mesh the page is painted on, `-1` for every slot

##
#### `SetPlaneSize`
> Set the default plane's size in centimetres. The page keeps its resolution, so a size off its ratio stretches it. Does nothing on another mesh, which [`SetScale`] sizes
```lua
my_webui:SetPlaneSize(tSize)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [Vector2D]            | `tSize`               |                           | Width and height in centimetres

##
#### `SetReloadOnFailEnabled`
> Enable or disable reloading the page 2 seconds after it fails to load (enabled by default)
```lua
my_webui:SetReloadOnFailEnabled(bEnabled)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bEnabled`            |                           | Should the WebUI3d2d reload on fail

##
#### `SetTargeting`
> Set the controls the WebUI3d2d can be targeted with (`WebUI3d2dTargeting.All` by default)
```lua
my_webui:SetTargeting(iTargeting)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [`WebUI3d2dTargeting`] | `iTargeting`          |                           | Flags, e.g. `WebUI3d2dTargeting.Cursor`

##
#### `AddMouseAliasKey`
> Add a key to the mouse aliases
```lua
my_webui:AddMouseAliasKey(sKeyName, sMouseButton)

-- Here we make the interact key acts as a left click
my_webui:AddMouseAliasKey(Input.GetMappedKeys("Interact")[1], "LeftMouseButton")
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [string]              | `sKey`                |                           | The key to use as alias
| [string]              | `sMouseButton`        |                           | The mouse button that will be aliased

##
#### `RemoveMouseAliasKey`
> Remove a key from the mouse aliases
```lua
my_webui:RemoveMouseAliasKey(sKey)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [string]              | `sKey`                |                           | The key to be removed

##
#### `GetAllMouseAliasKeys`
> Get the mouse aliases table
>
> Returns [table]
```lua
local ret = my_webui:GetAllMouseAliasKeys()
```

##
#### `GetMouseAliasKey`
> Get the mouse button aliased to a key
>
> Returns [string]
```lua
local ret = my_webui:GetMouseAliasKey("E")
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [string]              | `sKey`                |                           | The key to be checked

---

## 🚀 Events
[`OnWebUI3d2dTargetChange`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#onwebui3d2dtargetchange
[`OnWebUI3d2dFreezeChange`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#onwebui3d2dfreezechange

| Name                              | Description
| -                                 |:-
| [`OnWebUI3d2dTargetChange`]       | Triggered when a WebUI3d2d is targeted or untargeted
| [`OnWebUI3d2dFreezeChange`]       | Triggered when a WebUI3d2d's rendering freezes or resumes

##
#### `OnWebUI3d2dTargetChange`
> Triggered when a WebUI3d2d is targeted or untargeted
```lua
Events.Subscribe("OnWebUI3d2dTargetChange", function(xOldWebUI, xNewWebUI)

end)
```
| Type                              | Argument                  | Description
| -                                 |:-                         |:-
| [WebUI3d2d] or [boolean]          | `xOldWebUI`               | The previously targeted UI, `false` if inexistent
| [WebUI3d2d] or [boolean]          | `xNewWebUI`               | The new targeted UI, `false` on untarget

##
#### `OnWebUI3d2dFreezeChange`
> Triggered when a WebUI3d2d's rendering freezes or resumes. The page's JavaScript keeps running while it's frozen, so the script owning the page can forward this to it to pause its animations and timers
```lua
Events.Subscribe("OnWebUI3d2dFreezeChange", function(oWebUI, bFrozen)

end)
```
| Type                              | Argument                  | Description
| -                                 |:-                         |:-
| [WebUI3d2d]                       | `oWebUI`                  | The UI whose rendering froze or resumed
| [boolean]                         | `bFrozen`                 | `true` once frozen, `false` once rendering again
