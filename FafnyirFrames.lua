local PADDING = 8
local AGGRO_PADDING = 6
local POWER_BAR_HEIGHT = 6
local UPDATE_THROTTLE = 0.1
local lastUpdate = 0

local function AdjustCompactFrame(frame)
    if not frame or not frame.healthBar then return end

    -- Remove border if backdrop is supported
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(0, 0, 0, 0)
    end

    -- Inset background
    if frame.background then
        frame.background:ClearAllPoints()
        frame.background:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
        frame.background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)
    end

    -- Inset aggro highlight and push it behind
    if frame.aggroHighlight then
        frame.aggroHighlight:ClearAllPoints()
        frame.aggroHighlight:SetPoint("TOPLEFT", frame, "TOPLEFT", AGGRO_PADDING, -AGGRO_PADDING)
        frame.aggroHighlight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -AGGRO_PADDING, AGGRO_PADDING)
        frame.aggroHighlight:SetDrawLayer("BACKGROUND", -8)
    end

    -- Hide the default selection highlight
    if frame.selectionHighlight then
        frame.selectionHighlight:Hide()
        frame.selectionHighlight:SetScript("OnShow", function(self)
            self:Hide()
        end)
    end

    -- Create our own selection highlight replacement if it doesn't exist
    if not frame.fafnyrSelection then
        local sel = frame:CreateTexture(nil, "ARTWORK", nil, -1)
        sel:SetAtlas("RaidFrame-TargetFrame")
        sel:Hide()
        frame.fafnyrSelection = sel
    end

    frame.fafnyrSelection:ClearAllPoints()
    frame.fafnyrSelection:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
    frame.fafnyrSelection:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)

    -- Show/hide our selection based on whether this unit is targeted
    if frame.unit and UnitIsUnit("target", frame.unit) then
        frame.fafnyrSelection:Show()
    else
        frame.fafnyrSelection:Hide()
    end

    -- Hide overheal
    if frame.myHealPrediction then frame.myHealPrediction:Hide() end
    if frame.otherHealPrediction then frame.otherHealPrediction:Hide() end
    if frame.overHealAbsorbGlow then frame.overHealAbsorbGlow:Hide() end

    -- Adjust health bar inward
    frame.healthBar:ClearAllPoints()
    frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
    frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)

    -- Adjust power/mana bar if present
    if frame.powerBar then
        frame.powerBar:ClearAllPoints()
        frame.powerBar:SetHeight(POWER_BAR_HEIGHT)
        frame.powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", PADDING, PADDING)
        frame.powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)
    end
end

local function AdjustAllPartyFrames()
    if CompactPartyFrame then
        for i = 1, 5 do
            local frame = _G["CompactPartyFrameMember" .. i]
            if frame then
                AdjustCompactFrame(frame)
            end
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent", function(self, event)
    if CompactPartyFrame and not CompactPartyFrame.fafnyrHooked then
        CompactPartyFrame:SetScript("OnUpdate", function(self, elapsed)
            lastUpdate = lastUpdate + elapsed
            if lastUpdate >= UPDATE_THROTTLE then
                lastUpdate = 0
                AdjustAllPartyFrames()
            end
        end)
        CompactPartyFrame.fafnyrHooked = true
    end
    AdjustAllPartyFrames()
end)