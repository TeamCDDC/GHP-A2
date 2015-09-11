//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Handle Actor > BetterTouchActor > SGDKActor > Actor
//
// The Handle Actor is the handle found in many classic Sonic games.
// Players can grab hold of this actor upon contact and hang from it.
//================================================================================
class HandleActor extends BetterTouchActor
    ClassGroup(SGDK,Invisible)
    implements(DestroyableEntity)
    placeable;


/**The invisible sensor mesh that detects touching actors.*/ var() editconst SensorMeshComponent SensorMesh;
  /**Invisible box component used to check for visibility.*/ var VisibilityBoxComponent HiddenComponent;

                   /**If true, the hanging pawn always faces the same orientation.*/ var() bool bForceOneOrientation;
                        /**If true, can be a possible target for Homing Dash move.*/ var() bool bHomingDash;
                              /**Multiplier to apply to detaching speed magnitude.*/ var() float DetachSpeedMultiplier;
                           /**The sound played when a pawn hangs from this handle.*/ var() SoundCue HangSound;
/**The Homing Dash target location will offset from this spring using this vector.*/ var() vector HomingLocationOffset;
                             /**Name of the animation to play by the hanging pawn.*/ var() name PawnAnimName;
               /**The hanging pawn will offset from this handle using this vector.*/ var() vector PawnLocationOffset;

struct LocationsHistory
{
                /**Handle's location.*/ var vector Location;
/**Time stamp of the stored location.*/ var float Time;
};
/**Stores locations of this actor.*/ var LocationsHistory Locations[2];


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    HiddenComponent.BoxExtent = SensorMesh.Bounds.BoxExtent * 1.25;
    HiddenComponent.SetTranslation(SensorMesh.Bounds.Origin - Location);
    HiddenComponent.ForceUpdate(false);

    Locations[0].Location = Location;
    Locations[0].Time = WorldInfo.TimeSeconds;
    Locations[1] = Locations[0];
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    if (Owner != none)
    {
        Locations[0] = Locations[1];

        Locations[1].Location = Location;
        Locations[1].Time = WorldInfo.TimeSeconds;

        bDisableTick = false;
    }
    else
        bDisableTick = true;

    super.Tick(DeltaTime);
}

/**
 * Gets the location to where a Homing Dash special move must go.
 * @param APawn  the pawn that tries to destroy this object
 * @return       location of a vulnerable point
 */
function vector GetHomingLocation(SGDKPlayerPawn APawn)
{
    return (Location + (HomingLocationOffset >> Rotation));
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
    return bHomingDash;
}

/**
 * Is a pawn in condition to touch this actor?
 * @param P  the pawn involved in the touch
 * @return   true if pawn is a valid actor for touch events
 */
function bool IsValidTouchedBy(SGDKPawn P)
{
    local vector V;

    if (super.IsValidTouchedBy(P) && !SGDKPlayerPawn(P).bHanging)
    {
        V = vect(0,0,1) >> Rotation;

        if (V.Z >= 0.0)
            return (P.Location.Z < Location.Z);
        else
            return (P.Location.Z > Location.Z);
    }

    return false;
}

/**
 * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
 * @param Action  the related Kismet sequence action
 */
function OnToggle(SeqAct_Toggle Action)
{
    if (Owner != none && SGDKPlayerPawn(Owner) != none && Action.InputLinks[2].bHasImpulse)
        SGDKPlayerPawn(Owner).SetHanging(false);
}

/**
 * Called when a pawn is attached to this handle.
 * @param P  the attached pawn
 */
function PawnAttached(SGDKPawn P)
{
    SetOwner(P);

    Locations[0].Location = Location;
    Locations[0].Time = WorldInfo.TimeSeconds;
    Locations[1] = Locations[0];

    TriggerEventClass(class'SeqEvent_HandleTouch',P,0);

    if (HangSound != none)
        P.PlaySound(HangSound);
}

/**
 * Called when a pawn is detached from this handle.
 * @param P  the detached pawn
 */
function PawnDetached(SGDKPawn P)
{
    TriggerEventClass(class'SeqEvent_HandleTouch',P,1);

    SetOwner(none);

    SGDKPlayerPawn(P).SetVelocity(((Locations[1].Location - Locations[0].Location) /
                                  (Locations[1].Time - Locations[0].Time)) * DetachSpeedMultiplier);
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    SetOwner(none);

    Locations[0].Location = Location;
    Locations[0].Time = WorldInfo.TimeSeconds;
    Locations[1] = Locations[0];
}

/**
 * Reverses the facing direction of this handle.
 */
function ReverseRotation()
{
    local Actor OldBase;
    local SkeletalMeshComponent OldBaseSkelComponent;
    local name OldBaseBoneName;
    local vector X,Y,Z;

    OldBase = Base;
    OldBaseSkelComponent = BaseSkelComponent;
    OldBaseBoneName = BaseBoneName;

    SetBase(none);

    GetAxes(Rotation,X,Y,Z);
    SetRotation(OrthoRotation(-X,-Y,Z));

    if (OldBase != none)
        SetBase(OldBase,,OldBaseSkelComponent,OldBaseBoneName);
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    if (Owner == none && !SGDKPlayerPawn(P).bHanging)
        SGDKPlayerPawn(P).SetHanging(true,self);
}


defaultproperties
{
    Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorResources.S_KBSJoint'
        HiddenGame=true
        Scale=0.5
    End Object
    Components.Add(Sprite)


    Begin Object Class=SensorMeshComponent Name=SensorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.HandleMaterial'
        Scale=1.0
        Scale3D=(X=0.25,Y=1.5,Z=0.25)
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
    SensorMesh=SensorStaticMesh
    Components.Add(SensorStaticMesh)


    Begin Object Class=VisibilityBoxComponent Name=VisibilityComponent
    End Object
    HiddenComponent=VisibilityComponent
    Components.Add(VisibilityComponent)


    SupportedEvents.Empty
    SupportedEvents.Add(class'SeqEvent_HandleTouch')


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bMovable=true              //Actor can be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPushedByEncroachers=false //Whether encroachers can push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    bForceOneOrientation=false
    bHomingDash=true
    DetachSpeedMultiplier=1.0
    HangSound=none
    HomingLocationOffset=(X=0.0,Y=0.0,Z=0.0)
    PawnAnimName=Hang
    PawnLocationOffset=(X=-5.0,Y=0.0,Z=-33.0)
    TouchedByInterval=0.0
}
