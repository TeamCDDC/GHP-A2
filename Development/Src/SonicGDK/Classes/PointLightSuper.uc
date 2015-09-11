//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Point Light Super > SGDKSpawnablePointLight > PointLightMovable > PointLight >
//     > Light > Actor
//
// An omnidirectional movable point of light used for super form.
//================================================================================
class PointLightSuper extends SGDKSpawnablePointLight;


defaultproperties
{
    Begin Object Name=PointLightComponent0
        bCastCompositeShadow=false
        BloomTint=(R=255,G=255,B=0)
        Brightness=2.5
        CastDynamicShadows=false
        CastShadows=false
        CastStaticShadows=false
        LightColor=(R=255,G=255,B=0)
        Radius=256.0
    End Object
    LightComponent=PointLightComponent0
}
