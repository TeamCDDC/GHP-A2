//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Receive Pawn Events Interface
//
// An interface available to all objects to receive event notifications from a
// pawn controlled by a human player.
// An object class must implement this interface and join the NotifyEventsTo queue
// in a SGDKPlayerPawn to receive the notifications.
//================================================================================
interface ReceivePawnEvents;


/**
 * Called when the pawn is bounced.
 * @param ThePawn  the pawn that generates the event
 */
function PawnBounced(SGDKPlayerPawn ThePawn);

/**
 * Called when the pawn dies.
 * @param ThePawn  the pawn that generates the event
 */
function PawnDied(SGDKPlayerPawn ThePawn);

/**
 * Called when the pawn performs an aerial special move.
 * @param ThePawn  the pawn that generates the event
 */
function PawnDoubleJumped(SGDKPlayerPawn ThePawn);

/**
 * Called when the pawn enters a water volume.
 * @param ThePawn         the pawn that generates the event
 * @param TheWaterVolume  the new physics volume in which the pawn has entered
 */
function PawnEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);

/**
 * Called when the pawn's head enters a water volume.
 * @param ThePawn         the pawn that generates the event
 * @param TheWaterVolume  the new physics volume in which the pawn's head has entered
 */
function PawnHeadEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);

/**
 * Called when the pawn's head leaves a water volume.
 * @param ThePawn         the pawn that generates the event
 * @param TheWaterVolume  the old physics volume in which the pawn's head was
 */
function PawnHeadLeftWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);

/**
 * Called when the pawn hurts another pawn.
 * @param ThePawn       the pawn that generates the event
 * @param TheOtherPawn  the pawn which received the damage, if alive
 */
function PawnHurtPawn(SGDKPlayerPawn ThePawn,Pawn TheOtherPawn);

/**
 * Called when the pawn is at apex of jumps.
 * @param ThePawn  the pawn that generates the event
 */
function PawnJumpApex(SGDKPlayerPawn ThePawn);

/**
 * Called when the pawn jumps.
 * @param ThePawn  the pawn that generates the event
 */
function PawnJumped(SGDKPlayerPawn ThePawn);

/**
 * Called when the pawn lands on level geometry while falling.
 * @param ThePawn           the pawn that generates the event
 * @param bWillLeaveGround  true if the pawn will leave the actor is standing on soon
 * @param TheHitNormal      the surface normal of the actor/level geometry landed on
 * @param TheFloorActor     the actor landed on
 */
function PawnLanded(SGDKPlayerPawn ThePawn,bool bWillLeaveGround,vector TheHitNormal,Actor TheFloorActor);

/**
 * Called when the pawn leaves a water volume.
 * @param ThePawn         the pawn that generates the event
 * @param TheWaterVolume  the old physics volume in which the pawn was
 */
function PawnLeftWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);

/**
 * Called when all physics data of the pawn is adapted to a new physics environment.
 * @param ThePawn  the pawn that generates the event
 */
function PawnPhysicsChanged(SGDKPlayerPawn ThePawn);

/**
 * Called when damage is applied to the pawn.
 * @param ThePawn          the pawn that generates the event
 * @param TheDamageCauser  the actor that directly caused the damage
 */
function PawnTookDamage(SGDKPlayerPawn ThePawn,Actor TheDamageCauser);
