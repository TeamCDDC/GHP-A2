//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Camera Kismet > SGDKCameraBase > GameCameraBase > Object
//
// The base camera object defines all the properties and behavior that will be
// common to all camera objects.
// This class is the camera mode that takes location from the associated camera
// information object.
//================================================================================
class CameraKismet extends SGDKCameraBase;


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
    OutCameraLocation = CameraInformation.Location;

    super.CalculateCameraLocation(DeltaTime,ViewTarget,TargetLocation,TargetRotation,OutCameraLocation);
}


defaultproperties
{
}
