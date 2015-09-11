//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Player Spawn > SequenceEvent > SequenceOp > SequenceObject >
//     > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event activates if a player is spawned using the associated player start
// object.
//================================================================================
class SeqEvent_PlayerSpawn extends SequenceEvent;


defaultproperties
{
    MaxTriggerCount=0                   //This event can always be activated.
    ObjCategory="SGDK"                  //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Player Spawn"              //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Spawned") //Output link containing a connection; activated if a player is spawned.
}
