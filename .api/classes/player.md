[ᐊ Return to docs](https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/docs.md)

[WebUI3d2d]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/WIKI.md#-constructor

[`GetTargetedWebUI3d2d`]:https://github.com/Timmy-the-nobody/WebUI3d2d/blob/main/.api/classes/player.md#gettargetedwebui3d2d

# 👩‍💻 Player

> #### 💂 Authority
> These methods bellow can only be called on [🟧 Client](https://docs.nanos.world/docs/core-concepts/scripting/authority-concepts#client-side)

> #### 📝 Note
> These methods only work on the local player

## 🦠 Methods

| Returns               | Name                                  | Description
| -                     |:-                                     |:-
| [WebUI3d2d]           | [`GetTargetedWebUI3d2d`]              | Get the current targeted WebUI3d2d

##
### `GetTargetedWebUI3d2d`
> Get the current targeted WebUI3d2d
>
> Returns [WebUI3d2d], or `nil` if no WebUI3d2d is targeted
```lua
local ret = my_player:GetTargetedWebUI3d2d()
```
