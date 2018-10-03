Scriptname _KPW_PlayerRefScript extends ReferenceAlias  

_KPW_QuestScript Property KPWQuest  Auto
_KPW_Utilities Property KPWUtils  Auto


bool externalSleepStop
bool ambushedSleepStop


event OnInit()
	Maintenance()
endEvent

event OnPlayerLoadGame()
	KPWQuest.Update()
	KPWUtils.Update()
	Maintenance()
endEvent
 
event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)

	externalSleepStop = false
	ambushedSleepStop = false
	float realtimeStart = Utility.GetCurrentRealTime()
	float sleepStart = afSleepStartTime * 24
	float sleepEnd = afDesiredSleepEndTime * 24
	float sleepMaxDuration = sleepEnd - sleepStart
	int iMax = Round(sleepMaxDuration)
	KPWQuest.DebugStuff("Player went to sleep for " + iMax + " at: " + Utility.GameTimeToString(afSleepStartTime) + " (" + sleepStart + ", realtime " + realtimeStart + "), to wake up at: " + Utility.GameTimeToString(afDesiredSleepEndTime) + " (" + sleepEnd + ")")
	if (iMax <= 1)
		KPWQuest.DebugStuff("sleepMaxDuration <= 1 - let them sleep..")
		return
	endIf

	bool[] ps = KPWUtils.GetPlayerSituation()
	int[] modifiers = KPWUtils.GetSituationModifiers(ps[0], ps[1], ps[2], ps[3], ps[4], ps[5], ps[6], ps[7], ps[8], ps[9], ps[10], ps[11], ps[12], ps[13], ps[14], ps[15], ps[16], ps[17], ps[18])
	
	Actor[] watchers = KPWUtils.GetWatchRota()

	int[] attackChances
	float gameTime
	float timeOfDay
	int detectionBonus
	Actor currentWatcher = None
	bool[] ws
	int watcherBonus
	bool anyAttacks = false
	int i = 1
	while (!externalSleepStop && !anyAttacks && i < iMax)
		if (currentWatcher != watchers[i])
			currentWatcher = watchers[i]
			KPWQuest.DebugStuff("Now " + currentWatcher.GetLeveledActorBase().GetName() + "'s watch is begun")
			ws = KPWUtils.GetWatcherSituation(currentWatcher)
		endIf
		
		attackChances = KPWUtils.CreateAttackChances(modifiers)
		gameTime = Utility.GetCurrentGameTime()
		timeOfDay = (gameTime - (gameTime as int)) * 24
		detectionBonus = KPWUtils.ApplyTimebasedModifiers(attackChances, (timeOfDay > 9.0 && timeOfDay < 18.5), ps[19], ps[20], ps[21])
		detectionBonus += KPWUtils.ApplyActorWatchModifiers(attackChances, (timeOfDay > 9.0 && timeOfDay < 18.5), ws[0], ws[2], ws[4], (ws[1] || ws[3] || ws[5]), ws[6])
		
		anyAttacks = i > 4 && KPWUtils.AnyAttacks(attackChances)
		if (anyAttacks)
			KPWQuest.DebugStuff("Attacked during hour " + i + " (" + timeOfDay + ") - " + currentWatcher.GetLeveledActorBase().GetName() + " on watch, detection bonus " + detectionBonus)
		else
			KPWQuest.DebugStuff("Nothing happened during hour " + i + " (" + timeOfDay + ") - " + currentWatcher.GetLeveledActorBase().GetName() + " on watch")
		endIf
		i += 1
	endWhile
	
	if (externalSleepStop || !anyAttacks || !attackChances)
		KPWQuest.DebugStuff("Nothing happened (or player woke themselves), waking as normal..")
		return
	endIf

	i -= 1

	if (externalSleepStop)
		KPWQuest.DebugStuff("Awoken externally")
		return
	endIf
	
	ambushedSleepStop = true
	float gameTimeNow = gameTime * 24
	float gameHoursElapsed = gameTimeNow - sleepStart
	KPWQuest.DebugStuff("gameTimeNow: " + gameTimeNow + ", gameHoursElapsed: " + gameHoursElapsed + ", i: " + i)
	if (gameHoursElapsed >= i - 1)
		KPWQuest.DebugStuff("Placing enemies now!")
	else
		float realtimeNowTrig = Utility.GetCurrentRealTime()
		float ambushDelayTrig = realtimeStart + (i + 1) - realtimeNowTrig
		KPWQuest.DebugStuff("Placing enemies in " + ambushDelayTrig + "s.. (" + realtimeStart + " + " + (i + 1) + " - " + realtimeNowTrig + ")")
		Utility.WaitMenuMode(ambushDelayTrig)
	endIf
	
	; cue up enemies
	KPWUtils.PlaceEnemyGroups(attackChances, detectionBonus)

	gameTimeNow = gameTime * 24
	gameHoursElapsed = gameTimeNow - sleepStart
	KPWQuest.DebugStuff("gameTimeNow: " + gameTimeNow + ", gameHoursElapsed: " + gameHoursElapsed + ", i: " + i)
	if (gameHoursElapsed >= i)
		KPWQuest.DebugStuff("Triggering wake-up now!")
	else
		float realtimeNowWake = Utility.GetCurrentRealTime()
		float ambushDelayWake = realtimeStart + (i + 1) - realtimeNowWake
		KPWQuest.DebugStuff("Triggering wake-up in " + ambushDelayWake + "s.. (" + realtimeStart + " + " + (i + 1) + " - " + realtimeNowWake + ")")
		Utility.WaitMenuMode(ambushDelayWake)
	endIf
	KPWUtils.WakePlayer()
	
	KPWQuest.DebugStuff("All done, end event")
endEvent

event OnSleepStop(bool abInterrupted)
	externalSleepStop = true
	if abInterrupted
	    KPWQuest.DebugStuff("Player woke themselves at: " + Utility.GameTimeToString(Utility.GetCurrentGameTime()))
	elseIf ambushedSleepStop
	    KPWQuest.DebugStuff("Player woken by ambush at: " + Utility.GameTimeToString(Utility.GetCurrentGameTime()))
	else
	    KPWQuest.DebugStuff("Player woke up naturally at: " + Utility.GameTimeToString(Utility.GetCurrentGameTime()))
	endIf
	KPWUtils.TidyUp()
endEvent


function Maintenance()

	RegisterForSleep()

endFunction

int function Round(float i)
	if (i - (i as int)) < 0.5
		return i as int
	else
		return Math.Ceiling(i) as int
	endIf
endFunction
