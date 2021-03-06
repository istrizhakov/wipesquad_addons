
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Shazzrah", "Molten Core")

module.revision = 20004 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
module.toggleoptions = {"curse", "deaden", "blink", "counterspell", "bosskill"}

-- Proximity Plugin
-- module.proximityCheck = function(unit) return CheckInteractDistance(unit, 2) end
-- module.proximitySilent = false

---------------------------------
--      Module specific Locals --
---------------------------------

local timer = {
	cs = 16,
	firstCS = 15,
	curse =  20,
	firstCurse = 10,
	blink = 25,
	firstBlink = 25,
	earliestDeaden = 7,
	latestDeaden = 14,
	firstDeaden = 5,
}
local icon = {
	cs = "Spell_Frost_IceShock",
	curse = "Spell_Shadow_AntiShadow",
	blink = "Spell_Arcane_Blink",
	deaden = "Spell_Holy_SealOfSalvation",
}
local syncName = {
	cs = "ShazzrahCounterspell"..module.revision,
	curse = "ShazzrahCurse"..module.revision,
	blink = "ShazzrahBlink"..module.revision,
	deaden = "ShazzrahDeadenMagicOn"..module.revision,
	deadenOver = "ShazzrahDeadenMagicOff"..module.revision,
}

local _, playerClass = UnitClass("player")
local firstblink = true

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	blink_trigger = "casts Gate of Shazzrah",
	deaden_trigger = "Shazzrah gains Deaden Magic",
	curse_trigger = "afflicted by Shazzrah",
	cs_trigger2 = "Shazzrah casts Counterspell",
	cs_trigger = "Shazzrah(.+) Counterspell was resisted by",
	curse_trigger2 = "Shazzrah(.+) Curse was resisted",
	deaden_over_trigger = "Deaden Magic fades from Shazzrah",

	blink_warn = "Blink - 45 seconds until next one!",
	blink_soon_warn = "3 seconds to Blink!",
	deaden_warn = "Deaden Magic is up! Dispel it!",
	curse_warn = "Shazzrah's Curse! Decurse NOW!",
	cs_now_warn = "Counterspell! ~18 seconds until next one!",
	cs_soon_warn = "3 seconds until Counterspell!",

	blink_bar = "Possible Blink",
	deaden_bar = "Deaden Magic",
	curse_bar = "Shazzrah's Curse",
	cs_bar = "Possible Counterspell",

	cmd = "Shazzrah",


	-- counterspell after blink 2s later
	counterspell_cmd = "counterspell",
	counterspell_name = "Counterspell alert",
	counterspell_desc = "Warn for Shazzrah's Counterspell",

	curse_cmd = "curse",
	curse_name = "Shazzrah's Curse alert",
	curse_desc = "Warn for Shazzrah's Curse",

	deaden_cmd = "deaden",
	deaden_name = "Deaden Magic alert",
	deaden_desc = "Warn when Shazzrah has Deaden Magic",

	blink_cmd = "blink",
	blink_name = "Blink alert",
	blink_desc = "Warn when Shazzrah Blinks",
} end)

L:RegisterTranslations("esES", function() return {
	blink_trigger = "lanza Portal de Shazzrah",
	deaden_trigger = "Shazzrah gana Aligerar magia",
	curse_trigger = "sufre de Shazzrah",
	cs_trigger2 = "Shazzrah lanza Contrahechizo",
	cs_trigger = "Resistido Contrahechizo de Shazzrah",
	curse_trigger2 = "Resistido Maldici??n de Shazzrah",
	deaden_over_trigger = "Aligerar magia desaparece de Shazzrah",

	blink_warn = "??Traslaci??n - 45 segundos hasta el pr??ximo!",
	blink_soon_warn = "??3 segundos hasta Traslaci??n!",
	deaden_warn = "??Aligerar magia est?? activo! Dis??palo!",
	curse_warn = "??Maldici??n de Shazzrah! D??shazla AHORA!",
	cs_now_warn = "??Contrahechizo! ~18 segundos hasta el pr??ximo!",
	cs_soon_warn = "??3 segundos hasta Contrahechizo!",

	blink_bar = "Traslaci??n Posible",
	deaden_bar = "Aligerar magia",
	curse_bar = "Maldici??n de Shazzrah",
	cs_bar = "Contrahechizo Posible",

	--cmd = "Shazzrah",


	-- counterspell after blink 2s later
	--counterspell_cmd = "counterspell",
	counterspell_name = "Alerta de Contrahechizo",
	counterspell_desc = "Avisa para Contrahechizo de Shazzrah",

	--curse_cmd = "curse",
	curse_name = "Alerta de Maldici??n de Shazzrah",
	curse_desc = "Avisa para Maldici??n de Shazzrah",

	--deaden_cmd = "deaden",
	deaden_name = "Alerta de Aligerar magia",
	deaden_desc = "Avisa cuando Shazzrah tenga Aligerar magia",

	--blink_cmd = "blink",
	blink_name = "Alerta de Traslaci??n",
	blink_desc = "Avisa cuando Shazzrah lance Traslaci??n",
} end)

L:RegisterTranslations("deDE", function() return {
	blink_trigger = "Shazzrah wirkt Portal von Shazzrah",
	deaden_trigger = "Shazzrah bekommt \'Magie d??mpfen",
	curse_trigger = "von Shazzrahs Fluch betroffen",
	cs_trigger2 = "Shazzrah wirkt Gegenzauber",
	cs_trigger = "Shazzrahs Gegenzauber wurde von (.+) widerstanden",
	curse_trigger2 = "Shazzrahs Fluch(.)widerstanden",
	deaden_over_trigger = "Magie d??mpfen schwindet von Shazzrah",

	blink_warn = "Blinzeln! N??chstes in ~45 Sekunden!",
	blink_soon_warn = "Blinzeln in ~5 Sekunden!",
	deaden_warn = "Magie d??mpfen auf Shazzrah! Entferne magie!",
	curse_warn = "Shazzrahs Fluch! Entfluche JETZT!",
	cs_now_warn = "Gegenzauber - 40 Sekunden bis zum n??chsten!",
	cs_soon_warn = "3 Sekunden bis Gegenzauber!",

	blink_bar = "M??gliches Blinzeln",
	deaden_bar = "Magie d??mpfen",
	curse_bar = "N??chster Fluch",
	cs_bar = "M??glicher Gegenzauber",

	--cmd = "Shazzrah",

	--counterspell_cmd = "Gegenzauber",
	counterspell_name = "Alarm f??r Gegenzauber",
	counterspell_desc = "Warnen vor Shazzrahs Gegenzauber",

	--curse_cmd = "curse",
	curse_name = "Alarm f??r Shazzrahs Fluch",
	curse_desc = "Warnen vor Shazzrahs Fluch",

	--deaden_cmd = "deaden",
	deaden_name = "Alarm f??r Magie d??mpfen",
	deaden_desc = "Warnen wenn Shazzrah Magie d??mpfen hat",

	--blink_cmd = "blink",
	blink_name = "Alarm f??r Blinzeln",
	blink_desc = "Warnen wenn Shazzrah blinzelt",
} end)


------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS", "Event")

	self:ThrottleSync(10, syncName.blink)
	self:ThrottleSync(10, syncName.curse)
	self:ThrottleSync(5, syncName.deaden)
	self:ThrottleSync(5, syncName.deadenOver)
	self:ThrottleSync(0.5, syncName.cs)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	firstblink = true
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.counterspell then
		self:Bar(L["cs_bar"], timer.firstCS, icon.cs)
	end
	self:DelayedSync(timer.firstCS, syncName.cs)

	if self.db.profile.blink then
		self:Bar(L["blink_bar"], timer.firstBlink, icon.blink)
	end
	self:DelayedSync(timer.firstBlink, syncName.blink)

	if self.db.profile.curse then
		self:Bar(L["curse_bar"], timer.firstCurse, icon.curse) -- seems to be completly random
	end
	if self.db.profile.deaden then
		self:Bar(L["deaden_bar"], timer.firstDeaden, icon.deaden)
	end
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end

------------------------------
--      Event Handlers      --
------------------------------

function module:Event(msg)
	if (string.find(msg, L["deaden_trigger"])) then
		self:Sync(syncName.deaden)
	elseif (string.find(msg, L["deaden_over_trigger"])) then
		self:Sync(syncName.deadenOver)
	elseif (string.find(msg, L["blink_trigger"])) then
		self:Sync(syncName.blink)
	elseif (string.find(msg, L["cs_trigger2"]) or string.find(msg, L["cs_trigger"])) then
		self:Sync(syncName.cs)
	elseif (string.find(msg, L["curse_trigger"]) or string.find(msg, L["curse_trigger2"])) then
		self:Sync(syncName.curse)
	end
end

------------------------------
--      Synchronization	    --
------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.blink then
		self:Blink()
	elseif sync == syncName.deaden  then
		self:DeadenMagic()
	elseif sync == syncName.deadenOver then
		self:DeadenMagicOver()
	elseif sync == syncName.curse then
		self:Curse()
	elseif sync == syncName.cs then
		self:Counterspell()
	end
end

------------------------------
--      Sync Handlers	    --
------------------------------

function module:Counterspell()
	if self.db.profile.counterspell then
		self:Bar(L["cs_bar"], timer.cs, icon.cs)
	end
	self:DelayedSync(timer.cs, syncName.cs)
end

function module:Curse()
	self:Message(L["curse_warn"], "Attention", "Alarm")
	self:Bar(L["curse_bar"], timer.curse, icon.curse) -- seems to be completly random
end

function module:Blink()
	firstblink = false
	--self:KTM_Reset()

	if self.db.profile.blink then
		self:Message(L["blink_warn"], "Important")
		self:Bar(L["blink_bar"], timer.blink, icon.blink)

		self:DelayedMessage(timer.blink - 5, L["blink_soon_warn"], "Attention", "Alarm", nil, nil, true)
	end

	self:DelayedSync(timer.blink, syncName.blink)
end

function module:DeadenMagic()
	if self.db.profile.deaden then
		self:RemoveBar(L["deaden_bar"])
		self:Message(L["deaden_warn"], "Important")
		self:IntervalBar(L["deaden_bar"], timer.earliestDeaden, timer.latestDeaden, icon.deaden)
		if playerClass == "SHAMAN" or playerClass == "PRIEST" then
			self:WarningSign(icon.deaden, timer.earliestDeaden)
		end
	end
end

function module:DeadenMagicOver()
	if self.db.profile.deaden then
		if playerClass == "SHAMAN" or playerClass == "PRIEST" then
			self:RemoveWarningSign(icon.deaden)
		end
	end
end
