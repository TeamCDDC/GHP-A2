//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Drawable Entity Interface
//
// An interface available to all objects to convert them to a type of object which
// can be drawned on the canvas of the HUD.
//================================================================================
interface DrawableEntity;


/**
 * Draws 2D graphics on the HUD.
 * @param TheHud  the HUD
 */
function HudGraphicsDraw(SGDKHud TheHud);

/**
 * Updates all graphics' values safely.
 * @param DeltaTime  time since last render of the HUD
 * @param TheHud     the HUD
 */
function HudGraphicsUpdate(float DeltaTime,SGDKHud TheHud);
