//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Toggle Enemy Data > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action manipulates data stored in an enemy.
//================================================================================
class SeqAct_ToggleEnemyData extends SequenceAction;


/**If true, an item in the Damage Zones list is toggled.*/ var() bool bDamageZone;
  /**If true, an item in the Weak Spots list is toggled.*/ var() bool bWeakSpot;
         /**Index of an item in the list of zones/spots.*/ var() byte Index;


defaultproperties
{
    ObjCategory="SGDK"          //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Toggle Enemy Data" //Text label that describes this object.
    InputLinks[0]=(LinkDesc="Turn On")
    InputLinks[1]=(LinkDesc="Turn Off")
    InputLinks[2]=(LinkDesc="Toggle")
}
