////Setup\\\\
savePosition <- null
savePosition2 <- null
kzplayer <- Entities.FindByClassname(null, "player")
spawnPoint <- kzplayer.GetOrigin()

function blank()
{
	SendToConsole("radio")
}

////save\\\\
function saveP()
{
	savePosition = kzplayer.GetOrigin()
	SendToConsole("radio")
}

function saveP2()
{
	savePosition2 = kzplayer.GetOrigin()
	SendToConsole("radio")
}

function setSpawn()
{
	spawnPoint = kzplayer.GetOrigin()
	SendToConsole("radio")
}

////tele\\\\
function teleP()
{
	kzplayer.SetOrigin(savePosition)
	SendToConsole("radio")
}

function teleP2()
{
	kzplayer.SetOrigin(savePosition2)
	SendToConsole("radio")
}

function kzReset()
{
	kzplayer.SetOrigin(spawnPoint)
	SendToConsole("radio")
}
