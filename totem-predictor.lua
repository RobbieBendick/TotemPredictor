local _, core = ...;
local Config = core.Config;
core.TP = {};
TP = core.TP;
--[[ 
    SetMultiCastSpell
    ------------------------------
              fire, earth water air
    Elements  121,  122,  123, 124
    Ancestors 125,	126,  127, 128
    Spirits   129,  130,  131, 132
--]]


-- TODO: let user decide which totem to swap into

local warriorFearTimer
local eventHandlerTable = {
    ["PLAYER_LOGIN"] = function(self) TP:Player_Login(self) end,
    ["ARENA_OPPONENT_UPDATE"] = function(self, ...) TP:CheckEnemyTeamClassesAndSetTotemBar(self) end,
    ["UNIT_SPELLCAST_SUCCEEDED"] = function(self, ...) TP:WarriorFearHandler(self, ...) end,
    ["UPDATE_BATTLEFIELD_SCORE"] = function(self) TP:UpdateScore(self) end,
}
local fearClasses = {
    ["WARRIOR"] = false,
    ["WARLOCK"] = false,
    ["PRIEST"] = false,
}

local diseaseOrPoisonClasses = {
    "ROGUE",
    "DEATHKNIGHT",
};
local enemyHasDiseaseOrPoison = false;

local tremor, stoneskin, cleansing, manaSpring = 8143, 8071, 8170, 25570;




function TP:NumberOfTrueValuesInFearTable()
    local c = 0;
    for i, v in pairs(fearClasses) do
        if v then
            c = c + 1;
        end
    end
    return c;
end

function TP:UpdateScore()
    if warriorFearTimer and not warriorFearTimer:IsCancelled() then
        warriorFearTimer:Cancel();
    end
    TP:Reset();
end

function TP:CheckEnemyTeamClassesAndSetTotemBar(self)
    for i = 1, 5 do
        local _, class = UnitClass("arena" .. i);
        for k, v in pairs(fearClasses) do
            if class == k then
                fearClasses[k] = true;
            end
        end
        for j = 1, #diseaseOrPoisonClasses do
            if class == diseaseOrPoisonClasses[j] then
                enemyHasDiseaseOrPoison = true;
            end
        end
        if TP:NumberOfTrueValuesInFearTable() > 0 then
            SetMultiCastSpell(122, tremor);
        else
            SetMultiCastSpell(122, stoneskin);
        end
        if enemyHasDiseaseOrPoison then
            SetMultiCastSpell(123, cleansing);
        else
            SetMultiCastSpell(123, manaSpring);
        end
    end
end

function TP:Reset(self)
    enemyHasDiseaseOrPoison = false;
    for i, _ in pairs(fearClasses) do
        fearClasses[i] = false;
    end
end

function TP:WarriorFearHandler(self, caster, ...)
    local _, spellID = ...;
    local intimShout = 33786;
    if spellID == intimShout then
        -- team only has 1 fear
        if TP:NumberOfTrueValuesInFearTable() < 2 then
            SetMultiCastSpell(122, stoneskin);
            warriorFearTimer = C_Timer.NewTimer(120, function()
                SetMultiCastSpell(122, tremor);
            end)
        end
    end
end

function TP:Player_Login()
    if not TotemPredictorDB then
        TotemPredictorDB = {};
        TotemPredictorDB["prefferedEarthTotem"] = -1;
        TotemPredictorDB["prefferedWaterTotem"] = -1;
    end
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff33ff99" ..
        "TotemPredictor" ..
        "|r by " ..
        "|cff69CCF0" ..
        GetAddOnMetadata("TotemPredictor", "Author") .. "|r loaded.");
    core.Config:CreateMenu()


end

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
