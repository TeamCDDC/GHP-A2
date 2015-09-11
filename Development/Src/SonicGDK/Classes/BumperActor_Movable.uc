//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Bumper Actor Movable > BumperActor > SGDKActor > Actor
//
// The Bumper Actor is the round bumper found in some of the classic Sonic games.
// Players are bounced off harshly when touching this actor.
// This type can be moved during gameplay (attached to matinee, etc).
//================================================================================
class BumperActor_Movable extends BumperActor;


/**The bumper's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;


defaultproperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=BumperLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.0
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=BumperLightEnvironment
    Components.Add(BumperLightEnvironment)


    Begin Object Name=BumperActorMesh
        LightEnvironment=BumperLightEnvironment
        bAllowApproximateOcclusion=false
        bForceDirectLightMap=false
        bUsePrecomputedShadows=false
    End Object
    CollisionComponent=BumperActorMesh
    BumperMesh=BumperActorMesh


    bMovable=true         //Actor can be moved.
    bNoEncroachCheck=true //Doesn't do the overlap check when it moves.
}
