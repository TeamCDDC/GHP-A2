//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Destroyable Event > SequenceEvent > SequenceOp >
//     > SequenceObject > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event should be triggered when a destroyable object is hit or respawns.
//================================================================================
class SeqEvent_DestroyableEvent extends SequenceEvent;


defaultproperties
{
    bPlayerOnly=false                     //This event doesn't require to be activated by a player.
    MaxTriggerCount=0                     //This event can always be activated.
    ObjCategory="SGDK"                    //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Destroyable Event"           //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Hit")       //Output link containing a connection; destroyable object got hit.
    OutputLinks[1]=(LinkDesc="Destroyed") //Output link containing a connection; destroyable object was destroyed.
    OutputLinks[2]=(LinkDesc="Respawned") //Output link containing a connection; destroyable object respawned.
}
