//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Board Sphere Actor Bumper > BoardSphereActor > SGDKActor > Actor
//
// The parent class is a pickup placed on the Board Special Stage.
// This subclass is a bumper sphere.
//================================================================================
class BoardSphereActorBumper extends BoardSphereActor;


/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    if (Normal(P.Velocity) dot Normal(Location - P.Location) >= 0.0)
    {
        SGDKPlayerController(P.Controller).bBoardRunBackwards = !SGDKPlayerController(P.Controller).bBoardRunBackwards;

        P.PlaySound(TouchSound);
    }
}


defaultproperties
{
    Begin Object Name=SphereStaticMesh
        Materials[0]=MaterialInstanceConstant'SonicGDKPackStaticMeshes.Materials.SpecialBoardSphereBumperMIC'
    End Object
    SphereMesh=SphereStaticMesh


    TouchSound=SoundCue'SonicGDKPackSounds.BumperSoundCue'
}
