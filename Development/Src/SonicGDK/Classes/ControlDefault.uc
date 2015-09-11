//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Control Default > SGDKControlBase > Object
//
// The base control object defines all the properties and behavior that will be
// common to all control objects.
// This class is the default non-constrained 3D control mode.
//================================================================================
class ControlDefault extends SGDKControlBase;


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

    super.ProcessViewRotation(DeltaTime,ViewActor,ViewRotation,DeltaRotation);
}


defaultproperties
{
    bDisableTurning=false
}
