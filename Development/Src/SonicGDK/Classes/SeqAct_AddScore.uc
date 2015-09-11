//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Add Score > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action gives an amount of score points to players.
//================================================================================
class SeqAct_AddScore extends SequenceAction;


/**Score points that are granted.*/ var() int Amount;


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
            SGDKPlayerController(C).AddScore(Amount);
    }
}


defaultproperties
{
    bCallHandler=false  //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"  //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Add Score" //Text label that describes this object.
    VariableLinks[1]=(ExpectedType=class'SeqVar_Int',LinkDesc="Amount",MinVars=0,MaxVars=1,PropertyName=Amount)
}
