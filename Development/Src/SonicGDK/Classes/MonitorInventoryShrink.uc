//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Shrink > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass decreases the size of the player.
//================================================================================
class MonitorInventoryShrink extends MonitorInventory;


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
    if (!P.bMiniSize)
        P.MiniSize(true);

    Energy = 100.0;
}

/**
 * Removes a bonus effect from the given player pawn.
 * @param P  the player pawn which loses the bonus
 */
function StopEffect(SGDKPlayerPawn P)
{
    Energy = -1.0;

    P.MiniSize(false);

    if (P.bMiniSize)
        P.SetTimer(0.25,true,NameOf(P.MiniSize));
}


defaultproperties
{
    EnergyHudCoords=(U=704,V=328,UL=70,VL=70)
    PickupSound=SoundCue'SonicGDKPackSounds.ShrinkSoundCue'
    TimeRemaining=24.0
}
