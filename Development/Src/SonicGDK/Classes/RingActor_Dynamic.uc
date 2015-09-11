//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Ring Actor Dynamic > Ring Actor > SGDKActor > Actor
//
// The Ring Actor is the classic ring item found in all Sonic games.
// This type can be spawned in the level by splines and other stuff. It's more
// expensive than normal Ring Actors, use only when necessary.
//================================================================================
class RingActor_Dynamic extends RingActor
    placeable;


defaultproperties
{
    bNoDelete=false //Can be deleted during play.
}
