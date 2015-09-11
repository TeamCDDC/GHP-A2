//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Eggman > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass causes damage.
//================================================================================
class MonitorInventoryEggman extends MonitorInventory;


/**The evil laugh sound.*/ var SoundCue EggmanPickupSound;


/**
 * Plays an evil laugh.
 */
function PlayEvilLaugh()
{
    bIgnoreStopEffect = true;

    if (Owner != none)
        Owner.PlaySound(EggmanPickupSound);
}

/**
 * Adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P)
{
    P.TakeDamage(1,none,Location,(vect(0,0,1) >> Rotation) * 500.0,class'SGDKDmgType_EnemyMelee',,self);

    SetTimer(1.0,false,NameOf(PlayEvilLaugh));
}

/**
 * Removes a bonus effect from the given player pawn.
 * @param P  the player pawn which loses the bonus
 */
function StopEffect(SGDKPlayerPawn P)
{
    P.PlaySound(EggmanPickupSound);
}


defaultproperties
{
    LifeSpan=5.0

    EggmanPickupSound=SoundCue'SonicGDKPackSounds.EggmanLaughSoundCue'
}
