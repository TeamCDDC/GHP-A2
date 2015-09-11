//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Spawnable Point Light > PointLightMovable > PointLight > Light > Actor
//
// An omnidirectional movable and spawnable point of light.
//================================================================================
class SGDKSpawnablePointLight extends PointLightMovable
    abstract
    notplaceable;


defaultproperties
{
    bNoDelete=false
}
