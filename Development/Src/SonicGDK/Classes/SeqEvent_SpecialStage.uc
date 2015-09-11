//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Special Stage > SequenceEvent > SequenceOp > SequenceObject >
//     > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event should be triggered when a Special Stage is loaded/unloaded.
//================================================================================
class SeqEvent_SpecialStage extends SequenceEvent;


defaultproperties
{
    MaxTriggerCount=0                     //This event can always be activated.
    ObjCategory="SGDK"                    //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Special Stage Events"        //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="PreLoad")   //Output link containing a connection; Special Stage will be loaded.
    OutputLinks[1]=(LinkDesc="Loaded")    //Output link containing a connection; Special Stage is loaded.
    OutputLinks[2]=(LinkDesc="PreUnload") //Output link containing a connection; Special Stage will be unloaded.
    OutputLinks[3]=(LinkDesc="Unloaded")  //Output link containing a connection; Special Stage has been unloaded.
}
