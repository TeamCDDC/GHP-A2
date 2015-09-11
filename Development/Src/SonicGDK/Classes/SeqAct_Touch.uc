//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Touch > SequenceAction > SequenceOp > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action triggers touch events between targets and the given actor.
//================================================================================
class SeqAct_Touch extends SequenceAction;


/**Actor responsible for touch.*/ var Actor Instigator;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Actor A;

    if (Instigator != none)
        foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
        {
            A = Actor(ObjectVar.GetObjectValue());

            if (A != none)
            {
                A.Touch(Instigator,Instigator.CollisionComponent,Instigator.Location,Normal(Instigator.Location - A.Location));
                Instigator.Touch(A,A.CollisionComponent,A.Location,Normal(A.Location - Instigator.Location));
            }
        }
}


defaultproperties
{
    bCallHandler=false      //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"      //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Trigger Touch" //Text label that describes this object.
    VariableLinks[0]=(MinVars=1)
    VariableLinks[1]=(ExpectedType=class'SeqVar_Object',LinkDesc="Instigator",MinVars=0,MaxVars=1,PropertyName=Instigator)
}
