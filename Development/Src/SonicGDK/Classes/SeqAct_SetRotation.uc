//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Set Rotation > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action changes actor's rotation.
//================================================================================
class SeqAct_SetRotation extends SequenceAction;


 /**If true, the target actor must be a Controller.*/ var() bool bTargetIsController;
/**Default value to use if no variables are linked.*/ var() rotator RotationValue;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Vector VectorVar;
    local SeqVar_Object ObjectVar;
    local Pawn P;
    local Actor A;

    foreach LinkedVariables(class'SeqVar_Vector',VectorVar,"Rotation")
        RotationValue = rotator(VectorVar.VectValue);

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        A = Actor(ObjectVar.GetObjectValue());
        P = GetPawn(A);

        if (P != none && SGDKPlayerPawn(P) != none)
        {
            if (!bTargetIsController)
                SGDKPlayerPawn(P).ForceRotation(RotationValue,false,true);
            else
                SGDKPlayerPawn(P).SetViewRotation(RotationValue);
        }
        else
            A.SetRotation(RotationValue);
    }
}


defaultproperties
{
    bCallHandler=false           //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"           //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Set Actor Rotation" //Text label that describes this object.
    VariableLinks[0]=(MinVars=1)
    VariableLinks[1]=(ExpectedType=class'SeqVar_Vector',LinkDesc="Rotation",MinVars=0,MaxVars=1)
}
