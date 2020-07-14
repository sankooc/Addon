﻿ local BFChat = LibStub('AceAddon-3.0'):GetAddon('BigFootChat'); local L = LibStub("AceLocale-3.0"):GetLocale("BigFootChat"); local info = {}; local DemoMenu = {}; local zoneName; local Alliance = 1419; local Horde = 1374; function raidersFrame_Init() local raidersButton = _G.BFCIconFrameRaidersButton; if BFChatFrame_CheckNumber then raidersButton:SetPoint("LEFT",_G.BFCIconFrameReportButton,"RIGHT",1,0) else raidersButton:SetPoint("TOPLEFT",BFCChatFrame,"TOPLEFT",322,-3); end raidersButton:SetScript("OnEnter",function(self) BigFoot_ShowNewbieTooltip(L["Raiders"]); end) raidersButton:SetScript("OnLeave",function(self) BigFoot_HideNewbieTooltip(); end) createRaidersFrame(); end function createRaidersFrame() local raidersButton = _G.BFCIconFrameRaidersButton; if BFChat.db.profile.enableRaidersButton then DemoMenu = {}; local i; if not zoneName then zoneName=GetZoneText(); if Raid_List[zoneName] then RaidersMenu_Registers(raidersButton, {}); raidersButton:Show(); DemoMenu = { { text = L["Raiders"], isTitle = 1, notCheckable = 1, }, }; i=2; for _,boss in ipairs(Raid_List[zoneName]) do if boss then DemoMenu[i] = {}; DemoMenu[i].text = boss.name; DemoMenu[i].arg1 = boss.raiders; i=i+1; end end RaidersMenu_Registers(raidersButton, DemoMenu); end end raidersButton:RegisterEvent("ZONE_CHANGED"); raidersButton:RegisterEvent("ZONE_CHANGED_INDOORS"); raidersButton:RegisterEvent("ZONE_CHANGED_NEW_AREA"); raidersButton:SetScript("OnEvent",function(self,event,...) if zoneName~=GetZoneText() then zoneName=GetZoneText(); if Raid_List[zoneName] then RaidersMenu_Registers(self, {}); self:Show(); DemoMenu = { { text = L["Raiders"], isTitle = 1, notCheckable = 1, }, }; i=2; for _,boss in ipairs(Raid_List[zoneName]) do if boss then DemoMenu[i] = {}; DemoMenu[i].text = boss.name; DemoMenu[i].arg1 = boss.raiders; i=i+1; end end RaidersMenu_Registers(self, DemoMenu); else self:Hide(); end end end) else raidersButton:UnregisterAllEvents(); raidersButton:Hide(); zoneName = nil; end end function RaidersMenu_Registers(parent, menuList) local name = parent:GetName() and parent:GetName() .. "MenuFrame"; parent.menuFrame = parent.menuFrame or CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate"); parent.menuFrame:Hide(); parent.menuFrame.point = "BOTTOMLEFT"; BDropDownMenu_Initialize(parent.menuFrame, RaidersMenu_Initialize, "MENU", nil, menuList); if (parent:GetScript("OnClick")) then parent:HookScript("OnClick", function(self, button) BToggleDropDownMenu(nil, nil, self.menuFrame, "cursor", -2, -2, menuList); end); else parent:SetScript("OnClick", function(self, button) BToggleDropDownMenu(nil, nil, self.menuFrame, "cursor", -2, -2, menuList); end); end end function RaidersMenu_Initialize(frame, level, menuList) if (type(menuList) == "table") then info =BDropDownMenu_CreateInfo(); for index = 1, #(menuList) do local _info = menuList[index]; if (_info.text) then _info.index = index; _info.func = function () local raiders = _info.text..":".._info.arg1; local linkString = "|CFF00B4FF|Hraiders:"..index.."|h[发送攻略]|h|r"; raiders = raiders .. linkString; DEFAULT_CHAT_FRAME:AddMessage(raiders, 1, 0.9, 0.4); end _info.level = _info.level or 1; if (level == _info.level) then BDropDownMenu_AddButton(_info, level); else if (_info.hasArrow and _info.subMenu and BDROPDOWNMENU_MENU_VALUE == _info.value) then RaidersMenu_Initialize(_info.subMenu, level); return; end end end table.insert(info,_info); end end end function BFCIconFrameRaidersButton_OnLoad(self) local Raiders_SetHyperlink_Origin = ItemRefTooltip.SetHyperlink; ItemRefTooltip.SetHyperlink = function(self,link) if(strsub(link, 1, 7)=="raiders") then return end return Raiders_SetHyperlink_Origin(self,link); end hooksecurefunc("SetItemRef", Raiders_SetItemRef); end function Raiders_SetItemRef(link, text, button) if (strsub(link, 1, 7) == "raiders") then local id = 0 + gsub(gsub(strsub(link,9),"/2","|"),"/1","/"); if id then local message = BFRAIDER_AD..info[id].text..":|"..info[id].arg1; local name,raiders = strsplit("|",message,2) if IsInRaid() then SendChatMessage(name, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or "RAID"); SendChatMessage(raiders, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or "RAID"); elseif IsInGroup() then SendChatMessage(name, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or "PARTY"); SendChatMessage(raiders, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or "PARTY"); else SendChatMessage(name, "say"); SendChatMessage(raiders, "say"); end end end end; 
