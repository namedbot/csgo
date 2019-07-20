IncludeScript("vs_library")
Chat(" FreezeTest Loaded")

function SetupPlayers()
{
	::list_players_tt <- []
	::list_players_ct <- []
	local ent
	while( ent = Entities.FindByClassname(ent,"*") ) if( ent.GetClassname() == "player" )
	{
		if( ent.GetTeam() == 2 ) list_players_tt.append(ent)
		else if( ent.GetTeam() == 3 ) list_players_ct.append(ent)
	}
	
	local set = function(p)
	{
		p.SetMaxHealth(1000)
		p.SetHealth(1000)
		p.GetScriptScope().frozen <- false
		EntFireHandle(p, "Color","255 255 255")

		Chat(p.GetScriptScope().name + " spawned.")
	}
	
	foreach( p in list_players_tt ) set(p)
	foreach( p in list_players_ct ) set(p)
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
	EntFireHandle(player, "Color","25 75 255")
	EntFireHandle(player, "SetDamageFilter", "disableBullets")
	EntFireHandle(player, "Color","25 75 255")
	
	
	if( player.GetTeam() == 2 ){foreach( i, p in list_players_tt ) if( p == player ) list_players_tt.remove(i)}
	else if( player.GetTeam() == 3 ){foreach( i, p in list_players_ct ) if( p == player ) list_players_ct.remove(i)}
	
	if( list_players_tt.len() == 0 )
	{
		Chat(" CT Win")
		EntFire("roundEnd", "EndRound_CounterTerroristsWin", "5")
	}
	
	else if( list_players_ct.len() == 0 )
	{
		Chat(" T Win")
		EntFire("roundEnd", "EndRound_TerroristsWin", "5")		
	}
	
	Chat(" " + list_players_tt.len() + " Terrorists left " + list_players_ct.len() + " Counter-Terrorists Left")
}

::FreezeTag_revivePlayer <- function( player )
{
	player.GetScriptScope().frozen = false

	local reviveFloat = 1
	player.SetHealth(1000)
	EntFire("freezeSpeedmod", "ModifySpeed", reviveFloat.tostring(), 0, player);
	EntFire("revivedWeapons", "Use","" , 0, player);
	EntFireHandle(player, "Color","255 255 255")
	EntFireHandle(player, "SetDamageFilter", "")
		
	if( player.GetTeam() == 2 ) list_players_tt.append(player)
	else if( player.GetTeam() == 3 ) list_players_ct.append(player)
}

::OnGameEvent_player_hurt <- function( data )
{
	//VS.DumpScope(data)
	local player = VS.GetHandleByUserid(data.userid)
	local name = player.GetScriptScope().name

	ScriptPrintMessageChatTeam(player.GetTeam(), " ● " + name + " has lost " + (data.dmg_health) + " health.")

    if( data.health  <= 850 && data.health  >= 750 && player.GetScriptScope().frozen == false )
    {
		::FreezeTag_freezePlayer(player)
		ScriptPrintMessageChatTeam(player.GetTeam(), " ● " + name + " has been frozen.")
    }
	else if( data.health  <= 750 && player.GetScriptScope().frozen == true )
    {
		::FreezeTag_revivePlayer(player)
		ScriptPrintMessageChatTeam(player.GetTeam(), " ● " + name + " has been revived.")
    }
}

//ScriptPrintMessageChatTeam(2, "   - light red 2 -  violet - blue - light blue	 - T color - CT color - light red - green(money awards) - light green - green - Team color - red - white - gold")
