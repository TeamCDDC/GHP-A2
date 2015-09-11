//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Point Light Board > SGDKSpawnablePointLight > PointLightMovable > PointLight >
//     > Light > Actor
//
// An omnidirectional movable point of light used for the Sonic 3 & Knuckles
// Special Stage.
//================================================================================
class PointLightBoard extends SGDKSpawnablePointLight;


defaultproperties
{
    Begin Object Name=PointLightComponent0
        bCastCompositeShadow=false
        BloomTint=(R=255,G=255,B=255)
        Brightness=5.0
        CastDynamicShadows=false
        CastShadows=false
        CastStaticShadows=false
        LightColor=(R=255,G=255,B=255)
        LightingChannels=(BSP=false,CompositeDynamic=false,Dynamic=false,Gameplay_4=true,Static=false)
        Radius=512.0
    End Object
}
