//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Giant Ring Actor > SGDKActor > Actor
//
// The Giant Ring Actor is the giant ring found in all classic Sonic games.
//================================================================================
class GiantRingActor extends SGDKActor
    placeable;


      /**The ring visual static mesh.*/ var() editconst StaticMeshComponent RingMesh;
     /**The ring's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;
/**The associated collision cylinder.*/ var() editconst CylinderComponent CylinderComponent;

/**Sound played when picked up.*/ var() SoundCue PickupSound;
/**The particle visual effects.*/ var() ParticleSystem RingParticleSystem;

/**If true, this actor is reset when restarting level.*/ var() bool bReset;
                  /**Saves the first state of bHidden.*/ var bool bOldHidden;
                             /**Initial scale applied.*/ var float InitialScale;


/**
 * Called immediately before gameplay begins.
 */
event PreBeginPlay()
{
    //Save first state of bHidden.
    bOldHidden = bHidden;

    InitialScale = RingMesh.Scale;

    super.PreBeginPlay();
}

/**
 * Called after PostBeginPlay to set the initial state.
 */
simulated event SetInitialState()
{
    if (!bHidden)
        InitialState = 'Visible';
    else
        InitialState = 'Hidden';

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
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    if (bReset)
    {
        super.Reset();

        if (bHidden != bOldHidden)
        {
            if (!bOldHidden)
                GotoState('Visible');
            else
                GotoState('Hidden');
        }
    }
}


//The ring is visible and standing still.
state Visible
{
    event BeginState(name PreviousStateName)
    {
        RingMesh.SetScale(InitialScale);
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
            if (PickupSound != none)
                //Plays ring sound.
                P.PlaySound(PickupSound);

            if (RingParticleSystem != none)
            {
                //Display ring particle effects.
                RingEmitter = Spawn(class'SGDKEmitter',self,,Location,Rotation);
                RingEmitter.SetTemplate(RingParticleSystem,true);
            }

            GotoState('Hiding');
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
     * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
     * @param Action  the related Kismet sequence action
     */
    function OnToggle(SeqAct_Toggle Action)
    {
        if (Action.InputLinks[1].bHasImpulse || Action.InputLinks[2].bHasImpulse)
            GotoState('Hiding');
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
            else
                //Make sure not touching through wall.
                if (!FastTrace(P.Location,Location))
                {
                    SetTimer(0.5,false,NameOf(CheckTouching));

                    return false;
                }

        return true;
    }
}


//Ring is invisible and standing still.
state Hidden
{
    ignores Touch; //Ignores touch calls.

    event BeginState(name PreviousStateName)
    {
        SetHidden(true);

        RingMesh.SetScale(InitialScale * 0.01);
    }

    event EndState(name NextStateName)
    {
        SetHidden(false);
    }

    /**
     * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
     * @param Action  the related Kismet sequence action
     */
    function OnToggle(SeqAct_Toggle Action)
    {
        if (Action.InputLinks[0].bHasImpulse || Action.InputLinks[2].bHasImpulse)
            GotoState('Showing');
    }
}


//Ring is disappearing.
state Hiding extends Hidden
{
    event BeginState(name PreviousStateName)
    {
        RotationRate.Yaw *= 5;
    }

    event EndState(name NextStateName)
    {
        RotationRate.Yaw /= 5;
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        RingMesh.SetScale(FMax(0.01,RingMesh.Scale - InitialScale * DeltaTime));
    }

Begin:
    Sleep(1.0);

    GotoState('Hidden');
}


//Ring is appearing.
state Showing extends Visible
{
    event BeginState(name PreviousStateName)
    {
        RotationRate.Yaw *= 5;
    }

    event EndState(name NextStateName)
    {
        RotationRate.Yaw /= 5;
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        RingMesh.SetScale(FMin(RingMesh.Scale + InitialScale * DeltaTime,InitialScale));
    }

Begin:
    Sleep(1.0);

    GotoState('Visible');
}


defaultproperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=RingLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=RingLightEnvironment
    Components.Add(RingLightEnvironment)


    Begin Object Class=StaticMeshComponent Name=RingStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.GiantRingStaticMesh'
        LightEnvironment=RingLightEnvironment
        bAllowApproximateOcclusion=false
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=false
        BlockActors=false
        BlockRigidBody=false
        CastShadow=true
        CollideActors=true
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    RingMesh=RingStaticMesh
    Components.Add(RingStaticMesh)


    bBlockActors=false           //Doesn't block other nonplayer actors.
    bCollideActors=true          //Collides with other actors.
    bCollideWorld=false          //Doesn't collide with the world.
    bEdShouldSnap=true           //It snaps to the grid in the editor.
    bIgnoreEncroachers=true      //Ignore collisions between movers and this actor.
    bMovable=true                //Actor can be moved.
    bNoDelete=true               //Can't be deleted during play.
    bPushedByEncroachers=false   //Encroachers can't push this actor.
    bStatic=false                //It moves or changes over time.
    Physics=PHYS_Rotating        //Actor's physics mode; rotating physics.
    RotationRate=(Yaw=8192)      //Change in rotation per second.
    TickGroup=TG_DuringAsyncWork //Tick run in parallel of the async work.

    PickupSound=none
    RingParticleSystem=none

    bReset=false
}
