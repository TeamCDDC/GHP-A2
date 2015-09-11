//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Event Enemy Spawn > SequenceEvent > SequenceOp > SequenceObject >
//     > Object
//
// A sequence event is a representation of any event that is used to instigate a
// Kismet sequence.
// This event activates the appropriate output link for the various enemy spawner
// events.
//================================================================================
class SeqEvent_EnemySpawn extends SequenceEvent;


/**Reference to the enemy spawned by the spawner.*/ var SGDKEnemyPawn SpawnedEnemy;


/**
 * Called when this node is activated.
 */
event Activated()
{
    if (EnemySpawnerInfo(Originator) != none)
        SpawnedEnemy = EnemySpawnerInfo(Originator).EnemyPawn;
}


defaultproperties
{
    bPlayerOnly=false                    //This event doesn't require to be activated by a player.
    MaxTriggerCount=0                    //This event can always be activated.
    ObjCategory="SGDK"                   //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Enemy Spawn"                //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Spawned")  //Output link containing a connection; activated if the enemy of the associated enemy spawner is spawned.
    OutputLinks[1]=(LinkDesc="Vanished") //Output link containing a connection; activated if the enemy of the associated enemy spawner is vanished.
    VariableLinks[0]=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawned Enemy",bWriteable=true,PropertyName=SpawnedEnemy)
}
