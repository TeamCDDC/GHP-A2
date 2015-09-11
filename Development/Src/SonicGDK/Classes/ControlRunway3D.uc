//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Control Runway 3D > SGDKControlBase > Object
//
// The base control object defines all the properties and behavior that will be
// common to all control objects.
// This class is used for the constrained 3D control mode.
//================================================================================
class ControlRunway3D extends SGDKControlBase;


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
        V = Normal(ControllerX * InputManager.aForward);

        if (V.Z != 0.0 && (P.Physics == PHYS_Walking || P.Physics == PHYS_Falling))
            V = Normal(V * vect(1,1,0));

        return V * P.AccelRate;
    }
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
    local SGDKPlayerPawn P;
    local SGDKPlayerController PC;
    local vector Y,Z;

    P = SGDKPlayerPawn(ViewActor);

    if (P != none)
    {
        if (!P.bConstrainMovement)
        {
            PC = SGDKPlayerController(P.Controller);

            if (P.bSonicPhysicsMode || P.bSpiderPhysicsMode)
                Z = P.GetFloorNormal();
            else
                //Use reverse gravity direction instead of floor normal vector.
                Z = -P.GetGravityDirection();

            if (Abs(PC.ViewZ dot Z) > 0.01)
                //Get right vector with help of controller view rotation.
                Y = Normal(Z cross PC.ViewX);
            else
                //Get right vector with help of old and new controller view rotations.
                Y = QuatRotateVector(QuatFindBetween(PC.ViewZ,Z),PC.ViewY);

            //New view rotation; make a rotator with three orthogonal unit vectors.
            ViewRotation = OrthoRotation(Y cross Z,Y,Z);
        }
        else
            if (vector(P.DesiredMeshRotation) dot P.SplineX >= 0.0)
                ViewRotation = OrthoRotation(P.SplineX,P.SplineY,P.SplineZ);
            else
                ViewRotation = OrthoRotation(-P.SplineX,-P.SplineY,P.SplineZ);
    }

    super.ProcessViewRotation(DeltaTime,ViewActor,ViewRotation,DeltaRotation);
}

/**
 * Should the player view rotation be allowed to be modified?
 * @param P  pawn currently being moved
 * @return   true if view rotation (controls) can be rotated
 */
function bool ShouldViewRotate(SGDKPlayerPawn P)
{
    if (!P.bConstrainMovement)
        return !bDisableTurning;
    else
        return false;
}


defaultproperties
{
}
