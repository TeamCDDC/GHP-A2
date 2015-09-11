//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Spring Jump Pad > UDKJumpPad > NavigationPoint > Actor
//
// The Spring Jump Pad is the classic spring object found in all Sonic games used
// for pushing players.
// Players should leap onto the broad side to get catapulted into the air.
// Unlike the Spring Actor class, it allows to tweak the jump destination.
//================================================================================
class SpringJumpPad extends UDKJumpPad
    ClassGroup(SGDK,Visible)
    implements(DestroyableEntity,ReceivePawnEvents)
    placeable;


          /**The spring visible mesh.*/ var() editconst SkeletalMeshComponent SpringMesh;
   /**The spring's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;
/**The associated collision cylinder.*/ var() editconst CylinderComponent CylinderCollisionComp;

             /**If true, air control of the player is restored at apex of impulse.*/ var() bool bRestoreAirControl;
/**The Homing Dash target location will offset from this spring using this vector.*/ var() vector HomingLocationOffset;
                 /**The name of the animation that the catapulted pawns will play.*/ var() name PawnAnimName;
                                /**The name of the animation to play when touched.*/ var() name SpringAnimName;

  /**Last pawn that touched this actor.*/ var SGDKPlayerPawn LastPawn;
/**Last time a pawn touched this actor.*/ var float LastTouchTime;


/**
 * Called for PendingTouch actor after the native physics step completes.
 * @param Other  the other actor involved in the previous touch event
 */
event PostTouch(Actor Other)
{
    local SGDKPlayerPawn P;

    P = SGDKPlayerPawn(Other);

    if (P != none && P.Health > 0 && P.Physics != PHYS_None &&
        P.DrivenVehicle == none && (WorldInfo.TimeSeconds - LastTouchTime > 0.2 || P != LastPawn))
    {
        LastPawn = P;
        LastTouchTime = WorldInfo.TimeSeconds;

        if (WorldInfo.WorldGravityZ == WorldInfo.DefaultGravityZ || Abs(P.GetGravityZ()) != WorldInfo.WorldGravityZ)
            P.AerialBoost(JumpVelocity,P.Physics == PHYS_Falling,self,'Spring');
        else
            P.AerialBoost(JumpVelocity * Sqrt(Abs(P.GetGravityZ() / WorldInfo.DefaultGravityZ)),
                          P.Physics == PHYS_Falling,self,'Spring');

        P.MoveSmooth(Location - P.Location);

        P.bDoubleGravity = false;
        P.AirControl *= JumpAirControl;
        P.AirDragFactor = 0.0;
        P.Acceleration = vect(0,0,0);

        if (JumpSound != none)
            P.PlaySound(JumpSound);

        if (PawnAnimName != '')
            P.StartAnimation(PawnAnimName,1.0,0.1,0.1,true,true);

        P.NotifyEventsTo.AddItem(self);

        if (SpringAnimName != '')
            SpringMesh.PlayAnim(SpringAnimName);

        TriggerEventClass(class'SeqEvent_TouchAccepted',P,0);
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
    if (SGDKPlayerPawn(Other) != none)
    {
        PendingTouch = Other.PendingTouch;
        Other.PendingTouch = self;
    }
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
    return true;
}

//Ignored function calls.
function PawnDied(SGDKPlayerPawn ThePawn);
function PawnEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnHeadEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnHeadLeftWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnHurtPawn(SGDKPlayerPawn ThePawn,Pawn TheOtherPawn);
function PawnLeftWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnPhysicsChanged(SGDKPlayerPawn ThePawn);

/**
 * Called when the pawn is bounced.
 * @param ThePawn  the pawn that generates the event
 */
function PawnBounced(SGDKPlayerPawn ThePawn)
{
    ThePawn.NotifyEventsTo.RemoveItem(self);

    ThePawn.AirDragFactor = ThePawn.DefaultAirDragFactor;

    if (PawnAnimName != '')
        ThePawn.StopAnimation(PawnAnimName);
}

/**
 * Called when the pawn performs an aerial special move.
 * @param ThePawn  the pawn that generates the event
 */
function PawnDoubleJumped(SGDKPlayerPawn ThePawn)
{
    ThePawn.NotifyEventsTo.RemoveItem(self);

    ThePawn.AirDragFactor = ThePawn.DefaultAirDragFactor;

    if (PawnAnimName != '')
        ThePawn.StopAnimation(PawnAnimName);
}

/**
 * Called when the pawn is at apex of jumps.
 * @param ThePawn  the pawn that generates the event
 */
function PawnJumpApex(SGDKPlayerPawn ThePawn)
{
    local AnimNodeSequence AnimationNode;

    ThePawn.NotifyEventsTo.RemoveItem(self);

    if (bRestoreAirControl)
    {
        if (JumpAirControl > 0.0)
            ThePawn.AirControl /= JumpAirControl;
        else
            ThePawn.AirControl = ThePawn.DefaultAirControl;
    }

    ThePawn.AirDragFactor = ThePawn.DefaultAirDragFactor;

    if (PawnAnimName != '')
    {
        AnimationNode = ThePawn.FullBodyAnimSlot.GetCustomAnimNodeSeq();

        ThePawn.StartAnimation(PawnAnimName,1.0,0.0,FMin(0.25,AnimationNode.GetTimeLeft()),false,true,,
            AnimationNode.GetAnimPlaybackLength() * AnimationNode.GetGlobalPlayRate() * AnimationNode.GetNormalizedPosition());
    }
}

/**
 * Called when the pawn jumps.
 * @param ThePawn  the pawn that generates the event
 */
function PawnJumped(SGDKPlayerPawn ThePawn)
{
    ThePawn.NotifyEventsTo.RemoveItem(self);

    ThePawn.AirDragFactor = ThePawn.DefaultAirDragFactor;

    if (PawnAnimName != '')
        ThePawn.StopAnimation(PawnAnimName);
}

/**
 * Called when the pawn lands on level geometry while falling.
 * @param ThePawn           the pawn that generates the event
 * @param bWillLeaveGround  true if the pawn will leave the actor is standing on soon
 * @param TheHitNormal      the surface normal of the actor/level geometry landed on
 * @param TheFloorActor     the actor landed on
 */
function PawnLanded(SGDKPlayerPawn ThePawn,bool bWillLeaveGround,vector TheHitNormal,Actor TheFloorActor)
{
    ThePawn.NotifyEventsTo.RemoveItem(self);

    ThePawn.AirDragFactor = ThePawn.DefaultAirDragFactor;

    if (PawnAnimName != '')
        ThePawn.StopAnimation(PawnAnimName);
}

/**
 * Called when damage is applied to the pawn.
 * @param ThePawn          the pawn that generates the event
 * @param TheDamageCauser  the actor that directly caused the damage
 */
function PawnTookDamage(SGDKPlayerPawn ThePawn,Actor TheDamageCauser)
{
    ThePawn.NotifyEventsTo.RemoveItem(self);

    ThePawn.AirDragFactor = ThePawn.DefaultAirDragFactor;

    if (PawnAnimName != '')
        ThePawn.StopAnimation(PawnAnimName);
}


defaultproperties
{
    Components.Remove(JumpPadLightEnvironment);


    Begin Object Class=AnimNodeSequence Name=AnimationNodeSequence
    End Object


    Begin Object Name=Arrow
        bTreatAsASprite=true
        ArrowSize=1.5
        Rotation=(Pitch=16384,Yaw=0,Roll=0)
    End Object


    Begin Object Name=CollisionCylinder
        CollisionHeight=12.0
        CollisionRadius=32.0
    End Object
    CylinderCollisionComp=CollisionCylinder
    CylinderComponent=CollisionCylinder


    Begin Object Class=DynamicLightEnvironmentComponent Name=SpringLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=SpringLightEnvironment
    Components.Add(SpringLightEnvironment)


    Begin Object Class=SkeletalMeshComponent Name=SpringActorMesh
        Animations=AnimationNodeSequence
        AnimSets[0]=AnimSet'SonicGDKPackSkeletalMeshes.Animation.SpringAnimSet'
        PhysicsAsset=PhysicsAsset'SonicGDKPackSkeletalMeshes.PhysicsAssets.SpringPhysicsAsset'
        SkeletalMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.SpringSkeletalMesh'
        LightEnvironment=SpringLightEnvironment
        bAcceptsDynamicDecals=true
        bAcceptsStaticDecals=true
        bAllowApproximateOcclusion=false
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bIgnoreControllersWhenNotRendered=true
        bUpdateSkelWhenNotRendered=false
        BlockActors=false
        BlockRigidBody=false
        CastShadow=true
        CollideActors=false
        MaxDrawDistance=9000.0
        Scale=1.85
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=-16.0)
    End Object
    SpringMesh=SpringActorMesh
    Components.Add(SpringActorMesh)


    SupportedEvents.Add(class'SeqEvent_TouchAccepted')


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bMovable=false             //Actor can't be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPushedByEncroachers=false //Encroachers can't push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    JumpAirControl=0.0
    JumpSound=SoundCue'SonicGDKPackSounds.SpringSoundCue'

    bRestoreAirControl=false
    HomingLocationOffset=(X=0.0,Y=0.0,Z=35.0)
    PawnAnimName=Spring
    SpringAnimName=Bounce
}
