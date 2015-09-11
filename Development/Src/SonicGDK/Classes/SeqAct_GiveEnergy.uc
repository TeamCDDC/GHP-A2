//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Give Energy > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action gives an amount of energy points to the given pawns.
//================================================================================
class SeqAct_GiveEnergy extends SequenceAction;


/**Amount of energy points that are granted.*/ var() float Amount;


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
            SGDKPlayerPawn(P).ReceiveEnergy(Amount);
    }
}


defaultproperties
{
    bCallHandler=false    //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"    //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Give Energy" //Text label that describes this object.
    VariableLinks[1]=(ExpectedType=class'SeqVar_Float',LinkDesc="Amount",MinVars=0,MaxVars=1,PropertyName=Amount)
}
