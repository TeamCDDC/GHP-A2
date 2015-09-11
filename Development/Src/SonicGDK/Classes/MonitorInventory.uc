//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Inventory > UTTimedPowerup > UTInventory > Inventory > Actor
//
// Inventory is the parent class of all actors that can be carried by players.
// Inventory items are placed in the holding pawn inventory chain, a linked list
// of inventory actors.
// This class represents the item object that is given to players.
//================================================================================
class MonitorInventory extends UTTimedPowerup
    abstract;


     /**If true, destroys all other expiring items.*/ var bool bDestroyExpiringItems;
  /**If true, displays item information on the HUD.*/ var bool bDisplayTimeRemaining;
             /**If true, StopEffect() isn't called.*/ var bool bIgnoreStopEffect;
              /**If true, a text message is showed.*/ var bool bShowTextMessage;
                          /**Amount of energy left.*/ var float Energy;
/**Coordinates for mapping the energy icon texture.*/ var TextureCoordinates EnergyHudCoords;
          /**Screen position of the energy counter.*/ var vector2d EnergyHudPosition;
                /**Delay time for the pickup sound.*/ var float PickupSoundDelay;


/**
 * Announces this item to the given pawn which picked it up.
 * @param P  the pawn which receives this inventory item
 */
function AnnouncePickup(Pawn P)
{
    if (!bShowTextMessage)
        MessageClass = none;

    P.HandlePickup(self);

    if (PickupSound != none)
        SetTimer(FMax(0.01,PickupSoundDelay),false,NameOf(PlayPickupSound));
}

/**
 * Lets existing items in a pawn's inventory prevent the pawn from picking something up.
 * @param ItemClass  class of inventory the pawn owner is trying to pick up
 * @param Pickup     the actor containing that item
 * @return           true to abort pickup
 */
function bool DenyPickupQuery(class<Inventory> ItemClass,Actor Pickup)
{
    return false;
}

/**
 * Displays item information on the HUD.
 * @param Canvas           the drawing canvas that covers the whole screen
 * @param HUD              the related Heads-Up Display
 * @param ResolutionScale  holds the scaling factor given the current resolution of the screen
 * @param YPos             vertical position in screen coordinates
 */
simulated function DisplayPowerup(Canvas Canvas,UTHUD HUD,float ResolutionScale,out float YPos)
{
    if (bDisplayTimeRemaining)
        super.DisplayPowerup(Canvas,HUD,ResolutionScale,YPos);
}

/**
 * This item has just been given to a pawn.
 * @param P              the new inventory pawn owner
 * @param bDontActivate  if true, this item will not try to activate
 */
function GivenTo(Pawn P,optional bool bDontActivate)
{
    super.GivenTo(P,bDontActivate);

    StartEffect(SGDKPlayerPawn(P));
}

/**
 * Draws 2D graphics on the HUD.
 * @param TheHud           the HUD
 * @param YPositionOffset  the Y position offset in pixels
 */
function HudGraphicsDraw(SGDKHud TheHud,out float YPositionOffset)
{
    if (Owner != none && Energy >= 0.0)
    {
        TheHud.DrawInfoElement(vect2d(EnergyHudPosition.X,EnergyHudPosition.Y + YPositionOffset),false,
                               TheHud.BackgroundSCoords,EnergyHudCoords,vect2d(12,-16),Energy);

        YPositionOffset -= 50.0;
    }
}

/**
 * Updates all 2D graphics' values safely.
 * @param DeltaTime  time since last render of the HUD
 * @param TheHud     the HUD
 */
function HudGraphicsUpdate(float DeltaTime,SGDKHud TheHud)
{
}

/**
 * Called when this item is removed from an inventory manager.
 */
function ItemRemovedFromInvManager()
{
    if (!bIgnoreStopEffect && Owner != none)
        StopEffect(SGDKPlayerPawn(Owner));
}

/**
 * Destroys this item as quick as possible.
 */
function Kill()
{
    if (!bIgnoreStopEffect && Owner != none)
    {
        StopEffect(SGDKPlayerPawn(Owner));

        bIgnoreStopEffect = true;
    }

    Destroy();
}

/**
 * This item is given to a pawn.
 * @param P  the new inventory pawn owner
 */
function NewOwner(Pawn P)
{
    local Inventory Inv;
    local MonitorInventory MonitorItem;

    if (P.InvManager != none)
    {
        Inv = P.InvManager.FindInventoryType(Class,false);

        if (Inv != none)
        {
            MonitorInventory(Inv).ClientSetTimeRemaining(default.TimeRemaining);
            MonitorInventory(Inv).AnnouncePickup(P);
            MonitorInventory(Inv).ReplenishEffect(SGDKPlayerPawn(P));

            if (MonitorActor(Owner) != none)
                MonitorActor(Owner).PickedUpBy(P);
            else
                if (MonitorPickupFactory(Owner) != none)
                    MonitorPickupFactory(Owner).PickedUpBy(P);

            Destroy();
        }
        else
        {
            foreach P.InvManager.InventoryActors(class'MonitorInventory',MonitorItem)
            {
                if (bDestroyExpiringItems && 
                    MonitorItem.TimeRemaining != class'MonitorInventory'.default.TimeRemaining)
                    MonitorItem.Kill();
                else
                    if (MonitorItem.bDestroyExpiringItems &&
                        default.TimeRemaining != class'MonitorInventory'.default.TimeRemaining)
                    {
                        Destroy();

                        break;
                    }
            }

            if (!bDeleteMe)
            {
                GiveTo(P);
                AnnouncePickup(P);
            }
        }
    }
    else
        Destroy();
}

/**
 * Plays a pickup sound.
 */
function PlayPickupSound()
{
    if (Owner != none)
        Owner.PlaySound(PickupSound);
}

/**
 * Re-adds a bonus effect to the given player pawn.
 * @param P  the player pawn which receives the bonus
 */
function ReplenishEffect(SGDKPlayerPawn P)
{
    StartEffect(P);
}

/**
 * Adds a bonus effect to the given player pawn; delegated to subclasses.
 * @param P  the player pawn which receives the bonus
 */
function StartEffect(SGDKPlayerPawn P);

/**
 * Removes a bonus effect from the given player pawn; delegated to subclasses.
 * @param P  the player pawn which loses the bonus
 */
function StopEffect(SGDKPlayerPawn P);


defaultproperties
{
    bDelayedSpawn=false
    bDropOnDeath=false
    bPredictRespawns=false
    bReceiveOwnerEvents=true
    TimeRemaining=7200.0

    bDestroyExpiringItems=false
    bDisplayTimeRemaining=false
    bIgnoreStopEffect=false
    bShowTextMessage=true
    Energy=-1.0
    EnergyHudPosition=(X=16,Y=-104)
    PickupSoundDelay=1.0
}
