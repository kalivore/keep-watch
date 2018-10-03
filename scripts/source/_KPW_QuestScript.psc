Scriptname _KPW_QuestScript extends Quest  

float Property CurrentVersion = 0.0100 AutoReadonly
float previousVersion

string Property ModName = "Keep Watch" AutoReadonly
string Property LogName = "KeepWatch" AutoReadonly

GlobalVariable Property _KPW_DebugToFile Auto
bool priDebugToFile
bool Property DebugToFile
	bool function get()
		return true;priDebugToFile
	endFunction
	function set(bool val)
		_KPW_DebugToFile.SetValue(val as int)
		priDebugToFile = val
	endFunction
endProperty

GlobalVariable Property _KPW_AnimatedWaking Auto
bool priAnimatedWaking
bool Property AnimatedWaking
	bool function get()
		return priAnimatedWaking
	endFunction
	function set(bool val)
		_KPW_AnimatedWaking.SetValue(val as int)
		priAnimatedWaking = val
	endFunction
endProperty


FormList Property _KPW_Fires_All Auto
FormList Property _KPW_Fires_Small Auto
FormList Property _KPW_Fires_Medium Auto
FormList Property _KPW_Fires_Large Auto


event OnInit()

	Update()

endEvent

function Update()

	; floating-point math is hard..  let's go shopping!
	int iPreviousVersion = (PreviousVersion * 10000) as int
	int iCurrentVersion = (CurrentVersion * 10000) as int

	if (iCurrentVersion != iPreviousVersion)

		;;;;;;;;;;;;;;;;;;;;;;;;;;
		; version-specific updates
		;;;;;;;;;;;;;;;;;;;;;;;;;;

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; end version-specific updates
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		; notify current version
		string msg = ModName
		if (PreviousVersion > 0)
			msg += " updated from v" + GetVersionAsString(PreviousVersion) + " to "
		else
			msg += " running "
		endIf
		msg += "v" + GetVersionAsString(CurrentVersion)
		DebugStuff(msg, msg, true)

		PreviousVersion = CurrentVersion
	endIf

	Maintenance()

endFunction

Function Maintenance()

	Debug.OpenUserLog(LogName)

	DebugToFile = _KPW_DebugToFile.GetValue() as bool

endFunction




function AddCampfireFires()
	Form _Camp_Campfire_Light_2 = Game.GetFormFromFile(0x00025BBA, "Campfire.esm") ; Small
	Form _Camp_ObjectRubbleFire = Game.GetFormFromFile(0x0002D04D, "Campfire.esm") ; Medium
	Form _Camp_Campfire_Light_3 = Game.GetFormFromFile(0x00025BBB, "Campfire.esm") ; Medium
	Form _Camp_Campfire_Light_4 = Game.GetFormFromFile(0x00025BBC, "Campfire.esm") ; Medium
	Form _Camp_Campfire_Light_5 = Game.GetFormFromFile(0x00025BBD, "Campfire.esm") ; Large

	_KPW_Fires_All.AddForm(_Camp_Campfire_Light_2)
	_KPW_Fires_Small.AddForm(_Camp_Campfire_Light_2)

	_KPW_Fires_All.AddForm(_Camp_ObjectRubbleFire)
	_KPW_Fires_Medium.AddForm(_Camp_ObjectRubbleFire)
	_KPW_Fires_All.AddForm(_Camp_Campfire_Light_3)
	_KPW_Fires_Medium.AddForm(_Camp_Campfire_Light_3)
	_KPW_Fires_All.AddForm(_Camp_Campfire_Light_4)
	_KPW_Fires_Medium.AddForm(_Camp_Campfire_Light_4)

	_KPW_Fires_All.AddForm(_Camp_Campfire_Light_5)
	_KPW_Fires_Small.AddForm(_Camp_Campfire_Light_5)
endFunction

string function GetVersionAsString(float afVersion)

	string raw = afVersion as string
	int dotPos = StringUtil.Find(raw, ".")
	string major = StringUtil.SubString(raw, 0, dotPos)
	string minor = StringUtil.SubString(raw, dotPos + 1, 2)
	string revsn = StringUtil.SubString(raw, dotPos + 3, 2)
	return major + "." + minor + "." + revsn

endFunction

function DebugStuff(string asLogMsg, string asScreenMsg = "", bool abPrefix = false)

	if (DebugToFile)
		Debug.TraceUser(LogName, asLogMsg)
	endIf
	if (asScreenMsg != "")
		if (abPrefix)
			asScreenMsg = ModName + " - " + asScreenMsg
		endIf
		Debug.Notification(asScreenMsg)
	endIf

endFunction
