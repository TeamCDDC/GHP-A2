//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Magnetic > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass grants the magnetic shield.
//================================================================================
class MonitorInventoryMagnetic extends MonitorInventory;


/**
 * Adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P)
{
    P.Shield.GotoState('Magnetic');
}


defaultproperties
{
    LifeSpan=5.0
}
