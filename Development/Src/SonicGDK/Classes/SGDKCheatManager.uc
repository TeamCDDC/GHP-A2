//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Cheat Manager > UTCheatManager > CheatManager > Object
//
// Object within player controllers that manages "cheat" commands.
// It's only spawned in single player mode.
//================================================================================
class SGDKCheatManager extends UTCheatManager within SGDKPlayerController;


/**
 * Gives magnetic boots to player.
 */
exec function AntiGrav()
{
    if (Pawn != none && Pawn.Health > 0)
        //Toggle magnetic boots.
        SGDKPlayerPawn(Pawn).bAntiGravityMode = !SGDKPlayerPawn(Pawn).bAntiGravityMode;
}

/**
 * Gives bubble shield to player.
 */
exec function Bubble()
{
    if (Pawn != none && Pawn.Health > 0)
        SGDKPlayerPawn(Pawn).Shield.GotoState('Bubble');
}

/**
 * Gives flame shield to player.
 */
exec function Flame()
{
    if (Pawn != none && Pawn.Health > 0)
        SGDKPlayerPawn(Pawn).Shield.GotoState('Flame');
}

/**
 * Gives hyper form status to player.
 */
exec function HyperTrans()
{
    if (Pawn != none && Pawn.Health > 0)
        SGDKPlayerPawn(Pawn).HyperForm(!SGDKPlayerPawn(Pawn).bHyperForm);
}

/**
 * Gives magnetic shield to player.
 */
exec function Magnetic()
{
    if (Pawn != none && Pawn.Health > 0)
        SGDKPlayerPawn(Pawn).Shield.GotoState('Magnetic');
}

/**
 * Decreases the size of the player.
 */
exec function MiniSize()
{
    if (Pawn != none && Pawn.Health > 0)
        SGDKPlayerPawn(Pawn).MiniSize(!SGDKPlayerPawn(Pawn).bMiniSize);
}

/**
 * Resets all level actors.
 */
exec function ResetLevel()
{
    WorldInfo.Game.ResetLevel();
}

/**
 * Reverses world gravity direction.
 */
exec function RevGrav()
{
    //Reverse Z axis of world gravity.
    WorldInfo.WorldGravityZ *= -1.0;

    if (Pawn != none && Pawn.Health > 0)
        //Enable/disable reverse gravity.
        SGDKPlayerPawn(Pawn).ReversedGravity(WorldInfo.WorldGravityZ > 0.0);
}

/**
 * Gives standard shield to player.
 */
exec function Standard()
{
    if (Pawn != none && Pawn.Health > 0)
        SGDKPlayerPawn(Pawn).Shield.GotoState('Standard');
}

/**
 * Gives super form status to player.
 */
exec function SuperTrans()
{
    if (Pawn != none && Pawn.Health > 0)
        SGDKPlayerPawn(Pawn).SuperForm(!SGDKPlayerPawn(Pawn).bSuperForm);
}

/**
 * Returns to normal while in fly or ghost mode.
 */
exec function Walk()
{
    bCheatFlying = false;

    if (Pawn != none && Pawn.CheatWalk())
    {
        if (!Pawn.PhysicsVolume.bWaterVolume)
            Outer.GotoState(Pawn.LandMovementState);
        else
            Outer.GotoState(Pawn.WaterMovementState);
    }
}


defaultproperties
{
}
