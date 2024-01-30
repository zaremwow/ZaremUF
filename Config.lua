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
    classNamePlayer = true,
    classNameTarget = true,

    reactionHealth = true,
    reactionNamePlayer = true,
    reactionNameTarget = true,

    hidePVP = false,
    hideRest = false,
    hideAttack = true,

    playerFrameVis = "[combat] [@target,exists] [mod:shift] show; hide",

    customPos = {
        player = { "CENTER", UIParent, "CENTER", --[[-200, -180]] -510, 330 },
        target = { "CENTER", UIParent, "CENTER",  --[[200, -180]] -270, 330 },
    },
}

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
