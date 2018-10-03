Scriptname _KPW_Utilities extends Quest  

_KPW_QuestScript Property KPWQuest Auto
Quest Property KPWFollowerTracker Auto


int Property ATTACKER_SKEEVER		= 00 Autoreadonly
int Property ATTACKER_MUDCRAB		= 01 Autoreadonly
int Property ATTACKER_WOLF			= 02 Autoreadonly
int Property ATTACKER_BEAR			= 03 Autoreadonly
int Property ATTACKER_SABRECAT		= 04 Autoreadonly
int Property ATTACKER_SPIDER_SMALL	= 05 Autoreadonly
int Property ATTACKER_SPIDER_LARGE	= 06 Autoreadonly
int Property ATTACKER_GHOST			= 07 Autoreadonly
int Property ATTACKER_DRAUGR		= 08 Autoreadonly
int Property ATTACKER_FALMER		= 09 Autoreadonly
int Property ATTACKER_SPRIGGAN		= 10 Autoreadonly
int Property ATTACKER_HAGRAVEN		= 11 Autoreadonly
int Property ATTACKER_BANDIT		= 12 Autoreadonly
int Property ATTACKER_FORSWORN		= 13 Autoreadonly
int Property ATTACKER_VAMPIRE		= 14 Autoreadonly
int Property ATTACKER_WARLOCK		= 15 Autoreadonly
int Property ATTACKER_WEREWOLF		= 16 Autoreadonly


int Property AttackThreshold = 75 Autoreadonly


int Property OrcDeterBonus = 15 Autoreadonly
int Property VampDeterBonus = 10 Autoreadonly
int Property WereDeterBonus = 15 Autoreadonly

int Property KhajiitDetectBonus = 200 Autoreadonly
int Property ArgonianDetectBonus = 100 Autoreadonly
int Property VampDetectBonus = 150 Autoreadonly
int Property WereDetectBonus = 100 Autoreadonly
int Property DarkDetectPenalty = 500 Autoreadonly
int Property FireSmallDetectBonus = 100 Autoreadonly
int Property FireMediumDetectBonus = 200 Autoreadonly
int Property FireLargeDetectBonus = 300 Autoreadonly


Location Property ReachHoldLocation Auto

Keyword Property LocTypeClearable Auto

Keyword Property LocTypeHabitation Auto
Keyword Property LocTypeSettlement Auto
Keyword Property LocTypeInn Auto
Keyword Property LocTypeDwelling Auto
Keyword Property LocTypeHouse Auto
Keyword Property LocTypePlayerHouse Auto

Keyword Property LocTypeDungeon Auto
Keyword Property LocTypeDraugrCrypt Auto
Keyword Property LocTypeFalmerHive Auto

Keyword Property LocTypeAnimalDen Auto
Keyword Property LocTypeSprigganGrove Auto

Keyword Property LocTypeMine Auto
Keyword Property LocTypeCastle Auto
Keyword Property LocTypeBanditCamp Auto
Keyword Property LocTypeShipwreck Auto
Keyword Property LocTypeForswornCamp Auto

Keyword Property LocTypeHagravenNest Auto
Keyword Property LocTypeVampireLair Auto
Keyword Property LocTypeWarlockLair Auto
Keyword Property LocTypeWerewolfLair Auto


Race Property KhajiitRace Auto
Race Property KhajiitRaceVampire Auto
Race Property ArgonianRace Auto
Race Property ArgonianRaceVampire Auto
Race Property OrcRace Auto

Keyword Property Vampire Auto
Faction Property CompanionsCircle Auto

ReferenceAlias[] Property FollowerSlots Auto

ActorBase[] Property Ambushers Auto

Actor Property PlayerRef Auto
Static Property _KPW_XMarker Auto

ImageSpaceModifier Property Woozy Auto				; SleepyTimeFadeIn
Idle Property WakeUp Auto							; Idle_1stPersonWoozyGetUpFromBed


int[] attackerCountMin
int[] attackerCountMax

ObjectReference xMarkerPlayer
ObjectReference[] xMarkerEnemy


Actor[] function GetWatchRota()

	KPWFollowerTracker.Start()

	KPWQuest.DebugStuff("Find followers....")
	Actor[] watchers = new Actor[13]
	watchers[0] = PlayerRef
	int i = 0
	int fCount = 1
	while (i < 12)
		Actor f = FollowerSlots[i].GetReference() as Actor
		if (f)
			watchers[fCount] = f
			fCount += 1
		endIf
		i += 1
	endWhile
	if (fCount > 1)
		KPWQuest.DebugStuff("found " + (fCount - 1))
	else
		KPWQuest.DebugStuff("nothing :(")
	endIf
	
	Actor[] watchRota = new Actor[24]
	int h = 0
	int p = 0
	while (h < 24)
		watchRota[h] = watchers[p]
		h += 1
		if (h % 4 == 0 && p < (fCount - 1))
			p += 1
		endIf
	endWhile

	return watchRota
endFunction

bool[] function GetPlayerSituation()
	Location loc = PlayerRef.GetCurrentLocation()
	bool[] situations = new bool[22]
	situations[0] = PlayerRef.IsInInterior()
	situations[1] = loc && (ReachHoldLocation == loc || ReachHoldLocation.IsChild(loc))
	situations[2] = loc && (loc.HasKeyword(LocTypePlayerHouse) || loc.HasKeyword(LocTypeHouse) || loc.HasKeyword(LocTypeDwelling) \
								|| loc.HasKeyword(LocTypeInn) || loc.HasKeyword(LocTypeSettlement) || loc.HasKeyword(LocTypeHabitation))
	situations[3] = loc && loc.HasKeyword(LocTypeDungeon)
	situations[4] = loc && loc.HasKeyword(LocTypeDraugrCrypt)
	situations[5] = loc && loc.HasKeyword(LocTypeFalmerHive)
	situations[6] = loc && loc.HasKeyword(LocTypeAnimalDen)
	situations[7] = loc && loc.HasKeyword(LocTypeSprigganGrove)
	situations[8] = loc && loc.HasKeyword(LocTypeMine)
	situations[9] = loc && loc.HasKeyword(LocTypeCastle)
	situations[10] = loc && loc.HasKeyword(LocTypeBanditCamp)
	situations[11] = loc && loc.HasKeyword(LocTypeShipwreck)
	situations[12] = loc && loc.HasKeyword(LocTypeForswornCamp)
	situations[13] = loc && loc.HasKeyword(LocTypeHagravenNest)
	situations[14] = loc && loc.HasKeyword(LocTypeVampireLair)
	situations[15] = loc && loc.HasKeyword(LocTypeWarlockLair)
	situations[16] = loc && loc.HasKeyword(LocTypeWerewolfLair)
	situations[17] = loc && loc.HasKeyword(LocTypeClearable)
	situations[18] = loc && loc.IsCleared()
	
	; fire deters animals (snippet shamelessly nicked from Chesko!)
	; for now, assume they burn permanently (TODO - work out burn time)
    ObjectReference nearbySmallFire = Game.FindClosestReferenceOfAnyTypeInListFromRef(KPWQuest._KPW_Fires_Small, PlayerRef, 600.0)
    ObjectReference nearbyMediumFire = Game.FindClosestReferenceOfAnyTypeInListFromRef(KPWQuest._KPW_Fires_Medium, PlayerRef, 600.0)
    ObjectReference nearbyLargeFire = Game.FindClosestReferenceOfAnyTypeInListFromRef(KPWQuest._KPW_Fires_Large, PlayerRef, 600.0)
	
	situations[19] = nearbySmallFire != None
	situations[20] = nearbyMediumFire != None
	situations[21] = nearbyLargeFire != None
	
	return situations
endFunction

bool[] function GetWatcherSituation(Actor akActor)
	bool[] situations = new bool[7]

	Race actorRace = akActor.GetRace()
	situations[0] = actorRace == KhajiitRace
	situations[1] = actorRace == KhajiitRaceVampire
	situations[2] = actorRace == ArgonianRace
	situations[3] = actorRace == ArgonianRaceVampire
	situations[4] = actorRace == OrcRace
	situations[5] = actorRace.HasKeyword(Vampire) || akActor.HasKeyword(Vampire)
	situations[6] = akActor.IsInFaction(CompanionsCircle)
	
	return situations
endFunction

int[] function GetSituationModifiers(bool inInterior, bool inReach, bool inSettlement, bool inDungeon, bool inDraugrCrypt, bool inFalmerHive, \
									bool inAnimalDen, bool inSprigganGrove, bool inMine, bool inCastle, bool inBanditCamp, bool inShipwreck, \
									bool inForswornCamp, bool inHagravenNest, bool inVampireLair, bool inWarlockLair, bool inWerewolfLair, \
									bool isClearable, bool isCleared)

	int[] sitMods = new int[17]
	string msg = "GetSituationModifiers"

	if (inReach)
		msg += ": inReach"
		sitMods[ATTACKER_FORSWORN] = sitMods[ATTACKER_FORSWORN] + 10
	endIf
	if (inDungeon)
		msg += ": inDungeon"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_GHOST] = sitMods[ATTACKER_GHOST] + 10
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 10
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] + 10
			sitMods[ATTACKER_SPIDER_LARGE] = sitMods[ATTACKER_SPIDER_LARGE] + 5
			if (!inDraugrCrypt) ; if not explicitly a Draugr one, add a small chance here
				sitMods[ATTACKER_DRAUGR] = sitMods[ATTACKER_DRAUGR] + 10
			endIf
		endIf
	endIf
	if (inDraugrCrypt)
		msg += ": inDraugrCrypt"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_DRAUGR] = sitMods[ATTACKER_DRAUGR] + 10
			if (!inDungeon)
				sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 5
				sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] + 5
			endIf
		endIf
	endIf
	if (inFalmerHive)
		msg += ": inFalmerHive"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] - 10
			sitMods[ATTACKER_SPIDER_LARGE] = sitMods[ATTACKER_SPIDER_LARGE] - 10
			sitMods[ATTACKER_GHOST] = -150
			sitMods[ATTACKER_DRAUGR] = -150
			sitMods[ATTACKER_FALMER] = sitMods[ATTACKER_FALMER] + 10
			sitMods[ATTACKER_HAGRAVEN] = -150
			sitMods[ATTACKER_BANDIT] = -150
			sitMods[ATTACKER_FORSWORN] = -150
			sitMods[ATTACKER_VAMPIRE] = -150
			sitMods[ATTACKER_WARLOCK] = -150
			sitMods[ATTACKER_WEREWOLF] = -150
		endIf
	endIf
	if (inAnimalDen)
		msg += ": inAnimalDen"
		if (inInterior)
			msg += " (int)"
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] - 5
			sitMods[ATTACKER_MUDCRAB] = sitMods[ATTACKER_MUDCRAB] - 20
			sitMods[ATTACKER_WOLF] = sitMods[ATTACKER_WOLF] + 10
			sitMods[ATTACKER_BEAR] = sitMods[ATTACKER_BEAR] + 10
			sitMods[ATTACKER_SABRECAT] = sitMods[ATTACKER_SABRECAT] + 10
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] - 10
		endIf
		sitMods[ATTACKER_SPIDER_LARGE] = sitMods[ATTACKER_SPIDER_LARGE] - 10
		sitMods[ATTACKER_GHOST] = -150
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = sitMods[ATTACKER_HAGRAVEN] - 5
		sitMods[ATTACKER_SPRIGGAN] = sitMods[ATTACKER_SPRIGGAN] - 10
		sitMods[ATTACKER_BANDIT] = sitMods[ATTACKER_BANDIT] - 15
		sitMods[ATTACKER_FORSWORN] = sitMods[ATTACKER_FORSWORN] - 15
		sitMods[ATTACKER_VAMPIRE] = sitMods[ATTACKER_VAMPIRE] - 10
		sitMods[ATTACKER_WARLOCK] = sitMods[ATTACKER_WARLOCK] - 20
		sitMods[ATTACKER_WEREWOLF] = sitMods[ATTACKER_WEREWOLF] - 20
	endIf
	if (inSprigganGrove)
		msg += ": inSprigganGrove"
		sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] - 20
		sitMods[ATTACKER_MUDCRAB] = sitMods[ATTACKER_MUDCRAB] - 20
		sitMods[ATTACKER_WOLF] = sitMods[ATTACKER_WOLF] + 5
		sitMods[ATTACKER_BEAR] = sitMods[ATTACKER_BEAR] + 5
		sitMods[ATTACKER_SABRECAT] = sitMods[ATTACKER_SABRECAT] + 5
		sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] - 20
		sitMods[ATTACKER_SPIDER_LARGE] = sitMods[ATTACKER_SPIDER_LARGE] - 20
		sitMods[ATTACKER_GHOST] = -150
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = sitMods[ATTACKER_HAGRAVEN] + 5
		sitMods[ATTACKER_SPRIGGAN] = sitMods[ATTACKER_SPRIGGAN] + 10
		sitMods[ATTACKER_BANDIT] = -150
		sitMods[ATTACKER_FORSWORN] = -150
		sitMods[ATTACKER_VAMPIRE] = -150
		sitMods[ATTACKER_WARLOCK] = -150
		sitMods[ATTACKER_WEREWOLF] = -150
	endIf
	if (inHagravenNest)
		msg += ": inHagravenNest"
		SetZeroWildlifeChance(sitMods)
		sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] - 20
		sitMods[ATTACKER_SPIDER_SMALL] = -150
		sitMods[ATTACKER_SPIDER_LARGE] = -150
		sitMods[ATTACKER_GHOST] = -150
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = sitMods[ATTACKER_HAGRAVEN] + 10
		sitMods[ATTACKER_BANDIT] = -150
		sitMods[ATTACKER_FORSWORN] = -150
		sitMods[ATTACKER_VAMPIRE] = -150
		sitMods[ATTACKER_WARLOCK] = -150
		sitMods[ATTACKER_WEREWOLF] = -150
	endIf
	if (inMine)
		msg += ": inMine"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_GHOST] = sitMods[ATTACKER_GHOST] + 5
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 10
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] + 10
			sitMods[ATTACKER_DRAUGR] = -150
			sitMods[ATTACKER_FALMER] = -150
			sitMods[ATTACKER_HAGRAVEN] = -150
			sitMods[ATTACKER_WEREWOLF] = -150
		endIf
	endIf
	if (inCastle)
		msg += ": inCastle"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 5
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] + 5
			sitMods[ATTACKER_SPIDER_LARGE] = -150
			sitMods[ATTACKER_GHOST] = sitMods[ATTACKER_GHOST] + 5
			sitMods[ATTACKER_DRAUGR] = -150
			sitMods[ATTACKER_FALMER] = -150
			sitMods[ATTACKER_HAGRAVEN] = -150
			sitMods[ATTACKER_WEREWOLF] = -150
		endIf
	endIf
	if (inBanditCamp)
		msg += ": inBanditCamp"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 5
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] + 5
		endIf
		sitMods[ATTACKER_SPIDER_LARGE] = -150
		sitMods[ATTACKER_GHOST] = sitMods[ATTACKER_GHOST] + 5
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = -150
		sitMods[ATTACKER_BANDIT] = sitMods[ATTACKER_BANDIT] + 10
		sitMods[ATTACKER_FORSWORN] = sitMods[ATTACKER_FORSWORN] - 10
	endIf
	if (inForswornCamp)
		msg += ": inForswornCamp"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 5
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] + 5
		endIf
		sitMods[ATTACKER_SPIDER_LARGE] = -150
		sitMods[ATTACKER_GHOST] = -150
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = -150
		sitMods[ATTACKER_BANDIT] = sitMods[ATTACKER_BANDIT] - 10
		sitMods[ATTACKER_FORSWORN] = sitMods[ATTACKER_FORSWORN] + 10
	endIf
	if (inShipwreck)
		msg += ": inShipwreck"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 10
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] - 10
		endIf
		sitMods[ATTACKER_SPIDER_LARGE] = -150
		sitMods[ATTACKER_GHOST] = sitMods[ATTACKER_GHOST] + 5
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = -150
		sitMods[ATTACKER_BANDIT] = sitMods[ATTACKER_BANDIT] + 10
		sitMods[ATTACKER_FORSWORN] = sitMods[ATTACKER_FORSWORN] - 10
		sitMods[ATTACKER_VAMPIRE] = sitMods[ATTACKER_VAMPIRE] - 10
		sitMods[ATTACKER_WARLOCK] = sitMods[ATTACKER_WARLOCK] - 10
		sitMods[ATTACKER_WEREWOLF] = sitMods[ATTACKER_WEREWOLF] - 10
	endIf
	if (inVampireLair)
		msg += ": inVampireLair"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 5
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] + 5
		endIf
		sitMods[ATTACKER_SPIDER_LARGE] = -150
		sitMods[ATTACKER_GHOST] = -150
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = -150
		sitMods[ATTACKER_BANDIT] = sitMods[ATTACKER_BANDIT] - 20
		sitMods[ATTACKER_FORSWORN] = sitMods[ATTACKER_FORSWORN] - 20
		sitMods[ATTACKER_VAMPIRE] = sitMods[ATTACKER_VAMPIRE] + 10
		sitMods[ATTACKER_WARLOCK] = sitMods[ATTACKER_WARLOCK] - 10
		sitMods[ATTACKER_WEREWOLF] = sitMods[ATTACKER_WEREWOLF] - 20
	endIf
	if (inWarlockLair)
		msg += ": inWarlockLair"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 5
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] - 5
		endIf
		sitMods[ATTACKER_SPIDER_LARGE] = -150
		sitMods[ATTACKER_GHOST] = -150
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = -150
		sitMods[ATTACKER_BANDIT] = sitMods[ATTACKER_BANDIT] - 20
		sitMods[ATTACKER_FORSWORN] = sitMods[ATTACKER_FORSWORN] - 20
		sitMods[ATTACKER_VAMPIRE] = sitMods[ATTACKER_VAMPIRE] - 10
		sitMods[ATTACKER_WARLOCK] = sitMods[ATTACKER_WARLOCK] + 10
		sitMods[ATTACKER_WEREWOLF] = sitMods[ATTACKER_WEREWOLF] - 20
	endIf
	if (inWerewolfLair)
		msg += ": inWerewolfLair"
		if (inInterior)
			msg += " (int)"
			SetZeroWildlifeChance(sitMods)
			sitMods[ATTACKER_WOLF] = Utility.RandomInt(0, 100) + 20
			sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] + 5
			sitMods[ATTACKER_SPIDER_SMALL] = sitMods[ATTACKER_SPIDER_SMALL] - 5
		endIf
		sitMods[ATTACKER_SPIDER_LARGE] = -150
		sitMods[ATTACKER_GHOST] = -150
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = -150
		sitMods[ATTACKER_BANDIT] = sitMods[ATTACKER_BANDIT] - 20
		sitMods[ATTACKER_FORSWORN] = sitMods[ATTACKER_FORSWORN] - 20
		sitMods[ATTACKER_VAMPIRE] = sitMods[ATTACKER_VAMPIRE] - 20
		sitMods[ATTACKER_WARLOCK] = sitMods[ATTACKER_WARLOCK] - 20
		sitMods[ATTACKER_WEREWOLF] = sitMods[ATTACKER_WEREWOLF] + 10
	endIf
	
	
	; apply Global modifiers
	if (isClearable)
		msg += ": clearable"
		if (isCleared)
			msg += ", cleared"
		else
			msg += ", NOT cleared"
		endIf
	endIf
	int i = sitMods.Length
	while (i)
		i -= 1
		if (isClearable)
			if (isCleared)
				sitMods[i] = sitMods[i] - 20
			elseIf (sitMods[i] != 0)
				sitMods[i] = sitMods[i] + 10
			endIf
		endIf
	endWhile
	
	; don't think Draugr and Falmer get out much..
	if (!inInterior)
		msg += ": NOT inInterior"
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
	endIf
	if (inSettlement)
		msg += ": inSettlement"
		SetZeroWildlifeChance(sitMods)
		sitMods[ATTACKER_SKEEVER] = sitMods[ATTACKER_SKEEVER] - 20
		sitMods[ATTACKER_SPIDER_SMALL] = -150
		sitMods[ATTACKER_SPIDER_LARGE] = -150
		sitMods[ATTACKER_GHOST] = -150
		sitMods[ATTACKER_DRAUGR] = -150
		sitMods[ATTACKER_FALMER] = -150
		sitMods[ATTACKER_HAGRAVEN] = -150
		sitMods[ATTACKER_VAMPIRE] = sitMods[ATTACKER_VAMPIRE] - 5
		sitMods[ATTACKER_WEREWOLF] = sitMods[ATTACKER_WEREWOLF] - 20
	endIf

	KPWQuest.DebugStuff(msg)
	
	return sitMods
endFunction

int function ApplyTimebasedModifiers(int[] akAttackChances, bool abDaytime, bool nearbySmallFire, bool nearbyMediumFire, bool nearbyLargeFire)

	int detectBonus = 0
	string msg = "Time/fire modifiers"

	if (abDaytime)
		msg += ": daytime"
		; no vamps/werewolves during daytime
		akAttackChances[ATTACKER_VAMPIRE] = akAttackChances[ATTACKER_VAMPIRE] - 150
		akAttackChances[ATTACKER_WEREWOLF] = akAttackChances[ATTACKER_WEREWOLF] - 150
	else
		msg += ": nighttime"
		detectBonus -= DarkDetectPenalty
		akAttackChances[ATTACKER_SKEEVER] = akAttackChances[ATTACKER_SKEEVER] + 5
		akAttackChances[ATTACKER_WOLF] = akAttackChances[ATTACKER_WOLF] + 10
		akAttackChances[ATTACKER_BEAR] = akAttackChances[ATTACKER_BEAR] - 5
		akAttackChances[ATTACKER_SABRECAT] = akAttackChances[ATTACKER_SABRECAT] - 5
	endIf

	if (nearbySmallFire)
		msg += ": small fire"
		if (!abDaytime)
			detectBonus += FireSmallDetectBonus
		endIf
		akAttackChances[ATTACKER_SKEEVER] = akAttackChances[ATTACKER_SKEEVER] - 10
		akAttackChances[ATTACKER_MUDCRAB] = akAttackChances[ATTACKER_MUDCRAB] - 10
		akAttackChances[ATTACKER_SPIDER_SMALL] = akAttackChances[ATTACKER_SPIDER_SMALL] - 10
		akAttackChances[ATTACKER_WOLF] = akAttackChances[ATTACKER_WOLF] - 5
	endIf
	if (nearbyMediumFire)
		msg += ": medium fire"
		if (!abDaytime)
			detectBonus += FireMediumDetectBonus
		endIf
		akAttackChances[ATTACKER_SKEEVER] = akAttackChances[ATTACKER_SKEEVER] - 15
		akAttackChances[ATTACKER_MUDCRAB] = akAttackChances[ATTACKER_MUDCRAB] - 15
		akAttackChances[ATTACKER_WOLF] = akAttackChances[ATTACKER_WOLF] - 10
		akAttackChances[ATTACKER_BEAR] = akAttackChances[ATTACKER_BEAR] - 5
		akAttackChances[ATTACKER_SABRECAT] = akAttackChances[ATTACKER_SABRECAT] - 5
		akAttackChances[ATTACKER_SPIDER_LARGE] = akAttackChances[ATTACKER_SPIDER_LARGE] - 5
	endIf
	if (nearbyLargeFire)
		msg += ": large fire"
		if (!abDaytime)
			detectBonus += FireLargeDetectBonus
		endIf
		akAttackChances[ATTACKER_SKEEVER] = akAttackChances[ATTACKER_SKEEVER] - 20
		akAttackChances[ATTACKER_MUDCRAB] = akAttackChances[ATTACKER_MUDCRAB] - 20
		akAttackChances[ATTACKER_WOLF] = akAttackChances[ATTACKER_WOLF] - 15
		akAttackChances[ATTACKER_BEAR] = akAttackChances[ATTACKER_BEAR] - 10
		akAttackChances[ATTACKER_SABRECAT] = akAttackChances[ATTACKER_SABRECAT] - 10
		akAttackChances[ATTACKER_SPIDER_LARGE] = akAttackChances[ATTACKER_SPIDER_LARGE] - 10
		akAttackChances[ATTACKER_DRAUGR] = akAttackChances[ATTACKER_DRAUGR] - 5
		akAttackChances[ATTACKER_SPRIGGAN] = akAttackChances[ATTACKER_SPRIGGAN] - 5
	endIf

	KPWQuest.DebugStuff(msg)

	return detectBonus

endFunction

int function ApplyActorWatchModifiers(int[] akAttackChances, bool abDaytime, bool abIsKhajiit, bool abIsArgonian, bool abIsOrc, bool abIsVampire, bool abIsWerewolf)

	int detectBonus = 0
	
	string msg = "Actor modifiers - detection"
	
	if (!abDaytime && (abIsKhajiit || abIsVampire || abIsWerewolf))
		; cancel low light penalty
		msg += ": night vision"
		detectBonus += DarkDetectPenalty
	endIf
	
	if (abIsKhajiit)
		msg += ": Khajiit"
		detectBonus += KhajiitDetectBonus
	elseIf (abIsArgonian)
		msg += ": Argonian"
		detectBonus += ArgonianDetectBonus
	elseIf (abIsVampire)
		msg += ": vamp"
		detectBonus += VampDetectBonus
	endIf
	
	if (abIsWerewolf)
		msg += ": Werewolf"
		detectBonus += WereDetectBonus
	endIf
	
	msg += " - deterrence"
	int j = 17
	while (j)
		j -= 1
		if ((abIsOrc) && IsDeterred(0, j))
			msg += ": Orc"
			akAttackChances[j] = akAttackChances[j] - OrcDeterBonus
		endIf
		if ((abIsVampire) && IsDeterred(1, j))
			msg += ": vamp"
			akAttackChances[j] = akAttackChances[j] - VampDeterBonus
		endIf
		if ((abIsWerewolf) && IsDeterred(2, j))
			msg += ": Werewolf"
			akAttackChances[j] = akAttackChances[j] - WereDeterBonus
		endIf
	endWhile
	
	return detectBonus
endFunction

bool function IsDeterred(int aiActorDeterrer, int aiDetereeType)
	if (aiActorDeterrer == 0) ; orc
		return aiDetereeType == ATTACKER_SKEEVER || aiDetereeType == ATTACKER_MUDCRAB \
			|| aiDetereeType == ATTACKER_WOLF || aiDetereeType == ATTACKER_BEAR \
			|| aiDetereeType == ATTACKER_SABRECAT \
			|| aiDetereeType == ATTACKER_SPIDER_SMALL || aiDetereeType == ATTACKER_SPIDER_LARGE \
			|| aiDetereeType == ATTACKER_GHOST
	elseIf (aiActorDeterrer == 1) ; vamp
		return aiDetereeType == ATTACKER_SKEEVER || aiDetereeType == ATTACKER_MUDCRAB \
			|| aiDetereeType == ATTACKER_WOLF || aiDetereeType == ATTACKER_BEAR \
			|| aiDetereeType == ATTACKER_SABRECAT \
			|| aiDetereeType == ATTACKER_SPIDER_SMALL || aiDetereeType == ATTACKER_SPIDER_LARGE \
			|| aiDetereeType == ATTACKER_GHOST
	elseIf (aiActorDeterrer == 2) ; were
		return aiDetereeType == ATTACKER_SKEEVER || aiDetereeType == ATTACKER_MUDCRAB \
			|| aiDetereeType == ATTACKER_WOLF || aiDetereeType == ATTACKER_BEAR \
			|| aiDetereeType == ATTACKER_SABRECAT \
			|| aiDetereeType == ATTACKER_SPIDER_SMALL || aiDetereeType == ATTACKER_SPIDER_LARGE \
			|| aiDetereeType == ATTACKER_SPRIGGAN
	else
		return false
	endIf
endFunction

int[] function CreateAttackChances(int[] aiAttackModifiers)
	int[] attackChances = new int[17]
	int i = attackChances.Length
	while (i)
		i -= 1
		int attackChance = GetNormalisedRandomFloat(0, 100) as int
		if (aiAttackModifiers[i])
			attackChance += aiAttackModifiers[i]
		endIf
		attackChances[i] = attackChance
	endWhile
	return attackChances
endFunction

bool function AnyAttacks(int[] akAttackChances)
	bool attacked = false
	string ambushResult = "Final Scores: "
	int i = akAttackChances.length
	while (i)
		i -= 1
		ambushResult += i + ": " + akAttackChances[i]
		if (akAttackChances[i] > AttackThreshold)
			attacked = true
			ambushResult += "**"
		endIf
		ambushResult += "; "
	endWhile
	KPWQuest.DebugStuff(ambushResult)
	return attacked
endFunction

function PlaceEnemyGroups(int[] akAttackChances, int aiDetectionBonus)
	int i = akAttackChances.length
	while (i)
		i -= 1
		if (akAttackChances[i] > AttackThreshold)
			PlaceEnemyGroup(i, Ambushers[i], GetNormalisedRandomFloat(attackerCountMin[i], attackerCountMax[i]) as int, aiDetectionBonus)
		endIf
	endWhile
endFunction

function PlaceEnemyGroup(int aiAttackerType, ActorBase akEnemy, int aiNumber, int aiDetectionBonus, int aiLevelMod = 0)

	float[] offset = new float[3]
	float offsetX = Utility.RandomFloat(-1600, 1600)
	if (offsetX <= 0)
		offsetX -= aiDetectionBonus
	elseIf (offsetX > 0)
		offsetX += aiDetectionBonus
	endIf
	float offsetY = Utility.RandomFloat(-1600, 1600)
	if (offsetY <= 0)
		offsetY -= aiDetectionBonus
	elseIf (offsetY > 0)
		offsetY += aiDetectionBonus
	endIf
	offset[0] = offsetX
	offset[1] = offsetY
	offset[2] = 0

	float[] rotation = new float[3]
	rotation[0] = 0
	rotation[1] = 0
	rotation[2] = 0

	int i = aiNumber
	if (i < 1)
		i = 1
	endIf

	KPWQuest.DebugStuff("Place " + i + "x type " + aiAttackerType + " (" + akEnemy.GetName() + " - " + akEnemy + ") at (" + offsetX + ", " + offsetY + ") (detection bonus " + aiDetectionBonus + ")")
	
	int taskId = SpawnerTask.Create()
	while (i)
		i -= 1
		SpawnerTask.AddSpawn(taskId, akEnemy, playerRef, offset, rotation)
	endWhile

	ObjectReference[] spawned = SpawnerTask.Run(taskId)
	
	int a = spawned.length
	while (i)
		i -= 1
		spawned[i].Activate(playerRef, true)
		(spawned[i] as Actor).EvaluatePackage()
	endWhile
	
	KPWQuest.DebugStuff("Done placing these - next enemy")
endFunction

function WakePlayer()
	; set up markers
	if (xMarkerPlayer)
		xMarkerPlayer.Enable()
		xMarkerPlayer.MoveTo(PlayerRef)
	else
		xMarkerPlayer = PlayerRef.PlaceAtMe(_KPW_XMarker)
	endIf
	xMarkerPlayer.SetAngle(xMarkerPlayer.GetAngleX(), xMarkerPlayer.GetAngleY(), PlayerRef.GetAngleZ())

	; move player to awake
	PlayerRef.MoveTo(xMarkerPlayer)
	
	if (KPWQuest.AnimatedWaking)
		KPWQuest.DebugStuff("do animated waking")
		Game.DisablePlayerControls(ablooking = true, abCamSwitch = true)
		Game.ForceFirstPerson()
		Woozy.Apply()
		PlayerRef.PlayIdle(WakeUp)
		Utility.Wait(3)
		Game.EnablePlayerControls()
	endIf

	xMarkerPlayer.Disable()
	xMarkerPlayer.Delete()
endFunction

function SetZeroWildlifeChance(int[] akAttackChances)
	akAttackChances[ATTACKER_MUDCRAB] = 0
	akAttackChances[ATTACKER_WOLF] = 0
	akAttackChances[ATTACKER_BEAR] = 0
	akAttackChances[ATTACKER_SABRECAT] = 0
	akAttackChances[ATTACKER_SPRIGGAN] = 0
endFunction

float function GetNormalisedRandomFloat(int aiMin, int aiMax)
	return (Utility.RandomFloat(aiMin, aiMax) + Utility.RandomFloat(aiMin, aiMax) + Utility.RandomFloat(aiMin, aiMax)) / 3.0
endFunction

event OnInit()
	Update()
endEvent

function Update()
	Maintenance()
endFunction

function Maintenance()

	attackerCountMin = new int[17]
	attackerCountMax = new int[17]
	attackerCountMin[ATTACKER_SKEEVER] = 0
	attackerCountMax[ATTACKER_SKEEVER] = 7
	attackerCountMin[ATTACKER_MUDCRAB] = 0
	attackerCountMax[ATTACKER_MUDCRAB] = 7
	attackerCountMin[ATTACKER_WOLF] = 0
	attackerCountMax[ATTACKER_WOLF] = 5
	attackerCountMin[ATTACKER_BEAR] = 0
	attackerCountMax[ATTACKER_BEAR] = 2
	attackerCountMin[ATTACKER_SABRECAT] = 0
	attackerCountMax[ATTACKER_SABRECAT] = 2
	attackerCountMin[ATTACKER_SPIDER_SMALL] = 0
	attackerCountMax[ATTACKER_SPIDER_SMALL] = 4
	attackerCountMin[ATTACKER_SPIDER_LARGE] = 0
	attackerCountMax[ATTACKER_SPIDER_LARGE] = 2
	attackerCountMin[ATTACKER_GHOST] = 0
	attackerCountMax[ATTACKER_GHOST] = 3
	attackerCountMin[ATTACKER_DRAUGR] = 0
	attackerCountMax[ATTACKER_DRAUGR] = 5
	attackerCountMin[ATTACKER_FALMER] = 0
	attackerCountMax[ATTACKER_FALMER] = 5
	attackerCountMin[ATTACKER_SPRIGGAN] = 0
	attackerCountMax[ATTACKER_SPRIGGAN] = 2
	attackerCountMin[ATTACKER_HAGRAVEN] = 0
	attackerCountMax[ATTACKER_HAGRAVEN] = 2
	attackerCountMin[ATTACKER_BANDIT] = 0
	attackerCountMax[ATTACKER_BANDIT] = 5
	attackerCountMin[ATTACKER_FORSWORN] = 0
	attackerCountMax[ATTACKER_FORSWORN] = 5
	attackerCountMin[ATTACKER_VAMPIRE] = 0
	attackerCountMax[ATTACKER_VAMPIRE] = 3
	attackerCountMin[ATTACKER_WARLOCK] = 0
	attackerCountMax[ATTACKER_WARLOCK] = 4
	attackerCountMin[ATTACKER_WEREWOLF] = 0
	attackerCountMax[ATTACKER_WEREWOLF] = 2

	xMarkerEnemy = new ObjectReference[5]

endFunction

function TidyUp()
endFunction
