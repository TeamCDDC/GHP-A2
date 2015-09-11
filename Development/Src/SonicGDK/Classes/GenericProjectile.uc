//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Generic Projectile > UTProjectile > UDKProjectile > Projectile > Actor
//
// This is a generic delayed-hit projectile that moves around for some time after
// it is created.
//================================================================================
class GenericProjectile extends UTProjectile;


       /**Particles used when the projectile explodes.*/ var() ParticleSystem ExplodeParticles;
/**Particles for the projectile while it is in flight.*/ var() ParticleSystem FlightParticles;

/**The sound that is played when it explodes.*/ var() SoundCue ExplodeSound;
          /**The sound that is played looped.*/ var() SoundCue LoopingSound;

/**Material used for the decal for explosions.*/ var() MaterialInterface ExplodeDecalMaterial;
/**Height applied to the decal for explosions.*/ var() float ExplodeDecalHeight;
 /**Width applied to the decal for explosions.*/ var() float ExplodeDecalWidth;

 /**Speed is increased by this amount each second.*/ var() float AccelerationRate;
 /**DamageType class to use for projectile damage.*/ var() class<DamageType> DamageClass<AllowAbstract>;
/**Holds the time after which the projectile dies.*/ var() float LifeTime<DisplayName=Life Time>;

/**Actor types to ignore if the projectile hits them.*/ var() array< class<Actor> > ActorsToIgnoreWhenHit;

struct TRotationMask
{
/**Pitch component of rotation.*/ var() byte Pitch <ClampMin=0 | ClampMax=1>;
  /**Yaw component of rotation.*/ var() byte Yaw <ClampMin=0 | ClampMax=1>;
 /**Roll component of rotation.*/ var() byte Roll <ClampMin=0 | ClampMax=1>;

    structdefaultproperties
    {
        Pitch=1
        Yaw=1
        Roll=1
    }
};
/**Mask that can nullify certain components of initial rotation.*/ var() TRotationMask RotationMask;


/**
 * Called immediately before gameplay begins.
 */
event PreBeginPlay()
{
    AccelRate = AccelerationRate;
    AmbientSound = LoopingSound;
    DecalHeight = ExplodeDecalHeight;
    DecalWidth = ExplodeDecalWidth;
    ExplosionDecal = ExplodeDecalMaterial;
    ExplosionSound = ExplodeSound;
    LifeSpan = LifeTime;
    MyDamageType = DamageClass;
    ProjExplosionTemplate = ExplodeParticles;
    ProjFlightTemplate = FlightParticles;

    super.PreBeginPlay();
}

/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    local rotator R;

    super.PostBeginPlay();

    R = Rotation;

    R.Pitch *= RotationMask.Pitch;
    R.Yaw *= RotationMask.Yaw;
    R.Roll *= RotationMask.Roll;

    Init(vector(R));
}

/**
 * Determine whether an effect being spawned on this actor is relevant to the local client.
 * @param EffectInstigator     the instigator of this effect
 * @param bForceDedicated      whether the effect should always be spawned on dedicated server
 * @param VisibleCullDistance  maximum distance to spawn this effect if the spawn location is visible to the local player
 * @param HiddenCullDistance   maximum distance to spawn this effect if the spawn location is not visible to the local player
 * @return                     true if the effects is relevant
 */
simulated function bool ActorEffectIsRelevant(Pawn EffectInstigator,bool bForceDedicated,
                                              optional float VisibleCullDistance,optional float HiddenCullDistance)
{
    return WorldInfo.TimeSeconds - LastRenderTime < 5.0;
}

/**
 * Called when this projectile touches a blocking actor.
 * @param Other        the other actor involved in the collision
 * @param HitLocation  the world location where the touch occurred
 * @param HitNormal    the surface normal of the other actor
 */
simulated function ProcessTouch(Actor Other,vector HitLocation,vector HitNormal)
{
    if (Other != Instigator && Other.bProjTarget && ActorsToIgnoreWhenHit.Find(Other.Class) == INDEX_NONE)
    {
        if (SGDKPlayerPawn(Other) != none)
            Other.TakeDamage(Damage,InstigatorController,HitLocation,(vector(Rotation) * (Speed * 0.5) +
                             SGDKPlayerPawn(Other).GetGravityDirection() * -500.0) * MomentumTransfer,
                             MyDamageType,,self);
        else
            Other.TakeDamage(Damage,InstigatorController,HitLocation,Normal(Velocity) * MomentumTransfer,
                             MyDamageType,,self);

        Explode(HitLocation,HitNormal);
    }
}

/**
 * Spawns any effects needed for the flight of this projectile.
 */
simulated function SpawnFlightEffects()
{
    super.SpawnFlightEffects();

    if (SpawnSound != none)
        PlaySound(SpawnSound);
}


defaultproperties
{
    bCollideWorld=true
    AccelRate=1000.0
    CheckRadius=25.0
    Damage=100.0
    DamageRadius=0.0
    LifeSpan=7.0
    MaxEffectDistance=4096.0
    MaxSpeed=1000.0
    MomentumTransfer=1.0
    Speed=1000.0

    AccelerationRate=1000.0
    DamageClass=class'UTDmgType_LinkPlasma'
    ExplodeParticles=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Impact'
    ExplodeSound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_ImpactCue'
    FlightParticles=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
    LifeTime=7.0
    RotationMask=(Pitch=1,Yaw=1,Roll=1)
}
