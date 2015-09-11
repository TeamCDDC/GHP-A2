//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Simple Destroyable > UTSimpleDestroyable > DynamicSMActor > Actor
//
// SimpleDestroyable is the base class of all solid destroyable objects that you
// hit to destroy it.
//================================================================================
class SGDKSimpleDestroyable extends UTSimpleDestroyable
    ClassGroup(SGDK,Visible)
    implements(DestroyableEntity)
    placeable;


/**Invisible box component used to check for visibility.*/ var VisibilityBoxComponent HiddenComponent;

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
/**Fragments to create when destroyed.*/ var() array<TPhysMeshData> PhysicsMeshSlots;

       /**If true, this object is also vulnerable to types
                   of damage similar to the specified ones.*/ var() bool bAllowChildDamageType;
/**This object is only vulnerable to these types of damage.*/ var() array< class<DamageType> > DestroyedByDamageType<AllowAbstract>;

    /**If true, player always passes through this object.*/ var() bool bPlayerPassesThrough;
          /**If true, fragments use destroyer's velocity.*/ var() bool bUseDestroyerVelocity;
                          /**Stores destroyer's velocity.*/ var vector DestroyerVelocity;
       /**If non-zero, when destroyed the visuals of the
              game are paused during this amount of time.*/ var() float FramePauseTime;
            /**Last time a valid bump event has happened.*/ var float LastBumpTime;
/**Minimum frontal speed required to destroy this object.*/ var() float MinHitNormalSpeed;

                              /**Amount of hits.*/ var int Hits;
  /**Amount of hits needed to swap to MeshOnHit.*/ var() int HitsToSwapMesh;
 /**Amount of hits needed to destroy this actor.*/ var() int MaxHits;
/**Mesh to switch to when hit but not destroyed.*/ var() StaticMesh MeshOnHit;
                  /**Particles to play when hit.*/ var() ParticleSystem ParticlesOnHit;
                      /**Sound to play when hit.*/ var() SoundCue SoundOnHit;

         /**If true, it's destroyed by rigid body physics impacts.*/ var() bool bDestroyOnRigidImpact;
/**Minimum speed required to register a rigid body physics impact.*/ var() float MinRigidImpactSpeed;

/**If true, this object should be a valid target for Homing Dash.*/ var() bool bHomingDashTarget;
                   /**Minimum speed used to bounce the destroyer.*/ var() float MinBounceSpeed;
            /**Score bonus granted when this object is destroyed.*/ var() int ScoreBonus;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    if (bDestroyOnRigidImpact)
    {
        StaticMeshComponent.ScriptRigidBodyCollisionThreshold = MinRigidImpactSpeed;
        StaticMeshComponent.SetNotifyRigidBodyCollision(true);
    }

    HiddenComponent.BoxExtent = StaticMeshComponent.Bounds.BoxExtent * 1.5;
    HiddenComponent.SetTranslation(StaticMeshComponent.Bounds.Origin - Location);
    HiddenComponent.ForceUpdate(false);
}

/**
 * Called only once when collision with another blocking actor happens.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitNormal       the surface normal of this actor where the bump occurred
 */
event Bump(Actor Other,PrimitiveComponent OtherComponent,vector HitNormal)
{
    local SGDKPlayerPawn P;

    if (!bDestroyed && Pawn(Other) != none && WorldInfo.TimeSeconds - LastBumpTime > 0.05)
    {
        Instigator = Pawn(Other);
        P = SGDKPlayerPawn(Instigator);

        if (MinHitNormalSpeed == 0.0 || (P != none && P.GetVelocity() dot -HitNormal > MinHitNormalSpeed) ||
            (P == none && Instigator.Velocity dot -HitNormal > MinHitNormalSpeed))
        {
            LastBumpTime = WorldInfo.TimeSeconds;

            if (UDKVehicle(Instigator) == none)
            {
                if (bDestroyOnPlayerTouch)
                {
                    if (P != none)
                    {
                        super(DynamicSMActor).TakeDamage(1,P.Controller,P.Location,P.GetVelocity(),
                                                         class'UTDmgType_Encroached',,P);

                        if (bUseDestroyerVelocity)
                            DestroyerVelocity = P.GetVelocity();

                        P.OverrideVelocity();

                        GoBoom();

                        P.ReceiveScore(ScoreBonus,self);
                    }
                    else
                    {
                        super(DynamicSMActor).TakeDamage(1,Instigator.Controller,Instigator.Location,
                                                         Instigator.Velocity,class'UTDmgType_Encroached',,Instigator);

                        if (bUseDestroyerVelocity)
                            DestroyerVelocity = Instigator.Velocity;

                        GoBoom();
                    }
                }
                else
                    if (P != none && IsDestroyableBy(P))
                    {
                        super(DynamicSMActor).TakeDamage(1,P.Controller,P.Location,P.GetVelocity(),
                                                         P.GetMeleeDamageType(),,P);

                        if (bUseDestroyerVelocity)
                            DestroyerVelocity = P.GetVelocity();

                        if (!bPlayerPassesThrough && !P.ShouldPassThrough(self))
                            BouncePlayer(P,HitNormal);
                        else
                            P.OverrideVelocity();

                        GoBoom();

                        P.ReceiveScore(ScoreBonus,self);
                    }
            }
            else
                if (bDestroyOnVehicleTouch)
                {
                    super(DynamicSMActor).TakeDamage(1,Instigator.Controller,Instigator.Location,Instigator.Velocity,
                                                     UDKVehicle(Instigator).GetRanOverDamageType(),,Instigator);

                    if (bUseDestroyerVelocity)
                        DestroyerVelocity = Instigator.Velocity;

                    GoBoom();
                }
        }

        Instigator = none;
    }
}

/**
 * Called if another actor sets its new base to another actor and we were the old base before.
 * @param Other  the other actor that isn't attached any more
 */
event Detach(Actor Other)
{
    //Disabled.
}

/**
 * Called when this actor is involved in a rigid body physics collision.
 * @param HitComponent        component of this actor that collided
 * @param OtherComponent      the other component that collided
 * @param RigidCollisionData  information on the collision itself, including contact points
 * @param ContactIndex        the element in each ContactInfos' ContactVelocity and PhysMaterial arrays
 *                            that corresponds to this actor's HitComponent
 */
event RigidBodyCollision(PrimitiveComponent HitComponent,PrimitiveComponent OtherComponent,
                         const out CollisionImpactData RigidCollisionData,int ContactIndex)
{
    local vector V;

    if (!bDestroyed && bDestroyOnRigidImpact)
    {
        V = OtherComponent.Owner.Velocity;

        if (MinHitNormalSpeed == 0.0 || V dot RigidCollisionData.ContactInfos[0].ContactNormal > MinHitNormalSpeed)
        {
            if (bUseDestroyerVelocity)
                DestroyerVelocity = V;

            GoBoom();
        }
    }
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
simulated event TakeDamage(int DamageAmount,Controller EventInstigator,vector HitLocation,vector Momentum,
                           class<DamageType> DamageClass,optional TraceHitInfo HitInfo,optional Actor DamageCauser)
{
    super(DynamicSMActor).TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageClass,HitInfo,DamageCauser);

    if (!bDestroyed && bDestroyOnDamage && IsVulnerableTo(DamageClass))
    {
        if (bUseDestroyerVelocity)
            DestroyerVelocity = Momentum;

        GoBoom();
    }
}

/**
 * Bounces a player pawn.
 * @param P                the bounced player pawn
 * @param BounceDirection  the direction of the bounce impulse
 */
function BouncePlayer(SGDKPlayerPawn P,vector BounceDirection)
{
    if (!P.bReverseGravity)
        P.Bounce(BounceDirection * FMax(MinBounceSpeed,VSize(P.GetVelocity()) * 0.7),
                 BounceDirection.Z < P.WalkableFloorZ,false,true,self,'Destroyable');
    else
        P.Bounce(BounceDirection * FMax(MinBounceSpeed,VSize(P.GetVelocity()) * 0.7),
                 BounceDirection.Z < -P.WalkableFloorZ,false,true,self,'Destroyable');
}

/**
 * Used to countdown to respawn.
 */
simulated function CheckRespawn()
{
    TimeToRespawn -= 0.5;

    if (bDestroyed && TimeToRespawn <= 0.0 && WorldInfo.TimeSeconds - LastRenderTime > 0.5)
    {
        ClearTimer(NameOf(CheckRespawn));

        RespawnDestructible();
    }
}

/**
 * Gets the location to where a Homing Dash special move must go.
 * @param APawn  the pawn that tries to destroy this object
 * @return       location of a vulnerable point
 */
function vector GetHomingLocation(SGDKPlayerPawn APawn)
{
    return Location;
}

/**
 * Does the actual explosion.
 */
simulated function GoBoom()
{
    Hits++;

    if (Hits == MaxHits)
    {
        if (MeshOnDestroy != none)
            StaticMeshComponent.SetStaticMesh(MeshOnDestroy);
        else
        {
            SetCollision(false,false);
            CollisionComponent.SetBlockRigidBody(false);
            SetHidden(true);
        }

        if (ParticlesOnDestroy != none)
            WorldInfo.MyEmitterPool.SpawnEmitter(ParticlesOnDestroy,Location,Rotation);

        if (SoundOnDestroy != none)
            PlaySound(SoundOnDestroy);

        SpawnPhysicsMesh();

        bDestroyed = true;

        if (RespawnTime > 0.0)
        {
            AttachComponent(HiddenComponent);

            TimeToRespawn = RespawnTime;
            SetTimer(0.5,true,NameOf(CheckRespawn));
        }

        TriggerEventClass(class'SeqEvent_DestroyableEvent',Instigator,1);

        if (FramePauseTime > 0.0)
            SGDKGameInfo(WorldInfo.Game).FramePauseGame(FramePauseTime);
    }
    else
    {
        if (Hits == HitsToSwapMesh && MeshOnHit != none)
            StaticMeshComponent.SetStaticMesh(MeshOnHit);

        if (ParticlesOnHit != none)
            WorldInfo.MyEmitterPool.SpawnEmitter(ParticlesOnHit,Location,Rotation);

        if (SoundOnHit != none)
            PlaySound(SoundOnHit);

        TriggerEventClass(class'SeqEvent_DestroyableEvent',Instigator,0);
    }
}

/**
 * Can this object be destroyed by a certain pawn?
 * @param APawn  the pawn that tries to destroy this object
 * @return       true if this object is vulnerable to the pawn
 */
function bool IsDestroyableBy(SGDKPlayerPawn APawn)
{
    return (APawn.IsUsingMelee() && IsVulnerableTo(APawn.GetMeleeDamageType()));
}

/**
 * Can this object be a target for Homing Dash special move?
 * @return  true if this object is a valid target for Homing Dash
 */
function bool IsHomingTarget()
{
    return (bHomingDashTarget && !bDestroyed);
}

/**
 * Can this object be destroyed by a certain damage?
 * @param DamageClass  class describing the damage that is being done
 * @return             true if this object is vulnerable to the damage
 */
function bool IsVulnerableTo(class<DamageType> DamageClass)
{
    local int i;

    if (DestroyedByDamageType.Length == 0)
        return true;

    for (i = 0; i < DestroyedByDamageType.Length; i++)
        if (DestroyedByDamageType[i] == DamageClass ||
            (bAllowChildDamageType && ClassIsChildOf(DamageClass,DestroyedByDamageType[i])))
            return true;

    return false;
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
            if (!bDestroyed)
            {
                Hits = MaxHits - 1;

                GoBoom();
            }
        }
        else
            if (!bDestroyed)
            {
                Hits = MaxHits - 1;

                GoBoom();
            }
            else
                Reset();
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    if (bDestroyed || Hits != default.Hits)
    {
        ClearTimer(NameOf(CheckRespawn));

        RespawnDestructible();
    }
}

/**
 * Puts destructible back into pre-destroyed state.
 */
simulated function RespawnDestructible()
{
    DetachComponent(HiddenComponent);

    SetHidden(false);
    SetCollision(true,true);

    StaticMeshComponent.SetStaticMesh(RespawnStaticMesh);
    CollisionComponent.SetBlockRigidBody(true);

    bDestroyed = false;
    Hits = default.Hits;

    TriggerEventClass(class'SeqEvent_DestroyableEvent',none,2);
}

/**
 * Spawns the fragments.
 */
function SpawnPhysicsMesh()
{
    local int i;
    local KActor PhysMesh;

    if (PhysicsMeshSlots.Length == 0)
    {
        if (SpawnPhysMesh != none)
        {
            PhysMesh = Spawn(class'GameKActorSpawnableEffect',,,Location,Rotation);
            PhysMesh.StaticMeshComponent.SetStaticMesh(SpawnPhysMesh);

            WakePhysicsMesh(PhysMesh);
        }
    }
    else
    {
        for (i = 0; i < PhysicsMeshSlots.Length; i++)
        {
            if (PhysicsMeshSlots[i].Rotation == rot(0,0,0))
                PhysMesh = Spawn(class'GameKActorSpawnableEffect',,,
                                 Location + (PhysicsMeshSlots[i].Translation >> Rotation),Rotation);
            else
                PhysMesh = Spawn(class'GameKActorSpawnableEffect',,,
                                 Location + (PhysicsMeshSlots[i].Translation >> Rotation),
                                 QuatToRotator(QuatProduct(QuatFromRotator(Rotation),
                                                           QuatFromRotator(PhysicsMeshSlots[i].Rotation))));

            PhysMesh.StaticMeshComponent.SetStaticMesh(PhysicsMeshSlots[i].Mesh);

            PhysMesh.SetDrawScale(PhysicsMeshSlots[i].Scale);
            PhysMesh.SetDrawScale3D(PhysicsMeshSlots[i].Scale3D);

            WakePhysicsMesh(PhysMesh);
        }
    }
}

/**
 * Wakes the spawned fragments.
 */
function WakePhysicsMesh(KActor PhysMesh)
{
    if (!bUseDestroyerVelocity)
    {
        PhysMesh.StaticMeshComponent.SetRBLinearVelocity(SpawnPhysMeshLinearVel,false);
        PhysMesh.StaticMeshComponent.SetRBAngularVelocity(SpawnPhysMeshAngularVel,false);
    }
    else
    {
        PhysMesh.StaticMeshComponent.SetRBLinearVelocity(SpawnPhysMeshLinearVel + DestroyerVelocity +
                                                         VRand() * 100.0,false);
        PhysMesh.StaticMeshComponent.SetRBAngularVelocity(SpawnPhysMeshAngularVel + VRand() * 10.0,false);
    }

    PhysMesh.LifeSpan = SpawnPhysMeshLifeSpan;
    PhysMesh.PostBeginPlay();

    PhysMesh.StaticMeshComponent.WakeRigidBody();
}


defaultproperties
{
    Begin Object Name=MyLightEnvironment
        bDynamic=false
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=MyLightEnvironment


    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.MiniCubeStaticMesh'
        BlockActors=true
        BlockNonZeroExtent=true
        BlockRigidBody=true
        BlockZeroExtent=true
        CastShadow=true
        CollideActors=true
    End Object
    CollisionComponent=StaticMeshComponent0
    StaticMeshComponent=StaticMeshComponent0


    Begin Object Class=VisibilityBoxComponent Name=VisibilityComponent
    End Object
    HiddenComponent=VisibilityComponent


    SupportedEvents.Add(class'SeqEvent_DestroyableEvent')


    bBlockActors=true
    bCanBeDamaged=true
    bDestroyOnPlayerTouch=false
    bPathColliding=true
    BlockRigidBody=true
    RespawnTime=0.0
    SoundOnDestroy=SoundCue'SonicGDKPackSounds.DestroyWorldSoundCue'
    SpawnPhysMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.MiniCubeStaticMesh'
    SpawnPhysMeshLifeSpan=5.0

    bAllowChildDamageType=true
    bDestroyOnRigidImpact=false
    bHomingDashTarget=false
    bPlayerPassesThrough=false
    bUseDestroyerVelocity=true
    FramePauseTime=0.0
    Hits=0
    HitsToSwapMesh=0
    MaxHits=1
    MinBounceSpeed=500.0
    MinHitNormalSpeed=0.0
    MinRigidImpactSpeed=100.0
    ScoreBonus=100
}
