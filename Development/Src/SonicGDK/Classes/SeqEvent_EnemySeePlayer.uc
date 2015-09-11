//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Enemy See Player > SequenceEvent > SequenceOp > SequenceObject >
//     > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event should be triggered when an enemy sees a player.
//================================================================================
class SeqEvent_EnemySeePlayer extends SequenceEvent;


 /**Reference to the enemy pawn.*/ var Pawn EnemyPawn;
/**Reference to the player pawn.*/ var Pawn PlayerPawn;


/**
 * Called when this node is activated.
 */
event Activated()
{
    if (SGDKEnemyPawn(Originator) != none)
    {
        EnemyPawn = Pawn(Originator);
        PlayerPawn = EnemyPawn.Controller.Enemy;
    }
}


defaultproperties
{
    bPlayerOnly=false                             //This event doesn't require to be activated by a player.
    MaxTriggerCount=0                             //This event can always be activated.
    ObjCategory="SGDK"                            //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Enemy See Player"                    //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Noticed Player")    //Output link containing a connection; enemy noticed the player.
    OutputLinks[1]=(LinkDesc="Seeing Player")     //Output link containing a connection; enemy is seeing the player.
    OutputLinks[2]=(LinkDesc="Not Seeing Player") //Output link containing a connection; enemy isn't seeing the player.
    OutputLinks[3]=(LinkDesc="Lost Player")       //Output link containing a connection; enemy lost the player.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Enemy Pawn",bWriteable=true,PropertyName=EnemyPawn)
    VariableLinks[1]=(ExpectedType=class'SeqVar_Object',LinkDesc="Player Pawn",bWriteable=true,PropertyName=PlayerPawn)
}
