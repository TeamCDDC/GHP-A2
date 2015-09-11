//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Scale Deceleration > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action scales on ground deceleration rate of given pawns.
//================================================================================
class SeqAct_ScaleDeceleration extends SequenceAction;


/**Additional scale factor applied to on ground deceleration rate.*/ var() float Scale<ClampMin=0.01>;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Pawn P;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        P = GetPawn(Actor(ObjectVar.GetObjectValue()));

        if (P != none && SGDKPlayerPawn(P) != none)
            SGDKPlayerPawn(P).ScaleDeceleration(FMax(0.01,Scale));
    }
}


defaultproperties
{
    bCallHandler=false           //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"           //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Scale Deceleration" //Text label that describes this object.
    VariableLinks[1]=(ExpectedType=class'SeqVar_Float',LinkDesc="Scale",MinVars=0,MaxVars=1,PropertyName=Scale)

    Scale=1.0
}
