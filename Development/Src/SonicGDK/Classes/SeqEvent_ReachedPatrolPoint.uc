//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Reached Patrol Point > SequenceEvent > SequenceOp >
//     > SequenceObject > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event should be triggered when an enemy reaches a patrol point.
//================================================================================
class SeqEvent_ReachedPatrolPoint extends SequenceEvent;


defaultproperties
{
    bPlayerOnly=false                   //This event doesn't require to be activated by a player.
    MaxTriggerCount=0                   //This event can always be activated.
    ObjCategory="SGDK"                  //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Reached Patrol Point"      //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Reached") //Output link containing a connection; enemy reached a patrol point.
}
