local my_webui = WebUI3d2d(
    "file://"..Package.GetName().."/Client/my_cool_ui/index.html",      -- URL
    Vector2D(1920, 1080)                                                -- Page resolution: the plane is sized from it, 192 x 108 cm
)

-- Plays the page's audio in 3D from the mesh: full volume within 2 m, silent at 16 m, destroyed with the mesh
local my_sound = my_webui:SpawnSound(Vector(), false, 1, 200, 1600)
my_sound:AttachTo(my_webui:GetStaticMesh(), AttachmentRule.SnapToTarget, "", 0, false)
