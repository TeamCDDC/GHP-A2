//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Change World Collision > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action changes actor's collision channel that interacts with the world.
//================================================================================
class SeqAct_ChangeWorldCollision extends SequenceAction;


/**If true, the target actor collides with the world.*/ var() bool bCollideWorld;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Actor A;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        A = Actor(ObjectVar.GetObjectValue());

        if (A != none)
            A.bCollideWorld = bCollideWorld;
    }
}


defaultproperties
{
    bCallHandler=false               //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"               //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Change World Collision" //Text label that describes this object.
    VariableLinks[0]=(MinVars=1)

    bCollideWorld=true
}
