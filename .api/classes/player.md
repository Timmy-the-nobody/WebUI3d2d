[ᐊ Return to docs](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/docs.md)

[integer]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#integer
[float]:https://docs.nanos.world/docs/scripting-reference/glossary/basic-types#float
[WebUI3d2d]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/WIKI.md#-constructor

[`GetCameraFocusedWebUI3d2d`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/player.md#getcamerafocusedwebui3d2d
[`FocusWebUI3d2dCamera`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/player.md#focuswebui3d2dcamera
[`UnfocusWebUI3d2dCamera`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/player.md#unfocuswebui3d2dcamera
[`GetTargetWebUI3d2d`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/player.md#gettargetwebui3d2d

# 👩‍💻 Player

> #### 💂 Authority
> These methods bellow can only be called on [🟧 Client](https://docs.nanos.world/docs/core-concepts/scripting/authority-concepts#client-side)

> #### 📝 Note
> These methods only work on the local player

## 🦠 Methods

| Returns               | Name                                  | Description
| -                     |:-                                     |:-
| [WebUI3d2d]           | [`GetTargetWebUI3d2d`]                | Get the current targeted WebUI3d2d
| [WebUI3d2d]           | [`GetCameraFocusedWebUI3d2d`]         | Get the current camera focused WebUI3d2d
|                       | [`FocusWebUI3d2dCamera`]              | Focus the camera on a WebUI3d2d
|                       | [`UnfocusWebUI3d2dCamera`]            | Unfocus the WebUI3d2d camera

##
### `GetTargetWebUI3d2d`
> Get the current targeted WebUI3d2d
>
> Returns [WebUI3d2d], or `nil` if no WebUI3d2d is targeted
```lua
local ret = my_player:GetTargetWebUI3d2d()
```

##
### `GetCameraFocusedWebUI3d2d`
> Get the current camera focused WebUI3d2d
>
> Returns [WebUI3d2d], or `nil` if no WebUI3d2d has camera focus
```lua
local ret = my_player:GetCameraFocusedWebUI3d2d()
```

##
### `FocusWebUI3d2dCamera`
> Focus the camera on a WebUI3d2d
```lua
my_player:FocusWebUI3d2dCamera(oWebUI, fCameraDist, fClipPlaneDist, iBlendTime)
```
| Type                  | Name                  | Default                                                     | Description
| -                     |:-                     |:-                                                           |:-
| [WebUI3d2d]           | `oWebUI`              |                                                             | The WebUI3d2d to focus the camera on
| [float]               | `fCameraDist`         | Calculated according to the mesh bounds if nil or `false`   | The distance from the camera to the WebUI3d2d
| [float]               | `fClipPlaneDist`      | Calculated according to the mesh bounds if nil or `false`   | The distance from the camera to the clip plane
| [integer]             | `iBlendTime`          | `500`                                                       | The time it takes to blend to the new camera position

##
### `UnfocusWebUI3d2dCamera`
> Unfocus the WebUI3d2d camera
>
```lua
my_player:UnfocusWebUI3d2dCamera()
```
