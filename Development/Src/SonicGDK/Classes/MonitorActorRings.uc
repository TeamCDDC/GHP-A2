//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Actor Rings > MonitorActor > SGDKActor > Actor
//
// The parent class represents the visual object which can be broken.
// This subclass grants an amount of classic ring items.
//================================================================================
class MonitorActorRings extends MonitorActor
    placeable;


defaultproperties
{
    InventoryType=class'MonitorInventoryRings'
}
