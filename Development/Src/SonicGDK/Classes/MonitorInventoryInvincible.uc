//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory Invincible > MonitorInventory > UTTimedPowerup >
//     > UTInventory > Inventory > Actor
//
// The parent class represents the item object that is given to players.
// This subclass grants invulnerability to hazards.
//================================================================================
class MonitorInventoryInvincible extends MonitorInventory
    implements(ReceivePawnEvents);


/**Holds invincible particle visual effects.*/ var SGDKEmitter InvincibleEmitter;
  /**The invincible particle visual effects.*/ var ParticleSystem InvincibleParticleSystem;
   /**The invincible dynamic point of light.*/ var SGDKSpawnablePointLight InvinciblePointLight;
              /**The invincible music track.*/ var SoundCue InvincibleSoundCue;


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
    if (ThePawn.bSuperForm)
        Destroy();
}

/**
 * Re-adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function ReplenishEffect(SGDKPlayerPawn P)
{
    if (P.Controller != none && InvincibleSoundCue != none)
        SGDKPlayerController(P.Controller).GetMusicManager().StartMusicTrack(InvincibleSoundCue,0.0);
}

/**
 * Adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P)
{
    if (!P.bSuperForm)
    {
        P.bIsInvulnerable = true;
        P.ResetPhysicsValues();
        P.NotifyEventsTo.AddItem(self);

        InvincibleEmitter = Spawn(class'SGDKEmitter',P,,P.Location,P.GetRotation());
        InvincibleEmitter.SetBase(P);
        InvincibleEmitter.SetTemplate(InvincibleParticleSystem,false);

        InvinciblePointLight = Spawn(class'PointLightInvincible',P);
        P.AttachToRoot(InvinciblePointLight);

        if (P.Controller != none)
        {
            InvincibleSoundCue = SGDKPlayerController(P.Controller).GetMusicManager().InvincibleMusicTrack;

            if (InvincibleSoundCue != none)
                SGDKPlayerController(P.Controller).GetMusicManager().StartMusicTrack(InvincibleSoundCue,0.0);
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

    if (!P.bSuperForm)
        P.bIsInvulnerable = false;

    if (InvincibleEmitter != none)
    {
        InvincibleEmitter.DelayedDestroy();
        InvincibleEmitter = none;
    }

    if (InvinciblePointLight != none)
    {
        P.DetachFromRoot(InvinciblePointLight);
        InvinciblePointLight.Destroy();
    }

    P.ResetPhysicsValues();

    if (P.Controller != none && InvincibleSoundCue != none)
        SGDKPlayerController(P.Controller).GetMusicManager().StopMusicTrack(InvincibleSoundCue,1.0);
}


defaultproperties
{
    EnergyHudCoords=(U=544,V=328,UL=70,VL=70)
    TimeRemaining=24.0

    InvincibleParticleSystem=ParticleSystem'SonicGDKPackParticles.Particles.InvincibleParticleSystem'
}
