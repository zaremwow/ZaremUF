local _, ns = ...

local PlayerFrame, TargetFrame, PlayerFrameHealthBar = PlayerFrame, TargetFrame, PlayerFrameHealthBar
local TargetFrameToT, TargetFrameToTHealthBar = TargetFrameToT, TargetFrameToTHealthBar
local PlayerFrameBg

if not ZaremUFDB then
    ZaremUFDB = {
        lock = true,
        hide = false,
        darkMode = false,
        playerDragon = true,
        fontOutline = true,
        classPortrait = true,
    }
end

if ns.config.blueShaman then
    ns.ClassColors = {}
    for k, v in next, RAID_CLASS_COLORS do
        ns.ClassColors[k] = v
    end
    ns.ClassColors.SHAMAN = { r = 0, g = 0.44, b = 0.87, colorStr = "ff0070dd" }
end

local RAID_CLASS_COLORS = ns.ClassColors or RAID_CLASS_COLORS

TargetFrameToT:SetScale(ns.config.totScale)
PlayerFrame:SetScale(ns.config.scale)
TargetFrame:SetScale(ns.config.scale)

--------------------------------------------------------------------------------

local function ClassColor(unit)
    local _, class = UnitClass(unit)
    if not class then return end
    local color = RAID_CLASS_COLORS[class]
    return color.r, color.g, color.b
end

local function ReactionHealth(unit)
    local r, g, b
    if UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
        r, g, b = 0.6, 0.6, 0.6
    elseif UnitReaction(unit, "player") == 4 then
        r, g, b = 0.8, 0.7, 0
    elseif UnitIsFriend(unit, "player") then
        r, g, b = 0, 0.8, 0
    elseif UnitIsEnemy(unit, "player") then
        r, g, b = 0.9, 0.2, 0
    else
        r, g, b = 1, 1, 1
    end
    return r, g, b
end

local function ReactionNameBG(unit)
    local r, g, b
    if UnitIsDeadOrGhost(unit) or (UnitIsTapDenied(unit) and not UnitPlayerControlled(unit)) or not UnitIsConnected(unit) then
        r, g, b = 0.6, 0.6, 0.6
    elseif UnitReaction(unit, "player") == 4 then
        r, g, b = 0.8, 0.7, 0
    elseif UnitIsFriend(unit, "player") then
        r, g, b = 0, 0.8, 0
    elseif UnitIsEnemy(unit, "player") then
        r, g, b = 0.9, 0.2, 0
    else
        r, g, b = 1, 1, 1
    end
    return r, g, b
end

local function DifficultyColor(unit)
    local level = UnitLevel(unit)
    local color = GetQuestDifficultyColor(level)
    return color.r, color.g, color.b
end

local function DarkMode()
    for _, v in next, {
        PlayerFrameTexture,
        TargetFrameTextureFrameTexture,
        TargetFrameToTTextureFrameTexture,
        PetFrameTexture,
    }
    do
        if ZaremUFDB.darkMode then
            v:SetVertexColor(unpack(ns.config.darkRGB))
        else
            v:SetVertexColor(1, 1, 1, 1)
        end
    end
end

local function ApplyPosition()
    if not ZaremUFDB.lock then return end

    PlayerFrame_ResetUserPlacedPosition()
    TargetFrame_ResetUserPlacedPosition()

    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint(unpack(ns.config.customPos.player))
    PlayerFrame:SetUserPlaced(true)

    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint(unpack(ns.config.customPos.target))
    TargetFrame:SetUserPlaced(true)
end

local function PlayerFrameStatus()
    if ns.config.hideRest and IsResting() then 
        PlayerStatusTexture:Hide() 
        PlayerRestIcon:Hide()
        PlayerRestGlow:Hide()
        PlayerStatusGlow:Hide() 
    end

    if ns.config.hideAttack and (PlayerFrame.inCombat or UnitAffectingCombat("player")) then
        PlayerAttackIcon:Hide()
        PlayerStatusTexture:Hide()
        PlayerAttackGlow:Hide()
        PlayerStatusGlow:Hide() 
        PlayerAttackBackground:Hide()
    end

    if ns.config.difficultyLevel then
        PlayerLevelText:SetTextColor(DifficultyColor("player"))
    end
end

local function ClassPortrait(self)
    if not self.portrait then return end
    if not ZaremUFDB.classPortrait then return end

    if UnitIsPlayer(self.unit) then
        local _, class = UnitClass(self.unit)
        if not class then return end
        local coord = CLASS_ICON_TCOORDS[class]

        self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        self.portrait:SetTexCoord(unpack(coord))
    else
        self.portrait:SetTexCoord(0, 1, 0, 1)
    end
end

local function TargetNameBG(frame, unit)
    if not unit then return end

    if ns.config.classNameTarget and UnitIsPlayer(unit) then
        frame:SetVertexColor(ClassColor(unit))
    elseif ns.config.reactionNameTarget then
        frame:SetVertexColor(ReactionNameBG(unit))
    else
        frame:SetVertexColor(0, 0, 0, 0.5)
    end
end

local function HealthColor(frame, unit)
    if not unit then return end

    if ns.config.classHealth and UnitIsPlayer(unit) then
        frame:SetStatusBarColor(ClassColor(unit))
    elseif ns.config.reactionHealth then
        frame:SetStatusBarColor(ReactionHealth(unit))
    else
        frame:SetStatusBarColor(ns.config.healthColor[1], ns.config.healthColor[2], ns.config.healthColor[3])
    end
end

local function PlayerFrameHealth()
    if ns.config.classHealth then
        PlayerFrameHealthBar:SetStatusBarColor(ClassColor("player"))
    else
        PlayerFrameHealthBar:SetStatusBarColor(ns.config.healthColor[1], ns.config.healthColor[2], ns.config.healthColor[3])
    end
end

local function PlayerFrameBG()
    PlayerFrameBg = PlayerFrame:CreateTexture(nil, "ARTWORK")

    PlayerFrameBg:SetTexture(TargetFrameNameBackground:GetTexture())
    PlayerFrameBg:SetPoint("TOPLEFT", PlayerFrameBackground, "TOPLEFT", 0, 0)
    PlayerFrameBg:SetPoint("BOTTOMRIGHT", PlayerFrameBackground, "BOTTOMRIGHT", 0, 22)

    PlayerFrameBg:Show()
end

local function PlayerFrameBG_Colors()
    if ns.config.classNamePlayer then
        PlayerFrameBg:SetVertexColor(ClassColor("player"))
    elseif ns.config.reactionNamePlayer then
        PlayerFrameBg:SetVertexColor(ReactionNameBG("player"))
    else
        PlayerFrameBg:Hide()
    end
end

local function PlayerFramePVP()
    if ns.config.hidePVP then
        PlayerPVPIcon:Hide()
    end
end

local function PlayerFrameTextures()
    if ZaremUFDB.playerDragon then
        PlayerFrameTexture:SetTexture(ns.config.dragonTexture)
    else
        PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame.blp")
    end
end

local function FontOutline()
    for _, v in next, {
        PlayerName,
        TargetFrame.name,
        TargetFrame.deadText,
        TargetFrame.unconsciousText,
        TargetFrameToT.name,
        TargetFrameToT.deadText,
        TargetFrameToT.unconsciousText,
        PlayerLevelText,
        TargetFrame.levelText,
        PetName,
    }
    do
        if ZaremUFDB.fontOutline then
            v:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
            v:SetShadowColor(0, 0, 0, 0.35)
        else
            v:SetFont(STANDARD_TEXT_FONT, 10, "")
            v:SetShadowColor(0, 0, 0, 1)
        end
    end
end

local function TargetFrameHook(self)
    HealthColor(self.healthbar, self.unit)
    TargetNameBG(self.nameBackground, self.unit)
    PlayerFrameBG_Colors()

    if ns.config.colorizeNames then
        ns.ColorizeNames(self)
    end

    if ns.config.hidePVP then
        TargetFrameTextureFramePVPIcon:Hide()
    end

    if ns.config.difficultyLevel then
        self.levelText:SetTextColor(DifficultyColor(self.unit))
    end

    if ns.config.hideAttack and TargetFrameFlash then
        TargetFrameFlash:SetAlpha(0)
    end
end

local function AttributeDriver()
    if ZaremUFDB.hide then
        RegisterAttributeDriver(PlayerFrame, "state-visibility", ns.config.playerFrameVis)
    else
        RegisterAttributeDriver(PlayerFrame, "state-visibility", "show")
    end
end

local function EventHandler(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        ApplyPosition()
        AttributeDriver()
        DarkMode()
        PlayerFrameTextures()
        FontOutline()
    elseif event == "PET_ATTACK_START" then
        if ns.config.hideAttack then
            PetAttackModeTexture:Hide()
        end
    end
end

local function SlashHandler(msg)
    if msg == "hide" then
        ZaremUFDB.hide = not ZaremUFDB.hide
        print("ZaremUF hidden: " .. tostring(ZaremUFDB.hide))
        AttributeDriver()
    elseif msg == "lock" then
        ZaremUFDB.lock = not ZaremUFDB.lock
        print("ZaremUF locked: " .. tostring(ZaremUFDB.lock))
        ApplyPosition()
    elseif msg == "dark" then
        ZaremUFDB.darkMode = not ZaremUFDB.darkMode
        print("ZaremUF dark mode: " .. tostring(ZaremUFDB.darkMode))
        DarkMode()
    elseif msg == "dragon" then
        ZaremUFDB.playerDragon = not ZaremUFDB.playerDragon
        print("ZaremUF player dragon: " .. tostring(ZaremUFDB.playerDragon))
        PlayerFrameTextures()
    elseif msg == "portrait" then
        ZaremUFDB.classPortrait = not ZaremUFDB.classPortrait
        print("ZaremUF class portrait: " .. tostring(ZaremUFDB.classPortrait) .. " (ui reload required)")
    elseif msg == "outline" then
        ZaremUFDB.fontOutline = not ZaremUFDB.fontOutline
        print("ZaremUF font outline: " .. tostring(ZaremUFDB.fontOutline))
        FontOutline()
    else
        print("ZaremUF cmd list: /hide /lock /dark /dragon /portrait /outline")
    end
end

--------------------------------------------------------------------------------

for i = 1, 5 do 
    _G["ComboPoint" .. i]:SetAlpha(ns.config.comboAlpha) 
end

if ns.config.minStatus then
    for _, v in next, {
        PlayerFrameHealthBarTextLeft,
        PlayerFrameManaBarTextLeft,
        TargetFrameTextureFrame.HealthBarTextLeft,
        TargetFrameTextureFrame.ManaBarTextLeft,
        TargetFrameHealthBar.LeftText,
        TargetFrameManaBar.LeftText,
        PetFrameHealthBarTextLeft,
        PetFrameManaBarTextLeft,
    }
    do
        v:SetAlpha(0)
    end
end

PlayerFrameBG()
hooksecurefunc("PlayerFrame_ToPlayerArt", PlayerFrameHealth)
hooksecurefunc("PlayerFrame_UpdateStatus", PlayerFrameStatus)
hooksecurefunc("PlayerFrame_UpdatePvPStatus", PlayerFramePVP)
hooksecurefunc("TargetFrame_CheckFaction", TargetFrameHook)

hooksecurefunc("HealthBar_OnValueChanged", function(self, value) 
    if not value then return end
    HealthColor(self, self.unit) 
end)

hooksecurefunc("UnitFrameHealthBar_Update", function(self) 
    HealthColor(self, self.unit) 
end)

hooksecurefunc("UnitFramePortrait_Update", ClassPortrait) 

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
--eventHandler:RegisterEvent("PET_ATTACK_START")
eventHandler:SetScript("OnEvent", EventHandler)

SLASH_ZAREMUF1 = "/zaremuf"
SLASH_ZAREMUF2 = "/zuf"
SlashCmdList.ZAREMUF = SlashHandler 
