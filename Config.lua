--------------------------------------------------------------------------------
--- Config
--------------------------------------------------------------------------------

local _, ns = ...

ns.config = {
    scale = 1,
    totScale = 1,

    comboAlpha = 1,
    darkRGB = { 0.4, 0.4, 0.4 },
    healthColor = { 0, 0.8, 0 },

    --dragonTexture = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp",
    dragonTexture = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite.blp",

    colorizeNames = true,
    minStatus = false,
    difficultyLevel = true,
    blueShaman = false,

    classHealth = true,
    classNamePlayer = false,
    classNameTarget = false,

    reactionHealth = true,
    reactionAggro = true,
    reactionNamePlayer = false,
    reactionNameTarget = true,

    nameplate = true,
    nameplateClass = true,

    hidePVP = false,
    hideRest = false,
    hideAttack = false,

    driverVis = "[combat] [@target,exists] [mod:shift] show; hide",
    driverFrames = { PlayerFrame },

    customPos = {
        player = { "CENTER", UIParent, "CENTER", -160, -200 --[[-510, 330]] --[[-400, 250]] },
        target = { "CENTER", UIParent, "CENTER",  160, -200 --[[-270, 330]] --[[-300, 198]] },
    },
}

---------------------------------------------------------------------------------
--- Functions
---------------------------------------------------------------------------------

function ns.FontOutline()
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

function ns.DarkMode()
    for _, v in next, {
        PlayerFrameTexture,
        TargetFrameTextureFrameTexture,
        TargetFrameToTTextureFrameTexture,
        PetFrameTexture,
        TargetFrameSpellBar.Border,
    }
    do
        if ZaremUFDB.darkMode then
            v:SetVertexColor(unpack(ns.config.darkRGB))
        else
            v:SetVertexColor(1, 1, 1, 1)
        end
    end
end

function ns.ColorizeNames(self)
    PlayerName:SetTextColor(1, 0.82, 0)

    local r, g, b
    if UnitIsDeadOrGhost(self.unit) or not UnitIsConnected(self.unit) then
        r, g, b = 0.8, 0.8, 0.8
    elseif UnitPlayerControlled(self.unit) then
        r, g, b = 1, 0.82, 0 
    elseif UnitIsTapDenied(self.unit) then
        r, g, b = 0.8, 0.8, 0.8
    elseif UnitIsFriend(self.unit, "player") then
        r, g, b = 1, 0.82, 0
    else
        r, g, b = 1, 0.82, 0
    end

    self.name:SetTextColor(r, g, b)
    self.deadText:SetTextColor(r, g, b)
    self.unconsciousText:SetTextColor(r, g, b)
end

function ns.ReactionHealth(unit)
    local r, g, b
    if ns.config.reactionAggro and UnitIsUnit(unit .. "target", "player") then
        r, g, b = 0, 1, 0
    elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
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

function ns.ReactionNameBG(unit)
    local r, g, b
    if UnitIsDeadOrGhost(unit) or (UnitIsTapDenied(unit) and not UnitPlayerControlled(unit)) or not UnitIsConnected(unit) then
        r, g, b = 0.6, 0.6, 0.6
    elseif UnitReaction(unit, "player") == 4 then
        r, g, b = 0.8, 0.7, 0
    elseif UnitIsFriend(unit, "player") then
        if UnitPlayerControlled(unit) then
            if UnitIsPVP(unit) then
                r, g, b = 0, 0.8, 0
            else
                r, g, b = 0, 0.2, 1
            end
        else
            r, g, b = 0, 0.8, 0
        end
    elseif UnitIsEnemy(unit, "player") then
        r, g, b = 0.9, 0.2, 0
    else
        r, g, b = 1, 1, 1
    end
    return r, g, b
end

function ns.ReactionNamePlates(unit)
    local r, g, b
    if ns.config.reactionAggro and UnitIsUnit(unit .. "target", "player") then
        r, g, b = 0, 1, 0
    elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
        r, g, b = 0.5, 0.5, 0.5
    elseif UnitReaction(unit, "player") == 4 then
        r, g, b = 0.8, 0.7, 0.2
    elseif UnitIsFriend(unit, "player") then
        if UnitPlayerControlled(unit) then
            if UnitIsPVP(unit) then
                r, g, b = 0, 0.7, 0
            else
                r, g, b = 0, 0.4, 1
            end
        else
            r, g, b = 0, 0.7, 0
        end
    elseif UnitIsEnemy(unit, "player") then
        r, g, b = 0.9, 0, 0
    else
        r, g, b = 1, 1, 1
    end
    return r, g, b
end

