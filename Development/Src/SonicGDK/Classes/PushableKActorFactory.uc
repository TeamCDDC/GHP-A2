//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Pushable Karma Actor Factory > ActorFactoryRigidBody > ActorFactoryDynamicSM >
//     > ActorFactory > Object
//
// This is a factory used by the editor which places the desired actor in the map.
// This type of StaticMesh uses rigid body calculations for physics simulation and
// is pushable.
//================================================================================
class PushableKActorFactory extends ActorFactoryRigidBody;


defaultproperties
{
    MenuName="Add SGDK PushableKActor"
    NewActorClass=class'PushableKActor'
}
