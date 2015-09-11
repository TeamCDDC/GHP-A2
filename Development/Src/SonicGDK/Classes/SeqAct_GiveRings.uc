//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Give Rings > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action gives an amount of rings to the given pawns.
//================================================================================
class SeqAct_GiveRings extends SequenceAction;


/**Amount of rings that are granted.*/ var() int Amount;


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

        if (P != none && SGDKPlayerPawn(P) != none)
            SGDKPlayerPawn(P).GiveHealth(Amount,SGDKPlayerPawn(P).SuperHealthMax);
    }
}


defaultproperties
{
    bCallHandler=false   //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"   //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Give Rings" //Text label that describes this object.
    VariableLinks[1]=(ExpectedType=class'SeqVar_Int',LinkDesc="Amount",MinVars=0,MaxVars=1,PropertyName=Amount)
}
