//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Animation Blend By Falling > UDKAnimBlendBase > AnimNodeBlendList >
//     > AnimNode > AnimObject > Object
//
// A blend node for any animation tree to filter a set of animations according to
// falling state.
//================================================================================
class SGDKAnimBlendByFalling extends UDKAnimBlendBase;


/**Link to pawn owner.*/ var SGDKPlayerPawn PawnOwner;


/**
 * Changes active child AnimNode according to falling velocity.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last tick
 */
event TickAnim(float DeltaTime)
{
    local int i;

    //Make sure pawn owner exists, otherwise this blend node is being tested in the editor.
    if (PawnOwner != none && PawnOwner.Health > 0)
    {
        //Play dashing animation if required.
        if (PawnOwner.ShouldPlayDash())
            i = 5;
        else
            //If no falling velocity, set land state.
            if (PawnOwner.Velocity.Z == 0.0)
                i = 4;
            else
            {
                i = 0;

                if (PawnOwner.HasJumped())
                    i += 2;

                //Take into account falling velocity and gravity direction.
                if (PawnOwner.Velocity.Z < 0.0)
                {
                    if (!PawnOwner.bReverseGravity)
                        i++;
                }
                else
                    if (PawnOwner.bReverseGravity)
                        i++;
            }

        SetActiveChild(i,GetBlendTime(i));
    }
}


defaultproperties
{
    bFixNumChildren=true               //New children connectors can't be added.
    bTickAnimInScript=true             //This AnimBlend wants script TickAnim event called.
    Children[0]=(Name="Up",Weight=1.0) //AnimNode for falling while going up state.
    Children[1]=(Name="Down")          //AnimNode for falling while going down state.
    Children[2]=(Name="Jump Up")       //AnimNode for jumping while going up state.
    Children[3]=(Name="Jump Down")     //AnimNode for jumping while going down state.
    Children[4]=(Name="Land")          //AnimNode for standing on land state.
    Children[5]=(Name="Dash")          //AnimNode for dashing state.
}
