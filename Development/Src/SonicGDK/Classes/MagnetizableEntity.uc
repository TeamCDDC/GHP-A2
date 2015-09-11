//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Magnetizable Entity Interface
//
// An interface available to all objects to convert them to a type of object which
// can be magnetized.
//================================================================================
interface MagnetizableEntity;


/**
 * Tries to magnetize this object.
 * @param AnActor  the actor that tries to magnetize this object
 */
function Magnetize(Actor AnActor);
