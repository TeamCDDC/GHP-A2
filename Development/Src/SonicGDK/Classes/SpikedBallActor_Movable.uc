//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Spiked Ball Actor Movable > SpikedBallActor > SGDKActor > Actor
//
// The Spiked Ball Actor is a hazard found in many Sonic games.
// Players should avoid touching the spikes around this ball.
// This type can be moved during gameplay (attached to matinee, etc).
//================================================================================
class SpikedBallActor_Movable extends SpikedBallActor;


/**The spiked ball's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;


defaultproperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=BallLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.0
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=BallLightEnvironment
    Components.Add(BallLightEnvironment)


    Begin Object Name=BallStaticMesh
        LightEnvironment=BallLightEnvironment
        bAllowApproximateOcclusion=false
        bForceDirectLightMap=false
        bUsePrecomputedShadows=false
    End Object
    CollisionComponent=BallStaticMesh
    SpikedBallMesh=BallStaticMesh


    bMovable=true         //Actor can be moved.
    bNoEncroachCheck=true //Doesn't do the overlap check when it moves.
}
