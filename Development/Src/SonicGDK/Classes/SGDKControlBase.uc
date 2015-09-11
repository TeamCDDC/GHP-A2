//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Control Base > Object
//
// The base control object defines all the properties and behavior that will be
// common to all control objects.
//================================================================================
class SGDKControlBase extends Object
    abstract
    config(Control);


/**Reference to the associated camera information object.*/ var CameraInfo CameraInformation;
                       /**Reference to the owning camera.*/ var SGDKPlayerCamera PlayerCamera;

/**If true, disables input related to turning left/right.*/ var bool bDisableTurning;


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
    local vector V;

    V = Normal(ControllerX * InputManager.aForward + ControllerY * InputManager.aStrafe);

    if (V.Z != 0.0 && (P.Physics == PHYS_Walking || P.Physics == PHYS_Falling))
        V = Normal(V * vect(1,1,0));

    return V * P.AccelRate;
}

/**
 * Initializes the object; delegated to subclasses.
 */
function Init();

/**
 * Called when this control mode becomes active.
 * @param PreviousControls  the previous active control mode
 */
function OnBecomeActive(SGDKControlBase PreviousControls)
{
    CameraInformation = SGDKPlayerController(PlayerCamera.PCOwner).CurrentCameraInfo;

    if (CameraInformation != none)
        bDisableTurning = CameraInformation.bDisableTurning;
}

/**
 * Called when this control mode becomes inactive; delegated to subclasses.
 * @param NextControls  the next active control mode
 */
function OnBecomeInactive(SGDKControlBase NextControls);

/**
 * Called to influence player view rotation.
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param ViewActor      the target of the camera
 * @param ViewRotation   current player view rotation
 * @param DeltaRotation  player input added to view rotation
 */
function ProcessViewRotation(float DeltaTime,Actor ViewActor,out rotator ViewRotation,out rotator DeltaRotation)
{
    if (!bDisableTurning)
    {
        //If pawn is standing on something that is rotating...
        if (ViewActor.Base != none && !IsZero(ViewActor.Base.AngularVelocity) && SGDKPlayerPawn(ViewActor) != none)
            //Turn left-right the camera according to base rotation.
            ViewRotation.Yaw += SGDKPlayerPawn(ViewActor).NativePhysicsRotation.Yaw;
    }
    else
        DeltaRotation.Yaw = 0;
}

/**
 * Should the player view rotation be allowed to be modified?
 * @param P  pawn currently being moved
 * @return   true if view rotation (controls) can be rotated
 */
function bool ShouldViewRotate(SGDKPlayerPawn P)
{
    return !bDisableTurning;
}


defaultproperties
{
    bDisableTurning=true
}
