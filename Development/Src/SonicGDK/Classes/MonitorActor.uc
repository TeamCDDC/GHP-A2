//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Actor > SGDKActor > Actor
//
// Produces pickups when active and grants an item when touched.
// This class is the classic monitor found in most classic Sonic games, represents
// the visual object which can be broken.
// This type can be moved during gameplay and doesn't need a floor to work.
//================================================================================
class MonitorActor extends SGDKActor
    abstract
    ClassGroup(SGDK,Visible,Monitors)
    implements(DestroyableEntity);


                  /**If true, this monitor is destroyed.*/ var bool bPickupHidden;
                      /**The associated inventory class.*/ var() class<Inventory> InventoryType;
                      /**The intact monitor visual mesh.*/ var PrimitiveComponent PickupMesh;
/**Sound played while this actor is available to pickup.*/ var AudioComponent PickupReadySound;
  /**The force feedback played by the destroyed monitor.*/ var ForceFeedbackWaveform PickupWaveForm;
      /**Sound played when the pickup becomes available.*/ var SoundCue RespawnSound;

/**The intact monitor visual static mesh.*/ var() editconst StaticMeshComponent MonitorMesh;
      /**The monitor's light environment.*/ var() editconst DynamicLightEnvironmentComponent MonitorLightEnvironment;

            /**The destroyed monitor visual static mesh.*/ var() StaticMeshComponent DestroyedMesh;
/**The particle system shown with the destroyed monitor.*/ var() ParticleSystem DestroyedParticleSystem;
           /**The sound played by the destroyed monitor.*/ var() SoundCue DestroyedSound;

        /**If true, this monitor can fall to ground.*/ var() bool bCanFall;
/**If true, this monitor falls through other actors.*/ var() bool bFallThroughActors;
    /**If true, this monitor doesn't block movement.*/ var() bool bGhostCollision;
      /**Minimum speed used to bounce the destroyer.*/ var() float MinBounceSpeed;
                         /**Respawn after this time.*/ var() float RespawnTime;

/**If true, the monitor fell to ground.*/ var bool bFallen;
    /**Initial location of the monitor.*/ var vector InitialLocation;


/**
 * Called immediately before gameplay begins.
 */
event PreBeginPlay()
{
    InitializePickup();

    super.PreBeginPlay();
}

/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    if (PickupReadySound != none)
        PickupReadySound.Play();

    InitialLocation = Location;
}

/**
 * Called only once when collision with another blocking actor happens.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitNormal       the surface normal of this actor where the bump occurred
 */
event Bump(Actor Other,PrimitiveComponent OtherComponent,vector HitNormal)
{
    Touch(Other,OtherComponent,Location,HitNormal);
}

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
    if (Physics == PHYS_Falling)
    {
        if (!FloorActor.bWorldGeometry)
            SetTimer(0.01,false,NameOf(Fall));
        else
        {
            bCollideWorld = false;
            SetCollision(true,true);
            SetPhysics(PHYS_None);
        }
    }
}

/**
 * A player pawn just destroyed this monitor.
 * @param P  the player pawn involved in the destruction
 */
function DestroyedBy(SGDKPlayerPawn P)
{
    local vector V;
    local float PawnSpeed;
    local SGDKEmitter MonitorEmitter;

    if (!bGhostCollision)
    {
        if (!P.ShouldPassThrough(self))
        {
            V = vect(0,0,1) >> Rotation;
            PawnSpeed = P.GetVelocity() dot V;

            if (PawnSpeed > 0.0)
                V *= MinBounceSpeed;
            else
                V *= FMax(MinBounceSpeed,PawnSpeed * -0.7);

            P.Bounce(V,false,true,true,self,'Monitor');
        }
        else
            P.OverrideVelocity();
    }

    if (DestroyedParticleSystem != none)
    {
        MonitorEmitter = Spawn(class'SGDKEmitter',self,,Location,Rotation);
        MonitorEmitter.SetTemplate(DestroyedParticleSystem,true);
    }
}

/**
 * Falls to ground with an initial impulse.
 */
function Fall()
{
    bCollideWorld = true;
    bFallen = true;

    if (bFallThroughActors)
        SetCollision(false,true);

    SetPhysics(PHYS_Falling);
    Velocity.Z = FClamp(WorldInfo.WorldGravityZ,-1.0,1.0) * -200.0;
}

/**
 * Gets the location to where a Homing Dash special move must go.
 * @param APawn  the pawn that tries to destroy this object
 * @return       location of a vulnerable point
 */
function vector GetHomingLocation(SGDKPlayerPawn APawn)
{
    return (Location + (vect(0,0,50) >> Rotation));
}

/**
 * Gives an inventory object to a pawn.
 * @param P  the pawn that wants the pickup
 */
function GiveTo(Pawn P)
{
    SpawnCopyFor(P);
    PickedUpBy(P);
}

/**
 * Initializes the pickup data.
 */
simulated function InitializePickup()
{
}

/**
 * Can this object be destroyed by a certain pawn?
 * @param APawn  the pawn that tries to destroy this object
 * @return       true if this object is vulnerable to the pawn
 */
function bool IsDestroyableBy(SGDKPlayerPawn APawn)
{
    return false;
}

/**
 * Can this object be a target for Homing Dash special move?
 * @return  true if this object is a valid target for Homing Dash
 */
function bool IsHomingTarget()
{
    return false;
}

/**
 * A pawn has picked up the inventory object.
 * @param P  the pawn that grabbed the pickup
 */
function PickedUpBy(Pawn P)
{
    GotoState('Sleeping');

    TriggerEventClass(class'SeqEvent_PickupStatusChange',P,1);

    if (PlayerController(P.Controller) != none)
        PlayerController(P.Controller).ClientPlayForceFeedbackWaveform(PickupWaveForm);
}

/**
 * Re-checks to see if a touching pawn is no longer obstructed; delegated to states.
 */
function RecheckValidTouch();

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    if (bFallen)
    {
        bFallen = false;

        SetLocation(InitialLocation);

        bCollideWorld = false;
        SetCollision(true,true);
        SetPhysics(PHYS_None);
    }

    GotoState('Pickup');
}

/**
 * Shows respawn effects.
 */
function RespawnEffect()
{
}

/**
 * Hides pickup mesh and associated effects.
 */
function SetPickupHidden()
{
    bCanBeDamaged = false;

    PickupMesh.SetActorCollision(true,false);
    PickupMesh.SetBlockRigidBody(false);

    if (DestroyedMesh != none)
        DestroyedMesh.SetHidden(false);

    if (PickupReadySound != none)
        PickupReadySound.Stop();

    PickupMesh.SetHidden(true);

    bPickupHidden = true;
}

/**
 * Shows pickup mesh and associated effects.
 */
function SetPickupVisible()
{
    bPickupHidden = false;

    PickupMesh.SetHidden(false);

    if (PickupReadySound != none)
        PickupReadySound.Play();

    PickupMesh.SetActorCollision(true,!bGhostCollision);
    PickupMesh.SetBlockRigidBody(!bGhostCollision);

    if (DestroyedMesh != none)
        DestroyedMesh.SetHidden(true);

    bCanBeDamaged = true;
}

/**
 * Spawns an inventory item for a pawn.
 * @param P  the pawn which receives the inventory item
 */
function SpawnCopyFor(Pawn P)
{
    local Inventory Inv;

    if (DestroyedSound != none)
        P.PlaySound(DestroyedSound);

    P.MakeNoise(0.2);

    Inv = Spawn(InventoryType,self);

    if (Inv != none)
        MonitorInventory(Inv).NewOwner(P);
}

/**
 * Returns true if projectiles should call ProcessTouch() when they touch this actor.
 * @param P  the projectile involved in the touch
 * @return   true if the projectile should call ProcessTouch()
 */
simulated function bool StopsProjectile(Projectile P)
{
    return bCanBeDamaged;
}


//Intact pickup state; default state.
auto state Pickup
{
    event BeginState(name PreviousStateName)
    {
        SetPickupVisible();

        TriggerEventClass(class'SeqEvent_PickupStatusChange',none,0);
    }

    event EndState(name NextStateName)
    {
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
        local SGDKPlayerPawn P;

        P = SGDKPlayerPawn(Other);

        if (P != none)
        {
            if (P.Controller == none)
                SetTimer(0.2,false,NameOf(RecheckValidTouch));
            else
                if (bCanFall && !bGhostCollision && P.GetGravityDirection() dot HitNormal > 0.5)
                    Fall();
                else
                    if (P.CanPickupActor(self) && (bGhostCollision ||
                        (P.IsUsingMelee() && !ClassIsChildOf(P.GetMeleeDamageType(),P.InvincibleDamageType))))
                    {
                        DestroyedBy(P);

                        GiveTo(P);
                    }
        }
    }

    /**
     * Makes sure no pawn is already touching (while touch was disabled in sleep).
     */
    function CheckTouching()
    {
        local Pawn P;

        foreach TouchingActors(class'Pawn',P)
            Touch(P,none,Location,Normal(Location - P.Location));
    }

    /**
     * Can this object be destroyed by a certain pawn?
     * @param APawn  the pawn that tries to destroy this object
     * @return       true if this object is vulnerable to the pawn
     */
    function bool IsDestroyableBy(SGDKPlayerPawn APawn)
    {
        return APawn.IsUsingMelee();
    }

    /**
     * Can this object be a target for Homing Dash special move?
     * @return  true if this object is a valid target for Homing Dash
     */
    function bool IsHomingTarget()
    {
        return true;
    }

    /**
     * Re-checks to see if a touching pawn is no longer obstructed.
     */
    function RecheckValidTouch()
    {
        CheckTouching();
    }

Begin:
    CheckTouching();
}


//Destroyed state.
state Sleeping
{
    ignores Touch;

    event BeginState(name PreviousStateName)
    {
        SetPickupHidden();
    }

    event EndState(name NextStateName)
    {
    }

Begin:
    if (RespawnTime > 0.0)
    {
        Sleep(RespawnTime);

Respawn:
        if (WorldInfo.TimeSeconds - LastRenderTime > 0.25)
        {
            RespawnEffect();

            GotoState('Pickup');
        }
        else
        {
            Sleep(1.0);

            Goto('Respawn');
        }
    }
}


defaultproperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=PickupLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object
    MonitorLightEnvironment=PickupLightEnvironment
    Components.Add(PickupLightEnvironment)


    Begin Object Class=StaticMeshComponent Name=MonitorStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.MonitorIntactStaticMesh'
        LightEnvironment=PickupLightEnvironment
        bAllowApproximateOcclusion=false
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=false
        BlockActors=true
        BlockNonZeroExtent=true
        BlockRigidBody=true
        BlockZeroExtent=true
        CanBlockCamera=true
        CastShadow=true
        CollideActors=true
        MaxDrawDistance=9000.0
        Scale=1.1
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=-1.0)
    End Object
    CollisionComponent=MonitorStaticMesh
    MonitorMesh=MonitorStaticMesh
    PickupMesh=MonitorStaticMesh
    Components.Add(MonitorStaticMesh)


    Begin Object Class=StaticMeshComponent Name=MonitorStaticMeshB
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.MonitorDestroyedStaticMesh'
        LightEnvironment=PickupLightEnvironment
        bAllowApproximateOcclusion=false
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=false
        BlockActors=false
        BlockRigidBody=false
        CastShadow=true
        CollideActors=false
        HiddenEditor=true
        HiddenGame=true
        MaxDrawDistance=9000.0
        Scale=1.1
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=-1.0)
    End Object
    DestroyedMesh=MonitorStaticMeshB
    Components.Add(MonitorStaticMeshB)


    Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformPickup
        Samples[0]=(LeftAmplitude=80,RightAmplitude=30,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearIncreasing,Duration=0.2)
    End Object
    PickupWaveForm=ForceFeedbackWaveformPickup


    SupportedEvents.Add(class'SeqEvent_PickupStatusChange')


    bBlockActors=true          //Blocks other nonplayer actors.
    bCanBeDamaged=true         //It can take damage.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bEdShouldSnap=true         //It snaps to the grid in the editor.
    bMovable=true              //Actor can be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bNoEncroachCheck=true      //Doesn't do the overlap check when it moves.
    bPathColliding=true        //Blocks paths during AI path building in the editor. 
    bPushedByEncroachers=false //Whether encroachers can push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    bCanFall=false
    bFallThroughActors=false
    bGhostCollision=false
    DestroyedParticleSystem=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_GeneralExplosion'
    DestroyedSound=SoundCue'SonicGDKPackSounds.MonitorBreakSoundCue'
    MinBounceSpeed=500.0
    RespawnSound=SoundCue'A_Pickups.Generic.Cue.A_Pickups_Generic_ItemRespawn_Cue'
    RespawnTime=0.0
}
