//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Special Stage Actor > SGDKActor > Actor
//
// The Special Stage Actor is the representation of the Special Stage found in all
// classic Sonic games where players can earn a Chaos Emerald.
//================================================================================
class SpecialStageActor extends SGDKActor
    abstract;


/**
 * Calculates camera view point.
 * @param DeltaTime       contains the amount of time in seconds that has passed since the last tick
 * @param OutCamLocation  camera location
 * @param OutCamRotation  camera rotation
 * @param OutFOV          field of view angle of camera
 * @return                true if this actor should provide the camera point of view
 */
simulated function bool CalcCamera(float DeltaTime,out vector OutCamLocation,
                                   out rotator OutCamRotation,out float OutFOV)
{
    return false;
}

/**
 * Should the HUD draw the default graphics?
 * @return  true if the HUD should draw the default graphics
 */
function bool DrawGlobalGraphics()
{
    return false;
}

/**
 * Draws 2D graphics on the HUD; delegated to subclasses.
 * @param TheHud  the HUD
 */
function HudGraphicsDraw(SGDKHud TheHud);

/**
 * Updates all graphics' values safely; delegated to subclasses.
 * @param DeltaTime  time since last render of the HUD
 * @param TheHud     the HUD
 */
function HudGraphicsUpdate(float DeltaTime,SGDKHud TheHud);

/**
 * Manages a pawn to start playing the special stage; delegated to subclasses.
 * @param P  the pawn to manage
 */
function ManagePawn(SGDKPlayerPawn P);


defaultproperties
{
    SupportedEvents.Empty
    SupportedEvents.Add(class'SeqEvent_SpecialStage')
}
