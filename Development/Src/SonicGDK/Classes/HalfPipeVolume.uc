//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Half Pipe Volume > Volume > Brush > Actor
//
// This is a bounding volume, an invisible zone or area which tracks other actors
// entering and exiting it.
// This type tells pawns to switch to Sonic Physics mode if possible.
//================================================================================
class HalfPipeVolume extends Volume
    ClassGroup(SGDK)
    placeable;


/**Applies this volume to only a certain type of actor.*/ var() class<Actor> ApplyToActorClass;
        /**Applies this volume to only a certain actor.*/ var() Actor ApplyToActorObject;


defaultproperties
{
}
