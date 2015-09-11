//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Toggle Mini Size > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action decreases the size of the given pawn.
//================================================================================
class SeqAct_ToggleMiniSize extends SequenceAction;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Pawn Pawn;
    local SGDKPlayerPawn P;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        Pawn = GetPawn(Actor(ObjectVar.GetObjectValue()));

        if (Pawn != none && SGDKPlayerPawn(Pawn) != none)
        {
            P = SGDKPlayerPawn(Pawn);

            if (InputLinks[0].bHasImpulse)
            {
                if (!P.bMiniSize)
                    P.MiniSize(true);
            }
            else
                if (InputLinks[1].bHasImpulse)
                {
                    if (P.bMiniSize)
                    {
                        P.MiniSize(false);

                        if (P.bMiniSize)
                            P.SetTimer(0.25,true,NameOf(P.MiniSize));
                    }
                }
                else
                    P.MiniSize(!P.bMiniSize);
        }
    }
}


defaultproperties
{
    bCallHandler=false         //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"         //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Toggle Mini Size" //Text label that describes this object.
    InputLinks[0]=(LinkDesc="Turn On")
    InputLinks[1]=(LinkDesc="Turn Off")
    InputLinks[2]=(LinkDesc="Toggle")
    VariableLinks[0]=(MinVars=1,MaxVars=1)
}
