//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Dash Ring Actor Movable > DashRingActor > BetterTouchActor > SGDKActor > Actor
//
// The Dash Ring Actor is the dash ring object found in modern Sonic games.
// Players should pass through the ring to get catapulted into the air.
// This type can be moved during gameplay (attached to matinee, etc).
//================================================================================
class DashRingActor_Movable extends DashRingActor;


/**The ring's light environment.*/ var() editconst DynamicLightEnvironmentComponent LightEnvironment;


defaultproperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=DashRingLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.0
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=DashRingLightEnvironment
    Components.Add(DashRingLightEnvironment)


    Begin Object Name=DashRingStaticMesh
        LightEnvironment=DashRingLightEnvironment
        bAllowApproximateOcclusion=false
        bForceDirectLightMap=false
        bUsePrecomputedShadows=false
    End Object
    DashRingMesh=DashRingStaticMesh


    bMovable=true         //Actor can be moved.
    bNoEncroachCheck=true //Doesn't do the overlap check when it moves.
}
