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