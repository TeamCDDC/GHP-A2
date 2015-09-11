//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Damage Type Spikes > SGDKDamageType > UTDamageType > DamageType > Object
//
// DamageType is the base class of all types of damage; this and its subclasses
// are never spawned, just used as information holders.
// This type is related to damage inflicted by spikes.
//================================================================================
class SGDKDmgType_Spikes extends SGDKDamageType
    abstract;


defaultproperties
{
    bArmorStops=true    //Shields provide protection against this damage.
    bCausedByWorld=true //Damage is caused by the world.
    bNeverGibs=true     //Victim body will never blow up into small chunks.
}
