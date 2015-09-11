//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Save Status > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action notifies players to save its status.
//================================================================================
class SeqAct_SaveStatus extends SequenceAction;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Controller C;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        C = GetController(Actor(ObjectVar.GetObjectValue()));

        if (C != none && SGDKPlayerController(C) != none)
            SGDKPlayerController(C).StatusSave();
    }
}


defaultproperties
{
    bCallHandler=false           //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"           //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Save Player Status" //Text label that describes this object.
}
