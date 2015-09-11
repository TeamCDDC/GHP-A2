//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Enemy Pawn > SGDKPawn > UTPawn > UDKPawn > GamePawn > Pawn > Actor
//
// The Pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
// This type belongs to enemies and is controlled by artificial intelligence.
//================================================================================
class SGDKEnemyPawn extends SGDKPawn
    implements(DestroyableEntity)
    placeable
    showcategories(Debug);


/**The associated collision cylinder.*/ var(Template) editconst CylinderComponent CollisionMesh;
            /**The pawn visible mesh.*/ var(Template) editconst SkeletalMeshComponent VisibleMesh;

   /**The default physics mode for this pawn.*/ var EPhysics DefaultPhysics;
/**The enemy spawner which created this pawn.*/ var EnemySpawnerInfo EnemySpawner;

struct TDamageZoneData
{
          /**If true, the damage zone is disabled.*/ var() bool bDisabled;
           /**Class describing the type of damage.*/ var() class<Damagetype> DamageClass<AllowAbstract>;
       /**Magnitude of the applied damage impulse.*/ var() float Impulse;
/**Radius of the sphere that encompasses the spot.*/ var() float Radius;
        /**Name of the socket that holds the spot.*/ var() name Socket;
         /**Sound played when damage is inflicted.*/ var() SoundCue Sound;

    structdefaultproperties
    {
        DamageClass=class'SGDKDmgType_EnemyMelee'
        Impulse=500.0
        Radius=32.0
    }
};
/**Array of damage spots that hurt other pawns.*/ var(Template) array<TDamageZoneData> DamageZones;

struct TShootSlotData
{
            /**If true, aim at enemy player pawn.*/ var() bool bAimAtEnemy;
/**Actor archetype used to create the projectile.*/ var() Actor ProjectileArchetype;
       /**Name of the socket that holds the slot.*/ var() name Socket;

    structdefaultproperties
    {
        ProjectileArchetype=GenericProjectile'SonicGDKPackArchetypes.GenericProjectileArchetype'
    }
};
/**Array of slots that define the way projectiles are shot.*/ var(Template) array<TShootSlotData> ShootSlots;

struct TWeakSpotData
{
                /**If true, the weak spot is disabled.*/ var() bool bDisabled;
/**Spot will offset from the socket using this vector.*/ var() vector Offset;
            /**Name of the socket that holds the spot.*/ var() name Socket;
};
/**Array of weak spots that mark possible targets.*/ var(Template) array<TWeakSpotData> WeakSpots;

     /**If true, this pawn doesn't block other actors.*/ var(Template,Misc) bool bGhostCollision;
 /**Visual effect created when this pawn is destroyed.*/ var(Template,Misc) ParticleSystem DyingParticleSystem;
          /**Sound played when this pawn is destroyed.*/ var(Template,Misc) SoundCue DyingSound;
     /**Energy bonus granted when this pawn is killed.*/ var(Template,Misc) float EnergyBonus;
        /**Amount of hits needed to destroy this pawn.*/ var(Template,Misc) byte Hits;
                /**Sound played when this pawn is hit.*/ var(Template,Misc) SoundCue HitSound;
/**This pawn is invulnerable to these types of damage.*/ var(Template,Misc) array< class<DamageType> > InvulnerableToDamageType<AllowAbstract>;
    /**Sound played when this pawn lands on a surface.*/ var(Template,Misc) SoundCue LandingSound;
         /**Last time a valid bump event has happened.*/ var float LastBumpTime;
          /**DamageType class to use for melee damage.*/ var(Template,Misc) class<Damagetype> MeleeDamageType<AllowAbstract>;
           /**Minimum speed used to bounce the killer.*/ var(Template,Misc) float MinBounceSpeed;
  /**The normal of the plane that constrains movement.*/ var vector PlaneConstraintNormal;
  /**The origin of the plane that constrains movement.*/ var vector PlaneConstraintOrigin;
      /**Score bonus granted when this pawn is killed.*/ var(Template,Misc) int ScoreBonus;

                                    /**Maximum movement speed value.*/ var(Template,Stats) float MovementSpeed;
/**Maximum distance at which a full noise can be heard by the enemy.*/ var(Template,Stats) float PawnHearingThreshold;
                /**Angular limit of peripheral vision for the enemy.*/ var(Template,Stats) float PawnPeripheralVision;
                          /**How often player visibility is checked.*/ var(Template,Stats) float PawnSightInterval;
                           /**Maximum seeing distance for the enemy.*/ var(Template,Stats) float PawnSightRadius;
               /**Maximum change in rotation per second for turning.*/ var(Template,Stats) rotator TurningSpeed;


/**
 * Called immediately before gameplay begins.
 */
simulated event PreBeginPlay()
{
    if (!IsTemplate())
    {
        EnemySpawner = EnemySpawnerInfo(Owner);

        if (EnemySpawner.PawnTemplate != none)
        {
            bDebug = EnemySpawner.PawnTemplate.bDebug;
            Tag = EnemySpawner.PawnTemplate.Tag;

            bGhostCollision = EnemySpawner.PawnTemplate.bGhostCollision;
            Hits = EnemySpawner.PawnTemplate.Hits;
            PlaneConstraintNormal = EnemySpawner.PlaneConstraintNormal;

            MovementSpeed = EnemySpawner.PawnTemplate.MovementSpeed;
            PawnHearingThreshold = EnemySpawner.PawnTemplate.PawnHearingThreshold;
            PawnPeripheralVision = EnemySpawner.PawnTemplate.PawnPeripheralVision;
            PawnSightInterval = EnemySpawner.PawnTemplate.PawnSightInterval;
            PawnSightRadius = EnemySpawner.PawnTemplate.PawnSightRadius;
            TurningSpeed = EnemySpawner.PawnTemplate.TurningSpeed;
        }

        AirSpeed = MovementSpeed;
        GroundSpeed = MovementSpeed;
        Health = Hits;
        WaterSpeed = MovementSpeed;
        HearingThreshold = PawnHearingThreshold;
        PeripheralVision = Cos(PawnPeripheralVision * DegToRad);
        PlaneConstraintNormal = Normal(PlaneConstraintNormal);
        PlaneConstraintOrigin = Location;
        RotationRate = TurningSpeed;
        SightRadius = PawnSightRadius;

        super.PreBeginPlay();
    }
    else
        InitialState = 'Template';
}

/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    local SGDKBotController Brain;

    if (!IsTemplate())
    {
        super.PostBeginPlay();

        SetRotation(EnemySpawner.Rotation);

        if (bGhostCollision)
            SetCollision(true,false);

        if (Controller == none)
            SpawnDefaultController();

        if (Controller != none)
        {
            Brain = SGDKBotController(Controller);

            Brain.bChasePlayers = EnemySpawner.bChasePlayers;
            Brain.bHarshPatrolReturn = EnemySpawner.bHarshPatrolReturn;
            Brain.bPatrolIdleTurning = EnemySpawner.bPatrolIdleTurning;
            Brain.HearingThreshold = HearingThreshold;
            Brain.LoseEnemyCheckTime = EnemySpawner.LoseEnemyCheckTime;
            Brain.SightCounterInterval = PawnSightInterval;
        }

        if (EnemySpawner.PawnTemplate != none)
        {
            SetCollisionSize(EnemySpawner.PawnTemplate.GetCollisionRadius() *
                             EnemySpawner.PawnTemplate.CylinderComponent.Scale,
                             EnemySpawner.PawnTemplate.GetCollisionHeight() *
                             EnemySpawner.PawnTemplate.CylinderComponent.Scale);
            CylinderComponent.SetTranslation(vect(0,0,1) * (EnemySpawner.PawnTemplate.CylinderComponent.Translation.Z -
                                             EnemySpawner.PawnTemplate.PrePivot.Z));

            BaseTranslationOffset = EnemySpawner.PawnTemplate.Mesh.Translation.Z - EnemySpawner.PawnTemplate.PrePivot.Z;
            CrouchTranslationOffset = BaseTranslationOffset + GetCollisionHeight() - CrouchHeight;
            DefaultMeshScale = EnemySpawner.PawnTemplate.Mesh.Scale * EnemySpawner.PawnTemplate.DrawScale;

            Mesh.AnimSets = EnemySpawner.PawnTemplate.Mesh.AnimSets;
            Mesh.SetAnimTreeTemplate(EnemySpawner.PawnTemplate.Mesh.AnimTreeTemplate);

            Mesh.SetSkeletalMesh(EnemySpawner.PawnTemplate.Mesh.SkeletalMesh);

            Mesh.SetScale(DefaultMeshScale);

            Mesh.SetPhysicsAsset(EnemySpawner.PawnTemplate.Mesh.PhysicsAsset,true);

            DamageZones = EnemySpawner.PawnTemplate.DamageZones;
            DyingParticleSystem = EnemySpawner.PawnTemplate.DyingParticleSystem;
            DyingSound = EnemySpawner.PawnTemplate.DyingSound;
            EnergyBonus = EnemySpawner.PawnTemplate.EnergyBonus;
            HitSound = EnemySpawner.PawnTemplate.HitSound;
            InvulnerableToDamageType = EnemySpawner.PawnTemplate.InvulnerableToDamageType;
            LandingSound = EnemySpawner.PawnTemplate.LandingSound;
            MeleeDamageType = EnemySpawner.PawnTemplate.MeleeDamageType;
            MinBounceSpeed = EnemySpawner.PawnTemplate.MinBounceSpeed;
            ScoreBonus = EnemySpawner.PawnTemplate.ScoreBonus;
            ShootSlots = EnemySpawner.PawnTemplate.ShootSlots;
            WeakSpots = EnemySpawner.PawnTemplate.WeakSpots;
        }

        VerifyBodyMaterialInstance();
    }
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
    local vector EndPoint,StartPoint,V,SocketLocation;
    local int i;
    local float PawnSpeed;

    P = SGDKPlayerPawn(Other);

    if (Health > 0 && P != none && WorldInfo.TimeSeconds - LastBumpTime > 0.05)
    {
        LastBumpTime = WorldInfo.TimeSeconds;

        if (DamageZones.Length > 0)
        {
            V = vect(0,0,1) * P.GetCollisionHeight();
            EndPoint = P.Location + V;
            StartPoint = P.Location - V;

            for (i = 0; i < DamageZones.Length; i++)
                if (!DamageZones[i].bDisabled && !P.IsInvulnerable(DamageZones[i].DamageClass) &&
                    Mesh.GetSocketWorldLocationAndRotation(DamageZones[i].Socket,SocketLocation))
                {
                    V = EndPoint - StartPoint;
                    V = VLerp(StartPoint,EndPoint,FClamp(((SocketLocation - StartPoint) dot V) / VSizeSq(V),0.0,1.0));

                    if (VSizeSq(V - SocketLocation) < Square(DamageZones[i].Radius + P.GetCollisionRadius()))
                    {
                        V = Normal((P.Location - Location) * vect(1,1,0)) * DamageZones[i].Impulse;
                        V += P.GetGravityDirection() * -DamageZones[i].Impulse;

                        P.TakeDamage(1,Controller,Location,V,DamageZones[i].DamageClass,,self);

                        if (DamageZones[i].Sound != none)
                            P.PlaySound(DamageZones[i].Sound);

                        if (bGhostCollision && P.LastDamageTime != WorldInfo.TimeSeconds)
                            P.Bounce(Normal(P.Location - Location) * DamageZones[i].Impulse,true,false,false,self,'Enemy');

                        return;
                    }
                }
        }

        if (IsDestroyableBy(P))
        {
            P.HurtPawn(self);

            if (Health < 1)
            {
                if (!P.ShouldPassThrough(self))
                {
                    V = P.GetGravityDirection() * -1;
                    PawnSpeed = P.GetVelocity() dot V;

                    if (PawnSpeed > 0.0)
                        V *= MinBounceSpeed;
                    else
                        V *= FMax(MinBounceSpeed,PawnSpeed * -0.7);

                    P.Bounce(V,false,true,true,self,'Enemy');
                }
                else
                    P.OverrideVelocity();
            }
            else
                P.Bounce(Normal(P.Location - Location) * MinBounceSpeed,true,false,false,self,'Enemy');
        }
        else
        {
            V = Normal((P.Location - Location) * vect(1,1,0)) * MinBounceSpeed;
            V += P.GetGravityDirection() * -MinBounceSpeed;

            P.TakeDamage(1,Controller,Location,V,MeleeDamageType,,self);

            if (bGhostCollision && P.LastDamageTime != WorldInfo.TimeSeconds)
                P.Bounce(Normal(P.Location - Location) * MinBounceSpeed,true,false,false,self,'Enemy');
        }
    }
}

/**
 * Called when the pawn lands on level geometry while falling.
 * @param HitNormal   the surface normal of the actor/level geometry landed on
 * @param FloorActor  the actor landed on
 */
event Landed(vector HitNormal,Actor FloorActor)
{
    if (Health > 0)
        PlayLanded(Velocity.Z);

    LastHitBy = none;

    if (Abs(Velocity.Z) > 200.0)
    {
        OldZ = Location.Z;
        bJustLanded = bUpdateEyeHeight && Controller != none && Controller.LandingShake();
    }

    bDodging = false;
    bReadyToDoubleJump = false;
    AirControl = DefaultAirControl;
    MultiJumpRemaining = MaxMultiJump;

    SGDKBotController(Controller).ImpactVelocity = vect(0,0,0);

    PlayLandingSound();

    SetBaseEyeheight();
}

/**
 * Called for encroaching actors which successfully moved the other actor out of the way.
 */
event RanInto(Actor Other)
{
    Bump(Other,none,vect(0,0,0));
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
    local int ActualDamage,i;
    local Controller Killer;
    local SeqEvent_TakeDamage DamageEvent;

    if (Health > 0)
    {
        if (AccumulationTime != WorldInfo.TimeSeconds)
        {
            AccumulateDamage = 0.0;
            AccumulationTime = WorldInfo.TimeSeconds;
        }

        DamageAmount = Max(0,DamageAmount);

        if (DamageClass == none)
            DamageClass = class'DamageType';

        if (HitLocation == vect(0,0,0))
            HitLocation = Location;

        if (DrivenVehicle != none)
            DrivenVehicle.AdjustDriverDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageClass);

        ActualDamage = DamageAmount;

        AdjustDamage(ActualDamage,Momentum,EventInstigator,HitLocation,DamageClass,HitInfo,DamageCauser);

        if (ActualDamage > 0)
        {
            //Search for any damage events.
            for (i = 0; i < GeneratedEvents.Length; i++)
            {
                DamageEvent = SeqEvent_TakeDamage(GeneratedEvents[i]);

                if (DamageEvent != none)
                    //Notify the event of the damage received.
                    DamageEvent.HandleDamage(self,EventInstigator,DamageClass,ActualDamage);
            }

            Health -= ActualDamage;

            if (Health > 0)
            {
                HandleMomentum(Momentum,HitLocation,DamageClass,HitInfo);
                NotifyTakeHit(EventInstigator,HitLocation,ActualDamage,DamageClass,Momentum,DamageCauser);

                if (DrivenVehicle != none)
                    DrivenVehicle.NotifyDriverTakeHit(EventInstigator,HitLocation,ActualDamage,DamageClass,Momentum);

                if (EventInstigator != none && EventInstigator != Controller)
                    LastHitBy = EventInstigator;

                if (WorldInfo.TimeSeconds - LastPainSound > MinTimeBetweenPainSounds)
                {
                    LastPainSound = WorldInfo.TimeSeconds;

                    if (HitSound != none)
                        PlaySound(HitSound,false,true);
                }
            }
            else
            {
                Killer = SetKillInstigator(EventInstigator,DamageClass);

                if (PhysicsVolume.bDestructive && PhysicsVolume.bWaterVolume &&
                    WaterVolume(PhysicsVolume).ExitActor != none)
                    Spawn(WaterVolume(PhysicsVolume).ExitActor);

                TearOffMomentum = Momentum;

                Died(Killer,DamageClass,HitLocation);
            }

            LastPainTime = WorldInfo.TimeSeconds;

            MakeNoise(1.0);

            AccumulateDamage += ActualDamage;
        }
    }
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (!IsZero(PlaneConstraintNormal))
    {
        if (!IsZero(Velocity))
            Velocity = Velocity - PlaneConstraintNormal * (Velocity dot PlaneConstraintNormal);

        SetLocation(Location - PlaneConstraintNormal * ((Location - PlaneConstraintOrigin) dot PlaneConstraintNormal));
    }

    if (bDebug)
    {
        DrawDebugCone(Location,vector(Rotation),250.0,PawnPeripheralVision * DegToRad,
                      PawnPeripheralVision * DegToRad,16,MakeColor(255,0,0),false);
        DrawDebugSphere(Location,SightRadius,16,0,255,0,false);
    }
}

/**
 * Called when collision with another actor happens; also called every tick that the collision still occurs.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitLocation     the world location where the touch occurred
 * @param HitNormal       the surface normal of this actor where the touch occurred
 */
event Touch(Actor Other,PrimitiveComponent OtherComponent,vector HitLocation,vector HitNormal)
{
    Bump(Other,OtherComponent,HitNormal);

    super.Touch(Other,OtherComponent,HitLocation,HitNormal);
}

/**
 * Adjusts damage based on inventory and other attributes.
 * @param DamageAmount     the base damage to apply; return -1 if this pawn is invulnerable
 * @param Momentum         force/impulse caused by this hit
 * @param EventInstigator  the controller responsible for the damage
 * @param HitLocation      world location where the hit occurred
 * @param DamageClass      class describing the damage that was done
 * @param HitInfo          additional info about where the hit occurred
 * @param DamageCauser     the actor that directly caused the damage
 */
function AdjustDamage(out int DamageAmount,out vector Momentum,Controller EventInstigator,vector HitLocation,
                      class<DamageType> DamageClass,TraceHitInfo HitInfo,Actor DamageCauser)
{
    if (!IsVulnerableTo(DamageClass))
        DamageAmount = 0;

    super.AdjustDamage(DamageAmount,Momentum,EventInstigator,HitLocation,DamageClass,HitInfo,DamageCauser);
}

/**
 * Gets the location to where a Homing Dash special move must go.
 * @param APawn  the pawn that tries to destroy this object
 * @return       location of a vulnerable point
 */
function vector GetHomingLocation(SGDKPlayerPawn APawn)
{
    local vector SocketLocation,V;
    local int i;
    local float Dist,ChosenDist;

    if (WeakSpots.Length == 0)
        V = Location;
    else
        if (WeakSpots.Length == 1)
        {
            if (!WeakSpots[0].bDisabled && Mesh.GetSocketWorldLocationAndRotation(WeakSpots[0].Socket,SocketLocation))
                V = SocketLocation + WeakSpots[0].Offset;
            else
                V = Location;
        }
        else
        {
            ChosenDist = 999999999.0;

            for (i = 0; i < WeakSpots.Length; i++)
                if (!WeakSpots[i].bDisabled && Mesh.GetSocketWorldLocationAndRotation(WeakSpots[i].Socket,SocketLocation))
                {
                    SocketLocation += WeakSpots[i].Offset;

                    Dist = VSizeSq(APawn.Location - SocketLocation);

                    if (Dist < ChosenDist)
                    {
                        ChosenDist = Dist;
                        V = SocketLocation;
                    }
                }

            if (ChosenDist == 999999999.0)
                V = Location;
        }

    return V;
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
    return (Health > 0 && !bDeleteMe);
}

/**
 * Is seeing the enemy player pawn?
 * @return  true if seeing an enemy player pawn
 */
function bool IsSeeingEnemy()
{
    return (Controller != none && SGDKBotController(Controller).bEnemyIsVisible);
}

/**
 * Is this pawn vulnerable to a certain damage?
 * @param DamageClass  class describing the damage that is being done
 * @return             true if this pawn is vulnerable to the damage
 */
function bool IsVulnerableTo(class<DamageType> DamageClass)
{
    return (InvulnerableToDamageType.Find(DamageClass) == INDEX_NONE);
}

/**
 * Called when the enemy player pawn escapes.
 * @param Enemy  the enemy pawn
 */
function LostEnemy(Pawn Enemy)
{
    TriggerEventClass(class'SeqEvent_EnemySeePlayer',self,3);
}

/**
 * Called when the enemy player pawn is discovered.
 * @param Enemy  the enemy pawn
 */
function NoticedEnemy(Pawn Enemy)
{
    TriggerEventClass(class'SeqEvent_EnemySeePlayer',self,0);
}

/**
 * Function handler for SeqAct_ToggleEnemyData Kismet sequence action.
 * @param Action  the related Kismet sequence action
 */
function OnToggleEnemyData(SeqAct_ToggleEnemyData Action)
{
    if (Action.InputLinks[0].bHasImpulse)
    {
        if (Action.bDamageZone && Action.Index < DamageZones.Length)
            DamageZones[Action.Index].bDisabled = false;

        if (Action.bWeakSpot && Action.Index < WeakSpots.Length)
            WeakSpots[Action.Index].bDisabled = false;
    }
    else
        if (Action.InputLinks[1].bHasImpulse)
        {
            if (Action.bDamageZone && Action.Index < DamageZones.Length)
                DamageZones[Action.Index].bDisabled = true;

            if (Action.bWeakSpot && Action.Index < WeakSpots.Length)
                WeakSpots[Action.Index].bDisabled = true;
        }
        else
            if (Action.InputLinks[2].bHasImpulse)
            {
                if (Action.bDamageZone && Action.Index < DamageZones.Length)
                    DamageZones[Action.Index].bDisabled = !DamageZones[Action.Index].bDisabled;

                if (Action.bWeakSpot && Action.Index < WeakSpots.Length)
                    WeakSpots[Action.Index].bDisabled = !WeakSpots[Action.Index].bDisabled;
            }
}

/**
 * Spawns all dying effects.
 * @param DamageClass  class describing the damage that was done
 * @param HitLocation  world location where the hit occurred
 */
simulated function PlayDying(class<DamageType> DamageClass,vector HitLocation)
{
    local SGDKEmitter DyingEmitter;

    if (DyingSound != none)
        PlaySound(DyingSound,false,true,false);

    if (DyingParticleSystem != none)
    {
        DyingEmitter = Spawn(class'SGDKEmitter',self,,Location,Rotation);
        DyingEmitter.SetTemplate(DyingParticleSystem,true);
    }

    Destroy();
}

/**
 * Plays a landing sound.
 */
function PlayLandingSound()
{
    //Don't play landing sound while spawning.
    if (LandingSound != none && WorldInfo.TimeSeconds - LastStartTime > 1.0)
    {
        PlaySound(LandingSound);
    }
}

/**
 * Called before this pawn is teleported.
 * @param InTeleporter  the first teleporter object involved in teleportation
 * @return              false if teleportation is allowed
 */
function bool PreTeleport(Teleporter InTeleporter)
{
    return true;
}

/**
 * Called when a patrol point is reached.
 * @param PatrolPoint  reached patrol point
 */
function ReachedPatrolPoint(NavigationPoint PatrolPoint)
{
    TriggerEventClass(class'SeqEvent_ReachedPatrolPoint',self,0);
}

/**
 * Called while seeing/chasing the enemy player pawn.
 * @param Enemy     the enemy pawn
 * @param bVisible  true if the enemy is visible
 */
function SeeingEnemy(Pawn Enemy,bool bVisible)
{
    if (!bVisible)
        TriggerEventClass(class'SeqEvent_EnemySeePlayer',self,2);
    else
        TriggerEventClass(class'SeqEvent_EnemySeePlayer',self,1);
}

/**
 * Sets various basic properties for this pawn based on the character class metadata.
 * @param FamilyClass  structure which has information about a particular character
 */
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> FamilyClass)
{
    //Disabled.
}

/**
 * Sets the initial physics correctly.
 */
function SetMovementPhysics()
{
    if (DefaultPhysics == PHYS_Walking)
        SetPhysics(PHYS_Falling);
    else
        if (DefaultPhysics == PHYS_Swimming)
        {
            if (!PhysicsVolume.bWaterVolume)
                SetPhysics(PHYS_Falling);
            else
                SetPhysics(PHYS_Swimming);
        }
        else
        {
            if (DefaultPhysics == PHYS_Flying)
                bCanFly = true;

            SetPhysics(DefaultPhysics);
        }
}

/**
 * Shoots a created projectile.
 * @param SlotIndex  index of the shoot slot to use as reference
 */
function Shoot(int SlotIndex)
{
    local vector ProjectileLocation;
    local rotator ProjectileRotation;

    if (SlotIndex < ShootSlots.Length)
    {
        if (ShootSlots[SlotIndex].Socket == '' ||
            !Mesh.GetSocketWorldLocationAndRotation(ShootSlots[SlotIndex].Socket,ProjectileLocation,ProjectileRotation))
        {
            ProjectileLocation = Location;
            ProjectileRotation = Rotation;
        }

        if (ShootSlots[SlotIndex].bAimAtEnemy && Controller != none && Controller.Enemy != none)
            ProjectileRotation = rotator(Controller.Enemy.Location - ProjectileLocation);

        Spawn(ShootSlots[SlotIndex].ProjectileArchetype.Class,self,,ProjectileLocation,
              ProjectileRotation,ShootSlots[SlotIndex].ProjectileArchetype);
    }
}


defaultproperties
{
    Begin Object Name=WPawnSkeletalMeshComponent
        AnimSets[0]=AnimSet'SonicGDKPackSkeletalMeshes.Animation.BoxBadnikAnimSet'
        AnimTreeTemplate=AnimTree'SonicGDKPackSkeletalMeshes.Animation.BoxBadnikAnimTree'
        PhysicsAsset=PhysicsAsset'SonicGDKPackSkeletalMeshes.PhysicsAssets.BoxBadnikPhysicsAsset'
        SkeletalMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.BoxBadnikSkeletalMesh'
        Scale=0.5 //Scale to half size.
    End Object
    Mesh=WPawnSkeletalMeshComponent
    VisibleMesh=WPawnSkeletalMeshComponent


    Begin Object Name=CollisionCylinder
        CollisionHeight=25.0 //This value is half the total height for the cylinder.
        CollisionRadius=30.0 //This value is the radius for cylinder.
    End Object
    CollisionMesh=CollisionCylinder
    CylinderComponent=CollisionCylinder


    SupportedEvents.Add(class'SeqEvent_EnemySeePlayer')
    SupportedEvents.Add(class'SeqEvent_ReachedPatrolPoint')


    bCanBeBaseForPawns=true                         //Allows other pawns to be based on this pawn.
    bCanCrouch=false                                //Can't crouch.
    bCanDoubleJump=false                            //Can't double-jump.
    bCanFly=false                                   //Can't fly.
    bCanJump=false                                  //Can't jump.
    bCanPickupInventory=false                       //Can't pick up any items.
    bCanStrafe=false                                //Can't strafe.
    bCanSwim=false                                  //Can't swim.
    bCanWalk=false                                  //Can't walk.
    bCanWalkOffLedges=false                         //Can't fall off ledges.
    bEnableFootPlacement=false                      //Disables crappy foot placement IK system.
    bJumpCapable=false                              //Can't jump.
    AccelRate=999999.0                              //Acceleration rate to reach maximum speed.
    AirSpeed=250.0                                  //Maximum flying speed.
    AllowedYawError=0                               //No difference is allowed between Rotation.Yaw and DesiredRotation.Yaw.
    ControllerClass=class'SGDKBotController'        //Class to use when this pawn is controlled by AI.
    GroundSpeed=250.0                               //Maximum walking speed.
    MaxMultiJump=0                                  //Can't jump in the middle of a jump.
    RotationRate=(Pitch=16384,Yaw=32768,Roll=16384) //Maximum change in rotation per second for turning.
    SwimmingZOffset=0.0                             //No translation is applied to the attached skeletal mesh while swimming.
    UnderWaterTime=999999.0                         //How much time this pawn can stand in water without air (in seconds).
    WaterSpeed=250.0                                //Maximum swimming speed.

    WeakSpots.Add((bDisabled=false,Offset=(X=0,Y=0,Z=40),Socket=Main))

    bGhostCollision=false
    DyingParticleSystem=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_GeneralExplosion'
    DyingSound=SoundCue'SonicGDKPackSounds.EnemyExplosionSoundCue'
    EnergyBonus=5.0
    Hits=1
    MeleeDamageType=class'SGDKDmgType_EnemyMelee'
    MinBounceSpeed=500.0
    ScoreBonus=100

    MovementSpeed=250.0
    PawnHearingThreshold=1024.0
    PawnPeripheralVision=75.0
    PawnSightInterval=0.1
    PawnSightRadius=1024.0
    TurningSpeed=(Pitch=16384,Yaw=32768,Roll=16384)
}
