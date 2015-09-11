//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Speed > MonitorInventory > UTTimedPowerup > UTInventory >
//     > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass grants the speed boots.
//================================================================================
class MonitorInventorySpeed extends MonitorInventory
    implements(ReceivePawnEvents);


/**The speed boots' music track.*/ var SoundCue SpeedSoundCue;


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

//Ignored function calls.
function PawnDied(SGDKPlayerPawn ThePawn);
function PawnEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnHeadEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnHeadLeftWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnHurtPawn(SGDKPlayerPawn ThePawn,Pawn TheOtherPawn);
function PawnLeftWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnBounced(SGDKPlayerPawn ThePawn);
function PawnDoubleJumped(SGDKPlayerPawn ThePawn);
function PawnJumpApex(SGDKPlayerPawn ThePawn);
function PawnJumped(SGDKPlayerPawn ThePawn);
function PawnLanded(SGDKPlayerPawn ThePawn,bool bWillLeaveGround,vector TheHitNormal,Actor TheFloorActor);
function PawnTookDamage(SGDKPlayerPawn ThePawn,Actor TheDamageCauser);

/**
 * Called when all physics data of the pawn is adapted to a new physics environment.
 * @param ThePawn  the pawn that generates the event
 */
function PawnPhysicsChanged(SGDKPlayerPawn ThePawn)
{
    if (!ThePawn.bSuperForm)
    {
        ThePawn.DefaultAccelRate *= 2.0;
        ThePawn.DefaultAirControl *= 2.0;
        ThePawn.DefaultDecelRate *= 2.0;
        ThePawn.DefaultGroundSpeed *= 1.5;
    }
    else
        Destroy();
}

/**
 * Re-adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function ReplenishEffect(SGDKPlayerPawn P)
{
    if (P.Controller != none && SpeedSoundCue != none)
        SGDKPlayerController(P.Controller).GetMusicManager().StartMusicTrack(SpeedSoundCue,0.0);
}

/**
 * Adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P)
{
    if (!P.bSuperForm)
    {
        P.ResetPhysicsValues();

        P.DefaultAccelRate *= 2.0;
        P.DefaultAirControl *= 2.0;
        P.DefaultDecelRate *= 2.0;
        P.DefaultGroundSpeed *= 1.5;

        P.WaterRunAdhesionPct /= 1.5;

        P.NotifyEventsTo.AddItem(self);

        if (P.Controller != none)
        {
            SpeedSoundCue = SGDKPlayerController(P.Controller).GetMusicManager().SpeedBootsMusicTrack;

            if (SpeedSoundCue != none)
                SGDKPlayerController(P.Controller).GetMusicManager().StartMusicTrack(SpeedSoundCue,0.0);
            else
                SGDKPlayerController(P.Controller).GetMusicManager().SetPitch(1.1,0.5);
        }

        Energy = 100.0;
    }
    else
    {
        bIgnoreStopEffect = true;

        Destroy();
    }
}

/**
 * Removes a bonus effect from the given player pawn.
 * @param P  the player pawn which loses the bonus
 */
function StopEffect(SGDKPlayerPawn P)
{
    Energy = -1.0;

    P.NotifyEventsTo.RemoveItem(self);

    P.ResetPhysicsValues();

    P.WaterRunAdhesionPct *= 1.5;

    if (P.Controller != none)
    {
        if (SpeedSoundCue != none)
            SGDKPlayerController(P.Controller).GetMusicManager().StopMusicTrack(SpeedSoundCue,1.0);
        else
            SGDKPlayerController(P.Controller).GetMusicManager().SetPitch(1.0,0.5);
    }
}


defaultproperties
{
    EnergyHudCoords=(U=624,V=328,UL=70,VL=70)
    TimeRemaining=24.0
}
