local PADDING = 4
local POWER_BAR_HEIGHT = 6
local UPDATE_THROTTLE = 0.5
local lastUpdate = 0

local function AdjustCompactFrame(frame)
    if not frame or not frame.healthBar then return end

    -- Remove border
    if frame.background then
        frame.background:Hide()
    end
    frame:SetBackdropBorderColor(0, 0, 0, 0)

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

    -- Adjust name text if present
    --if frame.name then
        --frame.name:ClearAllPoints()
        --frame.name:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
        --frame.name:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PADDING, -PADDING)
    --end
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
    -- Hook OnUpdate onto CompactPartyFrame once it exists
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