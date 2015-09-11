//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Condition Has Emeralds > SequenceCondition > SequenceOp >
//     > SequenceObject > Object
//
// A sequence condition is a representation of a conditional statement such as a
// simple boolean expression. The appropriate output link is activated based on
// the evaluation of a bunch of variables.
// This condition activates output depending on whether the given player has a
// determined amount of Chaos Emeralds.
//================================================================================
class SeqCond_HasEmeralds extends SequenceCondition;


                         /**Number to check against.*/ var() byte Number;
/**Player to check his/her amount of Chaos Emeralds.*/ var Actor Target;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local Controller C;

    //Try to get a controller out of the given target actor.
    C = GetController(Target);

    if (C != none && SGDKPlayerController(C) != none)
        OutputLinks[(SGDKPlayerController(C).ChaosEmeralds >= Number) ? 0 : 1].bHasImpulse = true;
}


defaultproperties
{
    ObjCategory="SGDK"                        //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Has Emeralds"                    //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Emeralds >= N") //Output link containing a connection; target has n or more Chaos Emeralds.
    OutputLinks[1]=(LinkDesc="Emeralds < N")  //Output link containing a connection; target has less than n Chaos Emeralds.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
}
