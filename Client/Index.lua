--[[
    WebUI3d2d
    GNU General Public License v3.0
    Copyright © Timmy-the-nobody, 2023, https://github.com/Timmy-the-nobody
]]--
-- Cache some globals
local mathAbs = math.abs
local mathMax = math.max
local mathMin = math.min
local mathFloor = math.floor

local ipairs = ipairs
local pairs = pairs

local Client = Client
local Input = Input
local localPlayer = Client.GetLocalPlayer
local traceLineSingle = Trace.LineSingle
local getMousePosition = Viewport.GetMousePosition
local deprojectScreenToWorld = Viewport.DeprojectScreenToWorld

-- Dynamic vars (Internal)
local oTargetUI = false
local bKeyboardEngaged = false -- A click on the target makes it capture the keyboard (WebUI3d2dKeyboardCapture.OnClick)
local tInstances = {} -- Live WebUI3d2d set, so the lookup and freeze checks don't copy WebUI3d2d.GetAll() out of the engine
local iLastLookupTime = 0

-- Prefix of a local URL, and the prefixes a remote URL may start with
local sLocalURLPrefix = "file://"
local tRemoteURLPrefixes = {"http://", "https://", "www."}

-- Static vars (internal)
local iCollisionChannel = CollisionChannel.WorldStatic
local iTraceMode = TraceMode.TraceComplex | TraceMode.ReturnEntity | TraceMode.ReturnUV
local tNoActors = {}
local tCursorIgnored = {}

-- Static (render)
local MIN_UI_SIZE = 240                                                                 -- Minimum size in pixels of a WebUI3d2d page
local MAX_UI_SIZE = 8192                                                                -- Maximum size in pixels of a WebUI3d2d page
local DEFAULT_CURSOR_DECAL_SIZE = 1.2                                                   -- Default 3D cursor size, half its width in cm (if not changed by `SetCursorDecalSize`)
local CURSOR_HIDE_DELAY = 3000                                                          -- Delay in milliseconds before hiding the cursor decal when invactive (0 or less to disable)
local CURSOR_TEXTURE = "package://"..Package.GetName().."/Client/resources/cursor.png"  -- Path to the cursor texture
local CURSOR_MATERIAL = "nanos-world::M_Default_Masked_Unlit"                           -- Material of the 3D cursor, a plane: WebUI materials take no decals
local CURSOR_OFFSET = 0.1                                                               -- Distance in cm the 3D cursor floats in front of the mesh
local DEFAULT_MESH = "nanos-world::SM_Plane"                                            -- Default WebUI3d2d mesh
local PLANE_SIZE = 100                                                                  -- Size of nanos-world::SM_Plane (the default mesh and the 3D cursor) in cm before scale, U along X and V along Y from its -X -Y corner
local DEFAULT_RESOLUTION = Vector2D(1920, 1080)                                         -- Page resolution when the constructor gets none
local PLANE_PIXELS_PER_CM = 10                                                          -- Default plane size from the page resolution: 1920 x 1080 px make a 192 x 108 cm plane

-- Static (performance)
local TARGET_TICK_RATE = 10         -- Target lookups per second when a WebUI3d2d is targeted (don't set it too high, it will cause performance issues)
local TARGET_IDLE_TICK_RATE = 4     -- Target lookups per second when no WebUI3d2d is targeted (don't set it too high, it will cause performance issues)
local MIN_SCREEN_PERCENTAGE = 0.5   -- GetScreenPercentage() of the mesh needed to take input: about a quarter of the view's width at a 90° FOV, a bit more with narrower lenses
local FREEZE_FROM_DIST = 4          -- Distance from the targeted WebUI3d2d at which the UI will freeze ((width + height) * VALUE)
local FREEZE_CHECK_DELAY = 1000     -- Delay between freeze checks (don't set it too low or it will cause performance issues)

-- Enums
----------------------------------------------------------------------

---@enum WebUI3d2dTargeting
---`🔸 Client`<br>
---Controls a WebUI3d2d can be targeted with: the mouse cursor while the mouse is enabled, aiming the camera while it's disabled. Flags, `All` is `Cursor | Camera`
WebUI3d2dTargeting = {
    None = 0,
    Cursor = 1,
    Camera = 2,
    All = 3
}

---@enum WebUI3d2dInput
---`🔸 Client`<br>
---Game inputs. Flags, `All` is `Keyboard | Mouse`
WebUI3d2dInput = {
    None = 0,
    Keyboard = 1,
    Mouse = 2,
    All = 3
}

---@enum WebUI3d2dKeyboardCapture
---`🔸 Client`<br>
---When a targeted WebUI3d2d captures the keyboard, taking keys from the game
WebUI3d2dKeyboardCapture = {
    Off = 0,
    OnClick = 1,
    Always = 2
}

Package.Export("WebUI3d2dTargeting", WebUI3d2dTargeting)
Package.Export("WebUI3d2dInput", WebUI3d2dInput)
Package.Export("WebUI3d2dKeyboardCapture", WebUI3d2dKeyboardCapture)

---Bits of every value of a flags enum
---@param tEnum table<string, integer>
---@return integer
local function getFlagsMask(tEnum)
    local iMask = 0
    for _, iValue in pairs(tEnum) do
        iMask = (iMask | iValue)
    end
    return iMask
end

---Lowest and highest value of an enum
---@param tEnum table<string, integer>
---@return integer @Lowest value
---@return integer @Highest value
local function getEnumRange(tEnum)
    local iMin, iMax
    for _, iValue in pairs(tEnum) do
        iMin = iMin and mathMin(iMin, iValue) or iValue
        iMax = iMax and mathMax(iMax, iValue) or iValue
    end
    return iMin, iMax
end

-- Computed once, so the setters' checks follow the enums when values are added
local iTargetingMask = getFlagsMask(WebUI3d2dTargeting)
local iGameInputMask = getFlagsMask(WebUI3d2dInput)
local iKeyboardCaptureMin, iKeyboardCaptureMax = getEnumRange(WebUI3d2dKeyboardCapture)

local tASCIICharsRange = {
    {32, 126},
    {128, 128},
    {130, 140},
    {142, 142},
    {145, 156},
    {158, 159},
    {191, 214},
    {216, 246},
    {248, 255}
}

local tMouseTypes = {
    ["LeftMouseButton"] = WebUIMouseType.Left,
    ["RightMouseButton"] = WebUIMouseType.Right,
    ["MiddleMouseButton"] = WebUIMouseType.Middle
}

local tTranslateKeyModifiers = {
    {keymodifier = KeyModifier.CapsLocked, webuimodifier = WebUIModifier.CapsLockOn},
    {keymodifier = KeyModifier.LeftAltDown, webuimodifier = WebUIModifier.AltDown},
    {keymodifier = KeyModifier.RightAltDown, webuimodifier = WebUIModifier.AltgrDown},
    {keymodifier = KeyModifier.LeftShiftDown, webuimodifier = WebUIModifier.ShiftDown | WebUIModifier.IsLeft},
    {keymodifier = KeyModifier.RightShiftDown, webuimodifier = WebUIModifier.ShiftDown | WebUIModifier.IsRight},
    {keymodifier = KeyModifier.LeftControlDown, webuimodifier = WebUIModifier.ControlDown | WebUIModifier.IsLeft},
    {keymodifier = KeyModifier.RightControlDown, webuimodifier = WebUIModifier.ControlDown | WebUIModifier.IsRight},
    {keymodifier = KeyModifier.LeftCommandDown, webuimodifier = WebUIModifier.CommandDown | WebUIModifier.IsLeft},
    {keymodifier = KeyModifier.RightCommandDown, webuimodifier = WebUIModifier.CommandDown | WebUIModifier.IsRight}
}

local tTranslateMouseButtons = {
    {button = "LeftMouseButton", webuimodifier = WebUIModifier.LeftMouseButton},
    {button = "RightMouseButton", webuimodifier = WebUIModifier.RightMouseButton},
    {button = "MiddleMouseButton", webuimodifier = WebUIModifier.MiddleMouseButton}
}

---Special keys dictionary.
---This table contains all the special treatment for some key names
---ASCII: The ASCII code of the key, will not trigger Up/Down events, will only send the Char event
---code: The code of the key, will only trigger Up/Down events, will not send the Char event
local tSpecialKeys = {
    -- AZERTY only characters
    ["Ampersand"] =         {ASCII = "&"},
    ["Asterix"] =           {ASCII = "*"},
    ["Caret"] =             {ASCII = "^"},
    ["Colon"] =             {ASCII = ":"},
    ["Dollar"] =            {ASCII = "$"},
    ["Exclamation"] =       {ASCII = "!"},
    ["LeftParantheses"] =   {ASCII = "("},
    ["RightParantheses"] =  {ASCII = ")"},
    ["Quote"] =             {ASCII = '"'},
    ["Underscore"] =        {ASCII = "_"},
    ["Apostrophe"] =        {ASCII = "'"}, -- This one may be removed in the future
    ["A_AccentGrave"] =     {ASCII = 224},
    ["C_Cedille"] =         {ASCII = 231},
    ["E_AccentAigu"] =      {ASCII = 233},
    ["E_AccentGrave"] =     {ASCII = 232},
    ["Section"] =           {ASCII = 167},

    -- Keypad
    ["Add"] =               {ASCII = 43},
    ["Multiply"] =          {ASCII = 42},
    ["Subtract"] =          {ASCII = 45},
    ["Decimal"] =           {ASCII = 46},
    ["Divide"] =            {ASCII = 47},
    ["NumPadZero"] =        {ASCII = 48},
    ["NumPadOne"] =         {ASCII = 49},
    ["NumPadTwo"] =         {ASCII = 50},
    ["NumPadThree"] =       {ASCII = 51},
    ["NumPadFour"] =        {ASCII = 52},
    ["NumPadFive"] =        {ASCII = 53},
    ["NumPadSix"] =         {ASCII = 54},
    ["NumPadSeven"] =       {ASCII = 55},
    ["NumPadEight"] =       {ASCII = 56},
    ["NumPadNine"] =        {ASCII = 57},
    ["²"] =                 {ASCII = 178},

    -- Replaced key codes (no ASCII char sent, just replaced key code)
    ["F1"] =                {code = 112},
    ["F2"] =                {code = 113},
    ["F3"] =                {code = 114},
    ["F4"] =                {code = 115},
    ["F5"] =                {code = 116},
    ["F6"] =                {code = 117},
    ["F7"] =                {code = 118},
    ["F8"] =                {code = 119},
    ["F9"] =                {code = 120},
    ["F10"] =               {code = 121},
    ["F11"] =               {code = 122},
    ["F12"] =               {code = 123}
}

-- Internal utils (inputs related)
----------------------------------------------------------------------

---Translate key modifiers and mouse buttons to CEF modifiers
---@param oWebUI WebUI3d2d @The WebUI3d2d the event goes to
---@return WebUIModifier @The WebUIModifier integer
local function getWebUIModifiers(oWebUI)
    local iKeyModifiers = Input.GetModifierKeys()
    local iWebUIModifiers = WebUIModifier.None

    for _, v in ipairs(tTranslateKeyModifiers) do
        if ((iKeyModifiers & v.keymodifier) ~= 0) then
            iWebUIModifiers = iWebUIModifiers | v.webuimodifier
        end
    end

    -- The buttons held on it, as the mouse handlers track them, rather than asking the engine for each
    local tDownButtons = oWebUI.__down_mouse_buttons
    for _, v in ipairs(tTranslateMouseButtons) do
        if tDownButtons[v.button] then
            iWebUIModifiers = iWebUIModifiers | v.webuimodifier
        end
    end

    return iWebUIModifiers
end

local function isLetter(sInput)
    if (#sInput ~= 1) then return false end

    -- A-Z, a-z
    local iByte = sInput:byte()
    return ((iByte >= 65) and (iByte <= 90)) or ((iByte >= 97) and (iByte <= 122))
end

local function isCapsLockOn()
    return ((Input.GetModifierKeys() & KeyModifier.CapsLocked) ~= 0)
end

local function isShiftDown()
    local iKeyModifiers = Input.GetModifierKeys()

    if ((iKeyModifiers & KeyModifier.LeftShiftDown) ~= 0) then return true end
    if ((iKeyModifiers & KeyModifier.RightShiftDown) ~= 0) then return true end

    return false
end

-- --[[ isNumLockOn ]]--
-- local function isNumLockOn()
--     return ((Input.GetModifierKeys() & KeyModifier.NumLocked) ~= 0)
-- end

---Find the keycode of a key, the ASCII code if it's an ASCII character, and if it shouldn't trigger Up/Down events
---@param sKey string @The key name
---@return integer @The key code
---@return integer @The ASCII code
---@return boolean @Shouldn't trigger Up/Down events
local function getKeyInfo(sKey)
    if sKey:find("Gamepad") then return end

    local iKeyCode = Input.GetKeyCode(sKey)
    local tSpecialKey = tSpecialKeys[sKey]

    if tSpecialKey then
        -- Forced keycode, depending on the key name
        if (tSpecialKey.code ~= nil) then
            return tSpecialKey.code
        end

        -- Forced ASCII characters (e.g: used for AZERTY keyboard support)
        if (tSpecialKey.ASCII ~= nil) then
            local xKey = tSpecialKey.ASCII
            local iASCII = (type(xKey) == "number") and xKey or Input.GetKeyCode(xKey)

            return iKeyCode, iASCII, true
        end
    end

    -- Valid ASCII characters finder
    for _, tRange in ipairs(tASCIICharsRange) do
        if (iKeyCode >= tRange[1]) and (iKeyCode <= tRange[2]) then
            local bIsLetter = isLetter(sKey)

            if bIsLetter and (isCapsLockOn() or isShiftDown()) then
                return iKeyCode, iKeyCode
            end

            return iKeyCode, bIsLetter and Input.GetKeyCode(sKey:lower()) or iKeyCode
        end
    end

    return iKeyCode
end

-- Internal utils
----------------------------------------------------------------------

local function isRemoteURL(sURL)
    if (type(sURL) ~= "string") then return false end

    for _, sPrefix in ipairs(tRemoteURLPrefixes) do
        if (sURL:sub(1, #sPrefix) == sPrefix) then return true end
    end

    return false
end

local function isLocalURL(sURL)
    return (type(sURL) == "string") and (sURL:sub(1, #sLocalURLPrefix) == sLocalURLPrefix)
end

---Setup the material parameters of an actor, used for 3d2d rendering
local function setupMaterialParams(xActor)
    if not xActor or not xActor:IsValid() then return end

    xActor:SetMaterialScalarParameter("Specular", 0)
    xActor:SetMaterialScalarParameter("Roughness", 1)
    xActor:SetMaterialColorParameter("Normal", Color(0))
    xActor:SetMaterialColorParameter("Emissive", Color(0))
end

---Freeze WebUI3d2d objects that are not in the player's view or range
local function calcFreezeStates()
    if (next(tInstances) == nil) then return end

    local pPlayer = localPlayer()
    if not pPlayer then return end

    local tCamPos = pPlayer:GetCameraLocation()

    for oWebUI in pairs(tInstances) do
        if not oWebUI.__ready then goto continue end
        -- In use, or finishing an animation in sight (SetKeepAwake)
        if oWebUI:IsKeptAwake() then goto continue end

        if not oWebUI:WasRecentlyRendered() then
            if not oWebUI:IsFrozen() then
                oWebUI:SetFreeze(true)
            end
            goto continue
        end

        local iDist = oWebUI:GetLocation():DistanceSquared(tCamPos)
        local iBoundsSize = oWebUI:GetBounds().BoxExtent:Size()

        if oWebUI:IsFrozen() then
            if (iDist < (iBoundsSize * FREEZE_FROM_DIST) ^ 2) then
                oWebUI:SetFreeze(false)
            end
        else
            if (iDist > (iBoundsSize * FREEZE_FROM_DIST) ^ 2) then
                oWebUI:SetFreeze(true)
            end
        end

        ::continue::
    end
end

---Internal function to update the visibility of all WebUIs
local function updateWebUIsVisibility()
    for _, v in ipairs(WebUI.GetAll()) do
        if (v:GetClass() == WebUI3d2d) then goto continue end

        if oTargetUI then
            if (v:GetVisibility() ~= WidgetVisibility.Hidden) then
                v:SetValue("webui3d2d_prev_visibility", v:GetVisibility(), false)
                v:SetVisibility(WidgetVisibility.VisibleNotHitTestable)
            end
        else
            local iPrevVisibility = v:GetValue("webui3d2d_prev_visibility")
            if iPrevVisibility then
                v:SetVisibility(iPrevVisibility)
                v:SetValue("webui3d2d_prev_visibility", nil, false)
            end
        end

        ::continue::
    end
end

-- 3D cursor
----------------------------------------------------------------------

---A rotation tilted by the smallest turn that brings its up axis (+Z) onto a direction
---@param tRot Rotator
---@param tDir Vector @Unit direction
---@return Rotator
local function tiltUpOnto(tRot, tDir)
    local tUp = tRot:GetUpVector()
    local fDot = mathMax(-1, mathMin(tUp:Dot(tDir), 1))
    if (fDot > 0.9999) then return tRot end

    -- Facing the other way (the mesh seen from behind): half a turn around its forward axis
    local tAxis = (fDot < -0.9999) and tRot:GetForwardVector() or tUp:Cross(tDir):GetSafeNormal()
    local fHalfAngle = (math.acos(fDot) / 2)
    local fSin = math.sin(fHalfAngle)

    return (Quat(tAxis.X * fSin, tAxis.Y * fSin, tAxis.Z * fSin, math.cos(fHalfAngle)) * tRot:Quaternion()):Rotator()
end

---Get the 3d space location and rotation of the cursor plane: laid on the mesh, its texture's top-left
---corner (the arrow's tip) on the hit point
---@param tTrace table @The trace result of the target lookup
---@return Vector @The location of the cursor plane
---@return Rotator @The rotation of the cursor plane
local function findCursorDecalPos(tTrace)
    if not oTargetUI or not oTargetUI:IsValid() then
        return Vector(), Rotator()
    end

    -- The mesh's rotation, so the cursor's texture runs like the page's (U along X, V along Y), tilted onto
    -- the surface where it's hit: a bent mesh's curve, the mesh facing its local +Z like SM_Plane
    local tRot = tiltUpOnto(oTargetUI:GetRotation(), tTrace.Normal)
    local fHalfSize = oTargetUI:GetCursorDecalSize()

    return tTrace.Location + (tTrace.Normal * CURSOR_OFFSET) + (tRot:GetForwardVector() * fHalfSize) + (tRot:GetRightVector() * fHalfSize), tRot
end

---Internal function to hide the cursor decal after a delay without activity, and show it again on activity
---@param iNow integer @Current time in milliseconds
local function updateCursorDecalVisibility(iNow)
    if not oTargetUI or not oTargetUI:IsValid() then return end
    if not oTargetUI.__cursor_decal or not oTargetUI.__cursor_decal:IsValid() then return end
    if (CURSOR_HIDE_DELAY <= 0) or not oTargetUI.__last_activity then return end

    -- Its visibility is kept in Lua rather than asked of the engine on every lookup
    local bActive = ((iNow - oTargetUI.__last_activity) < CURSOR_HIDE_DELAY)
    if (bActive ~= oTargetUI.__cursor_decal_visible) then
        oTargetUI.__cursor_decal_visible = bActive
        oTargetUI.__cursor_decal:SetVisibility(bActive)
    end
end

---Scale of the cursor plane for a cursor size
---@param fHalfSize number @Half the cursor's width, in cm
---@return Vector
local function getCursorScale(fHalfSize)
    local fScale = (fHalfSize * 2 / PLANE_SIZE)
    return Vector(fScale, fScale, 1)
end

---`🔸 Client`<br>
---Handles the WebUI3d2d cursor movement
---@param oWebUI WebUI3d2d @The WebUI3d2d instance to handle the cursor movement for
---@param tTrace table @The trace result of the target lookup
---@param fGlideTime number @Seconds the cursor takes to reach its new location
local function handleCursorMouseMove(oWebUI, tTrace, fGlideTime)
    if not oWebUI:IsCursorDecalEnabled() then return end

    local tLoc, tRot = findCursorDecalPos(tTrace)

    -- Created on a cursor move rather than on targeting, so a cursor turned on mid-target shows up too
    if not oWebUI.__cursor_decal or not oWebUI.__cursor_decal:IsValid() then
        oWebUI.__cursor_decal = StaticMesh(tLoc, tRot, "nanos-world::SM_Plane", CollisionType.NoCollision)
        oWebUI.__cursor_decal:SetScale(getCursorScale(oWebUI:GetCursorDecalSize()))
        oWebUI.__cursor_decal:SetCastShadow(false)
        oWebUI.__cursor_decal:SetMaterial(CURSOR_MATERIAL)
        oWebUI.__cursor_decal:SetMaterialTextureParameter("Texture", CURSOR_TEXTURE)
        oWebUI.__cursor_decal_visible = true
        oWebUI.__cursor_decal_rot = tRot
        return
    end

    -- Glide to the new cursor location until the next lookup (engine-side interpolation)
    oWebUI.__cursor_decal:TranslateTo(tLoc, fGlideTime, 0)

    -- Turned only when the surface under it does, which a flat mesh never does
    if not tRot:Equals(oWebUI.__cursor_decal_rot, 0.01) then
        oWebUI.__cursor_decal_rot = tRot
        oWebUI.__cursor_decal:SetRotation(tRot)
    end
end

-- WebUI3d2d targeting
----------------------------------------------------------------------

---`🔸 Client`<br>
---Get the current targeted WebUI3d2d
---@return WebUI3d2d|nil @WebUI3d2d instance
function Player:GetTargetedWebUI3d2d()
    if oTargetUI and oTargetUI:IsValid() then
        return oTargetUI
    end
end

---UV of a trace hit on a WebUI3d2d mesh. nanos can return no hit UV (0, 0) when the hit body has<br>
---no complex collision or UV support; on the default plane the UV then follows from where the<br>
---trace hit the plane. Other meshes rely on nanos' UV.
---@param oWebUI WebUI3d2d @The WebUI3d2d instance
---@param tTrace table @The trace result
---@return number @U
---@return number @V
local function getHitUV(oWebUI, tTrace)
    local tUV = tTrace.UV
    if tUV and ((tUV.X ~= 0) or (tUV.Y ~= 0)) then
        return tUV.X, tUV.Y
    end

    if not oWebUI.__default_mesh then
        return 0, 0
    end

    local eMesh = oWebUI.__mesh
    local tLocal = eMesh:GetRotation():UnrotateVector(tTrace.Location - eMesh:GetLocation())
    local tScale = eMesh:GetScale()
    local fU = (tLocal.X / (PLANE_SIZE * tScale.X)) + 0.5
    local fV = (tLocal.Y / (PLANE_SIZE * tScale.Y)) + 0.5

    return mathMax(0, mathMin(fU, 1)), mathMax(0, mathMin(fV, 1))
end

---The targeting control in use: the cursor while the mouse is enabled, the camera otherwise
---@param bMouseEnabled boolean
---@return WebUI3d2dTargeting
local function getTargetingControl(bMouseEnabled)
    return bMouseEnabled and WebUI3d2dTargeting.Cursor or WebUI3d2dTargeting.Camera
end

---Whether a ready WebUI3d2d can be targeted with the current control
---@param bMouseEnabled boolean @Is the cursor the control
---@return boolean
local function hasTargetable(bMouseEnabled)
    local iControl = getTargetingControl(bMouseEnabled)

    for oWebUI in pairs(tInstances) do
        if oWebUI.__ready and ((oWebUI:GetTargeting() & iControl) ~= 0) then
            return true
        end
    end

    return false
end

---Lookup for a targetted WebUI3d2d object and find the mouse position (in pixels) on this WebUI3d2d
---@return WebUI3d2d? @WebUI3d2d instance
---@return number? @Cursor X on the page, in pixels
---@return number? @Cursor Y on the page, in pixels
---@return table? @The trace that hit it
local function targetLookup()
    -- The trace is the lookup's cost, skipped while no WebUI3d2d could take the hit
    local bMouseEnabled = Input.IsMouseEnabled()
    if not hasTargetable(bMouseEnabled) then return end

    local pPlayer = localPlayer()
    if not pPlayer then return end

    local tTrace

    -- The cursor plane floats in front of the mesh, the trace goes through it
    local eCursor = oTargetUI and oTargetUI.__cursor_decal
    local tIgnored = tNoActors
    if eCursor and eCursor:IsValid() then
        tCursorIgnored[1] = eCursor
        tIgnored = tCursorIgnored
    end

    -- Perform a trace line to find a potential target
    if bMouseEnabled then
        local tCursorToWorld = deprojectScreenToWorld(getMousePosition())

        tTrace = traceLineSingle(
            tCursorToWorld.Position,
            tCursorToWorld.Position + (tCursorToWorld.Direction * (MAX_UI_SIZE * 2)),
            iCollisionChannel,
            iTraceMode,
            tIgnored
        )
    else
        local tCamPos = pPlayer:GetCameraLocation()

        tTrace = traceLineSingle(
            tCamPos,
            tCamPos + (pPlayer:GetCameraRotation():GetForwardVector() * (MAX_UI_SIZE * 2)),
            iCollisionChannel,
            iTraceMode,
            tIgnored
        )
    end

    -- Check if the trace hit a WebUI3d2d, and if it's interactable
    if not tTrace.Entity then return end
    local oWebUI = tTrace.Entity:GetValue("webui3d2d_page")
    if not oWebUI or not oWebUI.__ready or not oWebUI:IsInteractable() then return end

    -- Check if the WebUI3d2d is big enough on screen to use (MIN_SCREEN_PERCENTAGE)
    if (oWebUI:GetScreenPercentage() < MIN_SCREEN_PERCENTAGE) then return end

    -- Translate the UV coordinates to pixels
    local tSize = oWebUI:GetSize()
    local fU, fV = getHitUV(oWebUI, tTrace)
    local iX = mathFloor(fU * tSize.X)
    local iY = mathFloor(fV * tSize.Y)

    return oWebUI, iX, iY, tTrace
end

---Releases the keys still held down on a WebUI3d2d
---@param oWebUI WebUI3d2d
local function releaseHeldKeys(oWebUI)
    local iWebUIModifiers = getWebUIModifiers(oWebUI)

    for iKeyCode, _ in pairs(oWebUI.__down_keys) do
        oWebUI:SendKeyEvent(WebUIKeyType.Up, iKeyCode, iWebUIModifiers)
    end

    oWebUI.__down_keys = {}
end

---Untargets the current targeted WebUI3d2d
local function untargetWebUI3d2d()
    if not oTargetUI then return end

    local xOldTarget = oTargetUI

    -- Remove cursor decal
    if oTargetUI.__cursor_decal and oTargetUI.__cursor_decal:IsValid() then
        oTargetUI.__cursor_decal:Destroy()
        oTargetUI.__cursor_decal = nil
    end

    -- A target destroyed before this gets no events, but the shared state below still resets, or every
    -- other WebUI would stay click-through
    if oTargetUI:IsValid() then
        -- Reset down keys/mouse buttons/mouse movement
        releaseHeldKeys(oTargetUI)

        -- Each button is released with the modifiers it leaves held, like doMouseUp
        local tDownButtons = oTargetUI.__down_mouse_buttons
        for sKey, _ in pairs(tDownButtons) do
            tDownButtons[sKey] = nil
            if tMouseTypes[sKey] then
                oTargetUI:SendMouseClickEvent(0, 0, tMouseTypes[sKey], true, getWebUIModifiers(oTargetUI), 1)
            end
        end

        oTargetUI:SendMouseMoveEvent(0, 0, getWebUIModifiers(oTargetUI), true)
        oTargetUI.__cursor_x, oTargetUI.__cursor_y = 0, 0
    end

    oTargetUI = false
    bKeyboardEngaged = false

    updateWebUIsVisibility()

    Events.Call("OnWebUI3d2dTargetChange", xOldTarget, oTargetUI)
end

---Targets a WebUI3d2d
---@param oWebUI WebUI3d2d instance
local function targetWebUI3d2d(oWebUI)
    local xOldTarget = oTargetUI

    untargetWebUI3d2d()
    oTargetUI = oWebUI

    updateWebUIsVisibility()

    Events.Call("OnWebUI3d2dTargetChange", xOldTarget, oTargetUI)
end

-- Target lookup and freeze check
----------------------------------------------------------------------

local function lookupTick()
    -- Next target lookup, sooner while a WebUI3d2d is targeted. Scheduled first so an error below can't end the loop
    Timer.SetTimeout(lookupTick, mathFloor(1000 / (oTargetUI and TARGET_TICK_RATE or TARGET_IDLE_TICK_RATE)))

    -- Timers fire on frames, so a lookup lands up to a frame after its interval. The cursor glides for the gap
    -- since the last lookup, the best guess of the next one, so it keeps moving until then; capped at two
    -- intervals so the first move after a pause doesn't crawl
    local iNow = Client.GetTime()
    local fGlideTime = (mathMin(iNow - iLastLookupTime, 2000 / TARGET_TICK_RATE) / 1000)
    iLastLookupTime = iNow

    -- Find a targeted WebUI3d2d
    local oWebUI, iX, iY, tTrace = targetLookup()
    if not oWebUI or not oWebUI:IsValid() then
        untargetWebUI3d2d()
        return
    end

    -- WebUI3d2d targeted
    if oTargetUI then
        if (oTargetUI ~= oWebUI) then
            targetWebUI3d2d(oWebUI)
        end
    else
        targetWebUI3d2d(oWebUI)
    end

    if (iX ~= oWebUI.__cursor_x) or (iY ~= oWebUI.__cursor_y) then
        oWebUI.__last_activity = iNow
        oWebUI.__cursor_x, oWebUI.__cursor_y = iX, iY
        oWebUI:SendMouseMoveEvent(iX, iY, getWebUIModifiers(oWebUI), false)

        handleCursorMouseMove(oWebUI, tTrace, fGlideTime)
    end

    updateCursorDecalVisibility(iNow)
end

Timer.SetTimeout(lookupTick, mathFloor(1000 / TARGET_IDLE_TICK_RATE))

-- Freeze check (CPU saver)
Timer.SetInterval(calcFreezeStates, FREEZE_CHECK_DELAY)

-- Mouse Events
----------------------------------------------------------------------

---Whether the game still gets an input while a WebUI3d2d is targeted, as the Input handlers return it
---@param iInput WebUI3d2dInput
---@return boolean
local function gameGetsInput(iInput)
    return ((oTargetUI:GetBlockedGameInput() & iInput) == 0)
end

local function doMouseDown(sKey)
    if not oTargetUI or not oTargetUI:IsValid() then return end
    if not tMouseTypes[sKey] then return end

    -- Multiple clicks detection
    local iTime = Client.GetTime()

    if oTargetUI.__last_clicked_key and (oTargetUI.__last_clicked_key == sKey) then
        if ((iTime - (oTargetUI.__last_click_time or 0)) < 250) then
            oTargetUI.__click_count = mathMin((oTargetUI.__click_count or 0) + 1, 3)
        else
            oTargetUI.__click_count = 1
        end
    else
        oTargetUI.__click_count = 1
    end

    -- First click/simple click
    oTargetUI.__last_click_time = iTime
    oTargetUI.__last_clicked_key = sKey
    -- Before the event, so its modifiers hold the button like the engine's state did
    oTargetUI.__down_mouse_buttons[sKey] = true

    oTargetUI:SendMouseClickEvent(
        oTargetUI.__cursor_x,
        oTargetUI.__cursor_y,
        tMouseTypes[sKey],
        false,
        getWebUIModifiers(oTargetUI),
        oTargetUI.__click_count
    )

    oTargetUI.__last_activity = iTime

    -- Captures the keyboard (WebUI3d2dKeyboardCapture.OnClick) until it's untargeted or Escape is pressed
    bKeyboardEngaged = true

    return gameGetsInput(WebUI3d2dInput.Mouse)
end

Input.Subscribe("MouseDown", doMouseDown)

local function doMouseUp(sKey)
    if not oTargetUI or not oTargetUI:IsValid() then return end
    if not tMouseTypes[sKey] then return end

    -- Before the event, so its modifiers no longer hold the button, like the engine's state did
    oTargetUI.__down_mouse_buttons[sKey] = nil

    oTargetUI:SendMouseClickEvent(
        oTargetUI.__cursor_x,
        oTargetUI.__cursor_y,
        tMouseTypes[sKey],
        true,
        getWebUIModifiers(oTargetUI),
        1
    )
    oTargetUI.__last_activity = Client.GetTime()

    return gameGetsInput(WebUI3d2dInput.Mouse)
end

--[[ Input MouseUp ]]--
Input.Subscribe("MouseUp", doMouseUp)

-- Keyboard Events
----------------------------------------------------------------------

---Whether the targeted WebUI3d2d captures the keyboard: always, or since a click on it
---@return boolean
local function capturesKeyboard()
    local iMode = oTargetUI:GetKeyboardCapture()
    if (iMode == WebUI3d2dKeyboardCapture.Always) then return true end

    return (iMode == WebUI3d2dKeyboardCapture.OnClick) and bKeyboardEngaged
end

Input.Subscribe("KeyDown", function(_)
    if not oTargetUI or not oTargetUI:IsValid() then return end
    -- Keys stay with the game until the WebUI3d2d captures the keyboard
    if not capturesKeyboard() then return end

    return gameGetsInput(WebUI3d2dInput.Keyboard)
end)

local function doKeyPress(sKey)
    if not oTargetUI or not oTargetUI:IsValid() then return end

    -- A mouse alias key acts as its mouse button only, it isn't typed into the page
    local sMBAlias = oTargetUI:GetMouseAliasKey(sKey)
    if sMBAlias then
        return doMouseDown(sMBAlias)
    end

    -- Check if the WebUI3d2d captures the keyboard, if a valid key is found, etc..
    if not capturesKeyboard() then return end

    -- Escape hands the keyboard back to the game
    if (sKey == "Escape") and (oTargetUI:GetKeyboardCapture() == WebUI3d2dKeyboardCapture.OnClick) then
        bKeyboardEngaged = false
        releaseHeldKeys(oTargetUI)
        return gameGetsInput(WebUI3d2dInput.Keyboard)
    end

    local iKeyCode, iASCIICode, bASCIICharOnly = getKeyInfo(sKey)
    if not iKeyCode then
        return gameGetsInput(WebUI3d2dInput.Keyboard)
    end

    local iWebUIModifiers = getWebUIModifiers(oTargetUI)

    if not bASCIICharOnly then
        oTargetUI:SendKeyEvent(WebUIKeyType.Down, iKeyCode, iWebUIModifiers)
        oTargetUI.__down_keys[iKeyCode] = true
    end

    if iASCIICode then
        oTargetUI:SendKeyEvent(WebUIKeyType.Char, iASCIICode, iWebUIModifiers)
    end

    -- Update last activity
    oTargetUI.__last_activity = Client.GetTime()

    return gameGetsInput(WebUI3d2dInput.Keyboard)
end

Input.Subscribe("KeyPress", doKeyPress)

local function doKeyRelease(sKey)
    if not oTargetUI or not oTargetUI:IsValid() then return end

    -- A mouse alias key acts as its mouse button only
    local sMBAlias = oTargetUI:GetMouseAliasKey(sKey)
    if sMBAlias then
        return doMouseUp(sMBAlias)
    end

    -- Check if the WebUI3d2d captures the keyboard, if a valid key is found, etc..
    if not capturesKeyboard() then return end

    -- Only a key the page got a Down for (char-only keys get a Char alone)
    local iKeyCode = getKeyInfo(sKey)
    if not iKeyCode or not oTargetUI.__down_keys[iKeyCode] then return end

    oTargetUI:SendKeyEvent(WebUIKeyType.Up, iKeyCode, getWebUIModifiers(oTargetUI))

    oTargetUI.__down_keys[iKeyCode] = nil
    oTargetUI.__last_activity = Client.GetTime()
end

Input.Subscribe("KeyUp", doKeyRelease)

local function doMouseScroll(_, _, iDelta)
    if not oTargetUI or not oTargetUI:IsValid() then return end

    local iWHMax = mathMax(oTargetUI.__width, oTargetUI.__height)

    oTargetUI:SendMouseWheelEvent(
        oTargetUI.__cursor_x,
        oTargetUI.__cursor_y,0,
        (iDelta * mathFloor(iWHMax * 0.1))
    )

    oTargetUI.__last_activity = Client.GetTime()

    return gameGetsInput(WebUI3d2dInput.Mouse)
end

Input.Subscribe("MouseScroll", doMouseScroll)

-- WebUI3d2d lifecycle
----------------------------------------------------------------------

local function onFail(oWebUI)
    oWebUI:MakeNoSignal()

    if oWebUI:IsReloadOnFailEnabled() then
        Timer.SetTimeout(function()
            if not oWebUI:IsValid() then return end
            oWebUI:LoadURL(oWebUI.__path)
        end, 2000)
    end
end

local function onReady(oWebUI)
    oWebUI:SetFreeze(false)
    oWebUI.__mesh:SetMaterialFromWebUI(oWebUI, oWebUI.__material_index)

    oWebUI.__ready = true
end

local function onDestroy(oWebUI)
    tInstances[oWebUI] = nil

    if oTargetUI and (oTargetUI == oWebUI) then
        untargetWebUI3d2d()
    end

    if oWebUI.__mesh and oWebUI.__mesh:IsValid() then oWebUI.__mesh:Destroy() end
    if oWebUI.__cursor_decal and oWebUI.__cursor_decal:IsValid() then oWebUI.__cursor_decal:Destroy() end
end

-- WebUI3d2d mesh
----------------------------------------------------------------------

---Whether a value is a Vector2D, or anything with numbers as X and Y
---@param xValue any
---@return boolean
local function isVector2D(xValue)
    local sType = type(xValue)
    return ((sType == "table") or (sType == "userdata")) and (type(xValue.X) == "number") and (type(xValue.Y) == "number")
end

---A page resolution brought within MIN_UI_SIZE and MAX_UI_SIZE, keeping its ratio: the long side down to
---MAX_UI_SIZE first, then the short side up to MIN_UI_SIZE
---@param tResolution Vector2D @Resolution in pixels
---@return integer @Width in pixels
---@return integer @Height in pixels
local function clampResolution(tResolution)
    local fW = mathMax(1, mathAbs(tResolution.X))
    local fH = mathMax(1, mathAbs(tResolution.Y))
    local fScale = mathMin(1, (MAX_UI_SIZE / mathMax(fW, fH)))
    fScale = mathMax(fScale, (MIN_UI_SIZE / mathMin(fW, fH)))

    return mathFloor((fW * fScale) + 0.5), mathFloor((fH * fScale) + 0.5)
end

---Sets the WebUI3d2d's mesh up for the page: its scale (the default plane sized from the page resolution,
---another mesh at 1), its material parameters, and the page on its material slot, or noise until it's ready
---@param oWebUI WebUI3d2d
---@param sMesh? string @Mesh asset, nil for the default plane
---@param iMaterialIndex? integer @Material slot the page is painted on, -1 for every slot
local function applyMesh(oWebUI, sMesh, iMaterialIndex)
    local eMesh = oWebUI.__mesh

    oWebUI.__default_mesh = ((sMesh or DEFAULT_MESH) == DEFAULT_MESH)
    oWebUI.__material_index = (iMaterialIndex or -1)

    if oWebUI.__default_mesh then
        local fCmPerScale = (PLANE_PIXELS_PER_CM * PLANE_SIZE)
        eMesh:SetScale(Vector((oWebUI.__width / fCmPerScale), (oWebUI.__height / fCmPerScale), 1))
    else
        eMesh:SetScale(Vector(1))
    end

    setupMaterialParams(eMesh)

    if oWebUI.__ready then
        eMesh:SetMaterialFromWebUI(oWebUI, oWebUI.__material_index)
    else
        -- Noise until `onReady` paints the page, or for good if the URL is not valid
        oWebUI:MakeNoSignal()
    end
end

-- WebUI3d2d class and methods
----------------------------------------------------------------------

---`🔸 Client`<br>
---`WebUI3d2d` is a class that represents a WebUI3d2d instance: a page painted on a mesh in the world
---@class WebUI3d2d : WebUI
---@overload fun(sURL: string, tResolution?: Vector2D, bTransparent?: boolean, sMesh?: string, iMaterialIndex?: integer): WebUI3d2d
WebUI3d2d = WebUI.Inherit("WebUI3d2d")

---`🔸 Client`<br>
---Spawns a WebUI3d2d. The default mesh, nanos-world::SM_Plane, is sized from the page resolution
---(PLANE_PIXELS_PER_CM pixels per centimetre) so the page isn't stretched; SetPlaneSize changes it
---@param sURL string @Page to load: a web URL, or a local page as `file://my_page.html`
---@param tResolution? Vector2D @Page resolution in pixels, brought within MIN_UI_SIZE and MAX_UI_SIZE keeping its ratio; past a 34:1 ratio both can't hold and the short side's MIN_UI_SIZE wins (default 1920 x 1080)
---@param bTransparent? boolean @Should the page's transparent parts show through (default false)
---@param sMesh? string @Mesh the page is painted on (default nanos-world::SM_Plane)
---@param iMaterialIndex? integer @Material slot of the mesh the page is painted on, -1 for every slot (default -1)
function WebUI3d2d:Constructor(sURL, tResolution, bTransparent, sMesh, iMaterialIndex)
    sURL = (type(sURL) == "string") and sURL or ""
    bTransparent = (bTransparent and true or false)

    local iW, iH = clampResolution(isVector2D(tResolution) and tResolution or DEFAULT_RESOLUTION)

    -- WebUI3d2d instance and listeners
    self.Super:Constructor("", sURL, WidgetVisibility.Hidden, bTransparent, false, iW, iH)
    self:Subscribe("Fail", onFail)
    self:Subscribe("Ready", onReady)
    self:Subscribe("Destroy", onDestroy)

    -- WebUI3d2d properties
    self.__width = iW
    self.__height = iH
    self.__cursor_decal_enabled = true
    self.__targeting = WebUI3d2dTargeting.All
    self.__keyboard_capture = WebUI3d2dKeyboardCapture.OnClick
    self.__blocked_game_input = WebUI3d2dInput.All

    self.__reload_on_fail = true
    self.__keep_awake = false
    self.__path = sURL -- WebUI has no GetPath, the reload on fail reads this
    self.__mouse_aliases = {}

    self.__cursor_x = 0
    self.__cursor_y = 0
    self.__down_keys = {}
    self.__down_mouse_buttons = {}

    -- Parent mesh
    self.__mesh = StaticMesh(Vector(), Rotator(), sMesh or DEFAULT_MESH)
    self.__mesh:SetValue("webui3d2d_page", self, false)
    self.__mesh:SetCollision(CollisionType.NoCollision)
    self.__mesh:SetCastShadow(false)
    self.__mesh:Subscribe("Destroy", function()
        if self:IsValid() then
            self:Destroy()
        end
    end)

    applyMesh(self, sMesh, iMaterialIndex)

    tInstances[self] = true
end

---`🔸 Client`<br>
---Makes the WebUI3d2d load the given URL
---@param sURL string @The URL to load
function WebUI3d2d:LoadURL(sURL)
    if not (isLocalURL(sURL) or isRemoteURL(sURL)) then
        self:MakeNoSignal()
        return
    end

    self.__path = sURL
    self.Super:LoadURL(sURL)
    self.__mesh:SetMaterialFromWebUI(self, self.__material_index)
end

---`🔸 Client`<br>
---Returns the URL the WebUI3d2d last loaded
---@return string @The URL
function WebUI3d2d:GetURL()
    return self.__path
end

---`🔸 Client`<br>
---Sets the WebUI3d2d to a "no signal" state
function WebUI3d2d:MakeNoSignal()
    self.__mesh:SetMaterial("nanos-world::M_Noise", self.__material_index)
end

---`🔸 Client`<br>
---Returns the static mesh on which the WebUI3d2d is painted
---@return StaticMesh @The parent mesh
function WebUI3d2d:GetStaticMesh()
    return self.__mesh
end

---`🔸 Client`<br>
---Returns the material index of the mesh the page is painted on
---@return integer @The material index, -1 for every slot
function WebUI3d2d:GetMaterialIndex()
    return self.__material_index
end

---`🔸 Client`<br>
---Changes the mesh the page is painted on. The mesh changes in place, keeping its location, its attachment
---and what's attached to it; its scale resets: the default plane to its size from the page resolution,
---another mesh to 1
---@param sMesh? string @Mesh asset, nil for the default plane (nanos-world::SM_Plane)
---@param iMaterialIndex? integer @Material slot of the mesh the page is painted on, -1 for every slot (default -1)
function WebUI3d2d:SetMesh(sMesh, iMaterialIndex)
    -- The page and noise painted on the previous mesh's slots would stay on the new one's
    self.__mesh:ResetMaterial(-1)
    self.__mesh:SetMesh(sMesh or DEFAULT_MESH)

    applyMesh(self, sMesh, iMaterialIndex)
end

---`🔸 Client`<br>
---Sets the default plane's size in centimetres. The page keeps its resolution, so a size off its ratio
---stretches it. Does nothing on another mesh, which SetScale sizes
---@param tSize Vector2D @Width and height in centimetres
function WebUI3d2d:SetPlaneSize(tSize)
    if not self.__default_mesh or not isVector2D(tSize) then return end
    self.__mesh:SetScale(Vector((mathAbs(tSize.X) / PLANE_SIZE), (mathAbs(tSize.Y) / PLANE_SIZE), 1))
end

---`🔸 Client`<br>
---Returns the default plane's size in centimetres, nil on another mesh
---@return Vector2D|nil @Width and height in centimetres
function WebUI3d2d:GetPlaneSize()
    if not self.__default_mesh then return end

    local tScale = self.__mesh:GetScale()
    return Vector2D((tScale.X * PLANE_SIZE), (tScale.Y * PLANE_SIZE))
end


---`🔸 Client`<br>
---Sets the controls the WebUI3d2d can be targeted with: the mouse cursor while the mouse is enabled, aiming the camera while it's disabled
---@param iTargeting WebUI3d2dTargeting @Flags, e.g. `WebUI3d2dTargeting.Cursor`
function WebUI3d2d:SetTargeting(iTargeting)
    if (math.type(iTargeting) ~= "integer") then return end
    self.__targeting = (iTargeting & iTargetingMask)
end

---`🔸 Client`<br>
---Returns the controls the WebUI3d2d can be targeted with
---@return WebUI3d2dTargeting @Flags
function WebUI3d2d:GetTargeting()
    return self.__targeting
end

---`🔸 Client`<br>
---Sets when the WebUI3d2d captures the keyboard while it's targeted, taking keys from the game: never, from a click on it until it's untargeted or Escape is pressed, or always
---@param iMode WebUI3d2dKeyboardCapture
function WebUI3d2d:SetKeyboardCapture(iMode)
    if (math.type(iMode) ~= "integer") or (iMode < iKeyboardCaptureMin) or (iMode > iKeyboardCaptureMax) then return end
    self.__keyboard_capture = iMode
end

---`🔸 Client`<br>
---Returns when the WebUI3d2d captures the keyboard while it's targeted
---@return WebUI3d2dKeyboardCapture
function WebUI3d2d:GetKeyboardCapture()
    return self.__keyboard_capture
end

---`🔸 Client`<br>
---Sets the game inputs kept from firing while the WebUI3d2d is targeted; the others reach the game as well as the WebUI3d2d. Keys are only kept from the game while the WebUI3d2d captures the keyboard (`SetKeyboardCapture`)
---@param iInputs WebUI3d2dInput @Flags, e.g. `WebUI3d2dInput.Mouse`
function WebUI3d2d:SetBlockedGameInput(iInputs)
    if (math.type(iInputs) ~= "integer") then return end
    self.__blocked_game_input = (iInputs & iGameInputMask)
end

---`🔸 Client`<br>
---Returns the game inputs kept from firing while the WebUI3d2d is targeted
---@return WebUI3d2dInput @Flags
function WebUI3d2d:GetBlockedGameInput()
    return self.__blocked_game_input
end

---`🔸 Client`<br>
---Adds a key to the mouse aliases
---@param sKey string @The key to be aliased
---@param sMouseButton string @The mouse button to be aliased
function WebUI3d2d:AddMouseAliasKey(sKey, sMouseButton)
    self.__mouse_aliases[sKey] = sMouseButton
end

---`🔸 Client`<br>
---Removes a key from the mouse aliases
---@param sKey string @The key to be removed
function WebUI3d2d:RemoveMouseAliasKey(sKey)
    self.__mouse_aliases[sKey] = nil
end

---`🔸 Client`<br>
---Returns the mouse aliases table
---@return table<string, string> @The mouse aliases
function WebUI3d2d:GetAllMouseAliasKeys()
    return self.__mouse_aliases
end

---`🔸 Client`<br>
---Returns the mouse button aliased to a key
---@param sKey string @The key to be checked
---@return string @The mouse button aliased to the key
function WebUI3d2d:GetMouseAliasKey(sKey)
    return self.__mouse_aliases[sKey]
end

---`🔸 Client`<br>
---Enable or disable reloading the page 2 seconds after it fails to load
---@param bEnabled boolean @Should the WebUI3d2d reload on fail
function WebUI3d2d:SetReloadOnFailEnabled(bEnabled)
    self.__reload_on_fail = (bEnabled and true or false)
end

---`🔸 Client`<br>
---Returns whether the WebUI3d2d reloads its page when it fails to load
---@return boolean @Is reload on fail enabled?
function WebUI3d2d:IsReloadOnFailEnabled()
    return self.__reload_on_fail
end

---`🔸 Client`<br>
---Returns whether the WebUI3d2d can be targeted with the current control: the cursor while the mouse is enabled, aiming otherwise
---@return boolean @Is the WebUI3d2d interactable?
function WebUI3d2d:IsInteractable()
    return ((self:GetTargeting() & getTargetingControl(Input.IsMouseEnabled())) ~= 0)
end

---`🔸 Client`<br>
---Returns the cursor's position on the page, in pixels: (0, 0) while the WebUI3d2d isn't targeted
---@return Vector2D @The cursor position
function WebUI3d2d:GetCursorPosition()
    return Vector2D(self.__cursor_x, self.__cursor_y)
end

---`🔸 Client`<br>
---Freezes or resumes the page's rendering to the mesh. Its JavaScript keeps running either way, so `OnWebUI3d2dFreezeChange` is called on a change for the page's own script to pause its work
---@param bFreeze boolean @Should the WebUI3d2d be frozen
function WebUI3d2d:SetFreeze(bFreeze)
    bFreeze = (bFreeze and true or false)
    local bChanged = (self:IsFrozen() ~= bFreeze)

    self.Super:SetFreeze(bFreeze)

    if bChanged then
        Events.Call("OnWebUI3d2dFreezeChange", self, bFreeze)
    end
end

---`🔸 Client`<br>
---Keeps the WebUI3d2d rendering whatever its distance or view, for a page in use or one finishing an animation in sight. On release it can stay awake a little longer, so the frame left on the mesh once it freezes is the final one
---@param bAwake boolean @Should the WebUI3d2d stay awake
---@param iReleaseDelay? integer @On release, milliseconds before it may freeze again (default 0)
function WebUI3d2d:SetKeepAwake(bAwake, iReleaseDelay)
    self.__keep_awake = (bAwake and true or false)

    if self.__keep_awake then
        self.__keep_awake_until = nil
        if self.__ready and self:IsFrozen() then
            self:SetFreeze(false)
        end
    else
        self.__keep_awake_until = (Client.GetTime() + mathMax(0, iReleaseDelay or 0))
    end
end

---`🔸 Client`<br>
---Returns wether the WebUI3d2d is kept awake, by SetKeepAwake or its release delay
---@return boolean @Is the WebUI3d2d kept awake?
function WebUI3d2d:IsKeptAwake()
    if self.__keep_awake then return true end
    return (self.__keep_awake_until ~= nil) and (Client.GetTime() < self.__keep_awake_until)
end

-- Cursor decal
----------------------------------------------------------------------

---`🔸 Client`<br>
---Enable or disable the 3D cursor decal, shown with either targeting control. Turned off, the decal goes at once; turned on, it shows on the next cursor move
---@param bEnabled boolean @Should the 3D cursor decal be enabled or not
function WebUI3d2d:SetCursorDecalEnabled(bEnabled)
    self.__cursor_decal_enabled = (bEnabled and true or false)

    if not self.__cursor_decal_enabled and self.__cursor_decal and self.__cursor_decal:IsValid() then
        self.__cursor_decal:Destroy()
        self.__cursor_decal = nil
    end
end

---`🔸 Client`<br>
---Returns whether the 3D cursor decal is enabled
---@return boolean @Is the 3D cursor decal enabled?
function WebUI3d2d:IsCursorDecalEnabled()
    return self.__cursor_decal_enabled
end

---`🔸 Client`<br>
---Returns the 3D cursor, a small plane laid on the mesh, nil until the cursor first moves on the targeted WebUI3d2d
---@return StaticMesh|nil @The 3D cursor
function WebUI3d2d:GetCursorDecal()
    return self.__cursor_decal
end

---`🔸 Client`<br>
---Sets the 3D cursor size: half its width, in cm
---@param fSize number @Half the 3D cursor's width, in cm
function WebUI3d2d:SetCursorDecalSize(fSize)
    if (type(fSize) ~= "number") or (fSize <= 0) then return end
    self.__cursor_decal_size = fSize

    -- A cursor already shown takes the size now, its tip back on the hit point at the next cursor move
    if self.__cursor_decal and self.__cursor_decal:IsValid() then
        self.__cursor_decal:SetScale(getCursorScale(fSize))
    end
end

---`🔸 Client`<br>
---Returns the 3D cursor size: half its width, in cm
---@return number @Half the 3D cursor's width, in cm
function WebUI3d2d:GetCursorDecalSize()
    return self.__cursor_decal_size or DEFAULT_CURSOR_DECAL_SIZE
end

-- WebUI3d2d wrapper methods
----------------------------------------------------------------------

local tSMWrapperMethods = {
    "AttachTo",
    "Detach",
    "GetAttachedTo",
    "GetBounds",
    "GetLocation",
    "GetRotation",
    "GetScale",
    "GetScreenPercentage",
    "RotateTo",
    "SetLifeSpan",
    "SetLocation",
    "SetRotation",
    "SetRelativeLocation",
    "SetRelativeRotation",
    "SetScale",
    "TranslateTo",
    "WasRecentlyRendered"
}

for _, sMethod in ipairs(tSMWrapperMethods) do
    WebUI3d2d[sMethod] = function(self, ...)
        return self.__mesh[sMethod](self.__mesh, ...)
    end
end