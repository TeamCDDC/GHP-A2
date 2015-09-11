//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Board Sphere Actor Yellow > BoardSphereActor > SGDKActor > Actor
//
// The parent class is a pickup placed on the Board Special Stage.
// This subclass is a yellow sphere.
//================================================================================
class BoardSphereActorYellow extends BoardSphereActor;


/**The speed magnitude of the impulse.*/ var float ImpulseZ;


/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    local SGDKPlayerPawn APawn;

    APawn = SGDKPlayerPawn(P);

    APawn.bDoubleGravity = false;

    APawn.AerialBoost(P.Velocity + vect(0,0,1) * ImpulseZ,false,self,'Spring');

    APawn.PlaySound(TouchSound);
}


defaultproperties
{
    Begin Object Name=SphereStaticMesh
        Materials[0]=MaterialInstanceConstant'SonicGDKPackStaticMeshes.Materials.SpecialBoardSphereYellowMIC'
    End Object
    SphereMesh=SphereStaticMesh


    TouchSound=SoundCue'SonicGDKPackSounds.SpringSoundCue'

    ImpulseZ=496.0
}
