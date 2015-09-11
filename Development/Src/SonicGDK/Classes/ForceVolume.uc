//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Force Volume > UDKForcedDirectionVolume > PhysicsVolume > Volume > Brush >
//     > Actor
//
// This is a bounding volume, an invisible zone or area which tracks other actors
// entering and exiting it.
// This type pushes actors away along a specified direction.
//================================================================================
class ForceVolume extends UDKForcedDirectionVolume
    ClassGroup(SGDK)
    hidecategories(UDKForcedDirectionVolume)
    placeable;


/**Indicates the direction of the applied force.*/ var() editconst ArrowComponent DirectionArrow;

              /**If true, only modifies velocity of the pushed actors.*/ var() bool bAffectVelocity;
                                  /**If true, this volume is disabled.*/ var() bool bDisabled;
                             /**Stores the default value of bDisabled.*/ var bool bOldDisabled;
                       /**If true, the applied force is bidirectional.*/ var() bool bTwoSidedForce;
            /**If true and a player pawn is being pushed, splines are
                 used as indication of direction of the applied force.*/ var() bool bUseSplineAsArrow;
         /**Allows the force to be limited to certain types of actors.*/ var() array< class<Actor> > ForcedActors;
                                    /**Magnitude of the applied force.*/ var() float ForceMagnitude;
/**Required minimum speed of the actors to be considered for the push.*/ var() float MinActorSpeed;
                                    /**Actors currently being tracked.*/ var array<Actor> TrackedActors;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    bOldDisabled = bDisabled;
}

/**
 * Called when an actor enters this volume.
 * @param Other  the other actor that entered this volume
 */
event ActorEnteredVolume(Actor Other)
{
    //Disabled.
}

/**
 * Called when an actor in this volume changes its physics mode.
 * @param Other  the other actor that changed its physics mode
 */
event PhysicsChangedFor(Actor Other)
{
    if (Other.Physics != PHYS_None)
        Touch(Other,Other.CollisionComponent,Other.Location,vect(0,0,0));
    else
        UnTouch(Other);
}

/**
 * Called when collision with another actor happens; also called every tick that the collision still occurs.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitLocation     the world location where the touch occurred
 * @param HitNormal       the surface normal of this actor where the touch occurred
 */
simulated event Touch(Actor Other,PrimitiveComponent OtherComponent,vector HitLocation,vector HitNormal)
{
    super(PhysicsVolume).Touch(Other,OtherComponent,HitLocation,HitNormal);
}

/**
 * Called when collision with another actor stops happening.
 * @param Other  the other actor involved in the collision
 */
simulated event UnTouch(Actor Other)
{
    super(PhysicsVolume).UnTouch(Other);
}

/**
 * Adds a force to an actor.
 * @param AnActor    the actor to push
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
function AddForceTo(Actor AnActor,float DeltaTime)
{
    local SGDKPlayerPawn P;
    local vector Direction,Force;
    local float Magnitude;

    if (MinActorSpeed <= 0.0 || VSizeSq(AnActor.Velocity) >= Square(MinActorSpeed))
    {
        P = SGDKPlayerPawn(AnActor);

        if (!bUseSplineAsArrow || P == none || P.CurrentSplineComp == none)
        {
            if (!bTwoSidedForce || (AnActor.Location - Location) dot ArrowDirection > 0.0)
                Direction = ArrowDirection;
            else
                Direction = -ArrowDirection;
        }
        else
        {
            Direction = class'SGDKSplineActor'.static.CalculateTangent(P.CurrentSplineComp,P.SplineDistance);

            if (bTwoSidedForce)
            {
                if (!IsZero(P.Velocity))
                    Direction = (P.GetVelocity() dot Direction >= 0.0) ? Direction : -Direction;
                else
                    Direction = (vector(P.GetRotation()) dot Direction >= 0.0) ? Direction : -Direction;
            }
        }

        Magnitude = ForceMagnitude;

        if (Magnitude < 0.0)
        {
            Direction *= -1;
            Magnitude = Abs(Magnitude);
        }

        if (!bAffectVelocity)
            AnActor.MoveSmooth(Direction * (Magnitude * DeltaTime));
        else
            if (AnActor.Physics == PHYS_RigidBody && AnActor.CollisionComponent != none)
            {
                if (!AnActor.CollisionComponent.RigidBodyIsAwake())
                {
                    AnActor.CollisionComponent.AddImpulse(Direction * FMax(25.0,Magnitude * 0.01));
                    AnActor.CollisionComponent.WakeRigidBody();
                }
                else
                    AnActor.CollisionComponent.AddForce(Direction * Magnitude);
            }
            else
                if (SGDKPawn(AnActor) == none)
                    AnActor.Velocity += Direction * (Magnitude * DeltaTime);
                else
                    if (P == none)
                    {
                        AnActor.Velocity += Direction * (Magnitude * DeltaTime);

                        if (AnActor.Physics == PHYS_Walking && SGDKPawn(AnActor).Floor dot Direction > 0.71)
                            AnActor.SetPhysics(PHYS_Falling);
                    }
                    else
                    {
                        if (IsZero(P.Velocity))
                            Force = Direction * FMax(25.0,Magnitude * 0.01);
                        else
                            Force = P.GetVelocity() + Direction * (Magnitude * DeltaTime);

                        if (P.IsTouchingGround() && P.GetFloorNormal() dot Direction > 0.71)
                            P.AerialBoost(Force,false,self,'ForceVolume');
                        else
                            P.SetVelocity(Force);

                        if (P.Physics == PHYS_Falling)
                            P.bDoubleGravity = false;
                    }
    }
}

/**
 * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
 * @param Action  the related Kismet sequence action
 */
simulated function OnToggle(SeqAct_Toggle Action)
{
    if (Action.InputLinks[0].bHasImpulse)
        bDisabled = false;
    else
        if (Action.InputLinks[1].bHasImpulse)
            bDisabled = true;
        else
            if (Action.InputLinks[2].bHasImpulse)
                bDisabled = !bDisabled;
}

/**
 * Should this volume apply a force to a specific type of actor?
 * @param ActorClass  class of the actor to check
 * @return            true if actor class is valid for the push
 */
function bool ShouldApplyForce(class<Actor> ActorClass)
{
    local int i;

    if (ForcedActors.Length == 0)
        return true;

    for (i = 0; i < ForcedActors.Length; i++)
        if (ClassIsChildOf(ActorClass,ForcedActors[i]))
            return true;

    return false;
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    bDisabled = bOldDisabled;

    GotoState('Idle');
}


auto state Idle
{
    event BeginState(name PreviousStateName)
    {
        TrackedActors.Length = 0;
    }

    /**
     * Called when collision with another actor happens; also called every tick that the collision still occurs.
     * @param Other           the other actor involved in the collision
     * @param OtherComponent  the associated primitive component of the other actor
     * @param HitLocation     the world location where the touch occurred
     * @param HitNormal       the surface normal of this actor where the touch occurred
     */
    simulated event Touch(Actor Other,PrimitiveComponent OtherComponent,vector HitLocation,vector HitNormal)
    {
        global.Touch(Other,OtherComponent,HitLocation,HitNormal);

        if (Other.Physics != PHYS_None && ShouldApplyForce(Other.Class))
        {
            TrackedActors.AddItem(Other);

            GotoState('Tracking');
        }
    }
}


state Tracking
{
    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        local Actor A;

        if (TrackedActors.Length > 0)
        {
            if (!bDisabled)
            {
                foreach TrackedActors(A)
                    AddForceTo(A,DeltaTime);
            }
        }
        else
            GotoState('Idle');
    }

    /**
     * Called when collision with another actor happens; also called every tick that the collision still occurs.
     * @param Other           the other actor involved in the collision
     * @param OtherComponent  the associated primitive component of the other actor
     * @param HitLocation     the world location where the touch occurred
     * @param HitNormal       the surface normal of this actor where the touch occurred
     */
    simulated event Touch(Actor Other,PrimitiveComponent OtherComponent,vector HitLocation,vector HitNormal)
    {
        global.Touch(Other,OtherComponent,HitLocation,HitNormal);

        if (Other.Physics != PHYS_None && ShouldApplyForce(Other.Class) && TrackedActors.Find(Other) == INDEX_NONE)
            TrackedActors.AddItem(Other);
    }

    /**
     * Called when collision with another actor stops happening.
     * @param Other  the other actor involved in the collision
     */
    simulated event UnTouch(Actor Other)
    {
        global.UnTouch(Other);

        TrackedActors.RemoveItem(Other);
    }
}


defaultproperties
{
    Begin Object Name=AC
        ArrowColor=(R=255,G=100,B=255,A=255)
    End Object
    Arrow=AC
    DirectionArrow=AC


    Begin Object Name=BrushComponent0
        BlockActors=false
        BlockNonZeroExtent=true
        BlockRigidBody=false
        BlockZeroExtent=true
        CollideActors=true
        RBChannel=RBCC_Default
    End Object


    bBlockActors=false
    bBlockSpectators=false
    bBlockPawns=false
    bColored=true
    bDenyExit=false
    bIgnoreHoverboards=true
    BrushColor=(R=255,G=100,B=255,A=255)
    TypeToForce=none

    bAffectVelocity=false
    bDisabled=false
    bTwoSidedForce=false
    bUseSplineAsArrow=false
    ForceMagnitude=100.0
    MinActorSpeed=0.0
}
