//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Actor Random > MonitorActor > SGDKActor > Actor
//
// The parent class represents the visual object which can be broken.
// This subclass grants a random powerup.
//================================================================================
class MonitorActorRandom extends MonitorActor
    placeable;


/**The list of monitor types to choose from.*/ var() array< class<MonitorInventory> > MonitorTypes;


/**
 * Initializes the pickup data.
 */
simulated function InitializePickup()
{
    ChooseMonitor();

    super.InitializePickup();
}

/**
 * Chooses a random monitor.
 */
function ChooseMonitor()
{
    InventoryType = MonitorTypes[Rand(MonitorTypes.Length)];
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    ChooseMonitor();
}


defaultproperties
{
    Begin Object Name=MonitorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.MonitorRandomMaterial'
    End Object
    MonitorMesh=MonitorStaticMesh
    PickupMesh=MonitorStaticMesh


    InventoryType=class'MonitorInventoryRings'

    MonitorTypes[0]=class'MonitorInventoryBubble'
    MonitorTypes[1]=class'MonitorInventoryFlame'
    MonitorTypes[2]=class'MonitorInventoryMagnetic'
    MonitorTypes[3]=class'MonitorInventoryStandard'
    MonitorTypes[4]=class'MonitorInventoryRings'
    MonitorTypes[5]=class'MonitorInventoryInvincible'
    MonitorTypes[6]=class'MonitorInventorySpeed'
    MonitorTypes[7]=class'MonitorInventoryGravity'
    MonitorTypes[8]=class'MonitorInventoryEggman'
    MonitorTypes[9]=class'MonitorInventoryLife'
    MonitorTypes[10]=class'MonitorInventoryShrink'
    MonitorTypes[11]=class'MonitorInventoryDrill'
    MonitorTypes[12]=class'MonitorInventoryHover'
    MonitorTypes[13]=class'MonitorInventoryLaser'
    MonitorTypes[14]=class'MonitorInventoryRocket'
    MonitorTypes[15]=class'MonitorInventorySpikes'
}
