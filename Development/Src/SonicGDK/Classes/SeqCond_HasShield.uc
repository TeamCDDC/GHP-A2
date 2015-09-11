//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Condition Has Shield > SequenceCondition > SequenceOp >
//     > SequenceObject > Object
//
// A sequence condition is a representation of a conditional statement such as a
// simple boolean expression. The appropriate output link is activated based on
// the evaluation of a bunch of variables.
// This condition activates output depending on whether the given player has a
// determined shield.
//================================================================================
class SeqCond_HasShield extends SequenceCondition;


/**Pawn to check its shield.*/ var Actor Target;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local Pawn P;
    local string StateName;
    local int i;

    //Try to get a pawn out of the given target actor.
    P = GetPawn(Target);

    if (P != none && SGDKPlayerPawn(P) != none)
    {
        if (!SGDKPlayerPawn(P).HasShield())
            OutputLinks[0].bHasImpulse = true;
        else
        {
            StateName = string(SGDKPlayerPawn(P).Shield.GetStateName());

            for (i = 1; i < OutputLinks.Length; i++)
                if (OutputLinks[i].LinkDesc ~= StateName)
                {
                    OutputLinks[i].bHasImpulse = true;

                    break;
                }
        }
    }
}


defaultproperties
{
    ObjCategory="SGDK"                   //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Has Shield"                 //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="No")       //Output link containing a connection; target doesn't have a shield.
    OutputLinks[1]=(LinkDesc="Bubble")   //Output link containing a connection; target has a bubble shield.
    OutputLinks[2]=(LinkDesc="Flame")    //Output link containing a connection; target has a flame shield.
    OutputLinks[3]=(LinkDesc="Magnetic") //Output link containing a connection; target has a magnetic shield.
    OutputLinks[4]=(LinkDesc="Standard") //Output link containing a connection; target has a standard shield.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
}
