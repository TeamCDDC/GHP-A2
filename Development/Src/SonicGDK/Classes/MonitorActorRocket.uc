//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Actor Rocket > MonitorActor > SGDKActor > Actor
//
// The parent class represents the visual object which can be broken.
// This subclass grants the "rocket" orb.
//================================================================================
class MonitorActorRocket extends MonitorActor
    placeable;


defaultproperties
{
    Begin Object Name=MonitorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.MonitorRocketMaterial'
    End Object
    MonitorMesh=MonitorStaticMesh
    PickupMesh=MonitorStaticMesh


    InventoryType=class'MonitorInventoryRocket'
}
