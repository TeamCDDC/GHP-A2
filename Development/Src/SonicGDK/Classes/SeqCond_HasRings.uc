//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Condition Has Rings > SequenceCondition > SequenceOp >
//     > SequenceObject > Object
//
// A sequence condition is a representation of a conditional statement such as a
// simple boolean expression. The appropriate output link is activated based on
// the evaluation of a bunch of variables.
// This condition activates output depending on whether the given player has a
// determined amount of rings.
//================================================================================
class SeqCond_HasRings extends SequenceCondition;


                /**Number to check against.*/ var() int Number;
/**Player to check his/her amount of rings.*/ var Actor Target;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local Pawn P;

    //Try to get a pawn out of the given target actor.
    P = GetPawn(Target);

    if (P != none)
        OutputLinks[(P.Health - 1 >= Number) ? 0 : 1].bHasImpulse = true;
}


defaultproperties
{
    ObjCategory="SGDK"                     //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Has Rings"                    //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Rings >= N") //Output link containing a connection; target has n or more rings.
    OutputLinks[1]=(LinkDesc="Rings < N")  //Output link containing a connection; target has less than n rings.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
}
