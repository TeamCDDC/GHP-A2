//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Force Volume Movable > ForceVolume > UDKForcedDirectionVolume > PhysicsVolume >
//     > Volume > Brush > Actor
//
// This is a bounding volume, an invisible zone or area which tracks other actors
// entering and exiting it.
// This type pushes actors away along a specified direction, and can be moved
// during gameplay (attached to matinee, etc).
//================================================================================
class ForceVolume_Movable extends ForceVolume;


defaultproperties
{
    bMovable=true //Actor can be moved.
}
