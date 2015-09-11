//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Sensor Touch > SequenceEvent > SequenceOp > SequenceObject >
//     > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event should be triggered when the touched functions of a SensorActor are
// called.
//================================================================================
class SeqEvent_SensorTouch extends SequenceEvent;


defaultproperties
{
    MaxTriggerCount=0                             //This event can always be activated.
    ObjCategory="SGDK"                            //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Sensor Touch"                        //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Touched")           //Output link containing a connection; event instigator is whithin the sensor.
    OutputLinks[1]=(LinkDesc="UnTouched (Front)") //Output link containing a connection; event instigator is in front of the sensor.
    OutputLinks[2]=(LinkDesc="UnTouched (Back)")  //Output link containing a connection; event instigator is behind the sensor.
}
