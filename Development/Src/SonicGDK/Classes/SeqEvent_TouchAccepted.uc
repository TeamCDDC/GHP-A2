//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Touch Accepted > SequenceEvent > SequenceOp > SequenceObject >
//     > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event should be triggered when an object accepts a touch/bump event and
// reacts to it.
//================================================================================
class SeqEvent_TouchAccepted extends SequenceEvent;


defaultproperties
{
    MaxTriggerCount=0                   //This event can always be activated.
    ObjCategory="SGDK"                  //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Touch Accepted"            //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Touched") //Output link containing a connection; event instigator has touched an object that reacts.
}
