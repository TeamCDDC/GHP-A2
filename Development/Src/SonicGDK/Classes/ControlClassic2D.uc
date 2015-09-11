//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Control Classic 2D > SGDKControlBase > Object
//
// The base control object defines all the properties and behavior that will be
// common to all control objects.
// This class is used for the constrained 2D control mode.
//================================================================================
class ControlClassic2D extends SGDKControlBase;


/**If true, forward key input can be used to advance.*/ var bool bForwardAdvances;


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

    if (P.bConstrainMovement)
    {
        if (InputManager.aStrafe != 0.0)
            V = Normal(ControllerY * InputManager.aStrafe);
        else
            if (bForwardAdvances && InputManager.aForward > 0.0 && !IsZero(P.Velocity))
            {
                if (vector(P.DesiredMeshRotation) dot ControllerY > 0.0)
                    V = Normal(ControllerY * InputManager.aForward);
                else
                    V = Normal(ControllerY * -InputManager.aForward);
            }

        if (V.Z != 0.0 && (P.Physics == PHYS_Walking || P.Physics == PHYS_Falling))
            V = Normal(V * vect(1,1,0));

        return V * P.AccelRate;
    }
    else
        return super.GetAccelerationInput(P,InputManager,ControllerX,ControllerY,ControllerZ);
}

/**
 * Called when this control mode becomes active.
 * @param PreviousControls  the previous active control mode
 */
function OnBecomeActive(SGDKControlBase PreviousControls)
{
    super.OnBecomeActive(PreviousControls);

    if (CameraInformation != none)
        bForwardAdvances = CameraInformation.bForwardAdvances;
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
    local SGDKPlayerPawn P;

    P = SGDKPlayerPawn(ViewActor);

    if (P != none)
        ViewRotation = OrthoRotation(-P.SplineY,P.SplineX,P.SplineZ);

    super.ProcessViewRotation(DeltaTime,ViewActor,ViewRotation,DeltaRotation);
}


defaultproperties
{
    bForwardAdvances=true
}
