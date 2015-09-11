//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Speed Booster Actor Movable > SpeedBoosterActor > BetterTouchActor >
//     > SGDKActor > Actor
//
// The Speed Booster Actor is the dash panel found in all modern Sonic games.
// Players should trot over the surface for an instant speed boost.
// This type can be moved during gameplay (attached to matinee, etc).
//================================================================================
class SpeedBoosterActor_Movable extends SpeedBoosterActor;


/**The speed booster's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;


defaultproperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=BoosterLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.0
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=BoosterLightEnvironment
    Components.Add(BoosterLightEnvironment)


    Begin Object Name=BoosterActorMesh
        LightEnvironment=BoosterLightEnvironment
        bAllowApproximateOcclusion=false
        bForceDirectLightMap=false
        bUsePrecomputedShadows=false
    End Object
    BoosterMesh=BoosterActorMesh


    bMovable=true         //Actor can be moved.
    bNoEncroachCheck=true //Doesn't do the overlap check when it moves.
}
