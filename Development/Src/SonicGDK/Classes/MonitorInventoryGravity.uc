//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Gravity > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass grants the anti-gravity boots.
//================================================================================
class MonitorInventoryGravity extends MonitorInventory;


/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (Owner != none && TimeRemaining > 0.0)
        Energy = 100.0 * TimeRemaining / default.TimeRemaining;
}

/**
 * Adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P)
{
    P.bAntiGravityMode = true;
    Energy = 100.0;
}

/**
 * Removes a bonus effect from the given player pawn.
 * @param P  the player pawn which loses the bonus
 */
function StopEffect(SGDKPlayerPawn P)
{
    Energy = -1.0;
    P.bAntiGravityMode = false;
}


defaultproperties
{
    EnergyHudCoords=(U=784,V=328,UL=70,VL=70)
    TimeRemaining=24.0
}
