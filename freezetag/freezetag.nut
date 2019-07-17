IncludeScript("vs_library")
IncludeScript("vs_library-events")
SendToConsole("say FreezeTest Loaded")


function spawnScript()
{
	activator.SetMaxHealth(1000)
	activator.SetHealth(1000)
	//activator.GetScriptScope().frozen <- false
	SendToConsole("say Spawned.")
	printl(activator)
	printl(activator.GetScriptScope())
}


function buddhaTest()
{
	DoEntFire("ccmd", "Command", "buddha", 0.00, activator, null)
}


::FreezeTag_freezePlayer <- function( player )
{
  local freezeFloat = 0
	EntFire("freezeSpeedmod", "ModifySpeed", freezeFloat.tostring(), 0, player);
	EntFire("stripWeapons", "Use","" , 0, player);
	EntFireByHandle(player, "Color","25 75 255" , 0, player, player);
	//To-do Add damage filter.
}


::FreezeTag_revivePlayer <- function( player )
{
	local reviveFloat = 1
	player.SetHealth(1000)
	EntFire("freezeSpeedmod", "ModifySpeed", reviveFloat.tostring(), 0, player);
	EntFire("revivedWeapons", "Use","" , 0, player);
	EntFireByHandle(player, "Color","255 255 255" , 0, player, player);
	//To-do Remove damage filter.
}


::OnGameEvent_player_hurt <- function( data )
{

	//VS.DumpScope(data)
	local player = VS.GetHandleByUserid(data.userid)
	local name = player.GetScriptScope().name
	//local validScope = player.ValidateScriptScope()
	
	
	ScriptPrintMessageChatTeam(2, " ● " + name + " has lost " + (data.dmg_health) + " health.")
	
    if( data.health  <= 850 && data.health  >= 750 && player.GetScriptScope().frozen == false)
    {
		::FreezeTag_freezePlayer(player)
		ScriptPrintMessageChatTeam(2, " ● " + name + " has been frozen.")
		player.GetScriptScope().frozen <- true
    }
	
	
	 if(data.health  <= 750 && player.GetScriptScope().frozen == true)
    {
		::FreezeTag_revivePlayer(VS.GetHandleByUserid( data.userid ))
		ScriptPrintMessageChatTeam(2, " ● " + name + " has been revived.")
		player.GetScriptScope().frozen <- false
    }
}



//ScriptPrintMessageChatTeam(2, "   - light red 2 -  violet - blue - light blue	 - T color - CT color - light red - green(money awards) - light green - green - Team color - red - white - gold")
