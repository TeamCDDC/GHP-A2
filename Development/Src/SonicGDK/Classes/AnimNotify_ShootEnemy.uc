//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Animation Notify Shoot Enemy > AnimNotify_Scripted > AnimNotify > Object
//
// Animations notifies are used to produce an action at a specific time frame of
// a specific animation.
// This notify orders an enemy to shoot a projectile.
//================================================================================
class AnimNotify_ShootEnemy extends AnimNotify_Scripted;


/**Index of the shoot slot to use as reference for projectile creation.*/ var() byte ShootSlotIndex;


/**
 * Called when the animation notify is activated.
 * @param Owner              the actor that is playing this animation
 * @param AnimSeqInstigator  the animation sequence that triggered the notify
 */
event Notify(Actor Owner,AnimNodeSequence AnimSeqInstigator)
{
    local SGDKEnemyPawn P;

    P = SGDKEnemyPawn(Owner);

    if (P != none)
        P.Shoot(ShootSlotIndex);
}


defaultproperties
{
}
