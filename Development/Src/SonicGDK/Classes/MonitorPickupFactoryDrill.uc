//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Pickup Factory Drill > MonitorPickupFactory > UTPickupFactory >
//     > UDKPickupFactory > PickupFactory > NavigationPoint > Actor
//
// The parent class represents the visual object which can be broken.
// This subclass grants the "drill" orb.
//================================================================================
class MonitorPickupFactoryDrill extends MonitorPickupFactory
    placeable;


defaultproperties
{
    Begin Object Name=MonitorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.MonitorDrillMaterial'
    End Object
    MonitorMesh=MonitorStaticMesh
    PickupMesh=MonitorStaticMesh


    InventoryType=class'MonitorInventoryDrill'
}
