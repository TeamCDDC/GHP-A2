//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Board Sphere Actor Ring > BoardSphereActor > SGDKActor > Actor
//
// The parent class is a pickup placed on the Board Special Stage.
// This subclass is a ring item.
//================================================================================
class BoardSphereActorRing extends BoardSphereActor;


/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    local rotator R;

    super.Tick(DeltaTime);

    R = Rotation;
    R.Yaw = WorldInfo.TimeSeconds * RotationRate.Yaw;

    SetRotation(R);
}

/**
 * Hides, deactivates and destroys this actor.
 */
function HideAndDestroy()
{
    super.HideAndDestroy();

    BoardSpecialStage(SGDKGameInfo(WorldInfo.Game).SpecialStage).SphereTouched(self);
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    HideAndDestroy();

    P.PlaySound(TouchSound);
}


defaultproperties
{
    Begin Object Name=SphereStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.RingStaticMesh'
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.SpecialBoardRingMaterial'
        Scale=1.6
    End Object
    SphereMesh=SphereStaticMesh


    RotationRate=(Yaw=24576) //Change in rotation per second.

    bDisableTick=false
}
