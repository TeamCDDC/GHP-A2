//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Rings > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass grants an amount of classic ring items.
//================================================================================
class MonitorInventoryRings extends MonitorInventory;


/**Amount of granted energy.*/ var float EnergyAmount;
 /**Amount of granted rings.*/ var byte RingsAmount;


/**
 * Adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P)
{
    local SGDKPlayerController PC;

    //Give rings.
    P.GiveHealth(RingsAmount,P.SuperHealthMax);

    //Give energy.
    P.ReceiveEnergy(EnergyAmount);

    //Updates the HUD.
    PC = SGDKPlayerController(P.Controller);
    if (PC != none)
    {
        PC.GetHud().LastHealthPickupTime = WorldInfo.TimeSeconds;
        PC.GetHud().LastPickupTime = WorldInfo.TimeSeconds;
    }
}


defaultproperties
{
    LifeSpan=5.0
    PickupSound=SoundCue'SonicGDKPackSounds.RingsSoundCue'

    EnergyAmount=5.0
    RingsAmount=10
}
