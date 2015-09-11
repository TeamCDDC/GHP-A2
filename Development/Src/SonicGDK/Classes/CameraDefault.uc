//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Camera Default > SGDKCameraBase > GameCameraBase > Object
//
// The base camera object defines all the properties and behavior that will be
// common to all camera objects.
// This class is the default third person camera mode.
//================================================================================
class CameraDefault extends SGDKCameraBase;


/**Distance to slide the camera back from pawn location.*/ var float CurrentCamDistance;
         /**Fixed amount used to modify camera distance.*/ var float DistanceCamIncrement;
           /**Maximum value allowed for camera distance.*/ var float MaxCamDistance;
           /**Minimum value allowed for camera distance.*/ var float MinCamDistance;

    /**Eye distance adjusted to speed of a pawn.*/ var float CurrentEyeDistance;
    /**Constant eye distance used while falling.*/ var float EyeDistanceFall;
      /**Maximum value allowed for eye distance.*/ var float MaxEyeDistance;
/**Maximum factor applied to eye FOV adjustment.*/ var float MaxEyeFOVFactor;
/**Minimum factor applied to eye FOV adjustment.*/ var float MinEyeFOVFactor;


/**
 * Called when this camera mode becomes active.
 * @param PreviousCamera  the previous active camera
 */
function OnBecomeActive(GameCameraBase PreviousCamera)
{
    local float ZoomRange;

    super.OnBecomeActive(PreviousCamera);

    ZoomRange = MaxCamDistance - MinCamDistance;

    MaxCamDistance = default.MaxCamDistance + ZoomRange * -MinZoomFactor;
    MinCamDistance = default.MinCamDistance + ZoomRange * (1.0 - MaxZoomFactor);

    CurrentCamDistance = FClamp(CurrentCamDistance,MinCamDistance,MaxCamDistance);
}

/**
 * Provides a point of view (POV) with camera location, rotation and FOV.
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param OutViewTarget  ViewTarget responsible for providing the camera with a point of view
 */
function UpdateViewTarget(float DeltaTime,out TViewTarget OutViewTarget)
{
    local SGDKPlayerPawn P;
    local quat CameraRotation;
    local vector CameraLocation,HitLocation,HitNormal,OffsetVector,RotVector,V;
    local float CamDistance;

    P = SGDKPlayerPawn(OutViewTarget.Target);

    if (P != none)
    {
        if (P.Health > 0 && !P.bFeigningDeath && P.Controller != none)
        {
            if (SmoothRotationRate > 0.0 || bResetCameraInterpolation)
                CurrentVerticalLookFactor = VerticalLookFactor;
            else
                CurrentVerticalLookFactor = Lerp(CurrentVerticalLookFactor,VerticalLookFactor,FMin(DeltaTime * 10.0,1.0));

            CameraRotation = QuatProduct(QuatFromAxisAndAngle(vect(0,1,0) >> P.DesiredViewRotation,
                                         CurrentVerticalLookFactor),QuatFromRotator(P.DesiredViewRotation));

            if (!bResetCameraInterpolation && SmoothRotationRate > 0.0)
                CameraRotation = QuatSlerp(CameraRotation,QuatFromRotator(OutViewTarget.POV.Rotation),
                                           0.5 ** (DeltaTime * SmoothRotationRate),true);

            OutViewTarget.POV.Rotation = Normalize(QuatToRotator(CameraRotation));

            if (RollRotation != 0)
                OutViewTarget.POV.Rotation.Roll = RollRotation;

            CameraLocation = P.GetCameraTarget() + ((vect(1,0,0) * -CurrentCamDistance +
                             vect(0,0,1) * P.EyeHeight) >> OutViewTarget.POV.Rotation);

            if (CurrentCamDistance > 0.0 && TargetData.bVelocityModsCamera && !IsZero(TargetData.VelocityFactors))	//moves camera based on sonic velocity
            {
                RotVector = vector(OutViewTarget.POV.Rotation);
                V = P.GetVelocity() * TargetData.VelocityFactors;

                if (P.Physics == PHYS_Falling)
                {
                    if (V.X != 0.0 || V.Y != 0.0)
                        CamDistance = EyeDistanceFall;
                }
                else
                    if (!IsZero(V))
                        CamDistance = (V dot RotVector) * CurrentCamDistance;

                CurrentEyeDistance = FMin(CurrentEyeDistance +
                                          (CamDistance - CurrentEyeDistance) * FMin(DeltaTime * 3.5,1.0),MaxEyeDistance);

                CameraLocation += RotVector * -CurrentEyeDistance;

                OutViewTarget.POV.FOV = FClamp(OutViewTarget.POV.FOV + CurrentEyeDistance * 0.1,
                                               OutViewTarget.POV.FOV * MinEyeFOVFactor,
                                               OutViewTarget.POV.FOV * MaxEyeFOVFactor);
            }
            else
                CurrentEyeDistance = 0.0;

            CameraLocation.X = FClamp(CameraLocation.X,MinLocation.X,MaxLocation.X);
            CameraLocation.Y = FClamp(CameraLocation.Y,MinLocation.Y,MaxLocation.Y);
            CameraLocation.Z = FClamp(CameraLocation.Z,MinLocation.Z,MaxLocation.Z);

            if (bResetCameraInterpolation || SmoothLocationRate == 0.0)
                OutViewTarget.POV.Location = CameraLocation;
            else
                OutViewTarget.POV.Location = VLerp(CameraLocation,OutViewTarget.POV.Location,
                                                   0.5 ** (DeltaTime * SmoothLocationRate));

            if (bEnableCollision)
            {
                OffsetVector = P.Location + ((vect(0,0,1) * P.EyeHeight) >> P.DesiredMeshRotation);

                if (P.Trace(HitLocation,HitNormal,OffsetVector,P.Location,true,
                            vect(6,6,12),,class'Actor'.const.TRACEFLAG_Blocking) != none)
                    OutViewTarget.POV.Location = HitLocation;
                else
                    if (P.Trace(HitLocation,HitNormal,OutViewTarget.POV.Location,OffsetVector,true,
                                vect(1,1,1) * CollisionRadius,,class'Actor'.const.TRACEFLAG_Blocking) != none)
                        OutViewTarget.POV.Location = HitLocation;
            }
        }
        else
        {
            if (bEnableCollision)
                P.FindSpot(vect(1,1,1) * CollisionRadius,OutViewTarget.POV.Location);

            OutViewTarget.POV.Rotation = Normalize(QuatToRotator(QuatSlerp(QuatFromRotator(rotator(P.GetCameraTarget() -
                                             OutViewTarget.POV.Location)),QuatFromRotator(OutViewTarget.POV.Rotation),
                                             0.5 ** (DeltaTime * 7.5),true)));
        }
    }

    PlayerCamera.ApplyCameraModifiers(DeltaTime,OutViewTarget.POV);

    bResetCameraInterpolation = false;
}

/**
 * Zooms in camera.
 */
function ZoomIn()
{
    if (AllowZoom())
        CurrentCamDistance = FMax(MinCamDistance,CurrentCamDistance - DistanceCamIncrement);
}

/**
 * Zooms out camera.
 */
function ZoomOut()
{
    if (AllowZoom())
        CurrentCamDistance = FMin(CurrentCamDistance + DistanceCamIncrement,MaxCamDistance);
}


defaultproperties
{
    bDisableZoom=false
    bEnableCollision=true
    InitialVerticalLookFactor=0.25
    MaxVerticalLookFactor=1.4
    MinVerticalLookFactor=-0.9
    SmoothLocationRate=0.0
    SmoothRotationRate=7.5
    TargetData=(bVelocityModsCamera=true,VelocityFactors=(X=0.00035,Y=0.00035,Z=0.00035))
    VerticalLookFactor=0.25
    VerticalLookIncrement=0.575

    CurrentCamDistance=350.0
    DistanceCamIncrement=25.0
    MaxCamDistance=700.0
    MinCamDistance=-25.0

    EyeDistanceFall=50.0
    MaxEyeDistance=150.0
    MaxEyeFOVFactor=1.15
    MinEyeFOVFactor=0.85
}
