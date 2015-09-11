//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Ring Actor > SGDKActor > Actor
//
// The Ring Actor is the classic ring item found in all Sonic games.
// It doesn't extend from a subclass of PickupFactory because that counts as a
// NavigationPoint and placing a lot of them makes bot paths too complex and takes
// ages when rebuilding paths of maps.
//================================================================================
class RingActor extends SGDKActor
    implements(MagnetizableEntity)
    placeable;


      /**The ring visual static mesh.*/ var() editconst StaticMeshComponent RingMesh;
     /**The ring's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;
/**The associated collision cylinder.*/ var() editconst CylinderComponent CylinderComponent;

/**Flash of light shown when picked up.*/ var() class<UDKExplosionLight> PickupLightClass;
        /**Sound played when picked up.*/ var() SoundCue PickupSound;
        /**The particle visual effects.*/ var() ParticleSystem RingParticleSystem;

/**If true, can be used as a path for Light Dash move.*/ var() bool bLightDash;
           /**If false, can't be attracted/magnetized.*/ var() bool bMagnetic;
                          /**Amount of granted energy.*/ var() float EnergyAmount;
                /**The magnetized ring class to spawn.*/ var() class<Actor> MagneticRingClass;
                           /**Amount of granted rings.*/ var() byte RingsAmount;

/**Saves the first state of bHidden.*/ var bool bOldHidden;
        /**Initial rotation applied.*/ var rotator InitialRotation;


/**
 * Called immediately before gameplay begins.
 */
event PreBeginPlay()
{
    //Save first state of bHidden.
    bOldHidden = bHidden;

    super.PreBeginPlay();
}

/**
 * Called after PostBeginPlay to set the initial state.
 */
simulated event SetInitialState()
{
    if (!bHidden)
        InitialState = 'Pickup';
    else
        InitialState = 'Sleeping';

    super.SetInitialState();
}

/**
 * Called when the actor falls out of the world 'safely' (below KillZ and such).
 * @param DamageClass  the type of damage
 */
simulated event FellOutOfWorld(class<DamageType> DamageClass)
{
}

/**
 * Called when the actor is outside the hard limit on world bounds.
 * @note physics and collision are automatically turned off after calling this function
 */
simulated event OutsideWorldBounds()
{
}

/**
 * Pawn picks up this ring actor.
 * @param P  the pawn
 */
function GrantRings(SGDKPlayerPawn P)
{
    local SGDKPlayerController PC;

    //Give rings.
    P.GiveHealth(RingsAmount,P.SuperHealthMax);

    //Give energy.
    P.ReceiveEnergy(EnergyAmount);

    //Alerts nearby AI.
    P.MakeNoise(0.1);

    if (PickupLightClass != none && !WorldInfo.bDropDetail)
        //Shows a flash of light.
        UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(PickupLightClass,Location);

    if (PickupSound != none)
        //Plays ring sound.
        P.PlaySound(PickupSound);

    //Updates the HUD.
    PC = SGDKPlayerController(P.Controller);
    if (PC != none)
    {
        PC.GetHud().LastHealthPickupTime = WorldInfo.TimeSeconds;
        PC.GetHud().LastPickupTime = WorldInfo.TimeSeconds;
    }

    //Triggers an event.
    TriggerEventClass(class'SeqEvent_PickupStatusChange',P,1);
}

/**
 * Tries to magnetize this object; delegated to states.
 * @param AnActor  the actor that tries to magnetize this object
 */
function Magnetize(Actor AnActor)
{
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    if (bHidden != bOldHidden)
    {
        if (!bOldHidden)
            GotoState('Pickup');
        else
            GotoState('Sleeping');
    }
}


//The ring is visible and standing still.
state Pickup
{
    event BeginState(name PreviousStateName)
    {
        local rotator R;

        //Randomizes initial rotation.
        R = default.InitialRotation;
        R.Yaw = Rand(4) * 16384;
        SetRotation(Normalize(R));

        //Randomizes yaw rotation rate.
        RotationRate.Yaw = default.RotationRate.Yaw * RandRange(0.75,1.33);

        //Triggers an event.
        TriggerEventClass(class'SeqEvent_PickupStatusChange',none,0);
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
        local SGDKEmitter RingEmitter;

        P = SGDKPlayerPawn(Other);

        //If valid touched by a player pawn, let him pick this up.
        if (P != none && ValidTouch(P))
        {
            GrantRings(P);

            if (RingParticleSystem != none)
            {
                //Display ring particle effects.
                RingEmitter = Spawn(class'SGDKEmitter',self,,Location,Rotation);
                RingEmitter.SetTemplate(RingParticleSystem,true);
            }

            GotoState('Sleeping');
        }
    }

    /**
     * Re-checks valid touches for all touching pawns.
     */
    function CheckTouching()
    {
        local Pawn P;

        foreach TouchingActors(class'Pawn',P)
            Touch(P,none,Location,Normal(Location - P.Location));
    }

    /**
     * Tries to magnetize this object.
     * @param AnActor  the actor that tries to magnetize this object
     */
    function Magnetize(Actor AnActor)
    {
        if (bMagnetic)
        {
            //Hide ring actor.
            GotoState('Sleeping');

            //Create ring projectile.
            Spawn(MagneticRingClass,AnActor,,Location,Rotation);
        }
    }

    /**
     * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
     * @param Action  the related Kismet sequence action
     */
    function OnToggle(SeqAct_Toggle Action)
    {
        if (Action.InputLinks[1].bHasImpulse || Action.InputLinks[2].bHasImpulse)
            //Hide ring actor.
            GotoState('Sleeping');
    }

    /**
     * Validates touch.
     * @param P  the player pawn that tries to pick up this object
     * @return   true if this object can be picked up
     */
    function bool ValidTouch(SGDKPlayerPawn P)
    {
        if (!P.CanPickupActor(self))
            return false;
        else
            if (P.Controller == none)
            {
                //Re-check later in case the pawn would have a controller shortly.
                SetTimer(0.2,false,NameOf(CheckTouching));

                return false;
            }

        return true;
    }
}


//Ring is invisible and standing still.
state Sleeping
{
    ignores Touch; //Ignores touch calls.

    event BeginState(name PreviousStateName)
    {
        //Hides ring model.
        SetHidden(true);
    }

    event EndState(name NextStateName)
    {
        //Shows ring model.
        SetHidden(false);
    }

    /**
     * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
     * @param Action  the related Kismet sequence action
     */
    function OnToggle(SeqAct_Toggle Action)
    {
        if (Action.InputLinks[0].bHasImpulse || Action.InputLinks[2].bHasImpulse)
            //Show ring actor.
            GotoState('Pickup');
    }
}


defaultproperties
{
    Begin Object Class=CylinderComponent Name=CollisionCylinder
        bAlwaysRenderIfSelected=true
        bDrawBoundingBox=false
        CollideActors=true
        CollisionHeight=30.0
        CollisionRadius=30.0
    End Object
    CollisionComponent=CollisionCylinder
    CylinderComponent=CollisionCylinder
    Components.Add(CollisionCylinder)


    Begin Object Class=DynamicLightEnvironmentComponent Name=RingLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=RingLightEnvironment
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


    SupportedEvents.Add(class'SeqEvent_PickupStatusChange')


    bBlockActors=false           //Doesn't block other nonplayer actors.
    bCollideActors=true          //Collides with other actors.
    bCollideWorld=false          //Doesn't collide with the world.
    bEdShouldSnap=true           //It snaps to the grid in the editor.
    bIgnoreEncroachers=true      //Ignore collisions between movers and this actor.
    bMovable=true                //Actor can be moved.
    bNoDelete=true               //Can't be deleted during play.
    bNoEncroachCheck=true        //Doesn't do the overlap check when it moves.
    bPushedByEncroachers=false   //Encroachers can't push this actor.
    bStatic=false                //It moves or changes over time.
    Physics=PHYS_Rotating        //Actor's physics mode; rotating physics.
    RotationRate=(Yaw=24576)     //Change in rotation per second.
    TickGroup=TG_DuringAsyncWork //Tick run in parallel of the async work.

    PickupLightClass=none
    PickupSound=SoundCue'SonicGDKPackSounds.RingSoundCue'
    RingParticleSystem=ParticleSystem'SonicGDKPackParticles.Particles.RingParticleSystem'

    bLightDash=false
    bMagnetic=true
    EnergyAmount=0.5
    InitialRotation=(Pitch=0,Yaw=0,Roll=2048)
    MagneticRingClass=class'RingProjectile'
    RingsAmount=1
}
