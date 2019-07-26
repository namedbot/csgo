IncludeScript("vs_library")
Chat(" FreezeTest Loaded")

function SetupPlayers( ent )
{
	if( ent.GetClassname() != "player" ) return

	ent.ValidateScriptScope()
	local scope = ent.GetScriptScope()

	// if the player is not set up
	if( !("frozen" in scope) )
	{
		// adds userid/networkid/name
		VS.ValidateUserid( ent )

		// your custom slots
		scope.frozen <- false

		ent.SetMaxHealth(1000)
		ent.SetHealth(1000)
		EntFire("revivedWeapons", "Use","" , 0, ent);
		EntFireHandle(ent, "Color","255 255 255")
		EntFireHandle(ent, "SetDamageFilter", "")
		delay( "printl(\" \" + VS.Entity.FindByString(\""+ent+"\").GetScriptScope().name + \" spawned.\")", 0.1 )
		if( ent.GetTeam() == 2 ) list_players_tt.append(ent)
		else if( ent.GetTeam() == 3 ) list_players_ct.append(ent)
	}
	
}

::FreezeTag_freezePlayer <- function( player )
{
	player.GetScriptScope().frozen = true

	local freezeFloat = 0
	EntFire("freezeSpeedmod", "ModifySpeed", freezeFloat.tostring(), 0, player)
	EntFire("stripWeapons", "Use","" , 0, player);
	EntFireHandle(player, "Color","25 75 255")
	EntFireHandle(player, "SetDamageFilter", "disableBullets")
	EntFireHandle(player, "Color","25 75 255")
	
	
	if( player.GetTeam() == 2 )
	{foreach( i, p in list_players_tt ) if( p == player ) list_players_tt.remove(i)}
	else if( player.GetTeam() == 3 ){foreach( i, p in list_players_ct ) if( p == player ) list_players_ct.remove(i)}
	
	if( list_players_tt.len() == 0 )
	{
		Chat(" Counter-Terrorist Win")
		EntFire("roundEnd", "EndRound_CounterTerroristsWin", "5")
		Chat(" " + list_players_tt.len() + " 	Terrorists left " + list_players_ct.len() + " Counter-Terrorists Left")
	}
	
	else if( list_players_ct.len() == 0 )
	{
		Chat(" Terrorist Win")
		EntFire("roundEnd", "EndRound_TerroristsWin", "5")	
		Chat(" " + list_players_tt.len() + " 	Terrorists left " + list_players_ct.len() + " Counter-Terrorists Left")		
	}

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
	local attacker = VS.GetHandleByUserid(data.attacker)
	
	// same team
	if( attacker && player.GetTeam() == attacker.GetTeam() )
	{
		local hp = data.health + data.dmg_health
	
		if( data.weapon == "knife" )
		{
			if( player.GetScriptScope().frozen && data.health <= 950)
			{
				hp += 2 * data.dmg_health
			}
			else if( player.GetScriptScope().frozen )
			{
				FreezeTag_revivePlayer(player)
			}
			
		}

		if(hp>1000)hp=1000
		{
		player.SetHealth(hp)
		}
	}
	
	// opposite team
	else
	{	
		ScriptPrintMessageChatTeam(player.GetTeam(), " ● " + name + " has lost " + (data.dmg_health) + " health.")

		if( data.health  <= 850 && player.GetScriptScope().frozen == false )
		{
			player.SetHealth(750)
			::FreezeTag_freezePlayer(player)
			ScriptPrintMessageChatTeam(player.GetTeam(), " ● " + name + " has been frozen by " + attacker.GetScriptScope().name + ".")
			EntFire( "addKill", "ApplyScore", "", 0, attacker )
		}
	}
}

::OnGameEvent_round_start <- function(data)
{
	::list_players_tt <- []
	::list_players_ct <- []
	local ent
	while( ent = Entities.FindByClassname(ent,"*") ) if( ent.GetClassname() == "player" ) try(delete ent.GetScriptScope().frozen)catch(e){}
    DoEntFire("scmd", "Command", "mp_autokick 0; mp_disable_autokick 1; mp_spawnprotectiontime -1; mp_td_dmgtokick 99999999; mp_td_dmgtowarn 99999999; mp_td_spawndmgthreshold 99999999; ff_damage_reduction_other 0.5;sv_kick_ban_duration 0  " , 0.00, activator, null)

}

::OnGameEvent_item_pickup <- function(data)
{
	return
	local player = VS.GetHandleByUserid(data.userid)
	
	if(player.GetScriptScope().frozen == true)
	{
		EntFire("stripWeapons", "Use","" , 0, player)
	}
}

//ScriptPrintMessageChatTeam(2, "   - light red 2 -  violet - blue - light blue	 - T color - CT color - light red - green(money awards) - light green - green - Team color - red - white - gold")
