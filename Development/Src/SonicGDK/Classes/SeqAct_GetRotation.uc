//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Get Rotation > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action gets actor's rotation.
//================================================================================
class SeqAct_GetRotation extends SequenceAction;


/**Holds the rotation information.*/ var vector Rotation;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Pawn P;
    local Actor A;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        A = Actor(ObjectVar.GetObjectValue());
        P = GetPawn(A);

        if (P != none && SGDKPlayerPawn(P) != none)
            Rotation = vector(SGDKPlayerPawn(P).GetRotation());
        else
            Rotation = vector(A.Rotation);
    }
}


defaultproperties
{
    bCallHandler=false           //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"           //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Get Actor Rotation" //Text label that describes this object.
    VariableLinks[0]=(MaxVars=1)
    VariableLinks[1]=(ExpectedType=class'SeqVar_Vector',LinkDesc="Rotation",bWriteable=true,PropertyName=Rotation)
}
