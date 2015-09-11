//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Board Sphere Actor Red > BoardSphereActor > SGDKActor > Actor
//
// The parent class is a pickup placed on the Board Special Stage.
// This subclass is a red sphere.
//================================================================================
class BoardSphereActorRed extends BoardSphereActor;


/**If true, touching pawns are ignored.*/ var bool bIgnoreTouch;


/**
 * Is a pawn in condition to touch this actor?
 * @param P  the pawn involved in the touch
 * @return   true if pawn is a valid actor for touch events
 */
function bool IsValidTouchedBy(SGDKPawn P)
{
    return (super.IsValidTouchedBy(P) && P.Physics == PHYS_Walking && !bIgnoreTouch);
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    P.PlaySound(TouchSound);

    BoardSpecialStage(SGDKGameInfo(WorldInfo.Game).SpecialStage).SphereTouched(self);
}

/**
 * Called when a pawn stops touching this actor.
 * @param P  the pawn involved in the untouch
 */
function UnTouchedBy(SGDKPawn P)
{
    bIgnoreTouch = false;
}


defaultproperties
{
    Begin Object Name=SphereStaticMesh
        Materials[0]=MaterialInstanceConstant'SonicGDKPackStaticMeshes.Materials.SpecialBoardSphereRedMIC'
    End Object
    SphereMesh=SphereStaticMesh


    bIgnoreTouch=false
    TouchSound=SoundCue'SonicGDKPackSounds.SphereRedSoundCue'
}
