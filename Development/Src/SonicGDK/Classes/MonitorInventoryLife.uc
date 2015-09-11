//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Life > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass grants an extra life.
//================================================================================
class MonitorInventoryLife extends MonitorInventory;


/**The extra life music track.*/ var SoundCue LifeSoundCue;


/**
 * Adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P)
{
    if (P.Controller != none)
    {
        SGDKPlayerController(P.Controller).AddLives(1);

        LifeSoundCue = SGDKPlayerController(P.Controller).GetMusicManager().ExtraLifeMusicTrack;

        if (LifeSoundCue != none)
        {
            SGDKPlayerController(P.Controller).GetMusicManager().StartMusicTrack(LifeSoundCue,0.0);

            LifeSpan = FMax(default.LifeSpan,LifeSoundCue.Duration - 1.0);
        }
    }
}

/**
 * Removes a bonus effect from the given player pawn.
 * @param P  the player pawn which loses the bonus
 */
function StopEffect(SGDKPlayerPawn P)
{
    if (P.Controller != none && LifeSoundCue != none)
        SGDKPlayerController(P.Controller).GetMusicManager().StopMusicTrack(LifeSoundCue,1.0);
}


defaultproperties
{
    LifeSpan=2.0
}
