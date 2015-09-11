//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Reset Level > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action resets the level.
//================================================================================
class SeqAct_ResetLevel extends SequenceAction;


/**
 * Called when this node is activated.
 */
event Activated()
{
    GetWorldInfo().Game.ResetLevel();
}


defaultproperties
{
    bCallHandler=false    //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"    //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Reset Level" //Text label that describes this object.
    VariableLinks.Empty
}
