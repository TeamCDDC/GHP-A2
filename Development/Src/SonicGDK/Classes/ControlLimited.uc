//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Control Limited > SGDKControlBase > Object
//
// The base control object defines all the properties and behavior that will be
// common to all control objects.
// This class is used to limit player movement.
//================================================================================
class ControlLimited extends SGDKControlBase;


/**
 * Gets the desired acceleration vector needed to move a pawn.
 * @param P             pawn to be moved
 * @param InputManager  object within controller that manages player input (pressed keys)
 * @param ControllerX   vector which points forward according to controller rotation
 * @param ControllerY   vector which points right according to controller rotation
 * @param ControllerZ   vector which points upward according to controller rotation
 * @return              acceleration to apply
 */
function vector GetAccelerationInput(SGDKPlayerPawn P,SGDKPlayerInput InputManager,
                                     vector ControllerX,vector ControllerY,vector ControllerZ)
{
    if (P.bConstrainMovement)
        return vect(0,0,0);
    else
        return super.GetAccelerationInput(P,InputManager,ControllerX,ControllerY,ControllerZ);
}

/**
 * Called to influence player view rotation.
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param ViewActor      the target of the camera
 * @param ViewRotation   current player view rotation
 * @param DeltaRotation  player input added to view rotation
 */
function ProcessViewRotation(float DeltaTime,Actor ViewActor,out rotator ViewRotation,out rotator DeltaRotation)
{
    if (SGDKPlayerPawn(ViewActor) != none)
        ViewRotation = SGDKPlayerPawn(ViewActor).DesiredMeshRotation;

    super.ProcessViewRotation(DeltaTime,ViewActor,ViewRotation,DeltaRotation);
}


defaultproperties
{
}
