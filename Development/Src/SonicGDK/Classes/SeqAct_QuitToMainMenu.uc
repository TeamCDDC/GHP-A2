//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Quit To Main Menu > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action quits the game to go to the main menu.
//================================================================================
class SeqAct_QuitToMainMenu extends SequenceAction;


defaultproperties
{
    ObjCategory="SGDK"          //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Quit to Main Menu" //Text label that describes this object.
    OutputLinks.Empty
}
