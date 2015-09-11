//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Damage Type Drowned > SGDKDamageType > UTDamageType > DamageType > Object
//
// DamageType is the base class of all types of damage; this and its subclasses
// are never spawned, just used as information holders.
// This type is related to damage inflicted by lack of air in an underwater
// environment.
//================================================================================
class SGDKDmgType_Drowned extends SGDKDamageType
    abstract;


defaultproperties
{
    bArmorStops=false   //Shields don't provide protection against this damage.
    bCausedByWorld=true //Damage is caused by the world.
    bNeverGibs=true     //Victim body will never blow up into small chunks.
}
