//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Anim Node Sequence > UDKAnimNodeSequence > AnimNodeSequence > AnimNode >
//     > AnimObject > Object
//
// This is an animation node which outputs the animation data within an animation
// sequence, which resides inside an animation set.
//================================================================================
class SGDKAnimNodeSequence extends UDKAnimNodeSequence;


      /**If true and when the last animation in the list is reached, it will be looped.*/ var() bool bLoopLastAnimation;
/**If true and when this node becomes relevant, animation is played from its beginning.*/ var() bool bResetOnBecomeRelevant;
        /**If this list exists, it has the animations that will be played sequentially.*/ var() array<name> AnimationsList;


/**
 * Called to allow initialization of script-side properties of this node.
 */
event OnInit()
{
    if (AnimationsList.Length > 0)
        bResetOnBecomeRelevant = true;

    bCallScriptEventOnBecomeRelevant = bResetOnBecomeRelevant;

    super.OnInit();
}

/**
 * Called when this node becomes relevant for the final blend (TotalWeight > 0).
 */
event OnBecomeRelevant()
{
    if (bResetOnBecomeRelevant)
    {
        SetPosition(0.0,false);

        if (AnimationsList.Length > 0)
        {
            SeqStack.Length = 0;

            PlayAnimationSet(AnimationsList,Rate,bLoopLastAnimation);
        }
    }
}


defaultproperties
{
    bCallScriptEventOnBecomeRelevant=true
    bLoopLastAnimation=true
    bResetOnBecomeRelevant=false
}
