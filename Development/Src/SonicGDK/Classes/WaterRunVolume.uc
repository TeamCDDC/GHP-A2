//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Water Run Volume > Volume > Brush > Actor
//
// This is a bounding volume, an invisible zone or area which tracks other actors
// entering and exiting it.
// This type tells pawns to try to run on water if possible.
//================================================================================
class WaterRunVolume extends Volume
    ClassGroup(SGDK)
    placeable;


defaultproperties
{
}
