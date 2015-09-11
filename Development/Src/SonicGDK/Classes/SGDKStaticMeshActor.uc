//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Static Mesh Actor > StaticMeshActor > StaticMeshActorBase > Actor
//
// An actor that is drawn using a static mesh: a mesh that never changes, and can
// be cached in video memory, resulting in a speed boost.
// Note that PostBeginPlay and SetInitialState events are never called.
// This type tells pawns to switch to Sonic physics mode if possible.
//================================================================================
class SGDKStaticMeshActor extends StaticMeshActor
    ClassGroup(SGDK,Visible)
    placeable;


defaultproperties
{
    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.CubeStaticMesh'
    End Object
    CollisionComponent=StaticMeshComponent0
    StaticMeshComponent=StaticMeshComponent0
}
