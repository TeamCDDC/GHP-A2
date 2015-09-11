//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Condition Using Gamepad > SequenceCondition > SequenceOp >
//     > SequenceObject > Object
//
// A sequence condition is a representation of a conditional statement such as a
// simple boolean expression. The appropriate output link is activated based on
// the evaluation of a bunch of variables.
// This condition activates output depending on whether the given player is using
// a gamepad to play.
//================================================================================
class SeqCond_UsingGamepad extends SequenceCondition;


/**Player to check if he/she is using gamepad.*/ var Actor Target;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local Controller C;

    //Try to get a controller out of the given target actor.
    C = GetController(Target);

    if (C != none && SGDKPlayerController(C) != none)
        OutputLinks[SGDKPlayerController(C).PlayerInput.bUsingGamepad ? 0 : 1].bHasImpulse = true;
}


defaultproperties
{
    ObjCategory="SGDK"                        //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Is Using Gamepad"                //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Using Pad")     //Output link containing a connection; target is using a gamepad.
    OutputLinks[1]=(LinkDesc="Not Using Pad") //Output link containing a connection; target isn't using a gamepad.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
}
