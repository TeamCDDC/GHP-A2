//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Condition Is Super Form > SequenceCondition > SequenceOp >
//     > SequenceObject > Object
//
// A sequence condition is a representation of a conditional statement such as a
// simple boolean expression. The appropriate output link is activated based on
// the evaluation of a bunch of variables.
// This condition activates output depending on whether the given pawn has super
// form status and its advantages.
//================================================================================
class SeqCond_IsSuperForm extends SequenceCondition;


/**Pawn to check its super form status.*/ var Actor Target;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local Pawn P;

    //Try to get a pawn out of the given target actor.
    P = GetPawn(Target);

    if (P != none && SGDKPlayerPawn(P) != none)
        OutputLinks[SGDKPlayerPawn(P).bSuperForm ? 0 : 1].bHasImpulse = true;
}


defaultproperties
{
    ObjCategory="SGDK"              //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Is Super Form"         //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Yes") //Output link containing a connection; target has super form status.
    OutputLinks[1]=(LinkDesc="No")  //Output link containing a connection; target doesn't have super form status.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
}
