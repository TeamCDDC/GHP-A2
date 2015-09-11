//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Roll Pawn > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action forces the given pawn to roll on ground.
//================================================================================
class SeqAct_RollPawn extends SequenceAction;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Pawn P;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        P = GetPawn(Actor(ObjectVar.GetObjectValue()));

        if (P != none && !IsZero(P.Velocity) && SGDKPlayerPawn(P) != none && SGDKPlayerPawn(P).IsTouchingGround())
            SGDKPlayerPawn(P).Duck(true);
    }
}


defaultproperties
{
    bCallHandler=false  //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"  //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Roll Pawn" //Text label that describes this object.
    VariableLinks[0]=(MinVars=1,MaxVars=1)
}
