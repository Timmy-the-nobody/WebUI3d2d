[ᐊ Return to docs](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/docs.md)

[boolean]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#boolean
[number]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#number
[string]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#string
[table]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#table
[integer]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#integer
[float]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#float
[Vector]:https://docs.nanos.world/docs/scripting-reference/structs/vector
[Rotator]:https://docs.nanos.world/docs/scripting-reference/structs/rotator
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
- [🦠 Methods](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#-methods)
- [🚀 Events](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#-events)

---

## 🎒 Examples
#### Spawning a simple WebUI3d2d
```lua
local my_webui = WebUI3d2d(
    "file://"..Package.GetName().."/Client/my_cool_ui/index.html",      -- Path
    false,                                                              -- Is transparent?
    1920,                                                               -- UI width
    1080,                                                               -- UI height
    Vector(1.92, 1.08, 1),                                              -- Mesh scale
    true                                                                -- Attach 3D sound
)
```

#### Changing the StaticMesh and the material index used to paint the WebUI3d2d
> This can have unforeseen consequences depending on the mesh and the material index used
```lua
local my_webui = WebUI3d2d(
    "https://www.google.com/",                                          -- Path
    false,                                                              -- Is transparent?
    1920,                                                               -- UI width
    1080,                                                               -- UI height
    Vector(2),                                                          -- Mesh scale
    true,                                                               -- Attach 3D sound
    "nanos-world::SM_TV_Hanging",                                       -- Mesh override
    1                                                                   -- Material index override
)
```

---

## 🛠 Constructor
```lua
local my_webui = WebUI3d2d(sPath, bTransparent, iW, iH, tScale, bAttach3DSound, sMesh, iMatIndex)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [HTML Path]           | `sPath`               | `""`                      | Web URL or [HTML File Path] as `file://my_file.html`
| [boolean]             | `bTransparent`        | `false`                   | Should the WebUI3d2d be transparent
| [integer]             | `iW`                  | X axis of `tScale`        | The WebUI3d2d width
| [integer]             | `iH`                  | Y axis of `tScale`        | The WebUI3d2d height
| [Vector]              | `tScale`              | `Vector(1, 1, 1)`         | The WebUI3d2d mesh scale
| [boolean]             | `bAttach3DSound`      | `false`                   | Should a 3D sound emitting audio from the UI be attached to this UI
| [string]              | `sMesh`               | `"nanos-world::SM_Plane"` | The mesh to use for the WebUI3d2d
| [integer]             | `iMatIndex`           | `-1`                      | The material index to use for the WebUI3d2d

---

## 🦠 Methods

#### WebUI3d2d methods
[`GetAttachedSound`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getattachedsound
[`GetCursorDecal`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getcursordecal
[`GetCursorSize`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getcursorsize
[`GetStaticMesh`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getstaticmesh
[`IsCameraTraceControlEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#iscameratracecontrolenabled
[`IsCursorTraceControlEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#iscursortracecontrolenabled
[`IsCursorDecalEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#iscursordecalenabled
[`IsInteractable`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#isinteractable
[`IsKeptAwake`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#iskeptawake
[`IsMouseEventsEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#ismouseeventsenabled
[`IsKeyboardEventsEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#iskeyboardeventsenabled
[`IsKeyboardInputEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#iskeyboardinputenabled
[`MakeNoSignal`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#makenosignal
[`SetCameraTraceControl`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setcameratracecontrol
[`SetCursorTraceControl`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setcursortracecontrol
[`SetCursorDecalEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setcursordecalenabled
[`SetCursorSize`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setcursorsize
[`SetKeepAwake`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setkeepawake
[`SetMouseEventsEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setmouseeventsenabled
[`SetKeyboardEventsEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setkeyboardeventsenabled
[`SetKeyboardInputEnabled`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#setkeyboardinputenabled

[`AddMouseAliasKey`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#addmousealiaskey
[`RemoveMouseAliasKey`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#removemousealiaskey
[`GetAllMouseAliasKeys`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getallmousealiaskeys
[`GetMouseAliasKey`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/webui3d2d.md#getmousealiaskey

> The following methods can be called on any [WebUI3d2d] instance

| Returns               | Name                                  | Description
| -                     |:-                                     |:-
| [Sound]               | [`GetAttachedSound`]                  | Get the WebUI3d2d attached sound
| [Decal]               | [`GetCursorDecal`]                    | Returns the cursor decal
| [float]               | [`GetCursorSize`]                     | Returns the cursor decal size
| [StaticMesh]          | [`GetStaticMesh`]                     | Get the WebUI3d2d parent mesh
| [boolean]             | [`IsCameraTraceControlEnabled`]       | Returns wether the camera trace control is enabled or not
| [boolean]             | [`IsCursorTraceControlEnabled`]       | Returns wether the cursor trace control is enabled or not
| [boolean]             | [`IsCursorDecalEnabled`]              | Returns wether the 3D cursor decal is enabled or not
| [boolean]             | [`IsInteractable`]                    | Returns wether the WebUI3d2d is interactable or not
| [boolean]             | [`IsKeptAwake`]                       | Returns wether the WebUI3d2d is kept awake or not
| [boolean]             | [`IsKeyboardInputEnabled`]            | Returns wether the WebUI3d2d accept keyboard input or not
| [boolean]             | [`IsKeyboardEventsEnabled`]           | Returns wether the WebUI3d2d allow keyboard events or not
| [boolean]             | [`IsMouseEventsEnabled`]              | Returns wether the WebUI3d2d allow mouse events or not
|                       | [`MakeNoSignal`]                      | Set the WebUI3d2d to a "no signal" state
|                       | [`SetCameraTraceControl`]             | Enable or disable the camera trace control
|                       | [`SetCursorTraceControl`]             | Enable or disable the cursor trace control
|                       | [`SetCursorDecalEnabled`]             | Enable or disable the 3D cursor decal
|                       | [`SetCursorSize`]                     | Set the cursor decal size
|                       | [`SetKeepAwake`]                      | Keep the WebUI3d2d rendering whatever its distance or view
|                       | [`SetKeyboardInputEnabled`]           | Enable or disable the keyboard input
|                       | [`SetKeyboardEventsEnabled`]          | Enable or disable the keyboard events
|                       | [`SetMouseEventsEnabled`]             | Enable or disable the mouse events
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
[`SetLifeSpan`]:https://docs.nanos.world/docs/next/scripting-reference/classes/base-classes/actor#function-setlifespan
[`SetLocation`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-setlocation
[`SetRotation`]:https://docs.nanos.world/docs/scripting-reference/classes/base-classes/actor#function-setrotation
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
| [table]               | [`GetBounds`]                         | Returns this WebUI3d2d bounds
| [Vector]              | [`GetLocation`]                       | Returns this WebUI3d2d location in the game world
| [Rotator]             | [`GetRotation`]                       | Returns this WebUI3d2d rotation in the game world
|                       | [`SetLifeSpan`]                       | Sets the time (in seconds) before this WebUI3d2d is destroyed
| [Vector]              | [`GetScale`]                          | Returns this WebUI3d2d scale
|                       | [`SetLocation`]                       | Set this WebUI3d2d location in the game world
|                       | [`SetRotation`]                       | Set this WebUI3d2d rotation in the game world
|                       | [`SetScale`]                          | Set this WebUI3d2d scale
| [boolean]             | [`WasRecentlyRendered`]               | Returns `true` if this WebUI3d2d was recently rendered on screen

##
#### `GetAttachedSound`
> Get the 3D attached sound
>
> Returns [Sound]
```lua
local ret = my_webui:GetAttachedSound()
```

##
#### `GetCursorDecal`
> Returns the cursor decal
>
> Returns [Decal]
```lua
local ret = my_webui:GetCursorDecal()
```

##
#### `GetCursorSize`
> Returns the cursor decal size
>
> Returns [float]
```lua
local ret = my_webui:GetCursorSize()
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
#### `IsCameraTraceControlEnabled`
> Returns wether the camera trace control is enabled or not
>
> Returns [boolean]
```lua
local ret = my_webui:IsCameraTraceControlEnabled()
```

##
#### `IsCursorTraceControlEnabled`
> Returns wether the cursor trace control is enabled or not
>
> Returns [boolean]
```lua
local ret = my_webui:IsCursorTraceControlEnabled()
```

##
#### `IsCursorDecalEnabled`
> Returns wether the 3D cursor decal is enabled or not
>
> Returns [boolean]
```lua
local ret = my_webui:IsCursorDecalEnabled()
```

##
#### `IsInteractable`
> Returns wether the WebUI3d2d is interactable or not
>> If hardware cursor is enabled it'll return the result of [`IsCursorTraceControlEnabled`]
<br> Otherwise it'll return the result of [`IsCameraTraceControlEnabled`]
<br> To take input, the WebUI3d2d's bounds diagonal, laid across the view where the cursor hits it, must also span at least a quarter of the view's width (its size, distance and the lens all count, not its page resolution): at a 90° FOV that's within 4 times `GetBounds().BoxExtent:Size()`
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
#### `IsKeyboardInputEnabled`
> Returns wether the WebUI3d2d accept keyboard input or not
>
> Returns [boolean]
```lua
local ret = my_webui:IsKeyboardInputEnabled()
```

##
#### `IsKeyboardEventsEnabled`
> Returns wether the WebUI3d2d allow keyboard events or not
>
> Returns [boolean]
```lua
local ret = my_webui:IsKeyboardEventsEnabled()
```

##
#### `IsMouseEventsEnabled`
> Returns wether the WebUI3d2d allow mouse events or not
>
> Returns [boolean]
```lua
local ret = my_webui:IsMouseEventsEnabled()
```

##
#### `MakeNoSignal`
> Set the WebUI3d2d to a "no signal" state
```lua
my_webui:MakeNoSignal()
```

##
#### `SetCameraTraceControl`
> Enable or disable the camera trace control (enabled by default)
```lua
my_webui:SetCameraTraceControl(bEnabled)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bEnabled`            |                           | Should the camera trace control be enabled or not

##
#### `SetCursorTraceControl`
> Enable or disable the mouse trace control (enabled by default)
```lua
my_webui:SetCursorTraceControl(bEnabled)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bEnabled`            |                           | Should the mouse trace control be enabled or not

##
#### `SetCursorDecalEnabled`
> Enable or disable the 3D cursor decal (enabled by default)
```lua
my_webui:SetCursorDecalEnabled(bEnabled)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bEnabled`            |                           | Should the 3D cursor decal be enabled or not

##
#### `SetCursorSize`
> Set the cursor decal size
```lua
my_webui:SetCursorSize(fSize)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [float]               | `fSize`               |                           | The new size of the cursor decal

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
#### `SetKeyboardInputEnabled`
> Enable or disable the keyboard input (enabled by default)
```lua
my_webui:SetKeyboardInputEnabled(bEnabled)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bEnabled`            |                           | The new size of the cursor decal

##
#### `SetKeyboardEventsEnabled`
> Enable or disable the keyboard events (disabled by default)
```lua
my_webui:SetKeyboardEventsEnabled(bEnabled)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bEnabled`            |                           | Should the WebUI3d2d (targeted) allow keyboard events to be triggered or not

##
#### `SetMouseEventsEnabled`
> Enable or disable the mouse events (disabled by default)
```lua
my_webui:SetMouseEventsEnabled(bEnabled)
```
| Type                  | Name                  | Default                   | Description
| -                     |:-                     |:-                         |:-
| [boolean]             | `bEnabled`            |                           | Should the WebUI3d2d (targeted) allow mouse events to be triggered or not

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

| Name                              | Description
| -                                 |:-
| [`OnWebUI3d2dTargetChange`]       | Triggered when a WebUI3d2d is targeted or untargeted

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
