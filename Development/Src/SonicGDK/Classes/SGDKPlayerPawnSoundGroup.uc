//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Player Pawn Sound Group > UTPawnSoundGroup > Object
//
// This object holds the references to all sound effects related to a pawn.
//================================================================================
class SGDKPlayerPawnSoundGroup extends UTPawnSoundGroup;


/**
 * The given pawn plays a body explosion sound.
 * @param P  a pawn
 */
static function PlayBodyExplosion(Pawn P)
{
    if (default.CrushedSound != none)
        super.PlayBodyExplosion(P);
}


defaultproperties
{
    DoubleJumpSound=SoundCue'SonicGDKPackSounds.JumpSoundCue'
}
