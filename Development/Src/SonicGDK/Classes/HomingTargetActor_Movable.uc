//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Homing Target Actor Movable > HomingTargetActor > SGDKActor > Actor
//
// The Homing Target Actor is an invisible target for Homing Dash.
// This type can be moved during gameplay (attached to matinee, etc).
//================================================================================
class HomingTargetActor_Movable extends HomingTargetActor;


defaultproperties
{
    bMovable=true         //Actor can be moved.
    bNoEncroachCheck=true //Doesn't do the overlap check when it moves.
}
