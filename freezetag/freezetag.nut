IncludeScript("vs_library")
Chat(" FreezeTest Loaded")

function spawnScript()
{
	activator.SetMaxHealth(1000)
	activator.SetHealth(1000)
	activator.GetScriptScope().frozen <- false
	Chat(" " + activator.GetScriptScope().name + " spawned.")
}

function buddhaTest()
{
	DoEntFire("ccmd", "Command", "buddha", 0.00, activator, null)
}

::FreezeTag_freezePlayer <- function( player )
{
	player.GetScriptScope().frozen = true

	local freezeFloat = 0
	EntFire("freezeSpeedmod", "ModifySpeed", freezeFloat.tostring(), 0, player);
	EntFire("stripWeapons", "Use","" , 0, player);
	EntFireByHandle(player, "Color","25 75 255" , 0, player, player);

	//To-do Add damage filter.
}

::FreezeTag_revivePlayer <- function( player )
{
	player.GetScriptScope().frozen = false

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

	ScriptPrintMessageChatTeam(2, " ● " + name + " has lost " + (data.dmg_health) + " health.")

    if( data.health  <= 850 && data.health  >= 750 && player.GetScriptScope().frozen == false )
    {
		::FreezeTag_freezePlayer(player)
		ScriptPrintMessageChatTeam(2, " ● " + name + " has been frozen.")
    }
	else if( data.health  <= 750 && player.GetScriptScope().frozen == true )
    {
		::FreezeTag_revivePlayer(player)
		ScriptPrintMessageChatTeam(2, " ● " + name + " has been revived.")
    }
}

//ScriptPrintMessageChatTeam(2, "   - light red 2 -  violet - blue - light blue	 - T color - CT color - light red - green(money awards) - light green - green - Team color - red - white - gold")
