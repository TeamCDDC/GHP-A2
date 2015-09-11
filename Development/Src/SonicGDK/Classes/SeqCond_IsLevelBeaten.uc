//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Condition Is Level Beaten > SequenceCondition > SequenceOp >
//     > SequenceObject > Object
//
// A sequence condition is a representation of a conditional statement such as a
// simple boolean expression. The appropriate output link is activated based on
// the evaluation of a bunch of variables.
// This condition activates output depending on whether the given level is beaten.
//================================================================================
class SeqCond_IsLevelBeaten extends SequenceCondition;


/**File name of the level.*/ var() string MapFileName;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local JsonObject Data;

    if (MapFileName != "")
    {
        Data = SGDKGameInfo(GetWorldInfo().Game).PersistentData.GetData();

        if (Data.HasKey("Maps") &&
            InStr(Data.GetStringValue("Maps"),"." $ MapFileName $ ".",,true) != INDEX_NONE)
            OutputLinks[0].bHasImpulse = true;
        else
            OutputLinks[1].bHasImpulse = true;
    }
    else
        OutputLinks[1].bHasImpulse = true;
}


defaultproperties
{
    ObjCategory="SGDK"              //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Is Level Beaten"       //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Yes") //Output link containing a connection; target is performing a melee attack.
    OutputLinks[1]=(LinkDesc="No")  //Output link containing a connection; target isn't performing a melee attack.
}
