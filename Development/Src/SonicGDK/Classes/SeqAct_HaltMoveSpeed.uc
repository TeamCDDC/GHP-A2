//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Halt Move Speed > SequenceAction > SequenceOp >
//     SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action halts movement of the given pawn.
//================================================================================
class SeqAct_HaltMoveSpeed extends SequenceAction;


defaultproperties
{
    ObjCategory="SGDK"        //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Halt Move Speed" //Text label that describes this object.
    InputLinks[0]=(LinkDesc="Halt")
    InputLinks[1]=(LinkDesc="Unhalt")
}
