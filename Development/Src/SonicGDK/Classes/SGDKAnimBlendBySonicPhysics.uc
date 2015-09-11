//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Animation Blend By Sonic Physics > UDKAnimBlendBase > AnimNodeBlendList >
//     > AnimNode > AnimObject > Object
//
// A blend node for any animation tree to filter a set of animations according to
// Sonic Physics mode status.
//================================================================================
class SGDKAnimBlendBySonicPhysics extends UDKAnimBlendBase;


/**
 * Changes active child AnimNode according to Sonic Physics mode.
 * @param bSonicPhysicsMode  sets/unsets active mode
 */
function PhysicsChanged(bool bSonicPhysicsMode)
{
    if (!bSonicPhysicsMode)
        SetActiveChild(0,GetBlendTime(0));
    else
        SetActiveChild(1,GetBlendTime(1));
}


defaultproperties
{
    bFixNumChildren=true                     //New children connectors can't be added.
    Children[0]=(Name="Inactive",Weight=1.0) //AnimNode for inactive state.
    Children[1]=(Name="Active")              //AnimNode for active state.
}
