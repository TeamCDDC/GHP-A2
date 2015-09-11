//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Condition Is Causing Damage > SequenceCondition > SequenceOp >
//     > SequenceObject > Object
//
// A sequence condition is a representation of a conditional statement such as a
// simple boolean expression. The appropriate output link is activated based on
// the evaluation of a bunch of variables.
// This condition activates output depending on whether the given pawn is
// performing a melee attack that inflicts a required damage type.
//================================================================================
class SeqCond_IsCausingDamage extends SequenceCondition;


/**Whether subclasses of the specified class count.*/ var() bool bAllowSubclass;
                     /**Melee damage type to check.*/ var() class<DamageType> RequiredDamageType<AllowAbstract>;
                  /**Pawn to check its melee state.*/ var Actor Target;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local Pawn P;

    //Try to get a pawn out of the given target actor.
    P = GetPawn(Target);

    if (P != none && SGDKPlayerPawn(P) != none)
    {
        if (!bAllowSubclass)
            OutputLinks[(SGDKPlayerPawn(P).GetMeleeDamageType() == RequiredDamageType) ? 0 : 1].bHasImpulse = true;
        else
            OutputLinks[(ClassIsChildOf(SGDKPlayerPawn(P).GetMeleeDamageType(),RequiredDamageType)) ? 0 : 1].bHasImpulse = true;
    }
}


defaultproperties
{
    ObjCategory="SGDK"                           //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Is Causing Melee Damage"            //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Causing Pain")     //Output link containing a connection; target is performing a melee attack.
    OutputLinks[1]=(LinkDesc="Not Causing Pain") //Output link containing a connection; target isn't performing a melee attack.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
}
