//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Give Shield > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action gives a determined shield to the given pawns.
//================================================================================
class SeqAct_GiveShield extends SequenceAction;


/**Name of the shield that is granted: Bubble, Flame, Magnetic or Standard.*/ var() name ShieldName;


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
            SGDKPlayerPawn(P).Shield.GotoState(ShieldName);
    }
}


defaultproperties
{
    bCallHandler=false    //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"    //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Give Shield" //Text label that describes this object.

    ShieldName=Standard
}
