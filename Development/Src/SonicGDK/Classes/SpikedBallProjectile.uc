//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Spiked Ball Projectile > UTProjectile > UDKProjectile > Projectile > Actor
//
// This is a generic delayed-hit projectile that moves around for some time after
// it is created and has three different states: falling, hovering and orbiting.
// This type is a spiked ball.
//================================================================================
class SpikedBallProjectile extends UTProjectile;


/**The spiked ball visual static mesh.*/ var StaticMeshComponent SpikedBallMesh;

/**If true, the XY plane is used for orbiting, instead of the XZ plane.*/ var bool bHorizontalOrbit;
                    /**Current angle that determines orbiting position.*/ var float OrbitAngle;
                                       /**Stores the orbiting position.*/ var vector OrbitLocation;
                                                     /**Orbital radius.*/ var float OrbitRadius;
                                                      /**Orbital speed.*/ var float OrbitSpeed;

/**Reference to the Orbinaut badnik owner.*/ var BadnikOrbinaut Orbinaut;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    if (Owner != none && BadnikOrbinaut(Owner) != none)
    {
        Orbinaut = BadnikOrbinaut(Owner);

        if (Orbinaut.SpikedBallMesh != SpikedBallMesh.StaticMesh)
            SpikedBallMesh.SetStaticMesh(Orbinaut.SpikedBallMesh);
    }
}

/**
 * Called after PostBeginPlay to determine the initial state of the object.
 */
simulated event SetInitialState()
{
    bScriptInitialized = true;

    if (Owner == none || BadnikOrbinaut(Owner) == none)
        GotoState('FallingState');
    else
        GotoState('OrbitingState');
}

/**
 * Called when this actor gets pushed somewhere and there isn't enough space at that location.
 * @param Other  the other actor that pushed this actor
 */
simulated event EncroachedBy(Actor Other)
{
    Explode(Location,Normal(Location - Other.Location));
}

/**
 * Called when this actor collides with a blocking piece of world geometry; delegated to states.
 * @param HitNormal      the surface normal of the hit actor/level geometry
 * @param WallActor      the hit actor
 * @param WallComponent  the associated primitive component of the wall actor
 */
simulated event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
{
}

/**
 * Called when the actor enters a new physics volume; delegated to states.
 * @param NewVolume  the new physics volume in which the actor is standing in
 */
event PhysicsVolumeChange(PhysicsVolume NewVolume)
{
}

/**
 * Called whenever time passes; delegated to states.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
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
 * Called when this actor touches a fluid surface.
 * @param FluidSurface  the touched fluid surface
 * @param HitLocation   the world location where the touch occurred
 */
simulated function ApplyFluidSurfaceImpact(FluidSurfaceActor FluidSurface,vector HitLocation)
{
    super(Actor).ApplyFluidSurfaceImpact(FluidSurface,HitLocation);

    if (CanSplash())
        WorldInfo.MyEmitterPool.SpawnEmitter(FluidSurface.ProjectileEntryEffect,HitLocation,rotator(vect(0,0,1)),self);
}

/**
 * Is this actor allowed to show effects when entering a water volume?
 * @return  true if effects are allowed
 */
simulated function bool CanSplash()
{
    return bBegunPlay;
}

/**
 * Explodes this projectile.
 * @param HitLocation  the world location where the explosion should occur
 * @param HitNormal    the surface normal of the hit actor
 */
simulated function Explode(vector HitLocation,vector HitNormal)
{
    SpawnExplosionEffects(HitLocation,HitNormal);

    ShutDown();
}

/**
 * Initializes this projectile.
 * @param Direction  the direction to face
 */
function Init(vector Direction)
{
    SetRotation(rotator(Direction));

    Velocity = Direction * Speed;
}

/**
 * Called when this projectile touches a blocking actor.
 * @param Other        the other actor involved in the collision
 * @param HitLocation  the world location where the touch occurred
 * @param HitNormal    the surface normal of the other actor
 */
simulated function ProcessTouch(Actor Other,vector HitLocation,vector HitNormal)
{
    if (Other != Instigator && Pawn(Other) != none)
    {
        if (IsZero(Velocity))
            Other.TakeDamage(Damage,InstigatorController,HitLocation,
                             Normal(Other.Location - Location) * (500.0 * MomentumTransfer),MyDamageType,,self);
        else
            if (SGDKPlayerPawn(Other) != none)
                Other.TakeDamage(Damage,InstigatorController,HitLocation,(Normal2D(Other.Location - Location) -
                                 SGDKPlayerPawn(Other).GetGravityDirection()) * (500.0 * MomentumTransfer),
                                 MyDamageType,,self);
            else
                Other.TakeDamage(Damage,InstigatorController,HitLocation,
                                 Normal(Velocity) * MomentumTransfer,MyDamageType,,self);

        Explode(HitLocation,HitNormal);
    }
}

/**
 * Vanishes this projectile.
 */
function Vanish()
{
    bShuttingDown = true;

    bCollideWorld = false;
    SetCollision(false);
    SetHidden(true);
    SetPhysics(PHYS_None);
    SetTickIsDisabled(true);

    LifeSpan = FRand();
}


state FallingState
{
    event BeginState(name PreviousStateName)
    {
        bCollideWorld = true;
        LifeSpan = default.LifeSpan;
        Speed = FMax(500.0,VSize(Velocity));
        Velocity = vector(Rotation) * Speed;

        if (PhysicsVolume.bWaterVolume)
            CustomGravityScaling = default.CustomGravityScaling * 0.5;

        if (GetGravityZ() > 0.0)
            CustomGravityScaling *= 2.0;

        SetOwner(none);
        SetPhysics(PHYS_Falling);
    }

    /**
     * Called when this actor collides with a blocking piece of world geometry.
     * @param HitNormal      the surface normal of the hit actor/level geometry
     * @param WallActor      the hit actor
     * @param WallComponent  the associated primitive component of the wall actor
     */
    simulated event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
    {
        if (Pawn(WallActor) == none)
        {
            if (ImpactSound != none)
                PlaySound(ImpactSound);

            if (GetGravityZ() <= 0.0)
                Velocity = MirrorVectorByNormal(Velocity * 0.75,HitNormal);
            else
                Velocity = MirrorVectorByNormal(Velocity * 0.5625,HitNormal);

            Speed = VSize(Velocity);

            ImpactedActor = WallActor;
            SetPhysics(PHYS_None);
        }
    }

    /**
     * Called when this actor enters a new physics volume.
     * @param NewVolume  the new physics volume in which the actor is standing in
     */
    event PhysicsVolumeChange(PhysicsVolume NewVolume)
    {
        if (!NewVolume.bWaterVolume)
            CustomGravityScaling = default.CustomGravityScaling;
        else
        {
            CustomGravityScaling = default.CustomGravityScaling * 0.5;
            Velocity.Z *= 0.5;
        }

        if (GetGravityZ() > 0.0)
            CustomGravityScaling *= 2.0;

        super.PhysicsVolumeChange(NewVolume);
    }
}


state HoveringState
{
    event BeginState(name PreviousStateName)
    {
        bCollideWorld = true;
        LifeSpan = default.LifeSpan;
        MaxSpeed = FMax(VSize(Velocity),MaxSpeed);
        Speed = MaxSpeed;
        Velocity = vector(Rotation) * Speed;

        SetOwner(none);
        SetPhysics(PHYS_Projectile);
    }

    /**
     * Called when this actor collides with a blocking piece of world geometry.
     * @param HitNormal      the surface normal of the hit actor/level geometry
     * @param WallActor      the hit actor
     * @param WallComponent  the associated primitive component of the wall actor
     */
    simulated event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
    {
        if (Pawn(WallActor) == none)
        {
            if (ImpactSound != none)
                PlaySound(ImpactSound);

            if (GetGravityZ() <= 0.0)
                Velocity = MirrorVectorByNormal(Velocity * 0.75,HitNormal);
            else
                Velocity = MirrorVectorByNormal(Velocity * 0.5625,HitNormal);

            Speed = VSize(Velocity);

            ImpactedActor = WallActor;
            SetPhysics(PHYS_None);
        }
    }
}


state OrbitingState
{
    event BeginState(name PreviousStateName)
    {
        local vector V;

        bCollideWorld = false;
        LifeSpan = 0.0;
        MaxSpeed = 0.0;
        Speed = 0.0;
        Velocity = vect(0,0,0);

        SetPhysics(PHYS_Projectile);

        V = Normal(Location - Owner.Location);
        OrbitAngle = Acos(V dot vect(1,0,0));

        if (Orbinaut != none)
        {
            bHorizontalOrbit = Orbinaut.bHorizontalOrbit;
            OrbitRadius = Orbinaut.OrbitRadius;
            OrbitSpeed = Orbinaut.OrbitSpeed;

            SpikedBallMesh.SetShadowParent(Orbinaut.Mesh);
        }
        else
            OrbitRadius = VSize(Location - Owner.Location);

        if (!bHorizontalOrbit)
        {
            if (V.Z < 0.0)
                OrbitAngle *= -1.0;
        }
        else
            if (V.Y < 0.0)
                OrbitAngle *= -1.0;
    }

    event EndState(name NextStateName)
    {
        if (!bCollideActors)
        {
            SetCollision(true);

            SpikedBallMesh.SetHidden(false);
        }

        SpikedBallMesh.SetShadowParent(none);
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        local vector V;
        local rotator R;

        if (!bShuttingDown && LifeSpan == 0.0 && Physics == PHYS_Projectile &&
            Instigator != none && !Instigator.bDeleteMe)
        {
            OrbitAngle += OrbitSpeed * DeltaTime;

            if (WorldInfo.TimeSeconds - LastRenderTime < 2.5 ||
                WorldInfo.TimeSeconds - Instigator.LastRenderTime < 2.5 ||
                (SGDKEnemyPawn(Instigator) != none && SGDKEnemyPawn(Instigator).IsSeeingEnemy()))
            {
                if (!bCollideActors)
                {
                    SetCollision(true);

                    SpikedBallMesh.SetHidden(false);
                }

                V.X = Cos(OrbitAngle);

                if (!bHorizontalOrbit)
                    V.Z = Sin(OrbitAngle);
                else
                    V.Y = Sin(OrbitAngle);

                R = Instigator.Rotation;

                if (!bHorizontalOrbit)
                    R.Pitch = 0;
                else
                    R.Yaw = 0;

                Move(Instigator.Location + ((V * OrbitRadius) >> R) - Location);
                SetRotation(Instigator.Rotation);

                if (Orbinaut != none && Orbinaut.bThrowBalls && Orbinaut.IsSeeingEnemy() &&
                    !IsZero(OrbitLocation) && V dot vect(1,0,0) < 0.2)
                {
                    if (!bHorizontalOrbit)
                    {
                        if (OrbitSpeed > 0.0)
                        {
                            if (OrbitLocation.X < V.X && OrbitLocation.Z < V.Z)
                                Throw();
                        }
                        else
                            if (OrbitLocation.X < V.X && OrbitLocation.Z > V.Z)
                                Throw();
                    }
                    else
                        if (OrbitSpeed > 0.0)
                        {
                            if (OrbitLocation.X < V.X && OrbitLocation.Y < V.Y)
                                Throw();
                        }
                        else
                            if (OrbitLocation.X < V.X && OrbitLocation.Y > V.Y)
                                Throw();
                }

                OrbitLocation = V;
            }
            else
                if (bCollideActors)
                {
                    SetCollision(false);

                    SpikedBallMesh.SetHidden(true);
                }
        }
        else
            if (Instigator != none && Instigator.Health < 1)
            {
                Explode(Location,vect(0,0,1));

                SetTickIsDisabled(true);
            }
            else
                Vanish();
    }

    /**
     * Throws itself.
     */
    function Throw()
    {
        if (Orbinaut != none)
            MaxSpeed = Orbinaut.ThrowSpeed;

        GotoState('HoveringState');
    }
}


defaultproperties
{
    Begin Object Name=CollisionCylinder
        CollideActors=true
        CollisionRadius=12.5
        CollisionHeight=12.5
    End Object
    CollisionComponent=CollisionCylinder
    CylinderComponent=CollisionCylinder


    Begin Object Class=DynamicLightEnvironmentComponent Name=BallLightEnvironment
        bCastShadows=true
        bDynamic=true
    End Object
    Components.Add(BallLightEnvironment)


    Begin Object Class=StaticMeshComponent Name=BallStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SpikedBallStaticMesh'
        LightEnvironment=BallLightEnvironment
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=false
        BlockActors=false
        BlockRigidBody=false
        CastShadow=true
        CollideActors=false
        MaxDrawDistance=4500.0
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    SpikedBallMesh=BallStaticMesh
    Components.Add(BallStaticMesh)


    bBlockedByInstigator=false
    bCollideComplex=false
    bRotationFollowsVelocity=false
    bSwitchToZeroCollision=false
    AccelRate=750.0
    CheckRadius=12.5
    CustomGravityScaling=0.75
    Damage=100.0
    DamageRadius=12.5
    ExplosionDecal=none
    ExplosionSound=SoundCue'SonicGDKPackSounds.EnemyExplosionSoundCue'
    ImpactSound=none
    LifeSpan=5.0
    MaxSpeed=6000.0
    MomentumTransfer=1.0
    MyDamageType=class'SGDKDmgType_EnemyMelee'
    ProjExplosionTemplate=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_GeneralExplosion'
    TossZ=0.0

    OrbitSpeed=2.5
}
