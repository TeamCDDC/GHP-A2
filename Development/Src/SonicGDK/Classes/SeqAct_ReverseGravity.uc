//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Reverse Gravity > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action reverses world gravity direction.
//================================================================================
class SeqAct_ReverseGravity extends SequenceAction;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local WorldInfo WorldInfo;
    local SGDKPlayerPawn P;

    WorldInfo = GetWorldInfo();

    WorldInfo.WorldGravityZ *= -1.0;

    foreach WorldInfo.AllPawns(class'SGDKPlayerPawn',P)
        if (P.Health > 0 && !P.bAmbientCreature)
            P.ReversedGravity(WorldInfo.WorldGravityZ > 0.0);
}


defaultproperties
{
    bCallHandler=false        //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"        //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Reverse Gravity" //Text label that describes this object.
    VariableLinks.Empty
}
