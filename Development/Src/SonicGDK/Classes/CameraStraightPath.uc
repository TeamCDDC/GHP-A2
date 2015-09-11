//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Camera Straight Path > SGDKCameraBase > GameCameraBase > Object
//
// The base camera object defines all the properties and behavior that will be
// common to all camera objects.
// This class is the camera mode that moves along a straight path while following
// a target.
//================================================================================
class CameraStraightPath extends SGDKCameraBase;


/**If true, target location Z component is used for camera location Z component.*/ var bool bFlexiblePath;
                          /**Additional offset applied to final camera location.*/ var vector OffsetVector;
                                                  /**Direction of straight path.*/ var vector PathDirection;
                                            /**Point contained in straight path.*/ var vector PathPoint;


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
    OutCameraLocation = PathPoint + ((PathDirection dot (TargetLocation - PathPoint)) * PathDirection);

    if (bFlexiblePath)
        OutCameraLocation.Z = TargetLocation.Z;

    OutCameraLocation += OffsetVector;

    super.CalculateCameraLocation(DeltaTime,ViewTarget,TargetLocation,TargetRotation,OutCameraLocation);
}

/**
 * Called when this camera mode becomes active.
 * @param PreviousCamera  the previous active camera
 */
function OnBecomeActive(GameCameraBase PreviousCamera)
{
    super.OnBecomeActive(PreviousCamera);

    bFlexiblePath = CameraInformation.bCameraFlexiblePath;
    OffsetVector = CameraInformation.CameraOffsetVector;
    PathDirection = vector(CameraInformation.Rotation);
    PathPoint = CameraInformation.Location;
}


defaultproperties
{
}
