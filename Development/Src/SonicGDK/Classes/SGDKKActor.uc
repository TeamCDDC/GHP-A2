//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Karma Actor > UTKActor > UDKKActorBreakable > KActor > DynamicSMActor >
//     > Actor
//
// A KActor is a static mesh that uses rigid body calculations for physics
// simulation: position, rotation, linear and angular velocities...
//================================================================================
class SGDKKActor extends UTKActor
    ClassGroup(SGDK,Visible)
    placeable;


/**The force applied to the body to address custom gravity.*/ var() float GravityFactor;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    if (StaticMeshComponent != none)
        StaticMeshComponent.GetRootBodyInstance().CustomGravityFactor = GravityFactor;
}


defaultproperties
{
    GravityFactor=1.0
}
