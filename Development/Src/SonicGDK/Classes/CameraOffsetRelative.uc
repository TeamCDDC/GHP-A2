//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Camera Offset Relative > SGDKCameraBase > GameCameraBase > Object
//
// The base camera object defines all the properties and behavior that will be
// common to all camera objects.
// This class is the camera mode that offsets from a target and doesn't ignore its
// rotation.
//================================================================================
class CameraOffsetRelative extends SGDKCameraBase;


/**Camera location uses camera rotation instead of target orientation.*/ var bool bRotationOffset;
      /**Camera location uses this offset relative to target location.*/ var vector OffsetVector;


/**
 * Calculates the desired location of this camera.
 * @param DeltaTime          contains the amount of time in seconds that has passed since the last tick
 * @param ViewTarget         ViewTarget responsible for providing the camera with a target
 * @param TargetLocation     location of camera target
 * @param TargetRotation     rotation of camera target
 * @param OutCameraLocation  location of camera
 * @return                   desired camera location
 */
function CalculateCameraLocation(float DeltaTime,TViewTarget ViewTarget,vector TargetLocation,
                                 rotator TargetRotation,out vector OutCameraLocation)
{
    if (!bRotationOffset)
        OutCameraLocation = TargetLocation + (OffsetVector >> TargetRotation);
    else
        OutCameraLocation = TargetLocation + (OffsetVector >> PlayerCamera.PCOwner.Rotation);

    super.CalculateCameraLocation(DeltaTime,ViewTarget,TargetLocation,TargetRotation,OutCameraLocation);
}

/**
 * Called when this camera mode becomes active.
 * @param PreviousCamera  the previous active camera
 */
function OnBecomeActive(GameCameraBase PreviousCamera)
{
    super.OnBecomeActive(PreviousCamera);

    bRotationOffset = CameraInformation.bCameraRotationOffset;
    OffsetVector = CameraInformation.CameraOffsetVector;
}


defaultproperties
{
}
