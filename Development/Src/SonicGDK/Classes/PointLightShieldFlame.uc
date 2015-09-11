//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Point Light Shield Flame > SGDKSpawnablePointLight > PointLightMovable >
//     > PointLight > Light > Actor
//
// An omnidirectional movable point of light used for flame shield.
//================================================================================
class PointLightShieldFlame extends SGDKSpawnablePointLight;


defaultproperties
{
    Begin Object Class=LightFunction Name=FlameLightFunction
        SourceMaterial=Material'SonicGDKPackStaticMeshes.Materials.ShieldFlameLightMaterial'
    End Object


    Begin Object Name=PointLightComponent0
        bCastCompositeShadow=false
        bEnabled=false
        Brightness=3.0
        CastDynamicShadows=false
        CastShadows=false
        CastStaticShadows=false
        Function=FlameLightFunction
        Radius=256.0
    End Object
    LightComponent=PointLightComponent0
}
