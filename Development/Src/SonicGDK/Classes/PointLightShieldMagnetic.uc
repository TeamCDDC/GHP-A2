//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Point Light Shield Magnetic > SGDKSpawnablePointLight > PointLightMovable >
//     > PointLight > Light > Actor
//
// An omnidirectional movable point of light used for magnetic shield.
//================================================================================
class PointLightShieldMagnetic extends SGDKSpawnablePointLight;


defaultproperties
{
    Begin Object Name=PointLightComponent0
        bCastCompositeShadow=false
        bEnabled=false
        BloomTint=(R=245,B=230,G=245)
        Brightness=1.0
        CastDynamicShadows=false
        CastShadows=false
        CastStaticShadows=false
        LightColor=(R=245,B=230,G=245)
        Radius=128.0
    End Object
    LightComponent=PointLightComponent0
}
