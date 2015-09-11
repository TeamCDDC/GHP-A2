//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Condition Is Actor Tag > SequenceCondition > SequenceOp >
//     > SequenceObject > Object
//
// A sequence condition is a representation of a conditional statement such as a
// simple boolean expression. The appropriate output link is activated based on
// the evaluation of a bunch of variables.
// This condition activates output depending on the tag of the given actor.
//================================================================================
class SeqCond_IsActorTag extends SequenceCondition;


/**Actor tag name to check.*/ var() name ActorTag;
 /**Actor to check its tag.*/ var Actor Target;


/**
 * Called when this node is activated.
 */
event Activated()
{
    OutputLinks[(Target.Tag == ActorTag) ? 0 : 1].bHasImpulse = true;
}


defaultproperties
{
    ObjCategory="SGDK"              //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Is Actor Tag"          //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Yes") //Output link containing a connection; target is performing a melee attack.
    OutputLinks[1]=(LinkDesc="No")  //Output link containing a connection; target isn't performing a melee attack.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
}
