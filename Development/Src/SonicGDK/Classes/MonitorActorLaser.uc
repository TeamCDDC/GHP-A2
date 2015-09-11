//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Actor Laser > MonitorActor > SGDKActor > Actor
//
// The parent class represents the visual object which can be broken.
// This subclass grants the "laser" orb.
//================================================================================
class MonitorActorLaser extends MonitorActor
    placeable;


defaultproperties
{
    Begin Object Name=MonitorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.MonitorLaserMaterial'
    End Object
    MonitorMesh=MonitorStaticMesh
    PickupMesh=MonitorStaticMesh


    InventoryType=class'MonitorInventoryLaser'
}
