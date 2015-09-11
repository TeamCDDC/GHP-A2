//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Play Special Stage > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action forces a player pawn to play a special stage.
//================================================================================
class SeqAct_PlaySpecialStage extends SequenceAction;


/**Reference to the associated special stage object.*/ var SpecialStageActor SpecialStage;


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
            SpecialStage.ManagePawn(SGDKPlayerPawn(P));
    }
}


defaultproperties
{
    bCallHandler=false           //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"           //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Play Special Stage" //Text label that describes this object.
    VariableLinks[0]=(MinVars=1,MaxVars=1)
    VariableLinks[1]=(ExpectedType=class'SeqVar_Object',LinkDesc="Special Stage",MinVars=1,MaxVars=1,PropertyName=SpecialStage)
}
