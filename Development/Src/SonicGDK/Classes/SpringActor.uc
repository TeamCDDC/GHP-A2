//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Spring Actor > BetterTouchActor > SGDKActor > Actor
//
// The Spring Actor is the classic spring object found in all Sonic games used for
// pushing players.
// Players should leap onto the broad side to get catapulted into the air.
//================================================================================
class SpringActor extends BetterTouchActor
    implements(DestroyableEntity,ReceivePawnEvents)
    placeable;


                               /**The spring visible mesh.*/ var() editconst SkeletalMeshComponent SpringMesh;
                        /**The spring's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;
/**The invisible sensor mesh that detects touching actors.*/ var() editconst SensorMeshComponent SensorMesh;

                               /**If true, impulse removes previous pawn velocity.*/ var() bool bHarsh;
                        /**If true, can be a possible target for Homing Dash move.*/ var() bool bHomingDash;
                              /**If true, impulse direction is parallel to ground.*/ var() bool bParallel;
             /**If true, air control of the player is restored at apex of impulse.*/ var() bool bRestoreAirControl;
                        /**If true, parallel impulses also rotate the camera view.*/ var() bool bRotateView;
                             /**How much time the player is forced to run forward
                                       for parallel impulses (turning is enabled).*/ var() float DisabledInputTime;
/**The Homing Dash target location will offset from this spring using this vector.*/ var() vector HomingLocationOffset;
  /**How much air control the player should have while in the air off this spring.*/ var() float JumpAirControl;
                                  /**The sound played when this spring is touched.*/ var() SoundCue JumpSound;
                                            /**The speed magnitude of the impulse.*/ var() float JumpSpeed;
                 /**The name of the animation that the catapulted pawns will play.*/ var() name PawnAnimName;
                                /**The name of the animation to play when touched.*/ var() name SpringAnimName;


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

    if (PawnAnimName != '')
        ThePawn.StopAnimation(PawnAnimName);
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    local SGDKPlayerPawn APawn;
    local vector X,Y,Z;

    APawn = SGDKPlayerPawn(P);

    if (!bParallel || !APawn.IsTouchingGround())
    {
        if (!bHarsh)
        {
            GetAxes(Rotation,X,Y,Z);

            APawn.AerialBoost(PointProjectToPlane(APawn.GetVelocity(),vect(0,0,0),X,Y) +
                              (Z * (JumpSpeed * 1000.0)),APawn.Physics == PHYS_Falling,self,'Spring');
        }
        else
            APawn.AerialBoost((vect(0,0,1) >> Rotation) * (JumpSpeed * 1000.0),
                              APawn.Physics == PHYS_Falling,self,'Spring');

        APawn.AirControl *= JumpAirControl;
        APawn.Acceleration = vect(0,0,0);

        if (PawnAnimName == '' && bRestoreAirControl)
            APawn.NotifyEventsTo.AddItem(self);
    }
    else
    {
        Z = APawn.GetFloorNormal();
        Y = Z cross (vect(0,0,1) >> Rotation);
        APawn.ForceRotation(OrthoRotation(Y cross Z,Y,Z),bRotateView);

        APawn.HighSpeedBoost(JumpSpeed,true,DisabledInputTime);
    }

    if (JumpSound != none)
        APawn.PlaySound(JumpSound);

    if (PawnAnimName != '')
    {
        APawn.StartAnimation(PawnAnimName,1.0,0.1,0.1,true,true);
        APawn.NotifyEventsTo.AddItem(self);
    }

    if (SpringAnimName != '')
        SpringMesh.PlayAnim(SpringAnimName);
}


defaultproperties
{
    Begin Object Class=AnimNodeSequence Name=AnimationNodeSequence
    End Object


    Begin Object Class=ArrowComponent Name=Arrow
        bTreatAsASprite=true
        ArrowSize=1.5
        Rotation=(Pitch=16384,Yaw=0,Roll=0)
    End Object
    Components.Add(Arrow)


    Begin Object Class=CylinderComponent Name=CollisionCylinder
        CollideActors=false
        CollisionHeight=0.0
        CollisionRadius=0.0
    End Object
    CollisionComponent=CollisionCylinder


    Begin Object Class=SensorMeshComponent Name=SensorStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.CylinderStaticMesh'
        Materials[0]=Material'SonicGDKPackSkeletalMeshes.Materials.SpringMaterialB'
        Scale=1.0
        Scale3D=(X=0.8,Y=0.8,Z=0.5)
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
    SensorMesh=SensorStaticMesh
    Components.Add(SensorStaticMesh)


    Begin Object Class=DynamicLightEnvironmentComponent Name=SpringLightEnvironment
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


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bMovable=true              //Actor can be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bNoEncroachCheck=true      //Doesn't do the overlap check when it moves.
    bPushedByEncroachers=false //Encroachers can't push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    TouchedByInterval=0.33

    bHarsh=true
    bHomingDash=true
    bParallel=false
    bRestoreAirControl=false
    bRotateView=false
    DisabledInputTime=0.35
    HomingLocationOffset=(X=0.0,Y=0.0,Z=35.0)
    JumpAirControl=1.0
    JumpSound=SoundCue'SonicGDKPackSounds.SpringSoundCue'
    JumpSpeed=1.0
    PawnAnimName=Spring
    SpringAnimName=Bounce
}
