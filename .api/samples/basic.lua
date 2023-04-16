local my_webui = WebUI3d2d(
    "file://"..Package.GetName().."/Client/my_cool_ui/index.html",      -- Path
    false,                                                              -- Is transparent?
    1920,                                                               -- UI width
    1080,                                                               -- UI height
    Vector(1.92, 1.08, 1),                                              -- Mesh scale
    true                                                                -- Attach 3D sound
)