//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sensor Mesh Component > StaticMeshComponent > MeshComponent >
//     > PrimitiveComponent > ActorComponent > Component
//
// A component available to all objects that need a collision shape linked to a
// specific static mesh.
// It's commonly used for invisible sensors to trigger touch events.
//================================================================================
class SensorMeshComponent extends StaticMeshComponent
    hidecategories(Collision,Lighting,Lightmass,MobileSettings,Physics,Rendering);


defaultProperties
{
    StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SensorStaticMesh'
    bAcceptsDecals=false
    bAcceptsDynamicLights=false
    bAcceptsLights=false
    bAcceptsStaticDecals=false
    bCastDynamicShadow=false
    bNeverBecomeDynamic=true
    bUseAsOccluder=false
    BlockActors=false
    BlockRigidBody=false
    CastShadow=false
    CollideActors=true
    HiddenGame=true
}
