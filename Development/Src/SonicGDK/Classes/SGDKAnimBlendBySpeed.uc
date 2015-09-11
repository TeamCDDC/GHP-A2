//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Animation Blend By Speed > UDKAnimBlendBySpeed > AnimNodeBlend >
//     > AnimNodeBlendBase > AnimNode > AnimObject > Object
//
// A blend node for any animation tree to blend between two nodes according to
// speed.
//================================================================================
class SGDKAnimBlendBySpeed extends UDKAnimBlendBySpeed;


/**
 * Applies a new scale to maximum and minimum speed.
 * @param NewScale  the new scale to apply
 */
function ScaleSpeed(float NewScale)
{
    MaxSpeed *= NewScale;
    MinSpeed *= NewScale;
}


defaultproperties
{
}
