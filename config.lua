--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
Config = core.Config;
local TPConfig;

local totems = {
    ["earth"] = {
        ["Stoneskin_Totem"] = 8155,
        ["Strength_of_Earth_Totem"] = 58643,
        ["Stoneclaw_Totem"] = 58582,
        ["Earthbind_Totem"] = 2484,
    },
    ["water"] = {
        ["Healing_Stream_Totem"] = 65994,
        ["Mana_Spring_Totem"] = 58774,
        ["Fire_Resistance_Totem"] = 58739,
    }
}

function Config:Toggle()
    TPConfig:SetShown(not TPConfig:IsShown());
    InterfaceOptionsFrame_OpenToCategory(TPConfig);
    InterfaceOptionsFrame_OpenToCategory(TPConfig);
end

function Config:CreateDropdownTitle(relativeFrame, dropText)
    local dropTitle = TPConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    dropTitle:SetText(dropText);
    dropTitle:SetPoint("CENTER", relativeFrame, 0, -32);
    return dropTitle;
end

function Config:CreateDropdown(relativeFrame, frameName)
    local dropDown = CreateFrame("Frame", frameName or nil, TPConfig, "UIDropDownMenuTemplate");
    dropDown:SetPoint("CENTER", relativeFrame, 0, -23);
    return dropDown;
end

function Config:CreateDropdownIcon(relativeFrame)
    local dropIcon = TPConfig:CreateTexture(nil, "MEDIUM", nil, 2);
    dropIcon:SetParent(relativeFrame);
    dropIcon:SetPoint("LEFT", relativeFrame, 25, 2);
    dropIcon:SetSize(16, 16);
    return dropIcon;
end

function Config:InitDropdown(dropdown, menu, clickID, markerID, frame)
    UIDropDownMenu_SetWidth(dropdown, 93);
    UIDropDownMenu_Initialize(dropdown, menu);
    UIDropDownMenu_SetSelectedID(dropdown, clickID);
    if spellID then
        frame:SetTexture(GetSpellTexture(spellID));
    end
end

function Config:SetDropdownInfo(dropdown, textVal, selectedVal, iconFrame, j)
    UIDropDownMenu_SetText(dropdown, textVal);
    UIDropDownMenu_SetSelectedID(dropdown, selectedVal);
    if spellID then
        iconFrame:SetTexture(GetSpellTexture(spellID));
    end
end

function Config:CreateMenu()

    TPConfig = CreateFrame("Frame", "TotemPredictorConfig", UIParent);

    TPConfig.name = "TotemPredictor";

    -- Options Title
    TPConfig.title = TPConfig:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    TPConfig.title:SetParent(TPConfig);
    TPConfig.title:SetPoint("TOPLEFT", 16, -16);
    TPConfig.title:SetText("|cff33ff99" .. TPConfig.name .. "|r");


    function Config:CreateDropdownMenu(disableOne, disableTwo, func)
        local info = UIDropDownMenu_CreateInfo();
        info.func = func;
        local function AddTotem(totemName, boolean, spellID)
            info.text, info.checked = totemName, boolean;
            if spellID then
                info.icon = GetSpellTexture(spellID);
            else
                info.icon = nil;
            end
            return UIDropDownMenu_AddButton(info);
        end

        for i, v in pairs(totems.earth) do
            AddTotem(i, false, v);
        end
    end

    function Config:CreatePetDropdownOnClick(self, disableOne, markerIDString, frame, iconFrame)
        -- set marker & click ID
        TotemPredictorDB[markerIDString] = self:GetID();
        Config:SetDropdownInfo(frame, self.value, self:GetID(), iconFrame, j);
    end

    -- Self-Pet Priority Dropdown
    local function ArenaMarker_Pet_DropDown_OnClick(self, arg1, arg2, checked)
        return Config:CreatePetDropdownOnClick(self, nil, "petDropDownMarkerID", AMConfig.dropDown, AMConfig.dropDownIcon);
    end

    function ArenaMarkerDropDownMenu(frame, level, menuList)
        return Config:CreateDropdownMenu(ArenaMarkerDB.petDropDownThreeMarkerID, ArenaMarkerDB.petDropDownTwoMarkerID,
            ArenaMarker_Pet_DropDown_OnClick);
    end

    TPConfig.dropDownTitle = self:CreateDropdownTitle(TPConfig.title, "Preferred Earth Totem");
    TPConfig.dropDown = self:CreateDropdown(TPConfig.dropDownTitle, "TotemPredictorDropDown");
    TPConfig.dropDownIcon = self:CreateDropdownIcon(TPConfig.dropDown);










    TPConfig:Hide();
    return InterfaceOptions_AddCategory(TPConfig);
end
