--------------------------------------
-- Namespace
--------------------------------------
local _, core = ...;
core.Config = {};
Config = core.Config;
local TPConfig;
core.totems = {
    ["earth"] = {
        ["Stoneskin Totem"] = 58753,
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

core.multiTotemSpellIDs = {
    66842,
    66843,
    66844,
}

core.totemBars = {
    { 121, 122, 123, 124 }, -- Elements
    { 125, 126, 127, 128 }, -- Ancestors
    { 129, 130, 131, 132 } -- Spirits
};

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
    if iconFrame and spellID then
        iconFrame:SetTexture(GetSpellTexture(spellID));
    end
end

function Config:CreateMenu()

    TPConfig = CreateFrame("Frame", "TotemPredictorConfig", UIParent);

    TPConfig.name = "TotemPredictor";

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
            else
                info.icon = nil;
            end
            return UIDropDownMenu_AddButton(info);
        end

        if totemFamily then
            for i, v in pairs(core.totems[totemFamily]) do
                AddTotem(i, false, v);
            end
            AddTotem("None", false, nil)
        else
            AddTotem("Call of the Elements", false, 66842);
            AddTotem("Call of the Ancestors", false, 66843);
            AddTotem("Call of the Spirits", false, 66844);
        end
    end

    function Config:CreateTotemDropdownOnClick(self, markerIDString, frame, iconFrame, totemSchool)
        -- set marker ID & dropdown info
        TotemPredictorDB[markerIDString] = { self:GetID(), core.totems[totemSchool][self.value] or nil };
        Config:SetDropdownInfo(frame, self.value, self:GetID(), iconFrame);
        iconFrame:SetTexture(GetSpellTexture(TotemPredictorDB[markerIDString][2]) or nil);
    end

    function Config:CreateTotemBarDropdownOnClick(self, markerIDString, frame, iconFrame)
        -- set marker ID & dropdown info
        for i = 1, 3 do
            if self:GetID() == i then
                TotemPredictorDB["prefferedTotemBar"] = { core.totemBars[i], core.multiTotemSpellIDs[i], i };
                break;
            end
        end
        Config:SetDropdownInfo(frame, self.value, self:GetID(), iconFrame);
        iconFrame:SetTexture(GetSpellTexture(TotemPredictorDB["prefferedTotemBar"][2]) or nil);
    end

    TPConfig.dropDownTitle = self:CreateDropdownTitle(dropDownTitleTwo, "Select Which TotemBar To Modify")
    TPConfig.dropDownTitle:SetPoint("CENTER", TPConfig.title, "RIGHT", -10, -35)
    TPConfig.dropDown = self:CreateDropdown(TPConfig.dropDownTitle, "TotemPredictorDropDown");
    TPConfig.dropDownIcon = self:CreateDropdownIcon(TPConfig.dropDown);

    -- First Dropdown
    local function Preferred_TotemBar_DropDown_OnClick(self, arg1, arg2, checked)
        return Config:CreateTotemBarDropdownOnClick(self, "prefferedTotemBar", TPConfig.dropDown,
            TPConfig.dropDownIcon)
    end

    function TotemPredictorDropDownMenu(frame, level, menuList)
        return Config:CreateDropdownMenu(Preferred_TotemBar_DropDown_OnClick);
    end

    -- Second Dropdown
    local function Preferred_Earth_Totem_DropDown_OnClick(self, arg1, arg2, checked)
        return Config:CreateTotemDropdownOnClick(self, "prefferedEarthTotem", TPConfig.dropDownTwo,
            TPConfig.dropDownIconTwo,
            "earth");
    end

    function TotemPredictorDropDownMenuTwo(frame, level, menuList)
        return Config:CreateDropdownMenu(Preferred_Earth_Totem_DropDown_OnClick, "earth");
    end

    TPConfig.dropDownTitleTwo = self:CreateDropdownTitle(TPConfig.dropDown, "Replace Tremor Totem When Needed");
    TPConfig.dropDownTwo = self:CreateDropdown(TPConfig.dropDownTitleTwo, "TotemPredictorDropDown");
    TPConfig.dropDownIconTwo = self:CreateDropdownIcon(TPConfig.dropDownTwo);

    -- Third Dropdown
    local function Preferred_Water_Totem_DropDown_OnClick(self, arg1, arg2, checked)
        return Config:CreateTotemDropdownOnClick(self, "prefferedWaterTotem", TPConfig.dropDownThree,
            TPConfig.dropDownIconThree, "water");
    end

    function TotemPredictorDropDownMenuThree(frame, level, menuList)
        return Config:CreateDropdownMenu(Preferred_Water_Totem_DropDown_OnClick, "water");
    end

    TPConfig.dropDownTitleThree = self:CreateDropdownTitle(TPConfig.dropDownTwo, "Replace Cleansing Totem When Needed");
    TPConfig.dropDownThree = self:CreateDropdown(TPConfig.dropDownTitleThree, "TotemPredictorDropDownTwo");
    TPConfig.dropDownIconThree = self:CreateDropdownIcon(TPConfig.dropDownThree);

    -- init dropdowns
    self:InitDropdown(TPConfig.dropDown, TotemPredictorDropDownMenu, TotemPredictorDB["prefferedTotemBar"][3],
        TPConfig.dropDownIcon, TotemPredictorDB["prefferedTotemBar"][2]);
    self:InitDropdown(TPConfig.dropDownTwo, TotemPredictorDropDownMenuTwo, TotemPredictorDB["prefferedEarthTotem"][1],
        TPConfig.dropDownIconTwo, TotemPredictorDB["prefferedEarthTotem"][2]);
    self:InitDropdown(TPConfig.dropDownThree, TotemPredictorDropDownMenuThree,
        TotemPredictorDB["prefferedWaterTotem"][1
        ],
        TPConfig.dropDownIconThree, TotemPredictorDB["prefferedWaterTotem"][2])

    TPConfig:Hide();
    return InterfaceOptions_AddCategory(TPConfig);
end

function Config:Player_Login()
    if not TotemPredictorDB then
        TotemPredictorDB = {};
        TotemPredictorDB["prefferedEarthTotem"] = { 3, core.totems.earth["Stoneskin Totem"] }; --clickID, spellID
        TotemPredictorDB["prefferedWaterTotem"] = { 2, core.totems.water["Mana Spring Totem"] }; --clickID, spellID
        TotemPredictorDB["prefferedTotemBar"] = { core.totemBars[1], core.multiTotemSpellIDs[1], 1 }; -- totem spellID table, multi-totem-drop spellID (call of the elements) etc, clickID
    end
    Config:CreateMenu()
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff33ff99" ..
        TPConfig.name ..
        "|r by " ..
        "|cff69CCF0" ..
        GetAddOnMetadata(TPConfig.name, "Author") ..
        "|r. Type |cff33ff99 " ..
        SLASH_TOTEMPREDICTOR1 ..
        "|r for additional options."
    );
end
