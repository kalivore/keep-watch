Scriptname _KPW_PlayerRefScript extends ReferenceAlias  

_KPW_QuestScript Property KPWQuest  Auto

Keyword Property LocTypeClearable Auto

Keyword Property LocTypeHabitation Auto
Keyword Property LocTypeSettlement Auto
Keyword Property LocTypeDwelling Auto
Keyword Property LocTypeInn Auto
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


FormList Property _KPW_Fires Auto


Actor Property PlayerRef Auto
Static Property _KPW_XMarker Auto

ImageSpaceModifier Property Woozy Auto				; SleepyTimeFadeIn
Idle Property WakeUp Auto							; Idle_1stPersonWoozyGetUpFromBed

Form xMarkerBase
bool externalSleepStop

ObjectReference xMarkerPos

event OnInit()
	RegisterForSleep()
	Debug.Notification("Registered For Sleep")
endEvent

event OnPlayerLoadGame()
	KPWQuest.Update()
endEvent
 
Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)

	float sleepStart = afSleepStartTime * 24
	float sleepEnd = afDesiredSleepEndTime * 24
	float sleepMaxDuration = (sleepEnd - sleepStart) - 1
	KPWQuest.DebugStuff("Player went to sleep at: " + sleepStart + ", to wake up at: " + sleepEnd)
	if (sleepMaxDuration < 1.0)
		KPWQuest.DebugStuff("sleepMaxDuration < 1 - let them sleep..")
		return
	endIf

	Location loc = PlayerRef.GetCurrentLocation()

	int ambushScore = Utility.RandomInt(0, 100)
	
	; fire deters animals (snippet shamelessly nicked from Chesko!)
    ObjectReference nearbyFire = Game.FindClosestReferenceOfAnyTypeInListFromRef(_KPW_Fires, PlayerRef, 600.0)

	string ambushResult = "Final Score: " + ambushScore
	if (ambushScore < 100)
		KPWQuest.DebugStuff(ambushResult + "; Nothing happened, sleep as normal..")
		return
	endIf

	float wakeyTime = Utility.RandomFloat(0.9, sleepMaxDuration)
	KPWQuest.DebugStuff(ambushResult + "; Triggering event in " + wakeyTime + "s..")

	if (xMarkerPos)
		xMarkerPos.Enable()
		xMarkerPos.MoveTo(PlayerRef)
	else
		xMarkerPos = PlayerRef.PlaceAtMe(_KPW_XMarker) as ObjectReference
	endIf
	float zAngle = PlayerRef.GetAngleZ()
	xMarkerPos.SetAngle(xMarkerPos.GetAngleX(), xMarkerPos.GetAngleY(), zAngle)

	Utility.WaitMenuMode(wakeyTime)
	
	if (externalSleepStop)
		KPWQuest.DebugStuff("Awoken externally")
		return
	endIf
	
	PlayerRef.MoveTo(xMarkerPos)
	if (KPWQuest.AnimatedWaking)
		Game.DisablePlayerControls(ablooking = true, abCamSwitch = true)
		Game.ForceFirstPerson()
		Woozy.Apply()
		PlayerRef.PlayIdle(WakeUp)
		Utility.Wait(3)
		Game.EnablePlayerControls()
	endIf

	xMarkerPos.Disable()
	xMarkerPos.Delete()
	
	KPWQuest.DebugStuff("All done, end event")
endEvent

Event OnSleepStop(bool abInterrupted)
	externalSleepStop = true
	if abInterrupted
	    KPWQuest.DebugStuff("Player woke themselves at: " + Utility.GameTimeToString(Utility.GetCurrentGameTime()))
	else
	    KPWQuest.DebugStuff("Player woke up naturally at: " + Utility.GameTimeToString(Utility.GetCurrentGameTime()))
	endIf
endEvent
