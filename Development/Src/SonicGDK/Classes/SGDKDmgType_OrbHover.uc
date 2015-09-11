//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Damage Type Orb Hover > SGDKDmgType_Jump > SGDKDamageType > UTDamageType >
//     > DamageType > Object
//
// DamageType is the base class of all types of damage; this and its subclasses
// are never spawned, just used as information holders.
// This type is related to damage inflicted by a pawn which has the "hover" orb.
//================================================================================
class SGDKDmgType_OrbHover extends SGDKDmgType_Jump
    abstract;


defaultproperties
{
}
