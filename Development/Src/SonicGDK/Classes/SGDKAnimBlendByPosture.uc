//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Animation Blend By Posture > UDKAnimBlendBase > AnimNodeBlendList >
//     > AnimNode > AnimObject > Object
//
// A blend node for any animation tree to filter a set of animations according to
// posture status.
//================================================================================
class SGDKAnimBlendByPosture extends UDKAnimBlendBase;


/**
 * Changes active child AnimNode according to posture.
 * @param ChildIndex  index of child node to activate
 */
function PostureChanged(byte ChildIndex)
{
    SetActiveChild(ChildIndex,GetBlendTime(ChildIndex));
}


defaultproperties
{
    bFixNumChildren=true                //New children connectors can't be added.
    Children[0]=(Name="Run",Weight=1.0) //AnimNode for running state.
    Children[1]=(Name="Skid")           //AnimNode for skidding state.
    Children[2]=(Name="Duck")           //AnimNode for ducking state.
    Children[3]=(Name="Roll")           //AnimNode for rolling on ground state.
    Children[4]=(Name="Spin")           //AnimNode for SpinDash state.
    Children[5]=(Name="Push")           //AnimNode for pushing state.
}
