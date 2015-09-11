//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Keep Running > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action forces players to run forward for a while (turning is enabled).
//================================================================================
class SeqAct_KeepRunning extends SequenceAction;


/**How much time the player is forced to run forward.*/ var() float DisabledInputTime;


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
            SGDKPlayerController(C).KeepRunning(DisabledInputTime);
    }
}


defaultproperties
{
    bCallHandler=false            //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"            //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Keep Player Running" //Text label that describes this object.

    DisabledInputTime=5.0
}
