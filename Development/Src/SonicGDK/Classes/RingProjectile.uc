//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Ring Projectile > UTProjectile > UDKProjectile > Projectile > Actor
//
// This class is a delayed-hit projectile that moves around for some time after it
// is created and has two different states: dropped and magnetized.
// This type is the classic ring item found in all Sonic games.
//================================================================================
class RingProjectile extends UTProjectile
    implements(MagnetizableEntity);


/**The ring visual static mesh.*/ var StaticMeshComponent RingMesh;

/**Determines the 2.5D plane for classic movement.*/ var vector ClassicTangent;
 /**Last speed magnitude used for magnetized code.*/ var float LastSpeed;
                /**The ring pickup class to spawn.*/ var class<RingActor> RingActorClass;


/**
 * Called after PostBeginPlay to determine the initial state of the object.
 */
simulated event SetInitialState()
{
    bScriptInitialized = true;

    if (Owner == none)
        GotoState('Dropped');
    else
        GotoState('Magnetized');
}

/**
 * Called when this actor gets pushed somewhere and there isn't enough space at that location.
 * @param Other  the other actor that pushed this actor
 */
simulated event EncroachedBy(Actor Other)
{
    if (!Other.bIgnoreEncroachers)
        Destroy();
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
    //Disabled.
}

/**
 * Pawn picks up this ring projectile.
 * @param P  the pawn
 */
function GrantRing(SGDKPlayerPawn P)
{
    local RingActor Ring;

    Ring = Spawn(RingActorClass,P,,Location,Rotation);
    Ring.Touch(P,P.CollisionComponent,Location,Normal(Location - P.Location));
    Ring.Destroy();
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
 * Tries to magnetize this object.
 * @param AnActor  the actor that tries to magnetize this object
 */
function Magnetize(Actor AnActor)
{
    SetOwner(AnActor);

    GotoState('Magnetized');
}

/**
 * Called when this projectile touches a blocking actor; delegated to states.
 * @param Other        the other actor involved in the collision
 * @param HitLocation  the world location where the touch occurred
 * @param HitNormal    the surface normal of the other actor
 */
simulated function ProcessTouch(Actor Other,vector HitLocation,vector HitNormal)
{
}

/**
 * Randomizes the yaw spin rate.
 * @param SpinRate  maximum spin rate to consider
 */
function RandomYawSpin(float SpinRate)
{
    RotationRate.Yaw = SpinRate * FRand();
}

/**
 * Sets 2.5D classic movement behaviour; delegated to states.
 * @param Tangent  the tangent vector that determines the 2.5D plane for classic movement
 */
function SetClassicMode(vector Tangent)
{
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


state Dropped
{
    event BeginState(name PreviousStateName)
    {
        local rotator R;

        bBounce = true;
        bCollideWorld = true;
        bRotationFollowsVelocity = false;
        ClassicTangent = vect(0,0,0);
        LifeSpan = 5.0;
        RotationRate = rot(0,0,0);
        Speed = FMax(500.0,VSize(Velocity));

        if (PreviousStateName != 'Magnetized')
        {
            R.Yaw = Rand(65536);
            SetRotation(R);

            if (!PhysicsVolume.bWaterVolume)
            {
                if (GetGravityZ() <= 0.0)
                    Velocity = vector(Rotation + rot(18000,0,0) + rot(2000,0,0) * FRand()) * Speed;
                else
                    Velocity = vector(Rotation + rot(-18000,0,0) + rot(-2000,0,0) * FRand()) * Speed;
            }
            else
            {
                if (GetGravityZ() <= 0.0)
                    Velocity = vector(Rotation + rot(20000,0,0) + rot(5000,0,0) * FRand()) * Speed;
                else
                    Velocity = vector(Rotation + rot(-20000,0,0) + rot(-5000,0,0) * FRand()) * Speed;
            }
        }
        else
            Velocity = vector(Rotation) * Speed;

        if (PhysicsVolume.bWaterVolume)
            CustomGravityScaling = default.CustomGravityScaling * 0.5;

        if (GetGravityZ() > 0.0)
            CustomGravityScaling *= 2.0;

        RandomYawSpin(25000);
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

            if (Speed > 100.0 || (Speed > 10.0 && Abs(HitNormal.Z) < 0.71) ||
                (Speed > 10.0 && GetGravityZ() <= 0.0 && HitNormal.Z <= -0.71) ||
                (Speed > 10.0 && GetGravityZ() > 0.0 && HitNormal.Z >= 0.71))
                RandomYawSpin(Speed * 500);
            else
            {
                ImpactedActor = WallActor;
                SetPhysics(PHYS_None);
            }
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
            RotationRate.Yaw *= 0.5;
            Velocity.Z *= 0.5;
        }

        if (GetGravityZ() > 0.0)
            CustomGravityScaling *= 2.0;

        super.PhysicsVolumeChange(NewVolume);
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        if (Physics == PHYS_Falling && !IsZero(ClassicTangent))
            Velocity = PointProjectToPlane(Velocity,vect(0,0,0),vect(0,0,1),ClassicTangent);

        if (LifeSpan < 1.5)
            RingMesh.SetHidden(WorldInfo.TimeSeconds % 0.15 < 0.075);
    }

    /**
     * Called when this projectile touches a blocking actor.
     * @param Other        the other actor involved in the collision
     * @param HitLocation  the world location where the touch occurred
     * @param HitNormal    the surface normal of the other actor
     */
    simulated function ProcessTouch(Actor Other,vector HitLocation,vector HitNormal)
    {
        local SGDKPlayerPawn P;

        P = SGDKPlayerPawn(Other);

        if (LifeSpan < 3.5 && P != none && P.CanPickupActor(self))
        {
            GrantRing(P);

            Destroy();
        }
    }

    /**
     * Sets 2.5D classic movement behaviour.
     * @param Tangent  the tangent vector that determines the 2.5D plane for classic movement
     */
    function SetClassicMode(vector Tangent)
    {
        local rotator R;

        ClassicTangent = Normal(Tangent * vect(1,1,0));

        R = rotator(ClassicTangent);
        R.Pitch += 32768 * FRand();

        Speed *= 1.5;
        Velocity = vector(R) * Speed;
    }
}


state Magnetized
{
    event BeginState(name PreviousStateName)
    {
        bBounce = false;
        bCollideWorld = false;
        bRotationFollowsVelocity = true;
        LifeSpan = 7.0;
        RotationRate = rot(0,0,0);
        Speed = FMax(FMax(350.0,VSize(Velocity)),VSize(Owner.Velocity) * 0.5);

        RingMesh.SetHidden(false);
        SetPhysics(PHYS_Projectile);

        Init(vector(Rotation));

        LastSpeed = Speed;
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        local bool bOverlapping;
        local SGDKPlayerPawn P;

        if (Owner == none || !SGDKPlayerPawn(Owner).IsMagnetized())
            GotoState('Dropped');
        else
        {
            bOverlapping = false;

            foreach WorldInfo.AllPawns(class'SGDKPlayerPawn',P)
                if (IsOverlapping(P) && P.CanPickupActor(self))
                {
                    bOverlapping = true;

                    break;
                }

            if (bOverlapping)
            {
                GrantRing(P);

                Destroy();
            }
            else
            {
                LastSpeed = FMin(LastSpeed + (AccelRate * DeltaTime),MaxSpeed);

                if (LifeSpan > 6.0)
                    Velocity = Normal(Normal(Velocity) + Normal(Owner.Location - Location) *
                               (DeltaTime * Square((default.LifeSpan - LifeSpan) * 0.4))) * LastSpeed;
                else
                    Velocity = Normal(Normal(Velocity) + Normal(Owner.Location - Location) *
                               (DeltaTime * Square(default.LifeSpan - LifeSpan))) * LastSpeed;
            }
        }
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


    Begin Object Class=DynamicLightEnvironmentComponent Name=RingLightEnvironment
        bCastShadows=true
        bDynamic=true
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object
    Components.Add(RingLightEnvironment)


    Begin Object Class=StaticMeshComponent Name=RingStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.RingStaticMesh'
        LightEnvironment=RingLightEnvironment
        bAllowApproximateOcclusion=false
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
    RingMesh=RingStaticMesh
    Components.Add(RingStaticMesh)


    bBlockedByInstigator=true
    bCollideComplex=false
    bSwitchToZeroCollision=false
    AccelRate=750.0
    CheckRadius=12.5
    CustomGravityScaling=0.75
    Damage=0.0
    DamageRadius=12.5
    ExplosionDecal=none
    ImpactSound=SoundCue'SonicGDKPackSounds.RingImpactSoundCue'
    MaxSpeed=6000.0
    MomentumTransfer=0.0
    MyDamageType=none
    TossZ=0.0

    RingActorClass=class'RingActor_Dynamic'
}
