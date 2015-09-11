//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Handle Touch > SequenceEvent > SequenceOp > SequenceObject >
//     > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event should be triggered when a pawn starts/stops hanging from a handle.
//================================================================================
class SeqEvent_HandleTouch extends SequenceEvent;


defaultproperties
{
    MaxTriggerCount=0                     //This event can always be activated.
    ObjCategory="SGDK"                    //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Handle Touch"                //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Touched")   //Output link containing a connection; event instigator started hanging from the handle.
    OutputLinks[1]=(LinkDesc="UnTouched") //Output link containing a connection; event instigator stopped hanging from the handle.
}
