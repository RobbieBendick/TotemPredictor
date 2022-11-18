--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
local Config = core.Config;
core.TP = {};
TP = core.TP;
--[[ 
    SetMultiCastSpell
    ------------------------------------
             fire, earth, water, air
    Elements  121,  122,  123, 124
    Ancestors 125,	126,  127, 128
    Spirits   129,  130,  131, 132
    ------------------------------------
--]]

eventHandlerTable = {
    ["PLAYER_LOGIN"] = function(self) core.Config:Player_Login(self) end,
    ["ARENA_OPPONENT_UPDATE"] = function(self, ...) TP:CheckEnemyTeamClassesAndSetTotemBar(self) end,
    -- ["UNIT_SPELLCAST_SUCCEEDED"] = function(self, ...) TP:WarriorFearHandler(self, ...) end,
    ["ZONE_CHANGED_NEW_AREA"] = function(self) TP:Reset(self) end,
}
-- local warriorFearTimer;

local fearClasses = {
    ["WARRIOR"] = false,
    ["WARLOCK"] = false,
    ["PRIEST"] = false,
}
local diseaseOrPoisonClasses = {
    ["ROGUE"] = false,
    ["DEATHKNIGHT"] = false,
    ["HUNTER"] = false,
    ["SHADOW_PRIEST"] = false,
};
local tremor, cleansing = 8143, 8170;

--------------------------------------
-- TP Functions
--------------------------------------

function TP:NumberOfTrueValues(t)
    local c = 0;
    for _, v in pairs(t) do
        if v then
            c = c + 1;
        end
    end
    return c;
end

function TP:CheckEnemyTeamClassesAndSetTotemBar(self)
    local _, instanceType = IsInInstance();
    if instanceType ~= "arena" then return end

    for i = 1, 5 do
        -- check for spriest
        C_Timer.After(0.5, function()
            for j = 1, 30 do
                local spellName = UnitBuff("arena" .. i, j);
                if not UnitExists("arena" .. i) then return end
                if not spellName then return end
                if diseaseOrPoisonClasses["SHADOW_PRIEST"] then return end
                if spellName == "Vampiric Embrace" then
                    diseaseOrPoisonClasses["SHADOW_PRIEST"] = true;
                    return SetMultiCastSpell(TotemPredictorDB["prefferedTotemBar"][1][3], cleansing);
                end
            end
        end)
        local _, class = UnitClass("arena" .. i);
        for k in pairs(fearClasses) do
            if class == k then
                fearClasses[k] = true;
            end
        end
        for k in pairs(diseaseOrPoisonClasses) do
            if class == k then
                diseaseOrPoisonClasses[k] = true;
            end
        end
    end
    if TP:NumberOfTrueValues(fearClasses) > 0 then
        --earth
        SetMultiCastSpell(TotemPredictorDB["prefferedTotemBar"][1][2], tremor);
    else
        SetMultiCastSpell(TotemPredictorDB["prefferedTotemBar"][1][2], TotemPredictorDB["prefferedEarthTotem"][2]);
    end
    if TP:NumberOfTrueValues(diseaseOrPoisonClasses) > 0 then
        --water
        SetMultiCastSpell(TotemPredictorDB["prefferedTotemBar"][1][3], cleansing);
    else
        SetMultiCastSpell(TotemPredictorDB["prefferedTotemBar"][1][3], TotemPredictorDB["prefferedWaterTotem"][2]);
    end
end

function TP:Reset(self)
    local _, instanceType = IsInInstance();
    if instanceType == "arena" then return end

    for i in pairs(diseaseOrPoisonClasses) do
        diseaseOrPoisonClasses[i] = false;
    end
    for i in pairs(fearClasses) do
        fearClasses[i] = false;
    end
    -- if not warriorFearTimer:IsCancelled() then
    --     warriorFearTimer:Cancel();
    -- end
end

-- TODO: FIX THIS FUNCTION. (reads everything correctly but doesnt swap totems for some reason)
-- function TP:WarriorFearHandler(self, caster, ...)
--     local _, instanceType = IsInInstance();
--     if instanceType ~= "arena" then return end
--     if warriorFearTimer then if not warriorFearTimer:IsCancelled() then return end end
--     local _, spellID = ...;
--     local intimShout = 5246;
--     if spellID == intimShout and not UnitIsFriend("player", caster) then
--         -- team only has 1 fear
--         if TP:NumberOfTrueValues(fearClasses) < 2 then
--             SetMultiCastSpell(TotemPredictorDB["prefferedTotemBar"][1][2], TotemPredictorDB["prefferedEarthTotem"][2]);
--             warriorFearTimer = C_Timer.NewTicker(120, function()
--                 SetMultiCastSpell(TotemPredictorDB["prefferedTotemBar"][1][2], tremor);
--             end, 1);
--         end
--     end
-- end

local addonLoadedFrame = CreateFrame("Frame");
addonLoadedFrame:RegisterEvent("ADDON_LOADED");
local eventFrame = CreateFrame("Frame");
function Addon_Loaded()
    -- register all relevant events
    for event, func in pairs(eventHandlerTable) do
        eventFrame:RegisterEvent(event);
    end

    SLASH_TOTEMPREDICTOR1 = "/tp";
    SlashCmdList.TOTEMPREDICTOR = core.Config.Toggle;
end

-- event handler
function EventHandler(self, event, ...)
    return eventHandlerTable[event](self, ...);
end

addonLoadedFrame:SetScript("OnEvent", Addon_Loaded);
eventFrame:SetScript("OnEvent", EventHandler);
