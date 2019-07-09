blockOrigin <- self.GetOrigin()
searchRadius <- 250

function think()
{
    local nearestplayer = Entities.FindByClassnameNearest("player", blockOrigin, searchRadius)
    if (nearestplayer != null)
    {
        local playerDistance = 3 * (1 - (blockOrigin -  nearestplayer.GetOrigin()).Length2D() / searchRadius)
        if (playerDistance > 1)
        {
            playerDistance = 1
        }

        DoEntFire("!self", "SetPosition", playerDistance.tostring(), 0, self, self)
    }
    
    else
    {
        DoEntFire("!self", "Close", "", 0, self, self)
    }
}
// Example: https://www.youtube.com/watch?v=8L8yFzs7D54
