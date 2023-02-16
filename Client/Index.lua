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

local Client = Client
local Input = Input

local lerpVector = NanosMath.VInterpTo
local localPlayer = Client.GetLocalPlayer
local traceLineSingle = Trace.LineSingle
local getMousePosition = Viewport.GetMousePosition
local deprojectScreenToWorld = Viewport.DeprojectScreenToWorld

-- Dynamic vars (Internal)
local oTargetUI = false
local bDebugCommands = false
local iNextTargetLookup = 0
local iNextFreezeHandle = 0

-- Static (render)
local iMinUISize = 240                                                                      -- Minimum size in pixels of a WebUI3d2d page
local iMaxUISize = 8192                                                                     -- Maximum size in pixels of a WebUI3d2d page
local fDefaultCursorSize = 1.2                                                              -- Default cursor size (if not changed by `SetCursorSize`)
local iCursorHideDelay = 3000                                                               -- Delay in milliseconds before hiding the cursor decal when invactive (0 or less to disable)
local sCursorTexture = "package://"..Package.GetPath().."/Client/resources/cursor.png"      -- Path to the cursor texture

-- Static (performance)
local iTargetTickRate = 12                                                                  -- Tick rate when a WebUI3d2d is targeted (don't set it too high, it will cause performance issues)
local iTargetIdleTickRate = 4                                                               -- Tick rate when no WebUI3d2d is targeted (don't set it too high, it will cause performance issues)
local fFreezeFromDist = 4                                                                   -- Distance from the targeted WebUI3d2d at which the UI will freeze ((width + height) * VALUE)
local iFreezeCheckDelay = 1000                                                              -- Delay between freeze checks (don't set it too low or it will cause performance issues)

-- Local and remote URL regex
local sLocalURLRegex = [[^file://]]                                                         -- Regex to match local URL
local tValidRemoteURLStart = {"http://www.", "https://www.", "http://", "https://", "www."} -- List of valid remote URL start

-- Static vars (internal)
local iCollisionChannel = CollisionChannel.WorldStatic
local iTraceMode = TraceMode.TraceComplex | TraceMode.ReturnEntity | TraceMode.ReturnUV

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

--[[
    Special keys dictionary
    This table contains all the special treatment for some key names

    ASCII: The ASCII code of the key, will not trigger Up/Down events, will only send the Char event
    code: The code of the key, will only trigger Up/Down events, will not send the Char event
]]--
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

----------------------------------------------------------------------
-- Debug
----------------------------------------------------------------------
if bDebugCommands then
    -- webui3d2d_focus
    Console.RegisterCommand("webui3d2d_focus", function(iID)
        local oWebUI = WebUI3d2d.GetByIndex(tonumber(iID) or 1)
        if oWebUI and oWebUI:IsValid() then
            localPlayer():FocusWebUI3d2dCamera(oWebUI)
        end
    end, "Focus camera on a WebUI3d2d", {"id"})

    -- webui3d2d_unfocus
    Console.RegisterCommand("webui3d2d_unfocus", function()
        if localPlayer():GetCameraFocusedWebUI3d2d() then
            localPlayer():UnfocusWebUI3d2dCamera()
        end
    end, "Unfocus camera from a WebUI3d2d")

    -- webui3d2d_spawn
    Console.RegisterCommand("webui3d2d_spawn", function()
        local pPlayer = localPlayer()
        if not pPlayer then return end

        local tCamLoc = pPlayer:GetCameraLocation()
        local tCamRot = pPlayer:GetCameraRotation()

        local oTestUI = WebUI3d2d("www.google.com", false, 1920, 1080, Vector(1.92, 1.08, 1), true)
        oTestUI:SetLocation(tCamLoc + (tCamRot:GetForwardVector() * 2000) - Vector(0, 0, 40))
        oTestUI:TranslateTo(tCamLoc + (tCamRot:GetForwardVector() * 400) - Vector(0, 0, 40), 0.5, 0)

        oTestUI:SetRotation(Rotator(0, tCamRot.Yaw + 90, 359))
        oTestUI:RotateTo(Rotator(0, tCamRot.Yaw + 90, 80), 1, 0)
    end, "Spawns a WebUI3d2d")
end

----------------------------------------------------------------------
-- Internal utils (inputs related)
----------------------------------------------------------------------
--[[
    getWebUIModifiers
        desc: Translate key modifiers and mouse buttons to CEF modifiers
        return: WebUIModifier (integer)
]]--
local function getWebUIModifiers()
    local iKeyModifiers = Input.GetModifierKeys()
    local iWebUIModifiers = WebUIModifier.None

    for _, v in ipairs(tTranslateKeyModifiers) do
        if ((iKeyModifiers & v.keymodifier) ~= 0) then
            iWebUIModifiers = iWebUIModifiers | v.webuimodifier
        end
    end

    for _, v in ipairs(tTranslateMouseButtons) do
        if Input.IsKeyDown(v.button) then
            iWebUIModifiers = iWebUIModifiers | v.webuimodifier
        end
    end

    return iWebUIModifiers
end

--[[ isLetter ]]--
local function isLetter(sInput)
    return (#sInput == 1) and (sInput:match("[A-Za-z]") ~= nil)
end

--[[ isCapsLockOn ]]--
local function isCapsLockOn()
    return ((Input.GetModifierKeys() & KeyModifier.CapsLocked) ~= 0)
end

--[[ isShiftDown ]]--
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

--[[
    getKeyInfo
        desc: Find the keycode of a key, the ASCII code if it's an ASCII character, and if it shouldn't trigger Up/Down events
        return:
            Key code (integer)
            Is ASCII character (boolean)
            ASCII character only, don't trigger Up/Down event (boolean)
]]--
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

----------------------------------------------------------------------
-- Internal utils
----------------------------------------------------------------------
--[[ isRemoteURL ]]--
local function isRemoteURL(sURL)
    if type(sURL) ~= "string" then return end

    for _, sStart in ipairs(tValidRemoteURLStart) do
        if sURL:find('^'..sStart) then
            return true
        end
    end
end

--[[ isLocalURL ]]--
local function isLocalURL(sURL)
    return (type(sURL) ~= "string") and (sURL:match(sLocalURLRegex) ~= nil)
end

--[[
    setupMaterialParams
        desc: Setup the material parameters of an actor, used for 3d2d rendering
]]--
local function setupMaterialParams(xActor)
    if not xActor or not xActor:IsValid() then return end

    xActor:SetMaterialScalarParameter("Specular", 0)
    xActor:SetMaterialScalarParameter("Roughness", 1)
    xActor:SetMaterialColorParameter("Normal", Color(0))
    xActor:SetMaterialColorParameter("Emissive", Color(0.2))
end

--[[
    calcFreezeStates
        desc: Freeze WebUI3d2d objects that are not in the player's view or range
]]--
local function calcFreezeStates()
    local pPlayer = localPlayer()
    if not pPlayer then return end

    local tCamPos = pPlayer:GetCameraLocation()

    for _, oWebUI in ipairs(WebUI3d2d.GetAll()) do
        if not oWebUI.ready then goto continue end

        if not oWebUI:WasRecentlyRendered() then
            if not oWebUI:IsFrozen() then
                oWebUI:SetFreeze(true)
            end
            goto continue
        end

        local iDist = oWebUI:GetLocation():DistanceSquared(tCamPos)
        local iBoundsSize = oWebUI:GetBounds().BoxExtent:Size()

        if oWebUI:IsFrozen() then
            if (iDist < (iBoundsSize * fFreezeFromDist) ^ 2) then
                oWebUI:SetFreeze(false)
            end
        else
            if (iDist > (iBoundsSize * fFreezeFromDist) ^ 2) then
                oWebUI:SetFreeze(true)
            end
        end

        ::continue::
    end
end

--[[
    updateWebUIsVisibility
        desc: Internal function to update the visibility of all WebUIs
]]--
local function updateWebUIsVisibility()
    for _, v in ipairs(WebUI.GetAll()) do
        if (v:GetClass() == WebUI3d2d) then goto continue end

        if oTargetUI then
            if (v:GetVisibility() ~= WebUIVisibility.Hidden) then
                v:SetValue("webui3d2d_prev_visibility", v:GetVisibility(), false)
                v:SetVisibility(WebUIVisibility.VisibleNotHitTestable)
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

----------------------------------------------------------------------
-- 3D cursor
----------------------------------------------------------------------
--[[
    findCursorDecalPos
        desc: Get the 3d space location and rotation of the cursor decal
        return: Location (Vector), Rotation (Rotator)
]]--
local function findCursorDecalPos(tTrace)
    if not oTargetUI or not oTargetUI:IsValid() then
        return Vector(), Rotator()
    end

    local tRot = (tTrace.Normal:Rotation():Quaternion() * Quat(1, 0, 0, 0)):Rotator()
    local tUp = tRot:GetUpVector()
    local tRight = tRot:GetRightVector()
    local fCursorSize = oTargetUI:GetCursorSize()

    return tTrace.Location + (tRight * fCursorSize) + (tUp * fCursorSize), tRot
end

--[[ 
    cursorDecalTick
        desc: Internal function to update the cursor decal location
]]--
local function cursorDecalTick(fDelta)
    if not oTargetUI or not oTargetUI:IsValid() then return end
    if not oTargetUI.cursor_decal or not oTargetUI.cursor_decal:IsValid() then return end

    -- Hide/show cursor decal after a delay/activity
    if (iCursorHideDelay > 0) and oTargetUI.last_activity then
        local iTime = Client.GetTime()
        local iElaspedSinceLastActivity = (iTime - oTargetUI.last_activity)

        if oTargetUI.cursor_decal:IsVisible() then
            if (iElaspedSinceLastActivity > iCursorHideDelay) then
                oTargetUI.cursor_decal:SetVisibility(false)
            end
        else
            if (iElaspedSinceLastActivity < iCursorHideDelay) then
                oTargetUI.cursor_decal:SetVisibility(true)
            end
        end
    end

    -- Lerp to targetted cursor location if visible
    if not oTargetUI.cursor_decal:IsVisible() then return end

    local tTargetLoc = oTargetUI.cursor_decal:GetValue("target_location")
    if not tTargetLoc then return end

    oTargetUI.cursor_decal:SetLocation(lerpVector(
        oTargetUI.cursor_decal:GetLocation(),
        tTargetLoc,
        fDelta,
        iTargetTickRate
    ))
end

--[[
    handleCursorMouseMove
        desc: Handles the WebUI3d2d cursor movement
        args:
            oWebUI: The WebUI3d2d instance to handle the cursor movement for (WebUI3d2d)
            tTrace: The trace result of the target lookup (table)
]]--
local function handleCursorMouseMove(oWebUI, tTrace)
    if not oWebUI:IsCursorDecalEnabled() then return end
    if not oWebUI.cursor_decal or not oWebUI.cursor_decal:IsValid() then return end

    -- Destroy cursor decal if mouse is enabled
    if Input.IsMouseEnabled() or localPlayer():GetCameraFocusedWebUI3d2d() then
        oWebUI.cursor_decal:Destroy()
        oWebUI.cursor_decal = nil
        return
    end

    -- Update cursor target location, and rotation
    local tLoc, tRot = findCursorDecalPos(tTrace)
    oWebUI.cursor_decal:SetValue("target_location", tLoc, false)
    oWebUI.cursor_decal:SetRotation(tRot)
end

----------------------------------------------------------------------
-- WebUI3d2d targeting
----------------------------------------------------------------------
--[[
    Player:GetTargetedWebUI3d2d
        desc: Get the current targeted WebUI3d2d
        return:
            WebUI3d2d object (WebUI3d2d)
]]--
function Player:GetTargetedWebUI3d2d()
    if oTargetUI and oTargetUI:IsValid() then
        return oTargetUI
    end
end

--[[
    targetLookup
        desc: Lookup for a targetted WebUI3d2d object and find the mouse position (in pixels) on this WebUI3d2d
        return:
            WebUI3d2d object (WebUI3d2d)
            X position (integer)
            Y position (integer)
            Trace result (table)
]]--
local function targetLookup()
    local pPlayer = localPlayer()
    if not pPlayer then return end

    local tTrace
    local tCamPos = pPlayer:GetCameraLocation()
    local bMouseEnabled = Input.IsMouseEnabled()

    -- Perform a trace line to find a potential target
    if bMouseEnabled then
        local tCursorToWorld = deprojectScreenToWorld(getMousePosition())

        tTrace = traceLineSingle(
            tCursorToWorld.Position,
            tCursorToWorld.Position + (tCursorToWorld.Direction * (iMaxUISize * 2)),
            iCollisionChannel,
            iTraceMode
        )
    else
        tTrace = traceLineSingle(
            tCamPos,
            tCamPos + (pPlayer:GetCameraRotation():GetForwardVector() * (iMaxUISize * 2)),
            iCollisionChannel,
            iTraceMode
        )
    end

    -- Check if the trace hit a WebUI3d2d, and if it's interactable
    if not tTrace.Entity then return end
    local oWebUI = tTrace.Entity:GetValue("webui3d2d_page")
    if not oWebUI or not oWebUI.ready or not oWebUI:IsInteractable() then return end

    -- Check if the WebUI3d2d is in range
    local iMaxInteractDist = ((oWebUI:GetBounds().BoxExtent:Size() * 4) ^ 2)
    if (tTrace.Location:DistanceSquared(tCamPos) > iMaxInteractDist) then return end

    -- Translate the UV coordinates to pixels
    local tSize = oWebUI:GetSize()
    local iX = mathFloor(tTrace.UV.X * tSize.X)
    local iY = mathFloor(tTrace.UV.Y * tSize.Y)

    return oWebUI, iX, iY, tTrace
end

--[[
    untargetWebUI3d2d
        desc: Untargets the current targeted WebUI3d2d
]]--
local function untargetWebUI3d2d()
    if not oTargetUI or not oTargetUI:IsValid() then return end

    local xOldTarget = oTargetUI

    -- Remove cursor decal
    if oTargetUI.cursor_decal and oTargetUI.cursor_decal:IsValid() then
        oTargetUI.cursor_decal:Destroy()
        oTargetUI.cursor_decal = nil
    end

    -- Reset down keys/mouse buttons/mouse movement
    local iWebUIModifiers = getWebUIModifiers()

    for iKeyCode, _ in pairs(oTargetUI.down_keys) do
        oTargetUI:SendKeyEvent(WebUIKeyType.Up, iKeyCode, iWebUIModifiers)
    end

    for sKey, _ in pairs(oTargetUI.down_mouse_buttons) do
        if tMouseTypes[sKey] then
            oTargetUI:SendMouseClickEvent(0, 0, tMouseTypes[sKey], true, iWebUIModifiers, 1)
        end
    end

    oTargetUI:SendMouseMoveEvent(0, 0, iWebUIModifiers, true)

    -- Reset properties
    oTargetUI.down_keys = {}
    oTargetUI.down_mouse_buttons = {}
    oTargetUI.cursor_x, oTargetUI.cursor_y = 0, 0
    oTargetUI = false

    updateWebUIsVisibility()

    Events.Call("OnWebUI3d2dTargetChange", xOldTarget, oTargetUI)
end

--[[
    targetWebUI3d2d
        desc: Targets a WebUI3d2d
]]--
local function targetWebUI3d2d(oWebUI, tTrace)
    local xOldTarget = oTargetUI

    untargetWebUI3d2d()
    oTargetUI = oWebUI

    -- Check if cursor decal is valid, if not create it
    if not oTargetUI.cursor_decal or not oTargetUI.cursor_decal:IsValid() then
        local tLoc, tRot = findCursorDecalPos(tTrace)
        local fCursorSize = oTargetUI:GetCursorSize()

        oTargetUI.cursor_decal = Decal(
            tLoc,
            tRot,
            "nanos-world::M_Default_Translucent_Lit_Decal",
            Vector(0.01, fCursorSize, fCursorSize),
            -1,
            0.0001
        )

        oTargetUI.cursor_decal:SetVisibility(false)
        oTargetUI.cursor_decal:SetMaterialTextureParameter("Texture", sCursorTexture)
        setupMaterialParams(oTargetUI.cursor_decal)
        oTargetUI.cursor_decal:SetVisibility(true)
    end

    updateWebUIsVisibility()

    Events.Call("OnWebUI3d2dTargetChange", xOldTarget, oTargetUI)
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------
--[[ Client Tick ]]--
Client.Subscribe("Tick", function(fDelta)
    local iTime = Client.GetTime()

    -- Freeze check (CPU saver)
    if (iTime >= iNextFreezeHandle) then
        iNextFreezeHandle = (iTime + iFreezeCheckDelay)
        calcFreezeStates()
    end

    -- Update cursor decal location and visibility
    cursorDecalTick(fDelta)

    -- Next target lookup; Change refresh rate depending on a WebUI3d2d being targeted/focused or not
    if (iTime < iNextTargetLookup) then return end

    local eChar = localPlayer()
    if not eChar or not eChar:IsValid() then return end

    if (oTargetUI or eChar:GetCameraFocusedWebUI3d2d()) then
        iNextTargetLookup = iTime + (1000 / iTargetTickRate)
    else
        iNextTargetLookup = iTime + (1000 / iTargetIdleTickRate)
    end

    -- Find a targeted WebUI3d2d
    local oWebUI, iX, iY, tTrace = targetLookup()
    if not oWebUI or not oWebUI:IsValid() then
        untargetWebUI3d2d()
        return
    end

    -- WebUI3d2d targeted
    if oTargetUI then
        if (oTargetUI ~= oWebUI) then
            targetWebUI3d2d(oWebUI, tTrace)
        end
    else
        targetWebUI3d2d(oWebUI, tTrace)
    end

    if (iX ~= oWebUI.cursor_x) or (iY ~= oWebUI.cursor_y) then
        oWebUI.last_activity = Client.GetTime()
        oWebUI.cursor_x, oWebUI.cursor_y = iX, iY
        oWebUI:SendMouseMoveEvent(iX, iY, getWebUIModifiers(), false)

        handleCursorMouseMove(oWebUI, tTrace)
    end
end)

----------------------------------------------------------------------
-- Mouse Events
----------------------------------------------------------------------
--[[ doMouseDown ]]--
local function doMouseDown(sKey)
    if not oTargetUI or not oTargetUI:IsValid() then return end
    if not tMouseTypes[sKey] then return end

    -- Multiple clicks detection
    local iTime = Client.GetTime()

    if oTargetUI.last_clicked_key and (oTargetUI.last_clicked_key == sKey) then
        if ((iTime - (oTargetUI.last_click_time or 0)) < 250) then
            oTargetUI.click_count = math.max((oTargetUI.click_count or 0) + 1, 3)
        else
            oTargetUI.click_count = 1
        end
    else
        oTargetUI.click_count = 1
    end

    -- First click/simple click
    oTargetUI.last_click_time = iTime
    oTargetUI.last_clicked_key = sKey

    oTargetUI:SendMouseClickEvent(
        oTargetUI.cursor_x,
        oTargetUI.cursor_y,
        tMouseTypes[sKey],
        false,
        getWebUIModifiers(),
        oTargetUI.click_count
    )

    oTargetUI.down_mouse_buttons[sKey] = true
    oTargetUI.last_activity = iTime

    return oTargetUI:IsMouseEventsEnabled()
end

--[[ Input MouseDown ]]--
Input.Subscribe("MouseDown", doMouseDown)

--[[ doMouseUp ]]--
local function doMouseUp(sKey)
    if not oTargetUI or not oTargetUI:IsValid() then return end
    if not tMouseTypes[sKey] then return end

    oTargetUI:SendMouseClickEvent(
        oTargetUI.cursor_x,
        oTargetUI.cursor_y,
        tMouseTypes[sKey],
        true,
        getWebUIModifiers(),
        1
    )

    oTargetUI.down_mouse_buttons[sKey] = nil
    oTargetUI.last_activity = Client.GetTime()

    return oTargetUI:IsMouseEventsEnabled()
end

--[[ Input MouseUp ]]--
Input.Subscribe("MouseUp", doMouseUp)

----------------------------------------------------------------------
-- Keyboard Events
----------------------------------------------------------------------
--[[ Input KeyDown ]]--
Input.Subscribe("KeyDown", function(_)
    if oTargetUI and oTargetUI:IsValid() then
        return oTargetUI:IsKeyboardEventsEnabled()
    end
end)

--[[ Input KeyPress ]]--
local function doKeyPress(sKey)
    if not oTargetUI or not oTargetUI:IsValid() then return end

    -- Mouse button alias check
    local sMBAlias = oTargetUI:GetMouseAliasKey(sKey)
    if sMBAlias then
        doMouseDown(sMBAlias)
    end

    -- Check if the WebUI3d2d can receive keyboard input, if a valid key is found, etc..
    if not oTargetUI:IsKeyboardInputEnabled() then return end

    local iKeyCode, iASCIICode, bASCIICharOnly = getKeyInfo(sKey)
    if not iKeyCode then
        return oTargetUI:IsKeyboardEventsEnabled()
    end

    local iWebUIModifiers = getWebUIModifiers()

    if not bASCIICharOnly then
        oTargetUI:SendKeyEvent(WebUIKeyType.Down, iKeyCode, iWebUIModifiers)
        oTargetUI.down_keys[iKeyCode] = true
    end

    if iASCIICode then
        oTargetUI:SendKeyEvent(WebUIKeyType.Char, iASCIICode, iWebUIModifiers)
    end

    -- Update last activity
    oTargetUI.last_activity = Client.GetTime()

    return oTargetUI:IsKeyboardEventsEnabled()
end

Input.Subscribe("KeyPress", doKeyPress)

--[[ Input KeyUp ]]--
local function doKeyRelease(sKey)
    if not oTargetUI or not oTargetUI:IsValid() then return end

    -- Mouse button alias check
    local sMBAlias = oTargetUI:GetMouseAliasKey(sKey)
    if sMBAlias then
        doMouseUp(sMBAlias)
    end

    -- Check if the WebUI3d2d can receive keyboard input, if a valid key is found, etc..
    if not oTargetUI:IsKeyboardInputEnabled() then return end

    local iKeyCode, _, bASCIICharOnly = getKeyInfo(sKey)
    if not iKeyCode or not bASCIICharOnly then return end

    oTargetUI:SendKeyEvent(WebUIKeyType.Up, iKeyCode, getWebUIModifiers())

    oTargetUI.down_keys[iKeyCode] = nil
    oTargetUI.last_activity = Client.GetTime()
end

Input.Subscribe("KeyUp", doKeyRelease)

--[[ Input MouseScroll ]]--
local function doMouseScroll(_, _, iDelta)
    if not oTargetUI or not oTargetUI:IsValid() then return end

    local iWHMax = mathMax(oTargetUI.width, oTargetUI.height)

    oTargetUI:SendMouseWheelEvent(
        oTargetUI.cursor_x,
        oTargetUI.cursor_y,0,
        (iDelta * mathFloor(iWHMax * 0.1))
    )

    oTargetUI.last_activity = Client.GetTime()

    return oTargetUI:IsMouseEventsEnabled()
end

Input.Subscribe("MouseScroll", doMouseScroll)

----------------------------------------------------------------------
-- WebUI3d2d class and methods
----------------------------------------------------------------------
WebUI3d2d = WebUI.Inherit("WebUI3d2d")

--[[
    WebUI3d2d:Constructor
        desc: Class that spawn a dynamic and usable WebUI in the world space 
        args:
            sPath: Web URL, or HTML File Path as file://my_file.html (string) [optionnal: default ""]
            bTransparent: Should the WebUI3d2d be transparent (boolean) [optionnal: default false]
            iW: The WebUI3d2d width (number) [optionnal: default `tScale` X]
            iH: The WebUI3d2d height (number) [optionnal: default `tScale` Y]
            tScale: The WebUI3d2d mesh scale (Vector) [optionnal: default Vector(1)]
            bAttach3DSound: Should a 3D sound emitting audio from the UI be attached to the WebUI3d2d (boolean) [optionnal: default false]
            sMesh: The mesh to use for the WebUI3d2d (string) [optionnal: default "nanos-world::SM_Plane"]
            iMatIndex: The material index to use for the WebUI3d2d (number) [optionnal: default -1]
]]--
function WebUI3d2d:Constructor(sPath, bTransparent, iW, iH, tScale, bAttach3DSound, sMesh, iMatIndex)
    sPath = (type(sPath) == "string") and sPath or ""
    bTransparent = (bTransparent and true or false)

    tScale = (getmetatable(tScale) == Vector) and tScale or Vector(1)
    tScale.X = mathAbs(tScale.X)
    tScale.Y = mathAbs(tScale.Y)

    -- Format w/h, and clamp the resolution between the min/max UI size + keep the aspect ratio
    iW = mathFloor(mathAbs(iW or tScale.X))
    iH = mathFloor(mathAbs(iH or tScale.Y))

    local iMaxVW, iMinVW = mathMax(iW, iH), mathMin(iW, iH)

    if (iMaxVW > iMaxUISize) then
        local fAspectRatio = mathFloor(iMaxUISize / iMaxVW)
        iW, iH = (iW * fAspectRatio), (iH * fAspectRatio)
    end
    if (iMinVW < iMinUISize) then
        local fAspectRatio = mathFloor(iMinUISize / iMinVW)
        iW, iH = (iW * fAspectRatio), (iH * fAspectRatio)
    end

    -- WebUI3d2d instance and listeners
    self.Super:Constructor("", sPath, WebUIVisibility.Hidden, bTransparent, false, iW, iH)
    self:Subscribe("Fail", self.OnFail)
    self:Subscribe("Ready", self.OnReady)
    self:Subscribe("Destroy", self.OnDestroy)

    -- WebUI3d2d properties
    self.width = iW
    self.height = iH
    self.cursor_decal_enabled = true
    self.cursor_trace_control = true
    self.camera_trace_control = true
    self.keyboard_input_enabled = true

    self.mouse_events_enabled = false
    self.keyboard_events_enabled = false

    self.material_index = (iMatIndex or -1)
    self.reload_on_fail = true
    self.mouse_aliases = {}

    self.cursor_x = 0
    self.cursor_y = 0
    self.down_keys = {}
    self.down_mouse_buttons = {}

    -- Parent mesh
    self.mesh = StaticMesh(Vector(), Rotator(), sMesh or "nanos-world::SM_Plane")
    self.mesh:SetValue("webui3d2d_page", self, false)
    self.mesh:SetScale(tScale)
    self.mesh:SetCollision(CollisionType.NoCollision)
    self.mesh:Subscribe("Destroy", function()
        if self:IsValid() then
            self:Destroy()
        end
    end)

    setupMaterialParams(self.mesh)

    -- Attached sound
    if bAttach3DSound then
        local iRadius = self:GetBounds().BoxExtent:Size()

        self.sound = self:SpawnSound(
            Vector(),
            false,
            1,
            iRadius,
            (iRadius * 8),
            AttenuationFunction.Linear
        )

        self.sound:AttachTo(self.mesh, AttachmentRule.SnapToTarget, "", -1, false)
    end

    -- Force a `MakeNoSignal` call if the URL is not valid
    if not (isLocalURL(sPath) or isRemoteURL(sPath)) then
        self:MakeNoSignal()
    end
end

--[[ WebUI3d2d:ReloadPage ]]--
function WebUI3d2d:ReloadPage()
    -- TODO: Uncoment when `webui:GetPath` will be added
    -- self:LoadURL(self:GetPath())
end

--[[
    WebUI3d2d:OnFail
        desc: Called when the WebUI3d2d fails to load
]]--
function WebUI3d2d:OnFail()
    self:MakeNoSignal()

    if self:ShouldReloadOnFail() then
        Timer.SetTimeout(function()
            self:ReloadPage()
        end, 2000)
    end
end

--[[
    WebUI3d2d:OnReady
        desc: Called when the WebUI3d2d is ready to be used
]]--
function WebUI3d2d:OnReady()
    self:SetFreeze(false)
    self.mesh:SetMaterialFromWebUI(self, self.material_index)

    self.ready = true
end

--[[
    WebUI3d2d:OnDestroy
        desc: Called when the WebUI3d2d is destroyed
]]--
function WebUI3d2d:OnDestroy()
    -- Untarget the WebUI3d2d if it's the current target (will also remove the cursor)
    if oTargetUI and (oTargetUI == self) then
        untargetWebUI3d2d()
    end

    -- Unfocus the camera if it's focused on this WebUI3d2d
    local oCameraFocused = localPlayer():GetCameraFocusedWebUI3d2d()
    if oCameraFocused and (oCameraFocused == self) then
        localPlayer():UnfocusWebUI3d2dCamera()
    end

    -- Destroy the mesh and sound
    if self.mesh and self.mesh:IsValid() then self.mesh:Destroy() end
    if self.sound and self.sound:IsValid() then self.sound:Destroy() end
    if self.cursor_decal and self.cursor_decal:IsValid() then self.cursor_decal:Destroy() end
end

--[[ WebUI3d2d:LoadURL ]]--
function WebUI3d2d:LoadURL(sURL)
    if not (isLocalURL(sURL) or isRemoteURL(sURL)) then
        self:MakeNoSignal()
        return
    end

    self.Super:LoadURL(sURL)
    self.mesh:SetMaterialFromWebUI(self, self.material_index)
end

--[[
    WebUI3d2d:MakeNoSignal
        desc: Set the WebUI3d2d to a "no signal" state
]]--
function WebUI3d2d:MakeNoSignal()
    self.mesh:SetMaterial("nanos-world::M_Noise", self.material_index)
end

--[[
    WebUI3d2d:GetStaticMesh
        desc: Get the WebUI3d2d parent mesh
        returns:
            The WebUI3d2d parent mesh (StaticMesh)
]]--
function WebUI3d2d:GetStaticMesh()
    return self.mesh
end

--[[
    WebUI3d2d:GetAttachedSound
        desc: Get the 3D attached sound
        returns:
            The WebUI3d2d attached sound (Sound)
]]--
function WebUI3d2d:GetAttachedSound()
    return self.sound
end

--[[
    WebUI3d2d:SetCursorTraceControl
        desc: Enable or disable the mouse trace control
        args:
            bEnabled: Should the mouse trace control be enabled or not (boolean)
]]--
function WebUI3d2d:SetCursorTraceControl(bEnabled)
    self.cursor_trace_control = (bEnabled and true or false)
end

--[[
    WebUI3d2d:IsCursorTraceControlEnabled
        desc: Returns wether the mouse trace control is enabled or not
        returns:
            Is mouse trace control enabled? (boolean)
]]--
function WebUI3d2d:IsCursorTraceControlEnabled()
    return self.cursor_trace_control
end

--[[
    WebUI3d2d:SetCameraTraceControl
        desc: Enable or disable the camera trace control
        args:
            bEnabled: Should the camera trace control be enabled or not (boolean)
]]--
function WebUI3d2d:SetCameraTraceControl(bEnabled)
    self.camera_trace_control = (bEnabled and true or false)
end

--[[
    WebUI3d2d:IsCameraTraceControlEnabled
        desc: Returns wether the camera trace control is enabled or not
        returns:
            Is camera trace control enabled? (boolean)
]]--
function WebUI3d2d:IsCameraTraceControlEnabled()
    return self.camera_trace_control
end

--[[
    WebUI3d2d:SetKeyboardEventsEnabled
        desc: Enable or disable the keyboard events
        args:
            bEnabled: Should the WebUI3d2d allow keyboard events or not (boolean)
]]
function WebUI3d2d:SetKeyboardEventsEnabled(bEnabled)
    self.keyboard_events_enabled = (bEnabled and true or false)
end

--[[
    WebUI3d2d:IsKeyboardEventsEnabled
        desc: Returns wether the WebUI3d2d allow keyboard events or not
        returns:
            Is keyboard events allowed? (boolean)
]]--
function WebUI3d2d:IsKeyboardEventsEnabled()
    return self.keyboard_events_enabled
end

--[[
    WebUI3d2d:SetMouseEventsEnabled
        desc: Enable or disable the mouse events
        args:
            bEnabled: Should the WebUI3d2d allow mouse events or not (boolean)
]]--
function WebUI3d2d:SetMouseEventsEnabled(bEnabled)
    self.mouse_events_enabled = (bEnabled and true or false)
end

--[[
    WebUI3d2d:IsMouseEventsEnabled
        desc: Returns wether the WebUI3d2d allows mouse events or not
        returns:
            Is mouse events allowed? (boolean)
]]--
function WebUI3d2d:IsMouseEventsEnabled()
    return self.mouse_events_enabled
end

--[[
    WebUI3d2d:SetKeyboardInputEnabled
        desc: Enable or disable the keyboard input
        args:
            bEnabled: Should the WebUI3d2d accept keyboard input or not (boolean)
]]--
function WebUI3d2d:SetKeyboardInputEnabled(bEnabled)
    self.keyboard_input_enabled = (bEnabled and true or false)
end

--[[
    WebUI3d2d:IsKeyboardInputEnabled
        desc: Returns wether the WebUI3d2d accept keyboard input or not
        returns:
            Is the WebUI3d2d accepting keyboard input? (boolean)
]]--
function WebUI3d2d:IsKeyboardInputEnabled()
    return self.keyboard_input_enabled
end

--[[
    WebUI3d2d:AddMouseAliasKey
        desc: Add a key to the mouse aliases
        args:
            sKey: The key to be aliased (string)
            sMouseButton: The mouse button to be aliased (string)
]]--
function WebUI3d2d:AddMouseAliasKey(sKey, sMouseButton)
    self.mouse_aliases[sKey] = sMouseButton
end

--[[
    WebUI3d2d:RemoveMouseAliasKey
        desc: Remove a key from the mouse aliases
        args:
            sKey: The key to be removed (string)
]]--
function WebUI3d2d:RemoveMouseAliasKey(sKey)
    self.mouse_aliases[sKey] = nil
end

--[[
    WebUI3d2d:GetAllMouseAliasKeys
        desc: Get the mouse aliases table
        returns:
            The mouse aliases (table)
]]--
function WebUI3d2d:GetAllMouseAliasKeys()
    return self.mouse_aliases
end

--[[
    WebUI3d2d:GetMouseAliasKey
        desc: Get the mouse button aliased to a key
        args:
            sKey: The key to be checked (string)
        returns:
            The mouse button aliased to the key (string)
]]--
function WebUI3d2d:GetMouseAliasKey(sKey)
    return self.mouse_aliases[sKey]
end

--[[
    WebUI3d2d:SetReloadOnFail
        desc: Enable or disable the reload on fail
        args:
            bReloadOnFail: Should the WebUI3d2d reload on fail or not (boolean)
]]--
function WebUI3d2d:SetReloadOnFail(bReloadOnFail)
    self.reload_on_fail = bReloadOnFail
end

--[[
    WebUI3d2d:ShouldReloadOnFail
        desc: Returns wether the WebUI3d2d reload on fail or not
        returns:
            Should the WebUI3d2d reload on fail or not (boolean)
]]--
function WebUI3d2d:ShouldReloadOnFail()
    return self.reload_on_fail
end

--[[
    WebUI3d2d:IsInteractable
        desc: Returns wether the WebUI3d2d is interactable or not
        returns:
            Is the WebUI3d2d interactable? (boolean)
]]--
function WebUI3d2d:IsInteractable()
    if Input.IsMouseEnabled() then
        return self:IsCursorTraceControlEnabled()
    end

    return self:IsCameraTraceControlEnabled()
end

----------------------------------------------------------------------
-- Cursor related
----------------------------------------------------------------------
--[[
    WebUI3d2d:SetCursorDecalEnabled
        desc: Enable or disable the 3D cursor decal
        args:
            bEnabled: Should the 3D cursor decal be enabled or not (boolean)
]]--
function WebUI3d2d:SetCursorDecalEnabled(bEnabled)
    self.cursor_decal_enabled = (bEnabled and true or false)
end

--[[
    WebUI3d2d:IsCursorDecalEnabled
        desc: Returns wether the 3D cursor decal is enabled or not
        returns:
            Is the 3D cursor decal enabled? (boolean)
]]--
function WebUI3d2d:IsCursorDecalEnabled()
    return self.cursor_decal_enabled
end

--[[
    WebUI3d2d:GetCursorDecal
        desc: Returns the cursor decal
        return:
            The 3D cursor decal (Decal)
]]--
function WebUI3d2d:GetCursorDecal()
    return self.cursor_decal
end

--[[
    WebUI3d2d:SetCursorSize
        desc: Set the cursor decal size
        args:
            fSize: The new size of the cursor decal (number)
]]--
function WebUI3d2d:SetCursorSize(fSize)
    if (type(fSize) ~= "number") or (fSize <= 0) then return end
    self.cursor_size = fSize
end

--[[
    WebUI3d2d:GetCursorSize
        desc: Returns the cursor decal size
        return:
            The size of the cursor decal (number)
]]--
function WebUI3d2d:GetCursorSize()
    return self.cursor_size or fDefaultCursorSize
end

----------------------------------------------------------------------
-- Camera focus
----------------------------------------------------------------------
--[[
    Player:GetCameraFocusedWebUI3d2d
        desc: Get the current focused WebUI3d2d
        return:
            Camera focused WebUI3d2d object (WebUI3d2d)
]]--
function Player:GetCameraFocusedWebUI3d2d()
    local oWebUI = self:GetValue("webui3d2d_cview_focused_instance")
    if oWebUI and oWebUI:IsValid() then
        return oWebUI
    end
end

--[[
    Player:UnfocusWebUI3d2dCamera
        desc: Unfocus the WebUI3d2d camera
]]--
function Player:UnfocusWebUI3d2dCamera()
    if (self ~= localPlayer()) or not self:GetCameraFocusedWebUI3d2d() then return end

    local tCViewInfo = self:GetValue("webui3d2d_cview_info")
    if tCViewInfo then
        if tCViewInfo.mesh and tCViewInfo.mesh:IsValid() then
            tCViewInfo.mesh:Destroy()
        end

        self:SetCameraArmLength(tCViewInfo.camera_arm_length)
        self:SetCameraRotation(tCViewInfo.camera_rotation)
        Client.SetNearClipPlane(tCViewInfo.near_clip_plane)

        if tCViewInfo.view_mode then
            local eChar = self:GetControlledCharacter()
            if eChar and eChar:IsValid() then
                eChar:SetViewMode(ViewMode.TPS1)
                eChar:SetViewMode(tCViewInfo.view_mode)
            end
        end
    end

    self:ResetCamera()
    self:SetValue("webui3d2d_cview_info", nil, false)
    self:SetValue("webui3d2d_cview_focused_instance", nil, false)

    Input.SetMouseEnabled(false)
    Input.SetInputEnabled(true)
end

--[[
    Player:FocusWebUI3d2dCamera
        desc: Focus the camera on a WebUI3d2d
        args:
            oWebUI: The WebUI3d2d to focus the camera on (WebUI3d2d)
            fCameraDist: The distance from the camera to the WebUI3d2d (float)
            fClipPlaneDist: The distance from the camera to the clip plane (float)
            iBlendTime: The time it takes to blend to the new camera position (integer)
]]--
function Player:FocusWebUI3d2dCamera(oWebUI, fCameraDist, fClipPlaneDist, iBlendTime)
    if (self ~= localPlayer()) then return end
    if (getmetatable(oWebUI) ~= WebUI3d2d) then return end

    self:UnfocusWebUI3d2dCamera()
    self:SetValue("webui3d2d_cview_focused_instance", oWebUI, false)

    -- Disable game inputs
    Input.SetMouseEnabled(true)
    Input.SetInputEnabled(false)

    -- Calculate camera distance/location/clip plane
    local tBounds = oWebUI:GetBounds()
    fCameraDist = fCameraDist or tBounds.BoxExtent:Size()

    local tCamLoc = (tBounds.Origin + (oWebUI.mesh:GetRotation():GetUpVector() * fCameraDist))
    fClipPlaneDist = (fClipPlaneDist or (tCamLoc:Distance(tBounds.Origin) * 0.5))
    iBlendTime = (iBlendTime or 500)

    -- Camera handler mesh
    local eCVMesh = StaticMesh(Vector(), Rotator(), "nanos-world::SM_Cube")
    eCVMesh:AttachTo(oWebUI.mesh, AttachmentRule.KeepRelative, "", 0, false)
    eCVMesh:SetRelativeLocation(Vector(0, 0, fCameraDist))
    eCVMesh:SetCollision(CollisionType.NoCollision)
    eCVMesh:SetVisibility(false)

    -- Cache some values for later use
    local eChar = self:GetControlledCharacter()
    self:SetValue("webui3d2d_cview_info", {
        mesh = eCVMesh,
        camera_rotation = self:GetCameraRotation(),
        camera_arm_length = self:GetCameraArmLength(true),
        near_clip_plane = Client.GetNearClipPlane(),
        view_mode = ((eChar and eChar:IsValid()) and eChar:GetViewMode() or false)
    }, false)

    -- Calc view
    self:AttachCameraTo(eCVMesh, Vector(), iBlendTime)
    self:RotateCameraTo((tBounds.Origin - tCamLoc):Rotation(), (iBlendTime * 0.001), 1)
    self:SetCameraArmLength(0)

    -- Adjust near clip plane
    Client.SetNearClipPlane(fClipPlaneDist)
end

--[[
    recoverFocusInputs
        desc: Internal function to recover the correct inputs and WebUIs visibility when the camera is focused
]]--
local function recoverFocusInputs()
    if not localPlayer() or not localPlayer():GetCameraFocusedWebUI3d2d() then return end

    Input.SetMouseEnabled(true)
    Input.SetInputEnabled(false)

    updateWebUIsVisibility()
end

Chat.Subscribe("Close", recoverFocusInputs)
Console.Subscribe("Close", recoverFocusInputs)
WebUI.Subscribe("Spawn", recoverFocusInputs)
WebUI.Subscribe("VisibilityChange", recoverFocusInputs)

Input.Subscribe("MouseEnable", function(bEnabled)
    if bEnabled then return end
    Timer.SetTimeout(recoverFocusInputs, 0)
end)

----------------------------------------------------------------------
-- WebUI3d2d wrapper methods
----------------------------------------------------------------------
local tSMWrapperMethods = {
    "AttachTo",
    "Detach",
    "GetAttachedTo",
    "GetBounds",
    "GetLocation",
    "GetRotation",
    "GetScale";
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
        return self.mesh[sMethod](self.mesh, ...)
    end
end