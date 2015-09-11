//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Drill > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass grants the "drill" orb.
//================================================================================
class MonitorInventoryDrill extends MonitorInventory;


/**The related music track.*/ var SoundCue DrillSoundCue;


/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (Owner != none && TimeRemaining > 0.0)
    {
        if (Owner.IsInState('OrbDrill'))
        {
            TimeRemaining -= VSize(Owner.Velocity) * 0.002 * DeltaTime;

            if (TimeRemaining > 0.0)
                Energy = 100.0 * TimeRemaining / default.TimeRemaining;
            else
                TimeExpired();
        }
        else
        {
            bIgnoreStopEffect = true;

            if (Pawn(Owner).Controller != none)
                SGDKPlayerController(Pawn(Owner).Controller).GetMusicManager().StopMusicTrack(DrillSoundCue,1.0);

            Destroy();
        }
    }
}

/**
 * Re-adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function ReplenishEffect(SGDKPlayerPawn P)
{
    Energy = 100.0;
}

/**
 * Adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P)
{
    P.GotoState('OrbDrill');

    if (P.IsInState('OrbDrill'))
    {
        Energy = 100.0;

        if (P.Controller != none)
            SGDKPlayerController(P.Controller).GetMusicManager().StartMusicTrack(DrillSoundCue,0.0);
    }
}

/**
 * Removes a bonus effect from the given player pawn.
 * @param P  the player pawn which loses the bonus
 */
function StopEffect(SGDKPlayerPawn P)
{
    Energy = -1.0;

    P.GotoState('Auto');

    if (P.Controller != none)
        SGDKPlayerController(P.Controller).GetMusicManager().StopMusicTrack(DrillSoundCue,1.0);
}


defaultproperties
{
    bDestroyExpiringItems=true
    EnergyHudCoords=(U=624,V=408,UL=70,VL=70)
    PickupSound=SoundCue'SonicGDKPackSounds.DrillPickupSoundCue'
    TimeRemaining=60.0

    DrillSoundCue=SoundCue'SonicGDKPackMusic.OrbDrillSoundCue'
}
