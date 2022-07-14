-- [[ Namespaces ]] --
local addonName, addon = ...;
local diagnostics = addon.Diagnostics;
local data = addon.Data;
data.SavedData = {};
local savedData = data.SavedData;

local LoadSolutions, Resolve;
function savedData.Load()
    SavedData = SavedData or {}; -- Does not exist yet for new users
    SavedData.Fixes = SavedData.Fixes or {}; -- Does not exist yet for new users

    local prevBuild = SavedData["Build"];
    diagnostics.Debug("Previous Build: " .. tostring(prevBuild)); -- Can be nil
    SavedData["Build"] = addon.MetaData.Build;
    local currBuild = SavedData["Build"];
    diagnostics.Debug("Current Build: " .. SavedData["Build"]);

    local prevVersion = SavedData["Version"];
    diagnostics.Debug("Previous Version: " .. tostring(prevVersion)); -- Can be nil
    SavedData["Version"] = addon.MetaData.Version;
    local currVersion = SavedData["Version"];
    diagnostics.Debug("Current Version: " .. SavedData["Version"]);

    if prevBuild == nil and prevVersion == nil then
        -- First time user
        Resolve(LoadSolutions(), prevBuild, currBuild, prevVersion, currVersion, true);
    else
        Resolve(LoadSolutions(), prevBuild, currBuild, prevVersion, currVersion, false);
    end

    diagnostics.Debug("SavedData loaded");
end

local FixFeaturesTutorialProgress, FixElvUISkin, FixFilters, FixEventDetails, FixShowExcludedCategory, FixEventDetails2, FixCharacters, FixEventAlert;
local FixMergeSmallCategoriesThresholdChanged, FixShowCurrentCharacterIcons, FixTabs, FixCovenantFilters, FixNewEarnedByFilter, FixTabs2, FixNewEarnedByFilter2;
function LoadSolutions()
    local solutions = {
        FixFeaturesTutorialProgress, -- 1
        FixElvUISkin, -- 2
        FixFilters, -- 3
        FixEventDetails, -- 4
        FixShowExcludedCategory, -- 5
        FixEventDetails2, -- 6
        FixCharacters, -- 7
        FixEventAlert, -- 8
        FixMergeSmallCategoriesThresholdChanged, -- 9
        FixShowCurrentCharacterIcons, -- 10
        FixTabs, -- 11
        FixCovenantFilters, -- 12
        FixNewEarnedByFilter, -- 13
        FixTabs2, -- 14
        FixNewEarnedByFilter2, -- 15
    };

    return solutions;
end

function Resolve(solutions, prevBuild, currBuild, prevVersion, currVersion, firstTime)
    if not (prevBuild == nil or prevVersion == nil or prevBuild .. "." .. prevVersion < currBuild .. "." .. currVersion) then
        diagnostics.Debug("Nothing to resolve, same build and version");
        return;
    end

    for _, solution in next, solutions do
        solution(prevBuild, currBuild, prevVersion, currVersion, firstTime);
    end
    diagnostics.Debug("Resolved all");
end

function FixFeaturesTutorialProgress(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 23.0 the tutorial was rewritten and moved from addon.Options.db.FeaturesTutorial to SavedData.FeaturesTutorial
    -- Here we clean up the old addon.Options.db.FeaturesTutorial for users pre 23.0
    -- SavedData.FeaturesTutorial is created by the Tutorial so we don't need to do this here

    if firstTime and currVersion > "23.0" then
        diagnostics.Debug("First time Features Tutorial Progress OK");
        return;
    end
    if SavedData.FeaturesTutorial then
        diagnostics.Debug("Features Tutorial Progress already cleared from previous version");
        return;
    end

    addon.Options.db.FeaturesTutorial = nil;

    diagnostics.Debug("Cleared Features Tutorial Progress from previous version");
end

function FixElvUISkin(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 23.0 the ElvUI skin settings were moved from addon.Options.db.ElvUISkin to SavedData.ElvUISkin
    -- Here we clean up the old addon.Options.db.ElvUISkin for users pre 23.0
    -- SavedData.ElvUISkin is created by the ElvUI plugin so we don't need to do this here

    if firstTime and currVersion > "23.0" then
        diagnostics.Debug("First time ElvUISkin OK");
        return;
    end
    if SavedData.ElvUISkin then
        diagnostics.Debug("ElvUISkin already cleared from previous version");
        return;
    end

    addon.Options.db.ElvUISkin = nil;

    diagnostics.Debug("Cleared ElvUISkin from previous version");
end

function FixFilters(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 24.0 the filters were moved from addon.Options.db.Filters to Filters
    -- Here we clean up the old addon.Options.db.Filters for users pre 24.0
    -- Filters is created by the Filters so we don't need to do this here

    if firstTime and currVersion > "24.0" then
        diagnostics.Debug("First time Filter OK");
        return;
    end
    if Filters then
        diagnostics.Debug("Filter settings already cleared from previous location");
        return;
    end

    addon.Options.db.Filters = nil;

    diagnostics.Debug("Clear filter settings from previous location");
end

function FixEventDetails(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 28.0 changes were made to the Event Reminders and the tutorial
    -- Here we reset the view flag to inform the users about the changes for users pre 28.0
    -- This is now however useless since FixEventDetails2 does a complete reset of the view flags

    -- Now we just make sure to remove the fix flag for users pre 34.0
    if firstTime and currVersion > "28.0" then
        diagnostics.Debug("First time EventDetails OK");
        return;
    end
    if SavedData.Fixes.FixEventDetails == nil then
        diagnostics.Debug("EventDetails already reset");
        return;
    end

    SavedData.Fixes.FixEventDetails = nil;

    diagnostics.Debug("EventDetails reset");
end

function FixShowExcludedCategory(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 29.0 addon.Options.db.Categories.ShowExcludedCategory was moved to addon.Options.db.Categories.Excluded.Show
    -- Here we clean up the old addon.Options.db.Categories.ShowExcludedCategory for users pre 29.0
    -- addon.Options.db.Categories.Excluded.Show is created by the Options so we don't need to do this here, just copy if previous existed

    if firstTime and currVersion > "29.0" then
        diagnostics.Debug("First time Show Excluded Category OK");
        return;
    end
    if addon.Options.db.Categories.ShowExcludedCategory == nil then
        diagnostics.Debug("Show Excluded Category already moved");
        return;
    end

    addon.Options.db.Categories.Excluded.Show = addon.Options.db.Categories.ShowExcludedCategory;
    addon.Options.db.Categories.ShowExcludedCategory = nil;

    diagnostics.Debug("Show Excluded Category moved");
end

function FixEventDetails2(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 34.0 the Event Reminders data structure changed
    -- Here we reset the EventDetails for users pre 34.0
    -- EventDetails is created by the Event Data so we don't need to do this here

    if firstTime and currVersion > "34.0" then
        SavedData.Fixes.FixEventDetails2 = true;
        diagnostics.Debug("First time EventDetails2 OK");
        return;
    end
    if SavedData.Fixes.FixEventDetails2 == true then
        diagnostics.Debug("EventDetails2 already reset");
        return;
    end

    EventDetails = nil;
    SavedData.Fixes.FixEventDetails2 = true;

    diagnostics.Debug("EventDetails2 reset");
end


function FixCharacters(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 34.0 the character cache structure changed
    -- Here we clean up the old SavedData.CharacterAchievementPoints for users pre 34.0

    if firstTime and currVersion > "34.0" then
        diagnostics.Debug("First time CharacterAchievementPoints OK");
        return;
    end
    if SavedData.CharacterAchievementPoints == nil then
        diagnostics.Debug("CharacterAchievementPoints already cleared from previous version");
        return;
    end

    SavedData.CharacterAchievementPoints = nil;

    diagnostics.Debug("Cleared CharacterAchievementPoints from previous version");
end

function FixEventAlert(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 34.0 options related to Event Alerts changed
    -- Here we move the old data to the new locations

    if firstTime and currVersion > "34.0" then
        diagnostics.Debug("First time EventAlerts OK");
        return;
    end
    if addon.Options.db.EventAlert == nil then
        diagnostics.Debug("EventAlerts already copied and cleared from previous version");
        return;
    end

    addon.Options.db.EventAlert.ShowPopUps = not addon.Options.db.EventAlert.NoPopUps;
    addon.Options.db.EventAlert.NoPopUps = nil;
    addon.Options.db.EventReminders = addon.Options.db.EventAlert;
    addon.Options.db.EventAlert = nil;

    diagnostics.Debug("Copied and cleared EventAlerts from previous version");
end

function FixMergeSmallCategoriesThresholdChanged(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 34.0 addon.Options.db.Window.MergeSmallCategoriesThresholdChanged became obsolete
    -- Here we clean up the old addon.Options.db.Window.MergeSmallCategoriesThresholdChanged for users pre 34.0

    if firstTime and currVersion > "34.0" then
        diagnostics.Debug("First time MergeSmallCategoriesThresholdChanged OK");
        return;
    end
    if addon.Options.db.Window.MergeSmallCategoriesThresholdChanged == nil then
        diagnostics.Debug("MergeSmallCategoriesThresholdChanged already cleared from previous version");
        return;
    end

    addon.Options.db.Window.MergeSmallCategoriesThresholdChanged = nil;

    diagnostics.Debug("Cleared MergeSmallCategoriesThresholdChanged from previous version");
end

function FixShowCurrentCharacterIcons(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    -- In version 34.0 addon.Options.db.Tooltip.Achievements.ShowCurrentCharacterIcons got split into 2 parts
    -- Here we copy the addon.Options.db.Tooltip.Achievements.ShowCurrentCharacterIcons to the 2 new parts

    if firstTime and currVersion > "34.0" then
        diagnostics.Debug("First time ShowCurrentCharacterIcons OK");
        return;
    end
    if addon.Options.db.Tooltip.Achievements.ShowCurrentCharacterIcons == nil then
        diagnostics.Debug("ShowCurrentCharacterIcons already cleared from previous version");
        return;
    end

    addon.Options.db.Tooltip.Achievements.ShowCurrentCharacterIconsPartOfAChain = addon.Options.db.Tooltip.Achievements.ShowCurrentCharacterIcons;
    addon.Options.db.Tooltip.Achievements.ShowCurrentCharacterIconsRequiredFor = addon.Options.db.Tooltip.Achievements.ShowCurrentCharacterIcons;
    addon.Options.db.Tooltip.Achievements.ShowCurrentCharacterIcons = nil;

    diagnostics.Debug("Cleared ShowCurrentCharacterIcons from previous version");
end

function FixTabs(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    if currVersion < "35.0" or currVersion >= "37.0" or addon.Options.db.Tabs == nil or SavedData.Fixes.FixTabs == true then
        diagnostics.Debug("Tabs already ported from previous version");
        return;
    end

    for addonName2, tab in next, addon.Options.db.Tabs do
        if not tab.AddonName then
            for tabName, _ in next, addon.Options.db.Tabs[addonName2] do
                for i, tab2 in next, addon.Options.db.Tabs do
                    if tab2.AddonName and tab2.AddonName == addonName2 and tab2.TabName == tabName then
                        addon.Options.db.Tabs[i].Show = addon.Options.db.Tabs[addonName2][tabName];
                    end
                end
            end
            addon.Options.db.Tabs[addonName2] = nil;
        end
    end

    SavedData.Fixes.FixTabs = true;

    diagnostics.Debug("Ported Tabs from previous version");
end

local function ClearCovenant(table)
    for i, _ in next, table do
        if i == "Covenant" then
            table[i] = nil;
        elseif type(table[i]) == "table" then
            ClearCovenant(table[i]);
        end
    end
end

function FixCovenantFilters(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    if currVersion < "35.1" or SavedData.Fixes.FixCovenantFilters == true then
        diagnostics.Debug("Covenant filters already cleared from previous version");
        return;
    end

    if Filters.profiles then
        ClearCovenant(Filters.profiles);
    end

    SavedData.Fixes.FixCovenantFilters = true;

    diagnostics.Debug("Cleared covenant filters from previous version");
end

function FixNewEarnedByFilter(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    if currVersion < "36.0" or SavedData.Fixes.FixNewEarnedByFilter == true then
        diagnostics.Debug("New earned by filter already transfered from previous version");
        return;
    end

    if Filters.profiles and Filters.profiles.Default and Filters.profiles.Default.EarnedBy == (GetCategoryInfo(92)) then
        Filters.profiles.Default.EarnedBy = (GetCategoryInfo(92)) .. " / " .. addon.L["Account"];
    end

    SavedData.Fixes.FixNewEarnedByFilter = true;

    diagnostics.Debug("Transfered new earned by filter from previous version");
end

function FixTabs2(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    if currVersion < "37.0" or addon.Options.db.Tabs == nil or SavedData.Fixes.FixTabs2 == true then
        diagnostics.Debug("Tabs2 already ported from previous version");
        return;
    end

    addon.Diagnostics.DebugTable(addon.Options.db.Tabs)

    -- -- if pcall(function()
    --     local addonName2, tabName, show, order;
    --     for addonName3, tab in next, addon.Options.db.Tabs do
    --         print(addonName3, tab.AddonName)
    --         if tab.AddonName ~= nil then -- 35.x - 36.x
    --             addonName2 = tab.AddonName;
    --             tabName = tab.TabName;
    --             show = tab.Show;
    --             order = tab.Order;

    --             print(addonName2, tabName, show, order, "35.x - 36.x");
    --             addon.Options.db.Tabs[addonName2] = addon.Options.db.Tabs[addonName2] or {};
    --             addon.Options.db.Tabs[addonName2][tabName] = {};
    --             addon.Options.db.Tabs[addonName2][tabName].Show = show;
    --             addon.Options.db.Tabs[addonName2][tabName].Order = order;
    --             addon.Diagnostics.DebugTable(addon.Options.db.Tabs)

    --             addon.Options.db.Tabs[addonName3] = nil;
    --         else -- <= 34.x or >= 37.x
    --             for tabName2, tab2 in next, tab do
    --                 print(tabName2, tab2, tab, "<= 34.x");
    --                 if type(tab2) == "boolean" then -- <= 34.x
    --                     addonName2 = addonName3;
    --                     tabName = tabName2;
    --                     show = tab2;
    --                     print(addonName2, tabName, show);

    --                     addon.Options.db.Tabs[addonName2] = addon.Options.db.Tabs[addonName2] or {};
    --                     addon.Options.db.Tabs[addonName2][tabName] = {};
    --                     addon.Options.db.Tabs[addonName2][tabName].Show = show;
    --                     addon.Diagnostics.DebugTable(addon.Options.db.Tabs)
    --                 end
    --             end
    --         end
    --     end

    --     local tabOrder = {};
    --     local noOrder = {};
    --     local tabs = 0;
    --     -- Now we have correct data, we can verify the order now
    --     for _, tab in next, addon.Options.db.Tabs do
    --         for _, tab2 in next, tab do
    --             tabs = tabs + 1;
    --             order = tab2.Order;
    --             if order == nil then
    --                 tinsert(noOrder, tab2);
    --             elseif tabOrder[order] == nil then
    --                 tabOrder[order] = tab2;
    --             else
    --                 tab2.Order = nil;
    --                 tinsert(noOrder, tab2);
    --             end
    --         end
    --     end

    --     local noOrderFixed = 1;
    --     for i = 1, tabs do
    --         if tabOrder[i] == nil then
    --             noOrder[noOrderFixed].Order = i;
    --             noOrderFixed = noOrderFixed + 1;
    --         end
    --     end
    -- -- end) then
    -- --     -- No errors, assume tabs are ported
    -- -- else
    -- --     -- Porting failed, just reset tabs
    -- --     addon.Options.db.Tabs = nil;
    -- -- end

    SavedData.Fixes.FixTabs2 = true;

    diagnostics.Debug("Ported Tabs2 from previous version");
end

function FixNewEarnedByFilter2(prevBuild, currBuild, prevVersion, currVersion, firstTime)
    if currVersion < "37.0" or SavedData.Fixes.FixNewEarnedByFilter2 == true then
        diagnostics.Debug("New earned by filter2 already transfered from previous version");
        return;
    end

    if Filters.profiles and Filters.profiles.Default and Filters.profiles.Default.EarnedBy == (GetCategoryInfo(92)) then
        Filters.profiles.Default.EarnedBy = addon.L["Character only"];
    end

    SavedData.Fixes.FixNewEarnedByFilter2 = true;

    diagnostics.Debug("Transfered new earned by filter2 from previous version");
end