local my_webui = WebUI3d2d(
    "https://www.google.com/",                                          -- URL
    Vector2D(1920, 1080),                                               -- Page resolution
    false,                                                              -- Transparent?
    "nanos-world::SM_TV_Hanging",                                       -- Mesh
    1                                                                   -- Material slot the page is painted on
)

my_webui:SetScale(Vector(2))                                            -- Another mesh is sized with SetScale

-- Plays the page's audio in 3D from the mesh: full volume within 2 m, silent at 16 m, destroyed with the mesh
local my_sound = my_webui:SpawnSound(Vector(), false, 1, 200, 1600)
my_sound:AttachTo(my_webui:GetStaticMesh(), AttachmentRule.SnapToTarget, "", 0, false)
