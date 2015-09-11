//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Water Volume Dynamic > SGDKWaterVolume > UTWaterVolume > WaterVolume >
//     > PhysicsVolume > Volume > Brush > Actor
//
// Water volumes are used to represent the zones which are filled with water.
// This type can be moved during gameplay (attached to matinee, etc).
//================================================================================
class SGDKWaterVolume_Dynamic extends SGDKWaterVolume;


defaultproperties
{
    bStatic=false //It moves or changes over time.
}
