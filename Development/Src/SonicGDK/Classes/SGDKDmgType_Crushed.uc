//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Damage Type Crushed > SGDKDamageType > UTDamageType > DamageType > Object
//
// DamageType is the base class of all types of damage; this and its subclasses
// are never spawned, just used as information holders.
// This type is related to damage inflicted by crushing stuff.
//================================================================================
class SGDKDmgType_Crushed extends SGDKDamageType
    abstract;


defaultproperties
{
    bAlwaysGibs=true    //Victim body will always blow up into small chunks.
    bArmorStops=false   //Shields don't provide protection against this damage.
    bCausedByWorld=true //Damage is caused by the world.
}
