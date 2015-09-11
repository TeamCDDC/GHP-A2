//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Enemy Pawn Flying > SGDKEnemyPawn > SGDKPawn > UTPawn > UDKPawn > GamePawn >
//     > Pawn > Actor
//
// The Pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
// This type belongs to flying enemies controlled by artificial intelligence.
//================================================================================
class EnemyPawnFlying extends SGDKEnemyPawn
    notplaceable;


defaultproperties
{
    bCanFly=true
    DefaultPhysics=PHYS_Flying
}
