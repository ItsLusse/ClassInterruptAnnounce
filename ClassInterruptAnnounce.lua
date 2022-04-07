-- Class Interrupt Announce
-- Created by Lusse
-- Date: 03/14/2022

Cia = CreateFrame("frame")
Cia.Options = CreateFrame("Frame","COF",UIParent)
Cia.Minimap = CreateFrame("Frame",nil,Minimap)

Cia:RegisterEvent("ADDON_LOADED")
Cia:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
Cia:RegisterEvent("SPELLCAST_START")
Cia:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
Cia:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE")
Cia:RegisterEvent("CHARACTER_POINTS_CHANGED")
Cia:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
Cia:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")

-- Version from .toc file
Cia_Version = GetAddOnMetadata("ClassInterruptAnnounce", "Version") -- Grab version from .toc
Cia_Version_Msg = "|cff00ff00"..Cia_Version.."|r"

Cia_Settings = Cia_Settings or {}

spelltable = {}

Cia_Channels = {
	[1] = "|cffffffffSAY",
	[2] = "|cffff0000YELL",
	[3] = "|cff00ccffPARTY",
	[4] = "|cffFF7D0ARAID",
	[5] = "|cffFF4500CUSTOM",
}

local mytarget = ""
local myspell = ""
local intspell = ""
local mytyp = ""

local procctimer = ""

local combopoints = "0"

local channel = "SAY"

local channelid = ""
local channeldrop = ""
local New_Custom_Channel = nil -- For changing channels


local strings = {
	["Hit"]		= SPELLLOGSELFOTHER,		-- Your %s hits %s for %s.
	["Crit"]	= SPELLLOGCRITSELFOTHER,	-- Your %s crits %s for %s.
	["Dodge"]	= SPELLDODGEDSELFOTHER,		-- Your %s was dodged by %s.
	["Parry"]	= SPELLPARRIEDSELFOTHER,	-- Your %s is parried by %s.
	["Miss"]	= SPELLMISSSELFOTHER,		-- Your %s missed %s.
	["Block"]	= SPELLBLOCKEDSELFOTHER,	-- Your %s was blocked by %s.
	["Deflect"]	= SPELLDEFLECTEDSELFOTHER,	-- Your %s was deflected by %s.
	["Evade"]	= SPELLEVADEDSELFOTHER,		-- Your %s was evaded by %s.
	["Immune"]	= SPELLIMMUNESELFOTHER,		-- Your %s failed. %s is immune.
	["Absorb"]	= SPELLLOGABSORBSELFOTHER,	-- Your %s is absorbed by %s.
	["Reflect"]	= SPELLREFLECTSELFOTHER,	-- Your %s is reflected back by %s.
	["Resist"]	= SPELLRESISTSELFOTHER		-- Your %s was resisted by %s.
}

local stringsMiss = {
	["Dodge"]	= SPELLDODGEDSELFOTHER,		-- Your %s was dodged by %s.
	["Parry"]	= SPELLPARRIEDSELFOTHER,	-- Your %s is parried by %s.
	["Miss"]	= SPELLMISSSELFOTHER,		-- Your %s missed %s.
	["Block"]	= SPELLBLOCKEDSELFOTHER,	-- Your %s was blocked by %s.
	["Deflect"]	= SPELLDEFLECTEDSELFOTHER,	-- Your %s was deflected by %s.
	["Evade"]	= SPELLEVADEDSELFOTHER,		-- Your %s was evaded by %s.
	["Immune"]	= SPELLIMMUNESELFOTHER,		-- Your %s failed. %s is immune.
	["Absorb"]	= SPELLLOGABSORBSELFOTHER,	-- Your %s is absorbed by %s.
	["Reflect"]	= SPELLREFLECTSELFOTHER,	-- Your %s is reflected back by %s.
	["Resist"]	= SPELLRESISTSELFOTHER		-- Your %s was resisted by %s.
}

local stringsHit = {
	["Hit"] = 1,
	["Crit"] = 1,
	["Absorb"] = 1
}

SpellIcons = { 
	["Kick"] = "Interface\\Icons\\ability_kick",
	["Pummel"] = "Interface\\Icons\\inv_gauntlets_04",
	["Shield Bash"] = "Interface\\Icons\\ability_warrior_shieldbash",
	["Counterspell"] = "Interface\\Icons\\spell_frost_iceshock",
	["Silence"] = "Interface\\Icons\\spell_shadow_impphaseshift",
	["Earth Shock"] = "Interface\\Icons\\spell_nature_earthshock",
	["Feral Charge"] = "Interface\\Icons\\ability_hunter_pet_bear",
	["Kidney Shot"] = "Interface\\Icons\\ability_rogue_kidneyshot",
	["Cheap Shot"] = "Interface\\Icons\\ability_cheapshot",
	["Bash"] = "Interface\\Icons\\ability_druid_bash",
	["Hammer of Justice"] = "Interface\\Icons\\spell_holy_sealofmight",
	["Intercept"] = "Interface\\Icons\\ability_rogue_sprint",
	["War Stomp"] = "Interface\\Icons\\ability_warstomp",
	["Concussion Blow"] = "Interface\\Icons\\ability_thunderbolt",
	["Blackout"] = "Interface\\Icons\\spell_shadow_gathershadows",
	["Charge"] = "Interface\\Icons\\ability_warrior_charge",
	["Gouge"] = "Interface\\Icons\\ability_gouge",
	["Sap"] = "Interface\\Icons\\ability_sap",
	["Concussive Shot"] = "Interface\\Icons\\spell_frost_stun",
	["Counterspell - Silenced"] = "Interface\\Icons\\spell_frost_iceshock",
	["Pyroclasm"] = "Interface\\Icons\\spell_fire_volcano",
	["Impact"] = "Interface\\Icons\\spell_fire_meteorstorm",
	["Blind"] = "Interface\\Icons\\spell_shadow_mindsteal",
	["Scatter Shot"] = "Interface\\Icons\\ability_golemstormbolt",
	["Pounce"] = "Interface\\Icons\\ability_druid_supriseattack",
	["Starfire Stun"] = "Interface\\Icons\\spell_arcane_starfire",
	["Spell Lock"] = "Interface\\Icons\\spell_shadow_mindrot",
	["Mace Stun Effect"] = "Interface\\Icons\\spell_frost_stun",
	["Kick - Silenced"] = "Interface\\Icons\\ability_kick",
	["Shield Bash - Silenced"] = "Interface\\Icons\\ability_warrior_shieldbash",
	["Revenge Stun"] = "Interface\\Icons\\ability_warrior_revenge",
	["Expose Armor"] = "Interface\\Icons\\ability_warrior_riposte",
	["Armor Shatter"] = "Interface\\Icons\\inv_axe_12",
	["Spell Vulnerability"] = "Interface\\Icons\\inv_axe_12",
	["Glimpse of Madness"] = "Interface\\Icons\\inv_axe_24",
	["Earthshaker"] = "Interface\\Icons\\inv_hammer_04",
	["Disarm Trap"] = "Interface\\Icons\\spell_shadow_grimward",
}

local Interrupts = {
	"Kick",
	"Pummel",
	"Shield Bash",
	"Counterspell",
	"Silence",
	"Earth Shock",
	"Feral Charge",
	"Spell Lock",
}

local Stuns = {
	"Kidney Shot",
	"Cheap Shot",
	"Bash",
	"Hammer of Justice",
	"Intercept Stun",
	"War Stomp",
	"Concussion Blow",
	"Charge Stun",
	"Gouge",
	"Sap",
	"Blind",
	"Scatter Shot",
	"Pounce",
}

local SpecialStuns = {
	-- Talents
	"Blackout",
	"Improved Concussive Shot",
	"Pyroclasm",
	"Impact",
	"Starfire Stun",
	"Mace Stun Effect",
	"Revenge Stun",

	-- Weapons
	"Glimpse of Madness",
	"Earthshaker",
}

local WeaponProccs = {
	"Armor Shatter", -- Annihilator 1 stack
	"Armor Shatter (2)", -- Annihilator 2 stacks
	"Armor Shatter (3)", -- Annihilator 3 stacks
	"Spell Vulnerability", -- Nightfall
}

local SpecialInterrupts = {
	-- Talents
	"Kick - Silenced",
	"Counterspell - Silenced",
	"Shield Bash - Silenced",
}

local IntTargets = { -- List of npcs you'll announce when interrupting
	-- AQ40
	"The Prophet Skeram",
	"Princess Yauj",
	"Obsidian Eradicator",
	"Qiraji Brainwasher",
	"Eye Tentacle",
	"Giant Eye Tentacle",
	-- Naxx
	"Kel'Thuzad",
	"Necropolis Acolyte",
	"Naxxramas Acolyte",
	"Necro Knight",
	"Necro Knight Guardian",
	"Mad Scientist",
	"Unrelenting Rider", --??
	-- BWL
	"Blackwing Warlock",
	"Blackwing Technician",
	"Blackwing Taskmaster",
	"Blackwing Mage",
	"Blackwing Spellbinder",
	-- ZG
	"High Priestess Jeklik",
	"Zealot Lor'Khan",
	"Voodoo Slave",
}

local StunTargets = { -- List of npcs you'll announce when stunning
	-- Naxx
	"Plagued Ghoul",
	"Infectious Ghoul",
	"Poisonous Skitterer",
	"Naxxramas Acolyte",
    "Naxxramas Cultist",
    "Deathchill Servant",
	"Shade of Naxxramas",
    "Spirit of Naxxramas",
    "Plagued Construct",
    "Deathknight Servant",
	-- ZG
	"Hakkari Priest",
	"Voodoo Slave",
	"Gurubashi Blood Drinker",
    "Gurubashi Axe Thrower",
    "Gurubashi Champion",
    "Gurubashi Headhunter",
	-- AQ40
    "Sartura's Royal Guard",
    "Battleguard Sartura",
	"Spawn of Fankriss",
}

local function print(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

function GetSpells()
    local spellID = 1
    local spell = GetSpellName(spellID, "BOOKTYPE_SPELL")
    while (spell) do 
        spelltable[spell] = spellID
        spellID = spellID+1
        spell = GetSpellName(spellID, "BOOKTYPE_SPELL")
    end
end

function SpellExists(findspell)
	if not findspell then return end
	for i = 1, MAX_SKILLLINE_TABS do
		local name, texture, offset, numSpells = GetSpellTabInfo(i)
		if not name then break end
		for s = offset + 1, offset + numSpells do
		local	spell, rank = GetSpellName(s, BOOKTYPE_SPELL)
		if rank then
			local spell = spell.." "..rank
		end
		if string.find(spell,findspell,nil,true) then
			return true
		end
		end
	end
end

function Cia_Send(mytarget, myspell, intspell, mytyp)
	
	if myspell == "Intercept Stun" then
		myspell = "Intercept"
	elseif myspell == "Charge Stun" then
		myspell = "Charge"
	elseif myspell == "Improved Concussive Shot" then
		myspell = "Concussive Shot"
	elseif myspell == "Gouge" then
		return
	elseif myspell == "Scatter Shot" then
		return
	end

	if Cia_Settings[myspell] == 1 then
		if SpellExists(myspell) then	
			local spell = GetSpellName(spelltable[myspell], BOOKTYPE_SPELL)

			if myspell == spell then
				local start, duration, enabled = GetSpellCooldown(spelltable[myspell],"BOOKTYPE_SPELL")
				local cooldown = duration-(GetTime()-start)

				if intspell ~= "" then 
					if cooldown > tonumber(duration)-0.6 then
						if channeldrop == 5 then
							SendChatMessage(myspell.."'d "..mytarget.."'s "..intspell.." - "..duration.."s CD!", "CHANNEL", nil, channelid);
						else
							SendChatMessage(myspell.."'d "..mytarget.."'s "..intspell.." - "..duration.."s CD!",channel)
						end
					end
				else
					if cooldown > tonumber(duration)-0.6 then
						if channeldrop == 5 then
							SendChatMessage(myspell.."'d "..mytarget.." - "..duration.."s CD!", "CHANNEL", nil, channelid);
						else
							SendChatMessage(myspell.."'d "..mytarget.." - "..duration.."s CD!",channel)
						end
					end
				end
			end
					
		elseif myspell == "Blackout" then
			if UnitClass("player") == "Priest" then
				_,_,_,_,TalentsIn=GetTalentInfo(3,2)
				if TalentsIn>0 then
					if Cia_Settings[myspell] == 1 then
						if channeldrop == 5 then
							SendChatMessage(myspell.." stunned "..mytarget.."!", "CHANNEL", nil, channelid);
						else
							SendChatMessage(myspell.." stunned "..mytarget.."!",channel)
						end
					end
				end
			end
		elseif myspell == "Pyroclasm" then
			if UnitClass("player") == "Warlock" then
				_,_,_,_,TalentsIn=GetTalentInfo(3,12)
				if TalentsIn>0 then
					if Cia_Settings[myspell] == 1 then
						if channeldrop == 5 then
							SendChatMessage(myspell.." stunned "..mytarget.."!", "CHANNEL", nil, channelid);
						else
							SendChatMessage(myspell.." stunned "..mytarget.."!",channel)
						end
					end
				end
			end
		elseif myspell == "Impact" then
			if UnitClass("player") == "Mage" then
				_,_,_,_,TalentsIn=GetTalentInfo(2,2)
				if TalentsIn>0 then
					if Cia_Settings[myspell] == 1 then
						if channeldrop == 5 then
							SendChatMessage(myspell.." stunned "..mytarget.."!", "CHANNEL", nil, channelid);
						else
							SendChatMessage(myspell.." stunned "..mytarget.."!",channel)
						end
					end
				end
			end
		elseif myspell == "Counterspell - Silenced" then
			if UnitClass("player") == "Mage" then
				_,_,_,_,TalentsIn=GetTalentInfo(1,11)
				if TalentsIn>0 then
					local start, duration, enabled = GetSpellCooldown(spelltable["Counterspell"],"BOOKTYPE_SPELL")
					local cooldown = duration-(GetTime()-start)
					if Cia_Settings[myspell] == 1 then
						if cooldown > tonumber(duration)-0.4 then
							if channeldrop == 5 then
								SendChatMessage(myspell.." "..mytarget.." - "..duration.."s CD!", "CHANNEL", nil, channelid);
							else
								SendChatMessage(myspell.." "..mytarget.." - "..duration.."s CD!",channel)
							end
						end
					end
				end
			end
		elseif myspell == "Shield Bash - Silenced" then
			if UnitClass("player") == "Warrior" then
				_,_,_,_,TalentsIn=GetTalentInfo(3,15)
				if TalentsIn>0 then
					local start, duration, enabled = GetSpellCooldown(spelltable["Shield Bash"],"BOOKTYPE_SPELL")
					local cooldown = duration-(GetTime()-start)
					if Cia_Settings[myspell] == 1 then
						if cooldown > tonumber(duration)-0.4 then
							if channeldrop == 5 then
								SendChatMessage("Shield Bash silenced "..mytarget.." - "..duration.."s CD!", "CHANNEL", nil, channelid);
							else
								SendChatMessage("Shield Bash silenced "..mytarget.." - "..duration.."s CD!",channel)
							end
						end
					end
				end
			end
		elseif myspell == "Starfire Stun" then
			if UnitClass("player") == "Druid" then
				_,_,_,_,TalentsIn=GetTalentInfo(1,12)
				if TalentsIn>0 then
					if Cia_Settings[myspell] == 1 then
						if channeldrop == 5 then
							SendChatMessage("Starfire stunned "..mytarget.."!", "CHANNEL", nil, channelid);
						else
							SendChatMessage("Starfire stunned "..mytarget.."!",channel)
						end
					end
				end
			end
		elseif myspell == "Mace Stun Effect" then
			if UnitClass("player") == "Rogue" then
				_,_,_,_,TalentsIn=GetTalentInfo(2,13)
				if TalentsIn>0 then
					if Cia_Settings[myspell] == 1 then
						if channeldrop == 5 then
							SendChatMessage("Mace Stun stunned "..mytarget.."!", "CHANNEL", nil, channelid);
						else
							SendChatMessage("Mace Stun stunned "..mytarget.."!",channel)
						end
					end
				end
			elseif UnitClass("player") == "Warrior" then
				_,_,_,_,TalentsIn=GetTalentInfo(1,14)
				if TalentsIn>0 then
					if Cia_Settings[myspell] == 1 then
						if channeldrop == 5 then
							SendChatMessage("Mace Stun stunned "..mytarget.."!", "CHANNEL", nil, channelid);
						else
							SendChatMessage("Mace Stun stunned "..mytarget.."!",channel)
						end
					end
				end
			end

		elseif myspell == "Kick - Silenced" then
			if UnitClass("player") == "Rogue" then
				_,_,_,_,TalentsIn=GetTalentInfo(2,10)
				if TalentsIn>0 then
					local start, duration, enabled = GetSpellCooldown(spelltable["Kick"],"BOOKTYPE_SPELL")
					local cooldown = duration-(GetTime()-start)
					if Cia_Settings[myspell] == 1 then
						if cooldown > tonumber(duration)-0.4 then
							if channeldrop == 5 then
								SendChatMessage(myspell.." "..mytarget.." - "..duration.."s CD!", "CHANNEL", nil, channelid);
							else
								SendChatMessage(myspell.." "..mytarget.." - "..duration.."s CD!",channel)
							end
						end
					end
				end
			end
		elseif myspell == "Spell Lock" then
			if UnitClass("player") == "Warlock" then
				if PetSpellNum(myspell) then
					local start,duration,enable = GetPetActionCooldown(PetSpellNum(myspell))
					local cooldown = duration-(GetTime()-start)

					if Cia_Settings[myspell] == 1 then
						if cooldown > tonumber(duration)-0.4 then
							if mytyp == stringsMiss[hitType] then
								if channeldrop == 5 then
									SendChatMessage(">>>MISSED<<< "..myspell.." on "..mytarget.." ("..mytyp..") - "..duration.."s CD!", "CHANNEL", nil, channelid);
								else
									SendChatMessage(">>>MISSED<<< "..myspell.." on "..mytarget.." ("..mytyp..") - "..duration.."s CD!",channel)
								end
							else
								if channeldrop == 5 then
									SendChatMessage(myspell.." silenced "..mytarget.." - "..duration.."s CD!", "CHANNEL", nil, channelid);
								else
									SendChatMessage(myspell.." silenced "..mytarget.." - "..duration.."s CD!",channel)
								end
							end
						end
					end
				end
			end
		elseif myspell == "Revenge Stun" then
			if UnitClass("player") == "Warrior" then
				_,_,_,_,TalentsIn=GetTalentInfo(3,8)
				if TalentsIn>0 then
					if Cia_Settings[myspell] == 1 then
						if channeldrop == 5 then
							SendChatMessage(myspell.."ned "..mytarget.."!", "CHANNEL", nil, channelid);
						else
							SendChatMessage(myspell.."ned "..mytarget.."!",channel)
						end
					end
				end
			end
		elseif myspell == "Earthshaker" then
			if GetInventoryItemTexture("player",16) == "Interface\\Icons\\INV_Hammer_04" then
				if channeldrop == 5 then
					SendChatMessage(myspell.." stunned "..mytarget.."!", "CHANNEL", nil, channelid);
				else
					SendChatMessage(myspell.." stunned "..mytarget.."!",channel)
				end
			end
		elseif myspell == "Glimpse of Madness" then
			if GetInventoryItemTexture("player",16) == "Interface\\Icons\\INV_Axe_24" then
				if channeldrop == 5 then
					SendChatMessage(myspell.." disoriented "..mytarget.."!", "CHANNEL", nil, channelid);
				else
					SendChatMessage(myspell.." disoriented "..mytarget.."!",channel)
				end
			end
		elseif myspell == "Armor Shatter" then
			if GetInventoryItemTexture("player",16) == "Interface\\Icons\\INV_Axe_12" then
				if channeldrop == 5 then
					SendChatMessage(myspell.."'d (1) "..mytarget.."!", "CHANNEL", nil, channelid);
				else
					SendChatMessage(myspell.."'d (1) "..mytarget.."!",channel)
				end
			end
		elseif myspell == "Armor Shatter (2)" then
			if GetInventoryItemTexture("player",16) == "Interface\\Icons\\INV_Axe_12" then
				if channeldrop == 5 then
					SendChatMessage("Armor Shatter'd (2) "..mytarget.."!", "CHANNEL", nil, channelid);
				else
					SendChatMessage("Armor Shatter'd (2) "..mytarget.."!",channel)
				end
			end
		elseif myspell == "Armor Shatter (3)" then
			if GetInventoryItemTexture("player",16) == "Interface\\Icons\\INV_Axe_12" then
				if channeldrop == 5 then
					SendChatMessage("Armor Shatter'd (3) "..mytarget.."!", "CHANNEL", nil, channelid);
				else
					SendChatMessage("Armor Shatter'd (3) "..mytarget.."!",channel)
				end
			end
		elseif myspell == "Spell Vulnerability" then
			if GetInventoryItemTexture("player",16) == "Interface\\Icons\\INV_Axe_12" and GetInventoryItemTexture("player",17) == nil then
				if channeldrop == 5 then
					SendChatMessage("Nightfall procc'd "..mytarget.."!", "CHANNEL", nil, channelid);
				else
					SendChatMessage("Nightfall procc'd "..mytarget.."!",channel)
				end
			end
		end
	elseif myspell == "" then
		if UnitClass("player") == "Warlock" then
			local lockspell = "Spell Lock"
			if PetSpellNum(lockspell) then
				local start,duration,enable = GetPetActionCooldown(PetSpellNum(lockspell))
				local cooldown = duration-(GetTime()-start)

				if Cia_Settings[lockspell] == 1 then
					if cooldown > tonumber(duration)-0.4 then
						if intspell ~= "" then
							if channeldrop == 5 then
								SendChatMessage(lockspell.." interrupted "..mytarget.."'s "..intspell.." - "..duration.."s CD!", "CHANNEL", nil, channelid);
							else
								SendChatMessage(lockspell.." interrupted "..mytarget.."'s "..intspell.." - "..duration.."s CD!",channel)
							end
						end
					end
				end
			end
		end
	end

	mytarget = ""
	myspell = ""
	intspell = ""
	mytyp = ""
end

function PetSpellNum(spell)
	local i
	for i=1,20 do
		local name,rank,texture,somtin,somtinelse,isAutocast,IsAutocastable=GetPetActionInfo(i)
		if name==spell then return i end
	end
end

function Cia_Tell(spell, target, hitType, cooldown)
	local msg = nil

	if stringsHit[hitType] then
		msg = format("%s'd %s - %ss CD!", spell, target, cooldown)
	end
	if stringsMiss[hitType] then
		msg = format(">>>MISSED<<< %s on %s (%s) - %ss CD!", spell, target, hitType, cooldown)
	end

	if Cia_Settings[spell] == 1 then
		for k,Interrupts in pairs(Interrupts) do
			if spell == Interrupts then
				for k,IntTargets in pairs(IntTargets) do
					if target == IntTargets then
						if channeldrop == 5 then
							SendChatMessage(msg, "CHANNEL", nil, channelid);
						else
							SendChatMessage(msg,channel)
						end
					end
				end
			end
		end

		for k,Stuns in pairs(Stuns) do
			if spell == Stuns then
				for k,StunTargets in pairs(StunTargets) do
					if target == StunTargets then
						if channeldrop == 5 then
							SendChatMessage(msg, "CHANNEL", nil, channelid);
						else
							SendChatMessage(msg,channel)
						end
					end
				end
			end
		end

		for k,SpecialStuns in pairs(SpecialStuns) do
			if spell == SpecialStuns then
				for k,StunTargets in pairs(StunTargets) do
					if target == StunTargets then
						if channeldrop == 5 then
							SendChatMessage(msg, "CHANNEL", nil, channelid);
						else
							SendChatMessage(msg,channel)
						end
					end
				end
			end
		end

		for k,SpecialInterrupts in pairs(SpecialInterrupts) do
			if spell == SpecialInterrupts then
				for k,IntTargets in pairs(IntTargets) do
					if target == IntTargets then
						if channeldrop == 5 then
							SendChatMessage(msg, "CHANNEL", nil, channelid);
						else
							SendChatMessage(msg,channel)
						end
					end
				end
			end
		end
	end
end

function Cia_Check()
	for typ, str in strings do
		local _, _, spell, target = string.find(arg1, str)
		if spell and target then
			if Cia_Settings[spell] == 1 then
				if SpellExists(spell) then
					for k,Interrupts in pairs(Interrupts) do
						if spell == Interrupts then
							local start, duration, enabled = GetSpellCooldown(spelltable[spell],"BOOKTYPE_SPELL")

							if tonumber(duration) <= 1.5 then
								CiaOnUpdateActivate("fetchcd")
								myspell = spell
								mytarget = target
								mytyp = typ
							else
								Cia_Tell(spell, target, typ, duration)
							end
							return
						end
					end

					for k,Stuns in pairs(Stuns) do
						if spell == Stuns then
							if spell == "Intercept Stun" then
								spell = "Intercept"
							elseif spell == "Charge Stun" then
								spell = "Charge"
							elseif spell == "Improved Concussive Shot" then
								spell = "Concussive Shot"
							end

							local start, duration, enabled = GetSpellCooldown(spelltable[spell],"BOOKTYPE_SPELL")

							if tonumber(duration) <= 1.5 then
								CiaOnUpdateActivate("fetchcd")
								myspell = spell
								mytarget = target
								mytyp = typ
							else
								Cia_Tell(spell, target, typ, duration)
							end
							return
						end
					end
				else
					for k,SpecialStuns in pairs(SpecialStuns) do
						if spell == SpecialStuns then
								Cia_Tell(spell, target, typ, duration)
							return
						end
					end

					for k,SpecialInterrupts in pairs(SpecialInterrupts) do
						if spell == SpecialInterrupts then
								Cia_Tell(spell, target, typ, duration)
							return
						end
					end
				end
			end
		end
	end
end

-- DelayTimer
local CiaOnUpdate = CreateFrame("Button","CiaOnUpdate",UIParent)

CiaOnUpdateTimerActive = nil
CiaOnUpdateTimer = nil
CiaUpdateFetchSpells = nil
CiaUpdateFetchCD = nil
CiaUpdateChannelChange = nil
CiaUpdateGetCP = nil

function CiaOnUpdate:OnUpdate()
	if CiaOnUpdateTimerActive == true then
		if GetTime() - CiaOnUpdateTimer > 0.2 then

			if CiaUpdateFetchSpells == true then
				GetSpells()
				CiaDefault()
				CiaOnUpdateActivate("fetchspells")
			end

			if CiaUpdateFetchCD == true then
				local start, duration, enabled = GetSpellCooldown(spelltable[myspell],"BOOKTYPE_SPELL")
				Cia_Tell(myspell, mytarget, mytyp, duration)
				myspell = ""
				mytarget = ""
				mytyp = ""
				CiaOnUpdateActivate("fetchcd")
			end

			if CiaUpdateChannelChange == true then
				Cia_ChangeChannel()
				CiaOnUpdateActivate("channelchange")
			end

			if CiaUpdateGetCP == true then
				combopoints = GetComboPoints("player", "target")
				CiaOnUpdateActivate("getcp")
			end
		end
    end
end

CiaOnUpdate:SetScript("OnUpdate", CiaOnUpdate.OnUpdate) 

function CiaOnUpdateActivate(arg)

	if arg == "fetchspells" then
		if CiaOnUpdateTimerActive == true then
			CiaOnUpdateTimerActive  = nil
			CiaOnUpdateTimer = nil
			CiaUpdateFetchSpells = nil
		else
			CiaOnUpdateTimer = GetTime();
			CiaOnUpdateTimerActive = true
			CiaUpdateFetchSpells = true
        end
	end

	if arg == "fetchcd" then
		if CiaOnUpdateTimerActive == true then
			CiaOnUpdateTimerActive  = nil
			CiaOnUpdateTimer = nil
			CiaUpdateFetchCD = nil
		else
			CiaOnUpdateTimer = GetTime();
			CiaOnUpdateTimerActive = true
			CiaUpdateFetchCD = true
        end
	end

	if arg == "channelchange" then
		if CiaOnUpdateTimerActive == true then
			CiaOnUpdateTimerActive  = nil
			CiaOnUpdateTimer = nil
			CiaUpdateChannelChange = nil
		else
			CiaOnUpdateTimer = GetTime();
			CiaOnUpdateTimerActive = true
			CiaUpdateChannelChange = true
        end
	end

	if arg == "getcp" then
		if CiaOnUpdateTimerActive == true then
			CiaOnUpdateTimerActive  = nil
			CiaOnUpdateTimer = nil
			CiaUpdateGetCP = nil
		else
			CiaOnUpdateTimer = GetTime();
			CiaOnUpdateTimerActive = true
			CiaUpdateGetCP = true
        end
	end
end

function Cia:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "ClassInterruptAnnounce" then
        CiaOnUpdateActivate("fetchspells")
		Cia.Options:Gui()
		Cia.Minimap:CreateMinimapIcon()
		print(Cia_GetClassColorForName(UnitClass("player")).."Class |cffffffffInterrupt |cffff0000Announce|r Loaded - "..Cia_Version_Msg)
		
		if (not Cia_Settings["customchannel"]) then
			Cia_Settings["customchannel"] = "cia"; -- The default used (private chan, guild, say, party etc)
		end

		for index in strings do
            for _, pattern in {"%%s", "%%d"} do
                strings[index] = gsub(strings[index], pattern, "(.*)")
            end
        end

	elseif event == "CHARACTER_POINTS_CHANGED" then
		GetSpells()

		if UnitClass("player") == "Mage" then
			_,_,_,_,TalentsIn=GetTalentInfo(1,11)
			if TalentsIn>0 then
				Cia_Settings["Counterspell"] = 0
				CounterspellCheck:SetChecked(0)
				CounterspellSilencedCheck:Show()
				CounterspellCheck:Hide()
			else
				Cia_Settings["Counterspell - Silenced"] = 0
				CounterspellSilencedCheck:SetChecked(0)
				CounterspellSilencedCheck:Hide()
				CounterspellCheck:Show()
			end
		end

		if UnitClass("player") == "Rogue" then
			_,_,_,_,TalentsIn=GetTalentInfo(2,10)
			if TalentsIn>0 then
				Cia_Settings["Kick"] = 0
				KickCheck:SetChecked(0)
				KickSilencedCheck:Show()
				KickCheck:Hide()
			else
				Cia_Settings["Kick - Silenced"] = 0
				KickSilencedCheck:SetChecked(0)
				KickSilencedCheck:Hide()
				KickCheck:Show()
			end
		end

		if UnitClass("player") == "Warrior" then
			_,_,_,_,TalentsIn=GetTalentInfo(3,15)
			if TalentsIn>0 then
				Cia_Settings["Shield Bash"] = 0
				ShieldBashCheck:SetChecked(0)
				ShieldBashSilencedCheck:Show()
				ShieldBashCheck:Hide()
			else
				Cia_Settings["Shield Bash - Silenced"] = 0
				ShieldBashSilencedCheck:SetChecked(0)
				ShieldBashSilencedCheck:Hide()
				ShieldBashCheck:Show()
			end
		end

	elseif event == "CHAT_MSG_COMBAT_SELF_HITS" then
		procctimer = math.floor(GetTime())

	elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then

		procctimer = math.floor(GetTime())
		CiaOnUpdateActivate("getcp")

		if string.find(arg1,"You interrupt (.+)") then
			for k,IntTargets in pairs(IntTargets) do
				if UnitClass("player") == "Mage" then
					local _,_,unit,cast= string.find(arg1,"You interrupt (.+)'s%s(.+).")
					if unit == IntTargets then
						mytarget = unit
						myspell = "Counterspell"
						intspell = cast
						Cia_Send(mytarget, myspell, intspell, mytyp)
					end
				elseif UnitClass("player") == "Druid" then
					local _,_,unit,cast= string.find(arg1,"You interrupt (.+)'s%s(.+).")
					if unit == IntTargets then
						mytarget = unit
						myspell = "Feral Charge"
						intspell = cast
						Cia_Send(mytarget, myspell, intspell, mytyp)
					end
				end
            end
		else
			Cia_Check()
		end

	elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then

		local _,_,unit,spell= string.find(arg1,"(.+) is afflicted by (.+).")
		
		if procctimer == "" then
			procctimer = "1"
		end

		local timeSinceStart = GetTime()-tonumber(procctimer)

		if timeSinceStart < 1.5 then
			if string.find(arg1,".+ is afflicted by .+.") then
				for k,StunTargets in pairs(StunTargets) do
					if unit == StunTargets then
						for k,SpecialStuns in pairs(SpecialStuns) do
							if spell == SpecialStuns then
								mytarget = unit
								myspell = spell
								Cia_Send(mytarget, myspell, intspell, mytyp)
							end
						end
					end
				end

				for k,IntTargets in pairs(IntTargets) do
					if unit == IntTargets then
						for k,SpecialInterrupts in pairs(SpecialInterrupts) do
							if spell == SpecialInterrupts then
								mytarget = unit
								myspell = spell
								Cia_Send(mytarget, myspell, intspell, mytyp)
							end
						end
					end
				end
			end
		end

		if string.find(arg1,".+ is afflicted by .+.") then
			for k,StunTargets in pairs(StunTargets) do
				if unit == StunTargets then
					for k,Stuns in pairs(Stuns) do 
						if spell == Stuns then
							mytarget = unit
							myspell = spell
							Cia_Send(mytarget, myspell, intspell, mytyp)
						end
					end
				end
			end

			for k,IntTargets in pairs(IntTargets) do
				if unit == IntTargets then
					for k,Interrupts in pairs(Interrupts) do 
						if spell == Interrupts then
							mytarget = unit
							myspell = spell
							intspell = ""
							Cia_Send(mytarget, myspell, intspell, mytyp)
						end
					end
				end
			end

			if UnitClassification("target") ==  "worldboss" then
				for k,WeaponProccs in pairs(WeaponProccs) do 
					if spell == WeaponProccs then
						mytarget = unit
						myspell = spell
						intspell = ""
						Cia_Send(mytarget, myspell, intspell, mytyp)
					end
				end
				if UnitClass("player") == "Rogue" then
					if spell == "Expose Armor" then
						--if combopoints == 5 then
							mytarget = unit
							myspell = spell
							intspell = ""
							Cia_Send(mytarget, myspell, intspell, mytyp)
						--else
						--	_,_,_,_,TalentsIn=GetTalentInfo(1,8)
						--	if TalentsIn>0 then
						--		SendChatMessage("Expose Armor'd "..unit.." with ONLY "..combopoints.." CP!",channel)
						--	else
						--		SendChatMessage("Expose Armor'd "..unit.." (NOT IMPROVED) with ONLY "..combopoints.." CP!",channel)
						--	end
						--end
					end
				end
			end
		end

		procctimer = ""
		timeSinceStart = ""
		combopoints = "0"

	elseif event == "CHAT_MSG_SPELL_PET_DAMAGE" then
		if string.find(arg1,".+'s .+ was .+ by .+.") then
			for k,IntTargets in pairs(IntTargets) do
				local _,_,mypet,spell,typ,unit= string.find(arg1,"(.+)'s (.+) was (.+) by (.+).")
				if unit == IntTargets then
					for k,Interrupts in pairs(Interrupts) do 
						if spell == Interrupts then
							mytarget = unit
							myspell = spell
							intspell = ""
							mytyp = typ
							Cia_Send(mytarget, myspell, intspell, mytyp)
						end
					end
				end
            end
		end
		if string.find(arg1,".+ interrupts .+'s .+.") then
			for k,IntTargets in pairs(IntTargets) do
				local _,_,mypet,unit,cast= string.find(arg1,"(.+) interrupts (.+)'s (.+).")
				if unit == IntTargets then 
					mytarget = unit
					myspell = ""
					intspell = cast
					mytyp = ""
					Cia_Send(mytarget, myspell, intspell, mytyp)
				end
            end
		end

	elseif event == "CHAT_MSG_SPELL_AURA_GONE_OTHER" then
		if UnitClassification("target") ==  "worldboss" then
			if UnitClass("player") == "Rogue" then
				_,_,_,_,TalentsIn=GetTalentInfo(1,8)
				if TalentsIn>0 then
					local _,_,spell = string.find(arg1,"(.+) fades from .+.")
					if spell == "Expose Armor" then
						SendChatMessage("Expose Armor expired on "..UnitName("target")..", I have "..GetComboPoints("player", "target").." CP and "..UnitMana("player").." Energy!",channel)
					end
				end
			end
		end

	elseif event == "SPELLCAST_START" then
		if GameTooltipTextLeft1:GetText() == "Suppression Device" then
			if arg1 == "Disarm Trap" then
				if Cia_Settings["Disarm Trap"] == 1 then
					if channeldrop == 5 then
						SendChatMessage("I'm disarming this trap!", "CHANNEL", nil, channelid);
					else
						SendChatMessage("I'm disarming this trap!",channel)
					end
				end
			end
		end
	end
end

Cia:SetScript("OnEvent", Cia.OnEvent) -- the OnEvent script

function Cia:CreateCheckbox(name,tab,text)
	if text == "" then
		text = name
	end

	local spacename = string.gsub(name,"[^%a+]", "")
	local MyCheckbox = CreateFrame("CheckButton", spacename.."Check", tab, "UICheckButtonTemplate")
	MyCheckbox:SetPoint("CENTER",0,80)
	MyCheckbox:SetWidth(35)
	MyCheckbox:SetHeight(35)
	MyCheckbox:SetFrameStrata("MEDIUM")
	MyCheckbox:SetScript("OnClick", function ()
		if MyCheckbox:GetChecked() == nil then 
			Cia_Settings[name] = nil
		elseif MyCheckbox:GetChecked() == 1 then 
			Cia_Settings[name] = 1 
		end
	end)
	MyCheckbox:SetNormalTexture("")
	MyCheckbox:SetPushedTexture("")
	MyCheckbox:SetChecked(Cia_Settings[name])
	MyCheckbox.Icon = MyCheckbox:CreateTexture(nil, 'ARTWORK',1)
	MyCheckbox.Icon:SetTexture(SpellIcons[name])
	MyCheckbox.Icon:SetWidth(35)
	MyCheckbox.Icon:SetHeight(35)
	MyCheckbox.Icon:SetPoint("CENTER",0,0)
	MyCheckbox.text = MyCheckbox:CreateFontString(nil, "OVERLAY")
	MyCheckbox.text:SetPoint("CENTER", MyCheckbox, "CENTER", 0, 25)
	MyCheckbox.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	MyCheckbox.text:SetTextColor(1, 1, 1, 1)
	MyCheckbox.text:SetShadowOffset(2,-2)
	MyCheckbox.text:SetText(text)

	--MyCheckbox.bg = Checkbox:CreateTexture(nil,"BACKGROUND")
	--MyCheckbox.bg:SetAllPoints(true)
	--MyCheckbox.bg:SetTexture(0.2, 0.6, 0, 0.8)
    return MyCheckbox
end

-- GUI
function Cia.Options:Gui()

	Cia.Options.Drag = { }
	function Cia.Options.Drag:StartMoving()
		this:StartMoving()
	end
	
	function Cia.Options.Drag:StopMovingOrSizing()
		this:StopMovingOrSizing()
	end

	backdrop = {
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	}
	self:SetFrameStrata("BACKGROUND")
	self:SetWidth(340)
	self:SetHeight(425)
	self:SetPoint("CENTER",0,0)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	--self:SetBackdrop(backdrop)
	--self:SetBackdropColor(0,0,0)
	self:SetScript("OnDragStart", Cia.Options.Drag.StartMoving)
	self:SetScript("OnDragStop", Cia.Options.Drag.StopMovingOrSizing)
	--self:SetBackdrop(backdrop) --border around the frame
	self:SetBackdropColor(0,0,0,1);
	
	-- background
	self.Background = {} -- Background Frame table
	
	self.Background.Topleft = CreateFrame("Frame",nil,self) -- Topleft Background Frame
	self.Background.Topright = CreateFrame("Frame",nil,self) -- Topright Background Frame
	self.Background.Bottomleft = CreateFrame("Frame",nil,self) -- Bottomleft Background Frame
	self.Background.Bottomright =  CreateFrame("Frame",nil,self) -- Bottomright Background Frame
	self.Background.Tab1 =  CreateFrame("Frame",nil,self) -- Mid Background Frame
	self.Background.Tab2 =  CreateFrame("Frame",nil,self) -- Mid Background Frame
	self.Background.Button1 =  CreateFrame("Button",nil,self) -- Mid Background Frame
	self.Background.Button2 =  CreateFrame("Button",nil,self) -- Mid Background Frame

	-- Topleft Background Frame
	local backdrop = {bgFile = "Interface\\TaxiFrame\\UI-TaxiFrame-TopLeft"} 
	self.Background.Topleft:SetFrameStrata("BACKGROUND")
	self.Background.Topleft:SetWidth(256)
	self.Background.Topleft:SetHeight(256)
	self.Background.Topleft:SetBackdrop(backdrop)
	self.Background.Topleft:SetPoint("TOPLEFT",-10,13)
	
	-- Topright Background Frame
	local backdrop = {bgFile = "Interface\\TaxiFrame\\UI-TaxiFrame-TopRight"}
	self.Background.Topright:SetFrameStrata("BACKGROUND")
	self.Background.Topright:SetWidth(128)
	self.Background.Topright:SetHeight(256)
	self.Background.Topright:SetBackdrop(backdrop)
	self.Background.Topright:SetPoint("TOPLEFT",246,13)
	
	-- Bottomleft Background Frame
	local backdrop = {bgFile = "Interface\\TaxiFrame\\UI-TaxiFrame-BotLeft"}
	self.Background.Bottomleft:SetFrameStrata("BACKGROUND")
	self.Background.Bottomleft:SetWidth(256)
	self.Background.Bottomleft:SetHeight(256)
	self.Background.Bottomleft:SetBackdrop(backdrop)
	self.Background.Bottomleft:SetPoint("TOPLEFT",-10,-243)
	
	-- Bottomright Background Frame
	local backdrop = {bgFile = "Interface\\TaxiFrame\\UI-TaxiFrame-BotRight"}
	self.Background.Bottomright:SetFrameStrata("BACKGROUND")
	self.Background.Bottomright:SetWidth(128)
	self.Background.Bottomright:SetHeight(256)
	self.Background.Bottomright:SetBackdrop(backdrop)
	self.Background.Bottomright:SetPoint("TOPLEFT",246,-243)
	
	--title text
	self.HeadText = self.Background.Topleft:CreateFontString(nil, "OVERLAY")
	self.HeadText:SetPoint("TOP",75,-18)
	self.HeadText:SetFont("Fonts\\FRIZQT__.TTF", 12)
	self.HeadText:SetTextColor(255, 255, 0, 1)
	self.HeadText:SetShadowOffset(2,-2)
	self.HeadText:SetText(Cia_GetClassColorForName(UnitClass("player")).."Class |cffffffffInterrupt |cffff0000Announce |cffffff00- Options")

	-- a texture
	local r, l, t, b = Cia:ClassPos(UnitClass("player"))
	self.Icon = self:CreateTexture(nil, 'ARTWORK')
	self.Icon:SetTexture("Interface\\AddOns\\ClassInterruptAnnounce\\Images\\UI-CLASSES-CIRCLES")
	self.Icon:SetTexCoord(r, l, t, b)
	self.Icon:SetWidth(64)
	self.Icon:SetHeight(64)
	self.Icon:SetPoint("TOPLEFT",-4,9)

	local backdrop = {
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		tile="true",
		tileSize="8",
		edgeSize="8",
		insets={
			left="2",
			right="2",
			top="2",
			bottom="2"
		}
	}

	-- Tab1 Background Frame
	self.Background.Tab1:SetFrameStrata("HIGH")
	self.Background.Tab1:SetWidth(315)
	self.Background.Tab1:SetHeight(350)
	self.Background.Tab1:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -65)

	--self.Background.Tab1.bg = self.Background.Tab1:CreateTexture(nil,"BACKGROUND")
	--self.Background.Tab1.bg:SetAllPoints(true)
	--self.Background.Tab1.bg:SetTexture(0.2, 0.6, 0, 0.8)
	
	-- Tab2 Background Frame
	self.Background.Tab2:SetFrameStrata("HIGH")
	self.Background.Tab2:SetWidth(315)
	self.Background.Tab2:SetHeight(350)
	self.Background.Tab2:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -65)	

	-- Tab buttons
	
	-- Button1
	local activebackdrop = {bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab"}
	local inactivebackdrop = {bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-InactiveTab"}
	self.Background.Button1:SetBackdrop(activebackdrop)
	--self.Background.Button1:SetBackdropColor(0,0,0,0.6)
	self.Background.Button1:SetFrameStrata("MEDIUM")
	self.Background.Button1:SetPoint("BOTTOMLEFT",15,-28)
	self.Background.Button1:SetWidth(80)
	self.Background.Button1:SetHeight(32)
	self.Background.Button1:SetScript("OnClick", function() 
		self.Background.Tab1:Show()
		self.Background.Tab2:Hide()
		self.Background.Button1:SetBackdrop(activebackdrop)
		self.Background.Button2:SetBackdrop(inactivebackdrop)
	end)
	
	self.tab1text = self.Background.Button1:CreateFontString(nil, "OVERLAY")
	self.tab1text:SetPoint("CENTER", 0, 0)
	self.tab1text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	self.tab1text:SetTextColor(255,255,0, 1)
	self.tab1text:SetShadowOffset(2,-2)
	self.tab1text:SetText("Abilities")

	-- Button2
	local activebackdrop = {bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab"}
	local inactivebackdrop = {bgFile = "Interface\\PaperDollInfoFrame\\UI-Character-InactiveTab"}
	self.Background.Button2:SetBackdrop(inactivebackdrop)
	--self.Background.Button2:SetBackdropColor(1,1,1,0)
	self.Background.Button2:SetFrameStrata("MEDIUM")
	self.Background.Button2:SetPoint("BOTTOMLEFT",90,-28)
	self.Background.Button2:SetWidth(80)
	self.Background.Button2:SetHeight(32)
	self.Background.Button2:SetScript("OnClick", function() 
		self.Background.Tab2:Show()
		self.Background.Tab1:Hide()

		self.Background.Button1:SetBackdrop(inactivebackdrop)
		self.Background.Button2:SetBackdrop(activebackdrop)
	end)
	
	self.tab2text = self.Background.Button2:CreateFontString(nil, "OVERLAY")
	self.tab2text:SetPoint("CENTER", 0, 0)
	self.tab2text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	self.tab2text:SetTextColor(255,255,0, 1)
	self.tab2text:SetShadowOffset(2,-2)
	self.tab2text:SetText("Weapons")

	self.Background.Tab2:Hide() -- hides second tab at start

	-- ClassFrame
	local Class = UnitClass("player")
	self.Class = CreateFrame("Frame",nil,self.Background.Tab1)
	self.Class:SetFrameStrata("MEDIUM")
	self.Class:SetWidth(300)
	self.Class:SetHeight(280)
	self.Class:SetPoint('TOP', 0, -20)
	self.Class:SetBackdrop(backdrop)
	self.Class:SetBackdropColor(0,0,0,1)

	local Classtext = self.Class:CreateFontString(nil, "OVERLAY")
	Classtext:SetPoint("TOP",0,20)
	Classtext:SetFont("Fonts\\FRIZQT__.TTF", 15)
	Classtext:SetTextColor(255, 255, 0, 1)
	Classtext:SetShadowOffset(2,-2)
	Classtext:SetText("Announce "..Cia_GetClassColors(UnitClass("player")).." Abilities:")

	-- TaurenFrame
	self.Tauren = CreateFrame("Frame",nil,self.Background.Tab1)
	self.Tauren:SetFrameStrata("MEDIUM")
	self.Tauren:SetWidth(300)
	self.Tauren:SetHeight(70)
	self.Tauren:SetPoint('BOTTOM', 0, 85)
	self.Tauren:SetBackdrop(backdrop)
	self.Tauren:SetBackdropColor(0,0,0,1)
	self.Tauren:Hide()

	local Taurentext = self.Tauren:CreateFontString(nil, "OVERLAY")
	Taurentext:SetPoint("TOP",0,20)
	Taurentext:SetFont("Fonts\\FRIZQT__.TTF", 15)
	Taurentext:SetTextColor(255, 255, 0, 1)
	Taurentext:SetShadowOffset(2,-2)
	Taurentext:SetText("Tauren Stun:")

	if UnitClass("player") == "Rogue" then
		self.Class:SetHeight(210)
		
		local Checkbox = Cia:CreateCheckbox("Kick",self.Class,"")
		Checkbox:SetPoint("TOP",-120, -20)
		Checkbox:SetScript("OnClick", function () 
			if Checkbox:GetChecked() == nil then 
				Cia_Settings["Kick"] = nil
			elseif Checkbox:GetChecked() == 1 then 
				Cia_Settings["Kick"] = 1 
				Cia_Settings["Kick - Silenced"] = nil
				KickSilencedCheck:SetChecked(0)
			end
		end)

		local Checkbox = Cia:CreateCheckbox("Kick - Silenced",self.Class,"Silence")
		Checkbox:SetPoint("TOP",-120, -20)
		Checkbox:SetScript("OnClick", function () 
			if Checkbox:GetChecked() == nil then 
				Cia_Settings["Kick - Silenced"] = nil
			elseif Checkbox:GetChecked() == 1 then 
				Cia_Settings["Kick - Silenced"] = 1 
				Cia_Settings["Kick"] = nil
				KickCheck:SetChecked(0)
			end
		end)
		
		local Checkbox = Cia:CreateCheckbox("Kidney Shot",self.Class,"")
		Checkbox:SetPoint("TOP",-40, -20)

		local Checkbox = Cia:CreateCheckbox("Cheap Shot",self.Class,"")
		Checkbox:SetPoint("TOP",40, -20)

		local Checkbox = Cia:CreateCheckbox("Gouge",self.Class,"")
		Checkbox:SetPoint("TOP",120, -20)

		local Checkbox = Cia:CreateCheckbox("Sap",self.Class,"")
		Checkbox:SetPoint("TOP",-90, -80)

		local Checkbox = Cia:CreateCheckbox("Blind",self.Class,"")
		Checkbox:SetPoint("TOP",0, -80)

		local Checkbox = Cia:CreateCheckbox("Expose Armor",self.Class,"")
		Checkbox:SetPoint("TOP",90, -80)

		local Checkbox = Cia:CreateCheckbox("Disarm Trap",self.Class,"Traps - Supression Room")
		Checkbox:SetPoint("TOP",-60, -150)

		local Checkbox = Cia:CreateCheckbox("Mace Stun Effect",self.Class,"Mace Stun")
		Checkbox:SetPoint("TOP",60, -150)

	elseif UnitClass("player") == "Mage" then
		self.Class:SetHeight(70)

		local Checkbox = Cia:CreateCheckbox("Counterspell",self.Class,"")
		Checkbox:SetPoint("TOP",40, -20)
		Checkbox:SetScript("OnClick", function () 
			if Checkbox:GetChecked() == nil then 
				Cia_Settings["Counterspell"] = nil
			elseif Checkbox:GetChecked() == 1 then 
				Cia_Settings["Counterspell"] = 1 
				Cia_Settings["Counterspell - Silenced"] = nil
				CounterspellSilencedCheck:SetChecked(0)
			end
		end)

		local Checkbox = Cia:CreateCheckbox("Counterspell - Silenced",self.Class,"Silence")
		Checkbox:SetPoint("TOP",40, -20)
		Checkbox:SetScript("OnClick", function () 
			if Checkbox:GetChecked() == nil then 
				Cia_Settings["Counterspell - Silenced"] = nil
			elseif Checkbox:GetChecked() == 1 then 
				Cia_Settings["Counterspell - Silenced"] = 1 
				Cia_Settings["Counterspell"] = nil
				CounterspellCheck:SetChecked(0)
			end
		end)

		local Checkbox = Cia:CreateCheckbox("Impact",self.Class,"")
		Checkbox:SetPoint("TOP",-40, -20)


	elseif UnitClass("player") == "Warrior" then
		self.Class:SetHeight(140)

		local Checkbox = Cia:CreateCheckbox("Pummel",self.Class,"")
		Checkbox:SetPoint("TOP",-120, -20)

		local Checkbox = Cia:CreateCheckbox("Shield Bash",self.Class,"")
		Checkbox:SetPoint("TOP",-40, -20)
		Checkbox:SetScript("OnClick", function () 
			if Checkbox:GetChecked() == nil then 
				Cia_Settings["Shield Bash"] = nil
			elseif Checkbox:GetChecked() == 1 then 
				Cia_Settings["Shield Bash"] = 1 
				Cia_Settings["Shield Bash - Silenced"] = nil
				ShieldBashSilencedCheck:SetChecked(0)
			end
		end)

		local Checkbox = Cia:CreateCheckbox("Shield Bash - Silenced",self.Class,"Silence")
		Checkbox:SetPoint("TOP",-40, -20)
		Checkbox:SetScript("OnClick", function () 
			if Checkbox:GetChecked() == nil then 
				Cia_Settings["Shield Bash - Silenced"] = nil
			elseif Checkbox:GetChecked() == 1 then 
				Cia_Settings["Shield Bash - Silenced"] = 1 
				Cia_Settings["Shield Bash"] = nil
				ShieldBashCheck:SetChecked(0)
			end
		end)

		local Checkbox = Cia:CreateCheckbox("Intercept",self.Class,"")
		Checkbox:SetPoint("TOP",40, -20)

		local Checkbox = Cia:CreateCheckbox("Charge",self.Class,"")
		Checkbox:SetPoint("TOP",120, -20)

		local Checkbox = Cia:CreateCheckbox("Concussion Blow",self.Class,"")
		Checkbox:SetPoint("TOP",-90, -80)

		local Checkbox = Cia:CreateCheckbox("Revenge Stun",self.Class,"Revenge")
		Checkbox:SetPoint("TOP",0, -80)

		local Checkbox = Cia:CreateCheckbox("Mace Stun Effect",self.Class,"Mace Stun")
		Checkbox:SetPoint("TOP",90, -80)

	elseif UnitClass("player") == "Priest" then
		self.Class:SetHeight(70)

		local Checkbox = Cia:CreateCheckbox("Silence",self.Class,"")
		Checkbox:SetPoint("TOP",-40, -20)

		local Checkbox = Cia:CreateCheckbox("Blackout",self.Class,"")
		Checkbox:SetPoint("TOP",40, -20)

	elseif UnitClass("player") == "Druid" then
		self.Class:SetHeight(70)

		local Checkbox = Cia:CreateCheckbox("Starfire Stun",self.Class,"Starfire")
		Checkbox:SetPoint("TOP",-120, -20)

		local Checkbox = Cia:CreateCheckbox("Feral Charge",self.Class,"")
		Checkbox:SetPoint("TOP",-40, -20)

		local Checkbox = Cia:CreateCheckbox("Bash",self.Class,"")
		Checkbox:SetPoint("TOP",40, -20)

		local Checkbox = Cia:CreateCheckbox("Pounce",self.Class,"")
		Checkbox:SetPoint("TOP",120, -20)

	elseif UnitClass("player") == "Paladin" then
		self.Class:SetHeight(70)

		local Checkbox = Cia:CreateCheckbox("Hammer of Justice",self.Class,"")
		Checkbox:SetPoint("TOP",0, -20)

	elseif UnitClass("player") == "Shaman" then
		self.Class:SetHeight(70)

		local Checkbox = Cia:CreateCheckbox("Earth Shock",self.Class,"")
		Checkbox:SetPoint("TOP",0, -20)

	elseif UnitClass("player") == "Hunter" then
		self.Class:SetHeight(70)

		local Checkbox = Cia:CreateCheckbox("Concussive Shot",self.Class,"")
		Checkbox:SetPoint("TOP",-65, -20)

		local Checkbox = Cia:CreateCheckbox("Scatter Shot",self.Class,"")
		Checkbox:SetPoint("TOP",65, -20)
	
	elseif UnitClass("player") == "Warlock" then
		self.Class:SetHeight(70)

		local Checkbox = Cia:CreateCheckbox("Pyroclasm",self.Class,"")
		Checkbox:SetPoint("TOP",-40, -20)

		local Checkbox = Cia:CreateCheckbox("Spell Lock",self.Class,"")
		Checkbox:SetPoint("TOP",40, -20)
	end

	if UnitRace("player") == "Tauren" then
		self.Tauren:Show()

		local Checkbox = Cia:CreateCheckbox("War Stomp",self.Tauren,"")
		Checkbox:SetPoint("TOP",0, -20)
	end
		

	self.ChannelDropdown = CreateFrame("Button", "Channel Dropdown",self, "UIDropDownMenuTemplate")
	self.ChannelDropdown:SetPoint("TOP", 25 , -385)

	local text = self.ChannelDropdown:CreateFontString(nil, "OVERLAY")
	text:SetPoint("TOP", 63, 12)
	text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	text:SetTextColor(1, 1, 1, 1)
	text:SetShadowOffset(2,-2)
	text:SetText("Announce in Channel:")

	UIDropDownMenu_Initialize(self.ChannelDropdown, Cia.Options.ChannelDrop)
	UIDropDownMenu_SetSelectedID(self.ChannelDropdown, Cia_Settings["channel"])

	-- ButtonsEditBox
	self.CustomChannelEditBox = CreateFrame("EditBox",CustomChannelEditBox,self.Class,"InputBoxTemplate")
	self.CustomChannelEditBox:SetFontObject("GameFontHighlight")
	self.CustomChannelEditBox:SetFrameStrata("MEDIUM")
	self.CustomChannelEditBox:SetPoint("TOP", 90 , -260)
	self.CustomChannelEditBox:SetWidth(120)
	self.CustomChannelEditBox:SetHeight(30)
	self.CustomChannelEditBox:SetAutoFocus(false)
	self.CustomChannelEditBox:ClearFocus()
	self.CustomChannelEditBox:SetScript("OnEnterPressed", function()
		if self.CustomChannelEditBox:GetText() ~= "" then
			New_Custom_Channel = Cia.Options.CustomChannelEditBox:GetText()
			Cia_ChangeChannel()
		else
			print("|cffff0000You need to enter a channel name...|r")
		end
		self.CustomChannelEditBox:ClearFocus()
	end)
	self.CustomChannelEditBox:SetScript("OnChar", function()
		local n = self.CustomChannelEditBox:GetText()
		if n then 
			local name = string.upper(string.sub(n,1,1))..string.lower(string.sub(n,2))
			self.CustomChannelEditBox:SetText(name)
		end
	end)
	self.CustomChannelEditBox:Hide()

	-- minimap option
	self.CheckboxMinimap = CreateFrame("CheckButton", "Minimap", self, "UICheckButtonTemplate")
	self.CheckboxMinimap:SetPoint("TOP",-145,-385)
	self.CheckboxMinimap:SetWidth(35)
	self.CheckboxMinimap:SetHeight(35)
	self.CheckboxMinimap:SetFrameStrata("MEDIUM")
	self.CheckboxMinimap:SetScript("OnClick", function () 
		if self.CheckboxMinimap:GetChecked() == nil then 
			Cia_Settings["Minimap"] = nil
		elseif self.CheckboxMinimap:GetChecked() == 1 then 
			Cia_Settings["Minimap"] = 1 
		end
		end)
		self.CheckboxMinimap:SetScript("OnEnter", function() 
			GameTooltip:SetOwner(self.CheckboxMinimap, "ANCHOR_RIGHT");
			GameTooltip:SetText("Turn on/off", 255, 255, 0, 1, 1);
			GameTooltip:Show()
		end)
	self.CheckboxMinimap:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.CheckboxMinimap:SetChecked(Cia_Settings["Minimap"])
	self.textMinimap = self.CheckboxMinimap:CreateFontString(nil, "OVERLAY")
    self.textMinimap:SetPoint("LEFT", 45, 0)
    self.textMinimap:SetFont("Fonts\\FRIZQT__.TTF", 12)
	self.textMinimap:SetTextColor(255,255,0, 1)
	self.textMinimap:SetShadowOffset(2,-2)
    self.textMinimap:SetText("Show minimap icon")

	-- WeaponsFrame
	
	self.Weapons = CreateFrame("Frame",nil,self.Background.Tab2)
	self.Weapons:SetFrameStrata("MEDIUM")
	self.Weapons:SetWidth(300)
	self.Weapons:SetHeight(140)
	self.Weapons:SetPoint('TOP', 0, -20)
	self.Weapons:SetBackdrop(backdrop)
	self.Weapons:SetBackdropColor(0,0,0,1)

	local Weaponstext = self.Weapons:CreateFontString(nil, "OVERLAY")
	Weaponstext:SetPoint("TOP",0,20)
	Weaponstext:SetFont("Fonts\\FRIZQT__.TTF", 15)
	Weaponstext:SetTextColor(255, 255, 0, 1)
	Weaponstext:SetShadowOffset(2,-2)
	Weaponstext:SetText("Announce Weapon Proccs:")

	local Checkbox = Cia:CreateCheckbox("Armor Shatter",self.Weapons,"|cff0070ddAnnihilator")
		Checkbox:SetPoint("TOP",-65, -20)
		Checkbox:SetScript("OnClick", function ()
			if Checkbox:GetChecked() == nil then 
				Cia_Settings["Armor Shatter"] = nil
				Cia_Settings["Armor Shatter (2)"] = nil
				Cia_Settings["Armor Shatter (3)"] = nil
			elseif Checkbox:GetChecked() == 1 then 
				Cia_Settings["Armor Shatter"] = 1
				Cia_Settings["Armor Shatter (2)"] = 1
				Cia_Settings["Armor Shatter (3)"] = 1
			end
		end)
		
		local Checkbox = Cia:CreateCheckbox("Spell Vulnerability",self.Weapons,"|cffa335eeNightfall")
		Checkbox:SetPoint("TOP",65, -20)

		local Checkbox = Cia:CreateCheckbox("Glimpse of Madness",self.Weapons,"|cffa335eeDark Edge of Insanity")
		Checkbox:SetPoint("TOP",-65, -80)

		local Checkbox = Cia:CreateCheckbox("Earthshaker",self.Weapons,"|cffa335eeEarthshaker")
		Checkbox:SetPoint("TOP",65, -80)

	-- button close
	self.CloseButton = CreateFrame("Button",CloseButton,self,"UIPanelCloseButton")
	self.CloseButton:SetPoint("TOPRIGHT",4,4)
	self.CloseButton:SetFrameStrata("LOW")
	self.CloseButton:SetWidth(32)
	self.CloseButton:SetHeight(32)
	self.CloseButton:SetText("")
	self.CloseButton:SetScript("OnLoad", function() PlaySound("igMainMenuOptionCheckBoxOn"); Cia.Options:Hide() end)
	self:Hide()
end

function Cia_ChangeChannel()
	-- Check the old channel is really gone
	if (GetChannelName(Cia_Settings["customchannel"]) > 0) then
		-- It still exists, try to leave it, and re-try this method.
		LeaveChannelByName(Cia_Settings["customchannel"]);
		CiaOnUpdateActivate("channelchange")
	else
		-- The channel is gone, begin joining a new one
			-- Set and join the channel
			JoinChannelByName(New_Custom_Channel);
			ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, New_Custom_Channel);
	
		-- Check the channel exists now
		if (GetChannelName(New_Custom_Channel) > 0) then
			-- Finalise the Change
			Cia_Settings["customchannel"] = New_Custom_Channel;
			channelid = GetChannelName(Cia_Settings["customchannel"])
			-- Announce the action
			print("Custom Channel set to: "..Cia_Settings["customchannel"]);
		else
			-- It doesn't exist yet, re-try
			CiaOnUpdateActivate("channelchange")
		end
	end
end

function Cia.Minimap:CreateMinimapIcon()
	local Moving = false
	
	function self:OnMouseUp()
		Moving = false;
	end
	
	function self:OnMouseDown()
		PlaySound("igMainMenuOptionCheckBoxOn")
		Moving = false;
		if (arg1 == "LeftButton") then 
			if Cia.Options:IsVisible() then 
				Cia.Options:Hide()
			else
				Cia.Options:Show() 
			end
		else Moving = true;
		end
	end
	
	function self:OnUpdate()
		if Moving == true then
			local xpos,ypos = GetCursorPosition();
			local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();
			xpos = xmin-xpos/UIParent:GetScale()+70;
			ypos = ypos/UIParent:GetScale()-ymin-70;
			local CiaIconPos = math.deg(math.atan2(ypos,xpos));
			if (CiaIconPos < 0) then
				CiaIconPos = CiaIconPos + 360
			end
			Cia_Settings["MinimapX"] = 54 - (78 * cos(CiaIconPos));
			Cia_Settings["MinimapY"] = (78 * sin(CiaIconPos)) - 55;
			
			Cia.Minimap:SetPoint(
			"TOPLEFT",
			"Minimap",
			"TOPLEFT",
			Cia_Settings["MinimapX"],
			Cia_Settings["MinimapY"]);
		end
	end
	
	function self:OnEnter()
		GameTooltip:SetOwner(Cia.Minimap, "ANCHOR_LEFT");
		GameTooltip:SetText(Cia_GetClassColorForName(UnitClass("player")).."Class |cffffffffInterrupt |cffff0000Announce|r v. "..Cia_Version_Msg);
		GameTooltip:AddDoubleLine("Toggle Cia Options", "Left-Click", 1,1,1,1,1,1);
		GameTooltip:AddDoubleLine("Drag", "Right-Click", 1,1,1,1,1,1);
		GameTooltip:Show()
	end
	
	function self:OnLeave()
		GameTooltip:Hide()
	end

	self:SetFrameStrata("LOW")
	self:SetWidth(31)
	self:SetHeight(31)
	self:SetPoint("CENTER", -75, -20)
	
	self.Button = CreateFrame("Button",nil,self)
	--self.Button:SetFrameStrata('HIGH')	
	self.Button:SetPoint("CENTER",0,0)
	self.Button:SetWidth(31)
	self.Button:SetHeight(31)
	self.Button:SetFrameLevel(8)
	self.Button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	self.Button:SetScript("OnMouseUp", self.OnMouseUp)
	self.Button:SetScript("OnMouseDown", self.OnMouseDown)
	self.Button:SetScript("OnUpdate", self.OnUpdate)
	self.Button:SetScript("OnEnter", self.OnEnter)
	self.Button:SetScript("OnLeave", self.OnLeave)
	
	local overlay = self:CreateTexture(nil, 'OVERLAY',self)
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint('TOPLEFT',0,0)
	
	local r, l, t, b = Cia:ClassPos(UnitClass("player"))
	local icon = self:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetTexture("Interface\\AddOns\\ClassInterruptAnnounce\\Images\\UI-CLASSES-CIRCLES")
	icon:SetTexCoord(r, l, t, b)
	icon:SetPoint('CENTER', 1, 0)
	self.icon = icon
	
	if Cia_Settings["MinimapX"] and Cia_Settings["MinimapY"] then
        Cia.Minimap:SetPoint(
            "TOPLEFT",
            "Minimap",
            "TOPLEFT",
            Cia_Settings["MinimapX"],
            Cia_Settings["MinimapY"]);
	end
	--self:Hide()
end

function Cia.Options:ChannelDrop()
	local info={}
	local i=1
	for k,v in pairs(Cia_Channels) do
		info.text=v
		info.value=i
		info.func= function () UIDropDownMenu_SetSelectedID(Cia.Options.ChannelDropdown, this:GetID())
			Cia_Settings["channel"] = this:GetID()
			local colorchannel = Cia_Channels[Cia_Settings["channel"]]
			local selectedchannel = string.gsub(colorchannel,"|cff(.)(.)(.)(.)(.)(.)", "")

			if selectedchannel == "CUSTOM" then
				Cia.Options.CustomChannelEditBox:Show()
				local n = Cia_Settings["customchannel"]
				if n then
					local name = string.upper(string.sub(n,1,1))..string.lower(string.sub(n,2))
					Cia.Options.CustomChannelEditBox:SetText(name)
					print("Custom Channel set to: "..name)
				end
				--Cia.Options.CustomChannelEditBox:SetText(Cia_Settings["customchannel"])
				channelid = GetChannelName(Cia_Settings["customchannel"])
				channeldrop = this:GetID()
			else
				Cia.Options.CustomChannelEditBox:Hide()
				channel = selectedchannel
				channeldrop = this:GetID()
			end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
		i=i+1
	end
end

function CiaDefault()
	if Cia_Settings["channel"] == nil then
		Cia_Settings["channel"] = 1
		UIDropDownMenu_SetSelectedID(Cia.Options.ChannelDropdown, Cia_Settings["channel"])
		local colorchannel = Cia_Channels[Cia_Settings["channel"]]
		channel = string.gsub(colorchannel,"|cff(.)(.)(.)(.)(.)(.)", "")
	else
		local colorchannel = Cia_Channels[Cia_Settings["channel"]]
		channel = string.gsub(colorchannel,"|cff(.)(.)(.)(.)(.)(.)", "")
	end

	if (not Cia_Settings["customchannel"]) then
		Cia_Settings["customchannel"] = "Cia"; -- The default used (private chan, guild, say, party etc)
	end

	if  Cia_Settings["channel"] == 5 then
		Cia.Options.CustomChannelEditBox:Show()
		local n = Cia_Settings["customchannel"]
		if n then
			local name = string.upper(string.sub(n,1,1))..string.lower(string.sub(n,2))
			Cia.Options.CustomChannelEditBox:SetText(name)
		end
	end

	channeldrop = UIDropDownMenu_GetSelectedID(Cia.Options.ChannelDropdown)
	channelid = GetChannelName(Cia_Settings["customchannel"])

	if UnitClass("player") == "Mage" then
		_,_,_,_,TalentsIn=GetTalentInfo(1,11)
		if TalentsIn>0 then
			Cia_Settings["Counterspell"] = 0
			CounterspellCheck:SetChecked(0)
			CounterspellCheck:Hide()
		else
			Cia_Settings["Counterspell - Silenced"] = 0
			CounterspellSilencedCheck:SetChecked(0)
			CounterspellSilencedCheck:Hide()
		end
	end

	if UnitClass("player") == "Rogue" then
		_,_,_,_,TalentsIn=GetTalentInfo(2,10)
		if TalentsIn>0 then
			Cia_Settings["Kick"] = 0
			KickCheck:SetChecked(0)
			KickSilencedCheck:Show()
			KickCheck:Hide()
		else
			Cia_Settings["Kick - Silenced"] = 0
			KickSilencedCheck:SetChecked(0)
			KickSilencedCheck:Hide()
			KickCheck:Show()
		end
	end

	if UnitClass("player") == "Warrior" then
		_,_,_,_,TalentsIn=GetTalentInfo(3,15)
		if TalentsIn>0 then
			Cia_Settings["Shield Bash"] = 0
			ShieldBashCheck:SetChecked(0)
			ShieldBashSilencedCheck:Show()
			ShieldBashCheck:Hide()
		else
			Cia_Settings["Shield Bash - Silenced"] = 0
			ShieldBashSilencedCheck:SetChecked(0)
			ShieldBashSilencedCheck:Hide()
			ShieldBashCheck:Show()
		end
	end
end

function Cia:ClassPos(class)
	if(class=="Warrior") then return 0, 0.25, 0, 0.25;	end
	if(class=="Mage")    then return 0.25, 0.5, 0,	0.25;	end
	if(class=="Rogue")   then return 0.5,  0.75,    0,	0.25;	end
	if(class=="Druid")   then return 0.75, 1,       0,	0.25;	end
	if(class=="Hunter")  then return 0,    0.25,    0.25,	0.5;	end
	if(class=="Shaman")  then return 0.25, 0.5,     0.25,	0.5;	end
	if(class=="Priest")  then return 0.5,  0.75,    0.25,	0.5;	end
	if(class=="Warlock") then return 0.75, 1,       0.25,	0.5;	end
	if(class=="Paladin") then return 0,    0.25,    0.5,	0.75;	end
	return 0.25, 0.5, 0.5, 0.75	-- Returns empty next one, so blank
end

function Cia_GetClassColors(name)
	if UnitClass("player") == "Warrior" then
		return "|cffC79C6E"..name.."|r"
	elseif UnitClass("player") == "Hunter" then
		return "|cffABD473"..name.."|r"
	elseif UnitClass("player") == "Mage" then
		return "|cff69CCF0"..name.."|r"
	elseif UnitClass("player") == "Rogue" then
		return "|cffFFF569"..name.."|r"
	elseif UnitClass("player") == "Warlock" then
		return "|cff9482C9"..name.."|r"
	elseif UnitClass("player") == "Druid" then
		return "|cffFF7D0A"..name.."|r"
	elseif UnitClass("player") == "Shaman" then
		return "|cff0070DE"..name.."|r"
	elseif UnitClass("player") == "Priest" then
		return "|cffFFFFFF"..name.."|r"
	elseif UnitClass("player") == "Paladin" then
		return "|cffF58CBA"..name.."|r"
	end
end

function Cia_GetClassColorForName(class)
	if class == "Warrior" then return "|cffC79C6E"
	elseif class == "Hunter" then return "|cffABD473"
	elseif class == "Mage" then return "|cff69CCF0"
	elseif class == "Rogue" then return "|cffFFF569"
	elseif class == "Warlock" then return "|cff9482C9"
	elseif class == "Druid" then return "|cffFF7D0A"
	elseif class == "Shaman" then return "|cff0070DE"
	elseif class == "Priest" then return "|cffFFFFFF"
	elseif class == "Paladin" then return "|cffF58CBA"
	end
end

function Cia:Update(force)
    if Cia_Settings["Minimap"] == nil then
        Cia.Minimap:Hide()
    elseif Cia_Settings["Minimap"] == 1 then
        Cia.Minimap:Show()
	end

	if UnitClass("player") == "Mage" then
		if Cia_Settings["Counterspell - Silenced"] == 1 then
			Cia_Settings["Counterspell"] = nil
			CounterspellCheck:SetChecked(0)
		end
		if Cia_Settings["Counterspell"] == 1 then
			Cia_Settings["Counterspell - Silenced"] = nil
			CounterspellSilencedCheck:SetChecked(0)
		end
	end

	if UnitClass("player") == "Rogue" then
		if Cia_Settings["Kick - Silenced"] == 1 then
			Cia_Settings["Kick"] = nil
			KickCheck:SetChecked(0)
		end
		if Cia_Settings["Kick"] == 1 then
			Cia_Settings["Kick - Silenced"] = nil
			KickSilencedCheck:SetChecked(0)
		end
	end

	if UnitClass("player") == "Warrior" then
		if Cia_Settings["Shield Bash - Silenced"] == 1 then
			Cia_Settings["Shield Bash"] = nil
			ShieldBashCheck:SetChecked(0)
		end
		if Cia_Settings["Shield Bash"] == 1 then
			Cia_Settings["Shield Bash - Silenced"] = nil
			ShieldBashSilencedCheck:SetChecked(0)
		end
	end
end

Cia:SetScript("OnUpdate", Cia.Update)

-- slash commands
function Cia.slash()
	if Cia.Options:IsVisible() then
		Cia.Options:Hide()
	else
		Cia.Options:Show()
	end
end

SlashCmdList["CIA_SLASH"] = Cia.slash
SLASH_CIA_SLASH1 = "/cia"
SLASH_CIA_SLASH2 = "/CIA"
