IncludeScript("vs_library")
Chat(" FreezeTag Loaded")
::hurt <- Entities.FindByName(null,"hurt")


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
		
		//player properties
		ent.SetMaxHealth(1000)
		ent.SetHealth(1000)
		EntFire("revivedWeapons", "Use","" , 0, ent);
		EntFireHandle(ent, "Color","255 255 255")
		EntFireHandle(ent, "SetDamageFilter", "")
		
		// your custom slots
		scope.frozen <- false
		scope.Kill <- function()
		{
			local targetname = UniqueString("player")
			VS.Entity.SetName( self, targetname )
			VS.Entity.SetKeyString( hurt, "DamageTarget", targetname )
			EntFireHandle( timer, "kill" )
			EntFire( "hurt", "hurt" )
			EntFire( "addKill", "ApplyScore", "", 0, self )
			ScriptPrintMessageChatTeam(self.GetTeam(), " A teammate froze to death.")
		}
		
		scope.game_text <- VS.Entity.CreateGameText(null, 
		{
			channel = 3,
			color = "220 90 90",
			// color2 = "240 110 0",
			// effect = 0,
			// fadein = 1.5,
			// fadeout = 0.5,
			// fxtime = 0.25,
			holdtime = 0.2,
			x = 0.1,
			y = 0.5,
			// spawnflags = 0,
			// message = ""
		})
		
		//player properties
		ent.SetMaxHealth(1000)
		ent.SetHealth(1000)
		EntFire("revivedWeapons", "Use","" , 0, ent);
		EntFireHandle(ent, "Color","255 255 255")
		EntFireHandle(ent, "SetDamageFilter", "")
		
		//message
		delay( "printl(\" \" + VS.Entity.FindByString(\""+ent+"\").GetScriptScope().name + \" spawned.\")", 0.1 )
		
		//teamlist
		if( ent.GetTeam() == 2 ) list_players_tt.append(ent)
		else if( ent.GetTeam() == 3 ) list_players_ct.append(ent)
	}
}

::FreezeTag_freezePlayer <- function( player )
{
	local scope = player.GetScriptScope()
	scope.frozen = true

	local freezeFloat = 0
	EntFire("freezeSpeedmod", "ModifySpeed", freezeFloat.tostring(), 0, player)
	EntFire("stripWeapons", "Use","" , 0, player);
	EntFireHandle(player, "SetDamageFilter", "disableBullets")
	EntFireHandle(player, "Color","25 75 255")
	EntFireHandle(scope.game_text, "SetTextColor", "25 75 255")	
	
	scope.timer <- VS.Timer.Create(null,50)
	VS.Timer.OnTimer( scope.timer, "Kill", scope )
	
	if( player.GetTeam() == 2 )
	{foreach( i, p in list_players_tt ) if( p == player ) list_players_tt.remove(i)}
	else if( player.GetTeam() == 3 ){foreach( i, p in list_players_ct ) if( p == player ) list_players_ct.remove(i)}
	
	if( list_players_tt.len() == 0 )
	{
		Chat(" Counter-Terrorist Win")
		EntFire("roundEnd", "EndRound_CounterTerroristsWin", "5")
		Chat(" " + list_players_tt.len() + " 	Terrorists left " + list_players_ct.len() + " Counter-Terrorists Left")
	}
	
	else if( list_players_ct.len() == 0 )
	{
		Chat(" 	Terrorist Win")
		EntFire("roundEnd", "EndRound_TerroristsWin", "5")	
		Chat(" " + list_players_tt.len() + " 	Terrorists left " + list_players_ct.len() + " Counter-Terrorists Left")		
	}
}

::FreezeTag_revivePlayer <- function( player )
{
	local scope = player.GetScriptScope()
	scope.frozen = false

	local reviveFloat = 1
	player.SetHealth(1000)
	EntFire("freezeSpeedmod", "ModifySpeed", reviveFloat.tostring(), 0, player);
	EntFire("revivedWeapons", "Use","" , 0, player);
	EntFireHandle(player, "Color","255 255 255")
	EntFireHandle(player, "SetDamageFilter", "")
	EntFireHandle(scope.timer, "kill" )
	EntFireHandle(scope.game_text, "SetTextColor", "220 90 90")	
	
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
		player.SetHealth(hp)
	}
	
	// opposite team
	else
	{			
		if( data.health  <= 850 && player.GetScriptScope().frozen == false )
		{
			player.SetHealth(750)
			FreezeTag_freezePlayer(player)
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
	while( ent = Entities.FindByClassname(ent,"*") ) if( ent.GetClassname() == "player" ){
		local scope = ent.GetScriptScope()
		try{
			delete scope.frozen
			scope.game_text.Destroy()
			delete scope.game_text
		}catch(e){}
	}
	DoEntFire("scmd", "Command", "mp_autokick 0; mp_disable_autokick 1; mp_spawnprotectiontime -1; mp_td_dmgtokick 999999999; mp_td_dmgtowarn 999999999; mp_td_spawndmgthreshold 999999999; ff_damage_reduction_other 0.5;sv_kick_ban_duration 0; mp_warmuptime 5  " , 0.00, activator, null)
}

function OnPostSpawn()
{
	VS.Timer.OnTimer( VS.Timer.Create(null,0.2), "GameText_Think", this )
}

function GameText_Think()
{
	local ent
	while( ent = Entities.FindByClassname(ent,"player") )
	{
		local scope = ent.GetScriptScope()
		
		
	    if (scope.frozen == true)
        {
			EntFireHandle( scope.game_text, "display", "", 0, ent )
			EntFireHandle(scope.game_text, "SetText", "You are Frozen!\n" + list_players_tt.len() + " Terrorists left.\n" + list_players_ct.len() + " Counter-Terrorists Left.")	
        }
		
		VS.Entity.SetKeyString( scope.game_text, "message", "HP: "+ ( ent.GetHealth() - 850 )) 
		EntFireHandle( scope.game_text, "display", "", 0, ent )
	}
}

function VS::Entity::CreateGameText( targetname = "", kv = null )
{
	targetname = GetUniqueName( targetname, "game_text" )
	return Create("game_text", targetname, kv)
}

::OnGameEvent_item_pickup <- function(data)
{
	local player = VS.GetHandleByUserid(data.userid)
	
	if(player.GetScriptScope().frozen == true)
	{
		EntFire("stripWeapons", "Use","" , 0, player)
	}
}

//ScriptPrintMessageChatTeam(2, "   - light red 2 -  violet - blue - light blue	 - T color - CT color - light red - green(money awards) - light green - green - Team color - red - white - gold")
