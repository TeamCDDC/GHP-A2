//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Star Post Actor > SGDKActor > Actor
//
// The Star Post Actor is the visual checkpoint found in all Sonic games. Toggle
// it to play its related effects.
//================================================================================
class StarPostActor extends SGDKActor
    placeable;


       /**The star post visible mesh.*/ var() editconst SkeletalMeshComponent StarPostMesh;
/**The star post's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;
/**The associated collision cylinder.*/ var() editconst CylinderComponent CylinderComponent;

/**The name of the animation to play when toggled.*/ var() name ActivationAnimName;
                /**The sound to play when toggled.*/ var() SoundCue ActivationSound;


/**
 * Function handler for SeqAct_SetMaterial Kismet sequence action.
 * @param Action  the related Kismet sequence action
 */
function OnSetMaterial(SeqAct_SetMaterial Action)
{
    StarPostMesh.SetMaterial(Action.MaterialIndex,Action.NewMaterial);
}

/**
 * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
 * @param Action  the related Kismet sequence action
 */
function OnToggle(SeqAct_Toggle Action)
{
    if (Action.InputLinks[2].bHasImpulse)
    {
        if (ActivationAnimName != '')
            StarPostMesh.PlayAnim(ActivationAnimName);

        if (ActivationSound != none)
            PlaySound(ActivationSound);
    }
}


defaultproperties
{
    Begin Object Class=AnimNodeSequence Name=AnimationNodeSequence
    End Object


    Begin Object Class=CylinderComponent Name=CollisionCylinder
        bAlwaysRenderIfSelected=true
        bDrawBoundingBox=false
        BlockActors=true
        BlockRigidBody=true
        CollideActors=true
        CollisionHeight=50.0
        CollisionRadius=13.0
    End Object
    CylinderComponent=CollisionCylinder
    CollisionComponent=CollisionCylinder
    Components.Add(CollisionCylinder)


    Begin Object Class=DynamicLightEnvironmentComponent Name=StarPostLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=StarPostLightEnvironment
    Components.Add(StarPostLightEnvironment)


    Begin Object Class=SkeletalMeshComponent Name=StarPostActorMesh
        Animations=AnimationNodeSequence
        AnimSets[0]=AnimSet'SonicGDKPackSkeletalMeshes.Animation.StarPostAnimSet'
        PhysicsAsset=PhysicsAsset'SonicGDKPackSkeletalMeshes.PhysicsAssets.StarPostPhysicsAsset'
        SkeletalMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.StarPostSkeletalMesh'
        LightEnvironment=StarPostLightEnvironment
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
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
    StarPostMesh=StarPostActorMesh
    Components.Add(StarPostActorMesh)


    bBlockActors=true          //Blocks other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bMovable=true              //Actor can be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPushedByEncroachers=false //Encroachers can't push this actor.
    bStatic=false              //It moves or changes over time.
    BlockRigidBody=true        //Blocks rigid body actors.
    Physics=PHYS_None          //Actor's physics mode.

    ActivationAnimName=Activation
    ActivationSound=SoundCue'SonicGDKPackSounds.StarPostSoundCue'
}
