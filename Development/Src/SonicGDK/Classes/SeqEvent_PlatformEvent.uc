//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Platform Event > SequenceEvent > SequenceOp > SequenceObject >
//     > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event should be triggered when a platform object falls or respawns.
//================================================================================
class SeqEvent_PlatformEvent extends SequenceEvent;


defaultproperties
{
    bPlayerOnly=false                        //This event doesn't require to be activated by a player.
    MaxTriggerCount=0                        //This event can always be activated.
    ObjCategory="SGDK"                       //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Platform Event"                 //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Obj Attached") //Output link containing a connection; object was attached to platform object.
    OutputLinks[1]=(LinkDesc="Obj Detached") //Output link containing a connection; object was detached from platform object.
    OutputLinks[2]=(LinkDesc="Fallen")       //Output link containing a connection; platform object fell to ground.
    OutputLinks[3]=(LinkDesc="Landed")       //Output link containing a connection; platform object landed on ground.
    OutputLinks[4]=(LinkDesc="Respawned")    //Output link containing a connection; platform object respawned.
}
