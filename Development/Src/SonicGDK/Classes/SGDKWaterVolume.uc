//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Water Volume > UTWaterVolume > WaterVolume > PhysicsVolume > Volume >
//     > Brush > Actor
//
// Water volumes are used to represent the zones which are filled with water.
// Always use this type of water volume.
//================================================================================
class SGDKWaterVolume extends UTWaterVolume
    ClassGroup(SGDK);


    /**Effect to play when a KActor enters this volume.*/ var() ParticleSystem KActorEnteredEffect;
      /**Effect to play when a pawn enters this volume.*/ var() ParticleSystem PawnEnteredEffect;
/**Effect to play when a projectile enters this volume.*/ var() ParticleSystem ProjectileEnteredEffect;
   /**Effect to play when a vehicle enters this volume.*/ var() ParticleSystem VehicleEnteredEffect;

/**Effect to play when a pawn puts a foot in this volume.*/ var() ParticleSystem SurfaceFootstepEffect;

/**Name of the SoundMode that applies changes to a set of sounds.*/ var() name UnderwaterSoundMode;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    AssociatedActor = none;

    BACKUP_bPainCausing = bPainCausing;

    if (bPainCausing)
        PainTimer = Spawn(class'VolumeTimer',self);

    PS_EnterWaterEffect_Pawn = PawnEnteredEffect;
    PS_EnterWaterEffect_Vehicle = VehicleEnteredEffect;
    ProjectileEntryEffect = ProjectileEnteredEffect;
}

/**
 * Shows an entry splash effect.
 * @param Other  the actor that entered this volume
 */
simulated function PlayEntrySplash(Actor Other)
{
    super.PlayEntrySplash(Other);

    if (!WorldInfo.bDropDetail && KActorEnteredEffect != none && KActor(Other) != none)
        WorldInfo.MyEmitterPool.SpawnEmitter(KActorEnteredEffect,Other.Location,rot(16384,0,0));
}

/**
 * Shows a footstep splash effect.
 * @param FootstepLocation  the location of the footstep
 */
simulated function PlayFootstepSplash(vector FootstepLocation)
{
    if (!WorldInfo.bDropDetail && SurfaceFootstepEffect != none)
        WorldInfo.MyEmitterPool.SpawnEmitter(SurfaceFootstepEffect,FootstepLocation,rot(16384,0,0));
}


defaultproperties
{
    bEntryPain=false
    bVelocityAffectsWalking=false
    FluidFriction=0.3
    TerminalVelocity=2000.0

    bAlwaysRelevant=true       //Ignore.
    bOnlyDirtyReplication=true //Ignore.
    bReplicateMovement=true    //Ignore.
    bStatic=true               //It doesn't move or change over time.
    RemoteRole=ROLE_None       //Ignore.
    TickGroup=TG_PreAsyncWork  //Ignore.

    KActorEnteredEffect=ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small'
    PawnEnteredEffect=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Player_Water_Impact'
    ProjectileEnteredEffect=ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small'
    VehicleEnteredEffect=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_General_VH_Water_Impact'

    SurfaceFootstepEffect=ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small'

    UnderwaterSoundMode=Underwater
}
