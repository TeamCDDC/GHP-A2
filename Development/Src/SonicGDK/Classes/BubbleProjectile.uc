//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Bubble Projectile > UTProjectile > UDKProjectile > Projectile > Actor
//
// The Bubble Projectile is the giant air bubble found in all classic Sonic games
// with underwater zones to refill player's supply of air and avoid drowning.
//================================================================================
class BubbleProjectile extends UTProjectile;


  /**The bubble visual static mesh.*/ var StaticMeshComponent BubbleMesh;
/**The sound played when picked up.*/ var SoundCue PickupSound;

/**The default scale of the visual static mesh.*/ var float OriginalMeshScale;
                 /**Stores the spawn timestamp.*/ var float SpawnTime;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    LifeSpan += FRand() * 5.0;
    OriginalMeshScale = BubbleMesh.Scale;
    SpawnTime = WorldInfo.TimeSeconds;

    BubbleMesh.SetScale(OriginalMeshScale * 0.1);
    SetRotation(MakeRotator(0,Rand(65536),0));
}

/**
 * Called when this actor gets pushed somewhere and there isn't enough space at that location.
 * @param Other  the other actor that pushed this actor
 */
simulated event EncroachedBy(Actor Other)
{
    Destroy();
}

/**
 * Called when this actor collides with a blocking piece of world geometry.
 * @param HitNormal      the surface normal of the hit actor/level geometry
 * @param WallActor      the hit actor
 * @param WallComponent  the associated primitive component of the wall actor
 */
simulated event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
{
    Destroy();
}

/**
 * Called when this actor enters a new physics volume.
 * @param NewVolume  the new physics volume in which the actor is standing in
 */
event PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if (!NewVolume.bWaterVolume)
        Destroy();
}

/**
 * Called for PendingTouch actor after the native physics step completes.
 * @param Other  the other actor involved in the previous touch event
 */
event PostTouch(Actor Other)
{
    local SGDKPlayerPawn P;

    P = SGDKPlayerPawn(Other);

    if (WorldInfo.TimeSeconds - SpawnTime > 1.0 && P.CanPickupActor(self))
    {
        P.Breath(true);
        P.Breath(false);

        P.PlaySound(PickupSound);

        P.CancelMoves();
        P.SetVelocity(P.GetVelocity() * 0.25);

        P.AirControl *= 0.25;

        Destroy();
    }

    ImpactedActor = none;
}

/**
 * Applies some amount of damage to this actor.
 * @param DamageAmount     the base damage to apply
 * @param EventInstigator  the controller responsible for the damage
 * @param HitLocation      world location where the hit occurred
 * @param Momentum         force/impulse caused by this hit
 * @param DamageClass      class describing the damage that was done
 * @param HitInfo          additional info about where the hit occurred
 * @param DamageCauser     the actor that directly caused the damage
 */
event TakeDamage(int DamageAmount,Controller EventInstigator,vector HitLocation,vector Momentum,
                 class<DamageType> DamageClass,optional TraceHitInfo HitInfo,optional Actor DamageCauser)
{
    Destroy();
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    if (BubbleMesh.Scale < OriginalMeshScale)
        BubbleMesh.SetScale(FMin(BubbleMesh.Scale + OriginalMeshScale * DeltaTime,OriginalMeshScale));
    else
        Disable('Tick');
}

/**
 * Called when collision with another actor happens; also called every tick that the collision still occurs.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitLocation     the world location where the touch occurred
 * @param HitNormal       the surface normal of this actor where the touch occurred
 */
simulated singular event Touch(Actor Other,PrimitiveComponent OtherComponent,vector HitLocation,vector HitNormal)
{
    if (Other != none && !Other.bDeleteMe && Other.StopsProjectile(self) && SGDKPlayerPawn(Other) != none)
    {
        ImpactedActor = Other;

        PendingTouch = Other.PendingTouch;
        Other.PendingTouch = self;
    }
}

/**
 * Explodes this projectile.
 * @param HitLocation  the world location where the explosion should occur
 * @param HitNormal    the surface normal of the hit actor
 */
simulated function Explode(vector HitLocation,vector HitNormal)
{
    Destroy();
}

/**
 * Spawns the explosion effects.
 * @param HitLocation  the world location where the explosion should occur
 * @param HitNormal    the surface normal of the hit actor
 */
simulated function SpawnExplosionEffects(vector HitLocation,vector HitNormal)
{
    //Disabled.
}


defaultproperties
{
    Begin Object Name=CollisionCylinder
        CollideActors=true
        CollisionRadius=32.0
        CollisionHeight=32.0
    End Object
    CollisionComponent=CollisionCylinder
    CylinderComponent=CollisionCylinder


    Begin Object Class=DynamicLightEnvironmentComponent Name=BubbleLightEnvironment
        bCastShadows=true
        bDynamic=true
    End Object
    Components.Add(BubbleLightEnvironment)


    Begin Object Class=StaticMeshComponent Name=BubbleStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SphereStaticMesh'
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.BubbleMaterial'
        LightEnvironment=BubbleLightEnvironment
        bCastDynamicShadow=false
        bForceDirectLightMap=true
        bUsePrecomputedShadows=false
        BlockActors=false
        BlockRigidBody=false
        CastShadow=false
        CollideActors=false
        MaxDrawDistance=4500.0
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    BubbleMesh=BubbleStaticMesh
    Components.Add(BubbleStaticMesh)


    bBlockedByInstigator=true
    bCollideComplex=false
    bSwitchToZeroCollision=false
    AccelRate=0.0
    CheckRadius=32.0
    CustomGravityScaling=0.0
    Damage=0.0
    DamageRadius=32.0
    ExplosionDecal=none
    ImpactSound=none
    LifeSpan=15.0
    MaxSpeed=50.0
    MomentumTransfer=0.0
    MyDamageType=none
    Speed=50.0
    TossZ=0.0

    PickupSound=SoundCue'SonicGDKPackSounds.BreathSoundCue'
}
