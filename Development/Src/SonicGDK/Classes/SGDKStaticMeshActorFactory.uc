//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Static Mesh Actor Factory > ActorFactoryStaticMesh > ActorFactory > Object
//
// This is a factory used by the editor which places the desired actor in the map.
// The type of StaticMesh tells pawns to switch to Sonic physics mode if possible.
//================================================================================
class SGDKStaticMeshActorFactory extends ActorFactoryStaticMesh;


defaultproperties
{
    MenuName="Add SGDK StaticMesh"
    NewActorClass=class'SGDKStaticMeshActor'
}
