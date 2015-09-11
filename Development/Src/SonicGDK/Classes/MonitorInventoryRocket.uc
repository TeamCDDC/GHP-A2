//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Rocket > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass grants the "rocket" orb.
//================================================================================
class MonitorInventoryRocket extends MonitorInventory;


/**The related music track.*/ var SoundCue RocketSoundCue;


/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (Owner != none && TimeRemaining > 0.0)
    {
        if (Owner.IsInState('OrbRocket'))
        {
            TimeRemaining -= VSize(Owner.Velocity) * 0.006 * DeltaTime;

            if (TimeRemaining > 0.0)
                Energy = 100.0 * TimeRemaining / default.TimeRemaining;
            else
                TimeExpired();
        }
        else
        {
            bIgnoreStopEffect = true;

            if (Pawn(Owner).Controller != none)
                SGDKPlayerController(Pawn(Owner).Controller).GetMusicManager().StopMusicTrack(RocketSoundCue,1.0);

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
    P.GotoState('OrbRocket');

    if (P.IsInState('OrbRocket'))
    {
        Energy = 100.0;

        if (P.Controller != none)
            SGDKPlayerController(P.Controller).GetMusicManager().StartMusicTrack(RocketSoundCue,0.0);
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
        SGDKPlayerController(P.Controller).GetMusicManager().StopMusicTrack(RocketSoundCue,1.0);
}


defaultproperties
{
    bDestroyExpiringItems=true
    EnergyHudCoords=(U=864,V=408,UL=70,VL=70)
    PickupSound=SoundCue'SonicGDKPackSounds.RocketPickupSoundCue'
    TimeRemaining=30.0

    RocketSoundCue=SoundCue'SonicGDKPackMusic.OrbRocketSoundCue'
}
