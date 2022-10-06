--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
Config = core.Config;
local TPConfig;


local totemPredictor;

core.totems = {
    ["earth"] = {
        ["Stoneskin Totem"] = 8155,
        ["Strength of Earth Totem"] = 58643,
        ["Stoneclaw Totem"] = 58582,
        ["Earthbind Totem"] = 2484,
    },
    ["water"] = {
        ["Healing Stream Totem"] = 58757,
        ["Mana Spring Totem"] = 58774,
        ["Fire Resistance Totem"] = 58739,
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


function Config:SetDropdownInfo(dropdown, textVal, selectedVal, iconFrame, j)
    UIDropDownMenu_SetText(dropdown, textVal);
    UIDropDownMenu_SetSelectedID(dropdown, selectedVal);
end

function Config:InitDropdown(dropdown, menu, markerID, iconFrame, spellID)
    UIDropDownMenu_SetWidth(dropdown, 155);
    UIDropDownMenu_Initialize(dropdown, menu);
    UIDropDownMenu_SetSelectedID(dropdown, markerID);
    if iconFrame then
        iconFrame:SetTexture(GetSpellTexture(spellID))
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


    function Config:CreateDropdownMenu(func, totemFamily)
        local info = UIDropDownMenu_CreateInfo();
        info.func = func;
        local function AddTotem(totemName, boolean, spellID)
            info.text, info.checked = totemName, boolean;
            if spellID then
                info.icon = GetSpellTexture(spellID);
            end
            return UIDropDownMenu_AddButton(info);
        end

        for i, v in pairs(core.totems[totemFamily]) do
            AddTotem(i, false, v);
        end
    end

    function Config:CreateTotemDropdownOnClick(self, markerIDString, frame, iconFrame, totemSchool)
        -- set marker ID & dropdown info
        TotemPredictorDB[markerIDString] = {self:GetID(), core.totems[totemSchool][self.value] or nil};
        Config:SetDropdownInfo(frame, self.value, self:GetID(), iconFrame);
        iconFrame:SetTexture(GetSpellTexture(TotemPredictorDB[markerIDString][2]) or nil);
    end

    -- First Dropdown
    local function Preferred_Earth_Totem_DropDown_OnClick(self, arg1, arg2, checked)
        return Config:CreateTotemDropdownOnClick(self, "prefferedEarthTotem", TPConfig.dropDown, TPConfig.dropDownIcon, "earth");
    end

    function TotemPredictorDropDownMenu(frame, level, menuList)
        return Config:CreateDropdownMenu(Preferred_Earth_Totem_DropDown_OnClick, "earth");
    end

    TPConfig.dropDownTitle = self:CreateDropdownTitle(TPConfig.title, "Replace Tremor Totem When Needed");
    TPConfig.dropDownTitle:SetPoint("CENTER", TPConfig.title, "RIGHT", -10, -35)
    TPConfig.dropDown = self:CreateDropdown(TPConfig.dropDownTitle, "TotemPredictorDropDown");
    TPConfig.dropDownIcon = self:CreateDropdownIcon(TPConfig.dropDown);

    -- Second Dropdown
    local function Preferred_Water_Totem_DropDown_OnClick(self, arg1, arg2, checked)
        return Config:CreateTotemDropdownOnClick(self, "prefferedWaterTotem", TPConfig.dropDownTwo, TPConfig.dropDownIconTwo, "water");
    end

    function TotemPredictorDropDownMenuTwo(frame, level, menuList)
        return Config:CreateDropdownMenu(Preferred_Water_Totem_DropDown_OnClick, "water");
    end


    TPConfig.dropDownTitleTwo = self:CreateDropdownTitle(TPConfig.dropDown, "Replace Cleansing Totem When Needed");
    TPConfig.dropDownTwo = self:CreateDropdown(TPConfig.dropDownTitleTwo, "TotemPredictorDropDownTwo");
    TPConfig.dropDownIconTwo = self:CreateDropdownIcon(TPConfig.dropDownTwo);


    self:InitDropdown(TPConfig.dropDown, TotemPredictorDropDownMenu, TotemPredictorDB["prefferedEarthTotem"][1], TPConfig.dropDownIcon, TotemPredictorDB["prefferedEarthTotem"][2]);
    self:InitDropdown(TPConfig.dropDownTwo, TotemPredictorDropDownMenuTwo, TotemPredictorDB["prefferedWaterTotem"][1], TPConfig.dropDownIconTwo, TotemPredictorDB["prefferedWaterTotem"][2]);


    TPConfig:Hide();
    return InterfaceOptions_AddCategory(TPConfig);
end

function Config:Player_Login()
    if not TotemPredictorDB then
        TotemPredictorDB = {};                     --clickID, spellID
        TotemPredictorDB["prefferedEarthTotem"] = {3, core.totems.earth["Stoneskin Totem"]};
        TotemPredictorDB["prefferedWaterTotem"] = {2, core.totems.water["Mana Spring Totem"]};
    end
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff33ff99" ..
        "TotemPredictor" ..
        "|r by " ..
        "|cff69CCF0" ..
        GetAddOnMetadata("TotemPredictor", "Author") .. 
        "|r. Type |cff33ff99/tp|r for additional options.");
    Config:CreateMenu()
end
