//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Point Light Invincible > SGDKSpawnablePointLight > PointLightMovable >
//     > PointLight > Light > Actor
//
// An omnidirectional movable point of light used for invulnerability.
//================================================================================
class PointLightInvincible extends SGDKSpawnablePointLight;


defaultproperties
{
    Begin Object Name=PointLightComponent0
        bCastCompositeShadow=false
        BloomTint=(R=255,B=255,G=255)
        Brightness=2.0
        CastDynamicShadows=false
        CastShadows=false
        CastStaticShadows=false
        LightColor=(R=255,B=255,G=255)
        Radius=96.0
    End Object
    LightComponent=PointLightComponent0
}
