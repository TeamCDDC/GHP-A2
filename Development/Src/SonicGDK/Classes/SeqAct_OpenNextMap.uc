//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Open Next Map > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action loads the next map in a list.
//================================================================================
class SeqAct_OpenNextMap extends SequenceAction;


/**
 * Called when this node is activated.
 */
event Activated()
{
    class'SGDKGameInfo'.static.OpenNextMap(SGDKGameInfo(GetWorldInfo().Game).MapsSequence);
}


defaultproperties
{
    bCallHandler=false      //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"      //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Open Next Map" //Text label that describes this object.
    OutputLinks.Empty
    VariableLinks.Empty
}
