//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Pickup Factory Eggman > MonitorPickupFactory > UTPickupFactory >
//     > UDKPickupFactory > PickupFactory > NavigationPoint > Actor
//
// The parent class represents the visual object which can be broken.
// This subclass causes damage.
//================================================================================
class MonitorPickupFactoryEggman extends MonitorPickupFactory
    placeable;


defaultproperties
{
    Begin Object Name=MonitorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.MonitorEggmanMaterial'
    End Object
    MonitorMesh=MonitorStaticMesh
    PickupMesh=MonitorStaticMesh


    InventoryType=class'MonitorInventoryEggman'
}
