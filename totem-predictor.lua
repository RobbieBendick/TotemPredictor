local _, core = ...;
--[[ 
    SetMultiCastSpell
    ------------------------------
              fire, earth water air
    Elements  121,  122,  123, 124
    Ancestors 125,	126,  127, 128
    Spirits   129,  130,  131, 132
--]]


-- TODO: let user decide which totem to swap into

local eventHandlerTable = {
    ["PLAYER_LOGIN"] = function(self) Player_Login(self) end,
    ["ARENA_OPPONENT_UPDATE"] = function(self, ...) CheckEnemyTeamClassesAndSetTotemBar(self) end,
    ["ZONE_CHANGED_NEW_AREA"] = function(self) Reset(self) end,
    -- ["UNIT_SPELLCAST_SUCCEEDED"] = function(self, ...) WarriorFearHandler(selWarf, ...) end,
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
local totemSets = {
    ['elements'] = {}
}
local tremor, stoneskin, cleansing, manaSpring = 8143, 8071, 8170, 25570;
local enemyHasDiseaseOrPoison = false;

function NumberOfTrueValuesInFearTable()
    local c = 0;
    for i, v in pairs(fearClasses) do
        if v then
            c = c + 1;
        end
    end
    return c;
end

function CheckEnemyTeamClassesAndSetTotemBar(self)
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
        if NumberOfTrueValuesInFearTable() > 0 then
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

function Reset(self)
    enemyHasDiseaseOrPoison = false;
    for i, _ in pairs(fearClasses) do
        fearClasses[i] = false;
    end
end

function Player_Login()
    return DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99" ..
        "TotemPredictor" ..
        "|r by " ..
        "|cff69CCF0" ..
        GetAddOnMetadata("totem-predictor", "Author") .. "|r loaded.");
end

local addonLoadedFrame = CreateFrame("Frame");
addonLoadedFrame:RegisterEvent("ADDON_LOADED");
local eventFrame = CreateFrame("Frame");
function Addon_Loaded()
    -- register all relevant events
    for event, func in pairs(eventHandlerTable) do
        eventFrame:RegisterEvent(event);
    end
end

-- event handler
function EventHandler(self, event, ...)
    return eventHandlerTable[event](self, ...);
end

addonLoadedFrame:SetScript("OnEvent", Addon_Loaded);
eventFrame:SetScript("OnEvent", EventHandler);
