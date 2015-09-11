//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Platform Actor > InterpActor > DynamicSMActor > Actor
//
// Dynamic static mesh actor intended to be used as a moving/collapsing platform.
//================================================================================
class PlatformActor extends InterpActor
    ClassGroup(SGDK,Visible)
    placeable;


/**If true, a simple endless movement is applied to this platform.*/ var() bool bCanMove;
                                         /**Direction of movement.*/ var() vector MoveDirection;
                                         /**Magnitude of movement.*/ var() float MoveDistance;
                       /**Factor applied to the speed of movement.*/ var() float MoveSpeedFactor;

/**If true, this platform sinks a bit when something is on it.*/ var() bool bCanSink;
                         /**Magnitude of the sinking movement.*/ var() float SinkDistance;
       /**Factor applied to the speed of the sinking movement.*/ var() float SinkSpeedFactor;

/**If true, this platform falls after something stands on it.*/ var() bool bCanFall;
               /**Particles to show when this platform falls.*/ var() ParticleSystem FallParticles;
                   /**Sound to play when this platform falls.*/ var() SoundCue FallSound;
     /**How much time this platform can float before falling.*/ var() float FallTime;
               /**Particles to show when this platform lands.*/ var() ParticleSystem LandParticles;
                   /**Sound to play when this platform lands.*/ var() SoundCue LandSound;

struct TPhysMeshData
{
                           /**Static mesh to use.*/ var() StaticMesh Mesh;
/**Translation offset from this actor's location.*/ var() vector Translation;
                              /**Rotation to use.*/ var() rotator Rotation;
                 /**Global scaling factor to use.*/ var() float Scale;
                        /**Scaling vector to use.*/ var() vector Scale3D;

    structdefaultproperties
    {
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    }
};
/**Fragments to create while collapsing.*/ var() array<TPhysMeshData> PhysicsMeshSlots;
  /**How long the fragments should last.*/ var() float PhysicsMeshLifeSpan;

/**Invisible box component used to check for visibility.*/ var VisibilityBoxComponent HiddenComponent;
               /**Time between vanishing and respawning.*/ var() float RespawnTime;

     /**If true, the platform fell to ground.*/ var bool bFallen;
         /**Initial location of the platform.*/ var vector InitialLocation;
/**Initial Z translation of the visible mesh.*/ var float InitialZTranslation;
     /**Cached locations for simple movement.*/ var vector MoveLocation1,MoveLocation2;
   /**Current percent of the simple movement.*/ var float MovePercent;
  /**Current percent of the sinking movement.*/ var float SinkPercent;
      /**Z translation of the mesh when sunk.*/ var float SinkZTranslation;
           /**Actors currently being tracked.*/ var array<Actor> TrackedActors;
 /**Z translation of the mesh before sinking.*/ var float UnSinkZTranslation;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    HiddenComponent.BoxExtent = StaticMeshComponent.Bounds.BoxExtent * 1.5;
    HiddenComponent.SetTranslation(StaticMeshComponent.Bounds.Origin - Location);
    HiddenComponent.ForceUpdate(false);

    InitialLocation = Location;
    InitialZTranslation = StaticMeshComponent.Translation.Z;

    MoveDirection = Normal(MoveDirection) * (MoveDistance * 0.5);
    MoveLocation1 = InitialLocation - MoveDirection;
    MoveLocation2 = InitialLocation + MoveDirection;
}

/**
 * Called when another actor is attached to this actor.
 * @param Other  the other actor that is attached
 */
event Attach(Actor Other)
{
    super.Attach(Other);

    TriggerEventClass(class'SeqEvent_PlatformEvent',Other,0);
}

/**
 * Called when another actor is detached from this actor.
 * @param Other  the other actor that is detached
 */
event Detach(Actor Other)
{
    super.Detach(Other);

    TriggerEventClass(class'SeqEvent_PlatformEvent',Other,1);
}

/**
 * Called when the actor falls out of the world 'safely' (below KillZ and such).
 * @param DamageClass  the type of damage
 */
simulated event FellOutOfWorld(class<DamageType> DamageClass)
{
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    local vector V;

    if (bCanMove)
    {
        MovePercent = FMin(MovePercent + MoveSpeedFactor * DeltaTime,1.0);

        Move(VLerp(MoveLocation1,MoveLocation2,FInterpEaseInOut(0.0,1.0,MovePercent,2.0)) - Location);

        if (MovePercent == 1.0)
        {
            MovePercent = 0.0;

            V = MoveLocation1;
            MoveLocation1 = MoveLocation2;
            MoveLocation2 = V;
        }
    }
}

/**
 * Falls to ground with an initial impulse.
 */
function Fall()
{
    local Actor A;

    ClearTimer(NameOf(Fall));

    bFallen = true;

    if (FallParticles != none)
        WorldInfo.MyEmitterPool.SpawnEmitter(FallParticles,Location + StaticMeshComponent.Translation,Rotation);

    if (FallSound != none)
        PlaySound(FallSound,,,,Location + StaticMeshComponent.Translation);

    TriggerEventClass(class'SeqEvent_PlatformEvent',none,2);

    if (PhysicsMeshSlots.Length == 0)
    {
        bCollideWorld = true;

        SetPhysics(PHYS_Falling);
        Velocity.Z = WorldInfo.WorldGravityZ * 0.2;

        foreach TrackedActors(A)
            if (SGDKPlayerPawn(A) != none)
                SGDKPlayerPawn(A).bDoubleGravity = false;

        GotoState('Fallen');
    }
    else
    {
        bCollideWorld = false;
        CollisionComponent.SetBlockRigidBody(false);
        SetCollision(false,false);

        SpawnPhysicsMesh();
        SetHidden(true);

        AttachComponent(HiddenComponent);

        GotoState('Hidden');
    }
}

/**
 * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
 * @param Action  the related Kismet sequence action
 */
simulated function OnToggle(SeqAct_Toggle Action)
{
    if (Action.InputLinks[0].bHasImpulse)
        Reset();
    else
        if (Action.InputLinks[1].bHasImpulse)
        {
            if (bCanFall && !bFallen)
                Fall();
        }
        else
            if (!bFallen)
            {
                if (bCanFall)
                    Fall();
            }
            else
                Reset();
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    if (bCanMove)
    {
        MovePercent = default.MovePercent;

        SetLocation(InitialLocation);
    }

    if (bCanSink)
        StaticMeshComponent.SetTranslation(vect(0,0,1) * InitialZTranslation);

    if (bFallen)
    {
        bFallen = false;

        DetachComponent(HiddenComponent);

        SetLocation(InitialLocation);

        bCollideWorld = false;
        CollisionComponent.SetBlockRigidBody(true);
        SetCollision(true,true);

        SetPhysics(PHYS_Interpolating);
        SetHidden(false);

        TriggerEventClass(class'SeqEvent_PlatformEvent',none,4);
    }

    TrackedActors.Length = 0;

    GotoState('Idle');
}

/**
 * Spawns the fragments.
 */
function SpawnPhysicsMesh()
{
    local int i;
    local KActor PhysMesh;

    for (i = 0; i < PhysicsMeshSlots.Length; i++)
    {
        if (PhysicsMeshSlots[i].Rotation == rot(0,0,0))
            PhysMesh = Spawn(class'GameKActorSpawnableEffect',,,
                             Location + StaticMeshComponent.Translation + (PhysicsMeshSlots[i].Translation >> Rotation),
                             Rotation);
        else
            PhysMesh = Spawn(class'GameKActorSpawnableEffect',,,
                             Location + StaticMeshComponent.Translation + (PhysicsMeshSlots[i].Translation >> Rotation),
                             QuatToRotator(QuatProduct(QuatFromRotator(Rotation),
                                                       QuatFromRotator(PhysicsMeshSlots[i].Rotation))));

        PhysMesh.StaticMeshComponent.SetStaticMesh(PhysicsMeshSlots[i].Mesh);

        PhysMesh.SetDrawScale(PhysicsMeshSlots[i].Scale);
        PhysMesh.SetDrawScale3D(PhysicsMeshSlots[i].Scale3D);

        PhysMesh.StaticMeshComponent.SetRBLinearVelocity(vect(0,0,1) * (WorldInfo.WorldGravityZ * 0.25),false);

        PhysMesh.LifeSpan = PhysicsMeshLifeSpan;
        PhysMesh.PostBeginPlay();

        PhysMesh.StaticMeshComponent.WakeRigidBody();
    }
}


auto state Idle
{
    /**
     * Called when another actor is attached to this actor.
     * @param Other  the other actor that is attached
     */
    event Attach(Actor Other)
    {
        global.Attach(Other);

        TrackedActors.AddItem(Other);

        if (bCanFall)
            SetTimer(FallTime,false,NameOf(Fall));

        if (bCanSink && !bFallen)
            GotoState('Sinking');
    }

    /**
     * Called when another actor is detached from this actor.
     * @param Other  the other actor that is detached
     */
    event Detach(Actor Other)
    {
        global.Detach(Other);

        TrackedActors.RemoveItem(Other);
    }
}


state Sunk
{
    /**
     * Called when another actor is attached to this actor.
     * @param Other  the other actor that is attached
     */
    event Attach(Actor Other)
    {
        global.Attach(Other);

        if (TrackedActors.Find(Other) == INDEX_NONE)
            TrackedActors.AddItem(Other);
    }

    /**
     * Called when another actor is detached from this actor.
     * @param Other  the other actor that is detached
     */
    event Detach(Actor Other)
    {
        global.Detach(Other);

        TrackedActors.RemoveItem(Other);

        if (TrackedActors.Length == 0)
            GotoState('UnSinking');
    }
}


state Sinking extends Sunk
{
    event BeginState(name PreviousStateName)
    {
        if (PreviousStateName != 'Idle')
            SinkPercent = 0.0;
        else
            SinkPercent = -0.25;

        UnSinkZTranslation = StaticMeshComponent.Translation.Z;

        if (WorldInfo.WorldGravityZ < 0.0)
            SinkZTranslation = InitialZTranslation - SinkDistance;
        else
            SinkZTranslation = InitialZTranslation + SinkDistance;
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        global.Tick(DeltaTime);

        SinkPercent = FMin(SinkPercent + SinkSpeedFactor * DeltaTime,1.0);

        if (SinkPercent > 0.0)
        {
            StaticMeshComponent.SetTranslation(vect(0,0,1) *
                                               FInterpEaseOut(UnSinkZTranslation,SinkZTranslation,SinkPercent,2.0));

            if (SinkPercent == 1.0)
                GotoState('Sunk');
        }
    }
}


state UnSinking extends Idle
{
    event BeginState(name PreviousStateName)
    {
        SinkPercent = -0.5;
        SinkZTranslation = StaticMeshComponent.Translation.Z;
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        global.Tick(DeltaTime);

        SinkPercent = FMin(SinkPercent + SinkSpeedFactor * DeltaTime,1.0);

        if (SinkPercent > 0.0)
        {
            StaticMeshComponent.SetTranslation(vect(0,0,1) *
                                               FInterpEaseOut(SinkZTranslation,InitialZTranslation,SinkPercent,2.0));

            if (SinkPercent == 1.0)
                GotoState('Idle');
        }
    }
}


state Fallen
{
    /**
     * Called when the pawn collides with a blocking piece of world geometry.
     * @param HitNormal      the surface normal of the hit actor/level geometry
     * @param WallActor      the hit actor
     * @param WallComponent  the associated primitive component of the wall actor
     */
    event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
    {
        if (WorldInfo.WorldGravityZ > 0.0 && HitNormal dot (vect(0,0,-1) * WorldInfo.WorldGravityZ) > 0.0)
            Landed(HitNormal,WallActor);
    }

    /**
     * Called when the pawn lands on level geometry while falling.
     * @param HitNormal   the surface normal of the actor/level geometry landed on
     * @param FloorActor  the actor landed on
     */
    event Landed(vector HitNormal,Actor FloorActor)
    {
        if (FloorActor.bWorldGeometry)
        {
            if (LandParticles != none)
                WorldInfo.MyEmitterPool.SpawnEmitter(LandParticles,Location + StaticMeshComponent.Translation,Rotation);

            if (LandSound != none)
                PlaySound(LandSound);

            bCollideWorld = false;
            SetCollision(true,true);

            SetPhysics(PHYS_None);

            TriggerEventClass(class'SeqEvent_PlatformEvent',none,3);
        }
        else
            SetTimer(0.01,false,NameOf(Fall));
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
    }

    /**
     * Falls to ground with an initial impulse.
     */
    function Fall()
    {
        SetPhysics(PHYS_Falling);
        Velocity.Z = FClamp(WorldInfo.WorldGravityZ,-1.0,1.0) * -200.0;
    }

Begin:
    if (RespawnTime > 0.0)
    {
        Sleep(2.0);

Check:
        if (WorldInfo.TimeSeconds - LastRenderTime > 2.0)
        {
            ClearTimer(NameOf(Fall));

            bCollideWorld = false;
            CollisionComponent.SetBlockRigidBody(false);
            SetCollision(false,false);

            SetHidden(true);
            SetPhysics(PHYS_None);

            AttachComponent(HiddenComponent);

            if (bCanSink)
                StaticMeshComponent.SetTranslation(vect(0,0,1) * InitialZTranslation);

            SetLocation(InitialLocation);

            GotoState('Hidden');
        }
        else
        {
            Sleep(2.0);

            Goto('Check');
        }
    }
}


state Hidden
{
    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
    }

Begin:
    if (RespawnTime > 0.0)
    {
        Sleep(RespawnTime);

Check:
        if (WorldInfo.TimeSeconds - LastRenderTime > 0.5)
            Reset();
        else
        {
            Sleep(0.5);

            Goto('Check');
        }
    }
}


defaultproperties
{
    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.PlatformStaticMesh'
        BlockRigidBody=true
    End Object
    CollisionComponent=StaticMeshComponent0
    StaticMeshComponent=StaticMeshComponent0


    Begin Object Class=VisibilityBoxComponent Name=VisibilityComponent
    End Object
    HiddenComponent=VisibilityComponent


    SupportedEvents.Add(class'SeqEvent_PlatformEvent')


    bBlockActors=true     //Blocks other nonplayer actors.
    bCollideActors=true   //Collides with other actors.
    bCollideWorld=false   //Doesn't collide with the world.
    bStopOnEncroach=false //Completes movements that would leave it encroaching another actor.

    bCanFall=false
    bCanMove=false
    bCanSink=false
    FallTime=1.0
    MoveDirection=(X=0.0,Y=0.0,Z=1.0)
    MoveDistance=256.0
    MovePercent=0.5
    MoveSpeedFactor=0.5
    PhysicsMeshLifeSpan=5.0
    RespawnTime=0.0
    SinkDistance=16.0
    SinkSpeedFactor=2.0
}
