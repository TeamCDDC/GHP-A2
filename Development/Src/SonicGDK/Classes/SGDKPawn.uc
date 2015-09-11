//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Pawn > UTPawn > UDKPawn > GamePawn > Pawn > Actor
//
// The pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
//================================================================================
class SGDKPawn extends UTPawn
    ClassGroup(SGDK,Invisible,PawnTemplates)
    hidecategories(AI,Attachment,Camera,Collision,DeathAnim,Debug,HeroCamera,Mobile,
                   Movement,Pawn,Physics,Swimming,TeamBeacon,UDKPawn,UTPawn)
    implements(DrawableEntity)
    notplaceable;


           /**If set, a custom animation is being played.*/ var name CustomAnimation;
/**Time to blend out before custom animation really ends.*/ var float CustomBlendOutTime;


/**
 * Called when a sequence node in the animation tree of the attached skeletal mesh reaches the end and stops.
 * bCauseActorAnimEnd must be set to true on the AnimNodeSequence for this event to get generated.
 * @param SequenceNode  node that finished playing
 * @param PlayedTime    time played on this animation (play rate independent)
 * @param ExcessTime    how much time overlapped beyond end of animation (play rate independent)
 */
event OnAnimEnd(AnimNodeSequence SequenceNode,float PlayedTime,float ExcessTime)
{
    if (SequenceNode.AnimSeqName == CustomAnimation)
        CustomAnimation = '';

    super.OnAnimEnd(SequenceNode,PlayedTime,ExcessTime);
}

/**
 * Called by AnimNotify_Footstep; plays a footstep sound.
 * @param FootId  specifies which foot hit; 0 is left footstep, 1 is right footstep
 */
simulated event PlayFootStepSound(int FootId)
{
    if (Health > 0)
        super.PlayFootStepSound(FootId);
}

/**
 * Called only if this pawn was rendered this tick and allows to render HUD overlays.
 * Assumes that appropriate font has already been set.
 * @param PC               the controlling player controller
 * @param Canvas           the drawing canvas that covers the whole screen
 * @param CameraPosition   the position of the camera
 * @param CameraDirection  the orientation of the camera
 */
simulated event PostRenderFor(PlayerController PC,Canvas Canvas,vector CameraPosition,vector CameraDirection)
{
    //Disabled.
}

/**
 * Draws 2D graphics on the HUD.
 * @param TheHud  the HUD
 */
function HudGraphicsDraw(SGDKHud TheHud)
{
}

/**
 * Updates all 2D graphics' values safely.
 * @param DeltaTime  time since last render of the HUD
 * @param TheHud     the HUD
 */
function HudGraphicsUpdate(float DeltaTime,SGDKHud TheHud)
{
}

/**
 * Is this pawn a template for others?
 * @return  true if it was placed with the editor
 */
function bool IsTemplate()
{
    return (CreationTime == 0.0);
}

/**
 * Handler for the SeqAct_HaltMoveSpeed action; allows level designers to halt movement.
 * @param Action  related Kismet sequence action
 */
function OnHaltMoveSpeed(SeqAct_HaltMoveSpeed Action)
{
    if (Action.InputLinks[0].bHasImpulse)
    {
        ZeroMovementVariables();
        MovementSpeedModifier = 0.0;
    }
    else
        MovementSpeedModifier = 1.0;
}

/**
 * Handler for the UTSeqAct_PlayAnim action; allows level designers to play an animation.
 * @param Action  related Kismet sequence action
 */
function OnPlayAnim(UTSeqAct_PlayAnim Action)
{
    StartAnimation(Action.AnimName,1.0,0.2,0.2,Action.bLooping,true);
}

/**
 * Handler for the SeqAct_SetMaterial action; allows level designers to change a material of the attached skeletal mesh.
 * @param Action  related Kismet sequence action
 */
function OnSetMaterial(SeqAct_SetMaterial Action)
{
    if (Action.MaterialIndex < BodyMaterialInstances.Length)
        BodyMaterialInstances[Action.MaterialIndex].SetParent(Action.NewMaterial);
    else
        super.OnSetMaterial(Action);
}

/**
 * Sets or unsets IK handles constraints to hand bones of character skeleton.
 * @param bSet  sets/unsets hand constraints
 */
simulated function SetHandIKEnabled(bool bSet)
{
    //Disabled.
}

/**
 * Starts/plays an animation.
 * @param AnimName      name of the animation to play
 * @param Rate          rate of the animation that should be played at
 * @param BlendInTime   blend duration to play the animation
 * @param BlendOutTime  time to blend out before animation ends
 * @param bLooping      true to loop the animation forever until told to stop
 * @param bOverride     true to play the animation over again even if it's already being played
 * @param LoopTime      duration of looping animation
 * @param StartTime     time frame at which the animation must start to be played
 * @param EndTime       time frame at which the animation must end
 * @return              playback length of animation
 */
function float StartAnimation(name AnimName,float Rate,optional float BlendInTime,optional float BlendOutTime,
                              optional bool bLooping,optional bool bOverride,optional float LoopTime,
                              optional float StartTime,optional float EndTime)
{
    local float AnimLength;

    if (FullBodyAnimSlot != none)
        AnimLength = FullBodyAnimSlot.PlayCustomAnim(AnimName,Rate,BlendInTime,BlendOutTime,
                                                     bLooping,bOverride,StartTime,EndTime);

    if (AnimLength > 0.0)
    {
        if (!bLooping)
            FullBodyAnimSlot.SetActorAnimEndNotification(true);
        else
            if (LoopTime > 0.0)
                SetTimer(LoopTime - BlendOutTime,false,NameOf(StopAnimationDelayed));

        CustomAnimation = AnimName;
        CustomBlendOutTime = BlendOutTime;
    }

    return AnimLength;
}

/**
 * Stops playing an animation.
 * @param AnimName      name of the animation to stop, pass empty name for any animation
 * @param BlendOutTime  time to blend out before animation ends
 */
function StopAnimation(optional name AnimName,optional float BlendOutTime = -1.0)
{
    if (CustomAnimation != '' && (AnimName == '' || AnimName == CustomAnimation))
    {
        ClearTimer(NameOf(StopAnimationDelayed));

        if (BlendOutTime >= 0.0)
            FullBodyAnimSlot.StopCustomAnim(BlendOutTime);
        else
            FullBodyAnimSlot.StopCustomAnim(CustomBlendOutTime);

        CustomAnimation = '';
        CustomBlendOutTime = 0.0;
    }
}

/**
 * Stops playing a looping animation after a timer runs out.
 */
protected function StopAnimationDelayed()
{
    StopAnimation(CustomAnimation);
}


//Pawn is a template.
state Template
{
    ignores Bump,HitWall,Landed,PhysicsVolumeChange,TakeDamage,Touch;

    event BeginState(name PreviousStateName)
    {
        local ActorComponent AComponent;

        bAmbientCreature = true;
        bCanPickupInventory = false;
        bIgnoreForces = true;
        bIsInvisible = true;

        if (Mesh != none)
            Mesh.bPauseAnims = true;

        SetCollision(false,false);
        SetPhysics(PHYS_None);

        if (CollisionComponent != none)
            CollisionComponent.SetBlockRigidBody(false);

        foreach ComponentList(class'ActorComponent',AComponent)
            DetachComponent(AComponent);

        SetHidden(true);

        Velocity = vect(0,0,0);
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        //Disabled.
    }

    /**
     * Called whenever time passes and after physics movement has completed.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last TickSpecial call
     */
    event TickSpecial(float DeltaTime)
    {
        //Disabled.
    }

    /**
     * Called every tick to update player eye height position, based on smoothing view while moving up and down
     * stairs and adding view bobs for landing.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last tick
     */
    event UpdateEyeHeight(float DeltaTime)
    {
        //Disabled.
    }

    /**
     * Resets this actor to its initial state; used when restarting level without reloading.
     */
    function Reset()
    {
        //Disabled.
    }

    /**
     * Freezes this pawn; stops sounds, animations, physics...
     */
    simulated function TurnOff()
    {
        //Disabled.
    }
}


defaultproperties
{
    Begin Object Name=WPawnSkeletalMeshComponent
        bAcceptsDynamicDecals=false            //Doesn't accept dynamic decals created during gameplay.
        bAcceptsStaticDecals=false             //Doesn't accept static decals placed in the level with the editor.
        bCacheAnimSequenceNodes=false          //Animation sequence nodes won't cache values when not playing animations.
        bCastDynamicShadow=true                //Casts dynamic shadows.
        bHasPhysicsAssetInstance=true          //Uses a physical representation in the physics engine.
        bIgnoreControllersWhenNotRendered=true //Skeletal controls are ignored if the mesh isn't visible.
        bOwnerNoSee=false                      //It's visible to the owner.
        bPerBoneMotionBlur=true                //Uses per-bone motion blur.
        bUpdateSkelWhenNotRendered=false       //Skeleton isn't updated if it isn't visible.
        bUseOnePassLightingOnTranslucency=true //Uses nice lighting for hair.
        AnimTreeTemplate=none                  //No animation tree is assigned here.
        BlockRigidBody=true                    //Blocks rigid bodies managed by the physics engine.
        CastShadow=true                        //Can cast shadows.
        Scale=1.0                              //Restores to default scale value.
        TickGroup=TG_PreAsyncWork              //Operates on last frame's physics simulation results.
        Translation=(X=0.0,Y=0.0,Z=0.0)        //No translation offset from pawn owner location.
    End Object
    Mesh=WPawnSkeletalMeshComponent


    Begin Object Name=CollisionCylinder
        bAlwaysRenderIfSelected=true        //The cylinder will always be drawn when the actor is selected.
        bDrawBoundingBox=false              //Doesn't draw the red bounding box for the cylinder in debug mode.
        BlockActors=true                    //Blocks all actors.
        BlockNonZeroExtent=true             //Blocks wide ray checks.
        BlockZeroExtent=true                //Blocks line/ray checks.
        CollideActors=true                  //Interacts with all actors.
        CylinderColor=(R=0,G=255,B=0,A=255) //Color used to draw the cylinder in debug mode.
    End Object
    CylinderComponent=CollisionCylinder

	

    bEdShouldSnap=true //It snaps to the grid in the editor.
    Buoyancy=0.0       //Water buoyancy; 1.0 means neutral buoyancy; 0.0 means no buoyancy.
    Health=1           //Amount of health this pawn has.
}
