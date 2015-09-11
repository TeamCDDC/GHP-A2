//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Camera Base > GameCameraBase > Object
//
// The base camera object defines all the properties and behavior that will be
// common to all camera objects.
//================================================================================
class SGDKCameraBase extends GameCameraBase
    abstract;


/**Reference to the associated camera information object.*/ var CameraInfo CameraInformation;

   /**Horizontal field of view angle uses this value
         (in degrees), 0 means default value is used.*/ var float FieldOfView;
/**Roll component of camera rotation uses this value.*/ var int RollRotation;

/**Maximum allowed values for each component of camera location.*/ var vector MaxLocation;
/**Minimum allowed values for each component of camera location.*/ var vector MinLocation;

/**Camera smooth movement rate, 0 means no smooth rate.*/ var float SmoothLocationRate;
/**Camera smooth rotation rate, 0 means no smooth rate.*/ var float SmoothRotationRate;

/**Current vertical look factor that modifies camera and/or target location.*/ var float CurrentVerticalLookFactor;
/**Initial vertical look factor that modifies camera and/or target location.*/ var float InitialVerticalLookFactor;
                                    /**Maximum allowed vertical look factor.*/ var float MaxVerticalLookFactor;
                                    /**Minimum allowed vertical look factor.*/ var float MinVerticalLookFactor;
        /**Vertical look factor that modifies camera and/or target location.*/ var float VerticalLookFactor;
                /**Fixed amount used to harshly modify vertical look factor.*/ var float VerticalLookIncrement;

/**If true, disables zoom in/out of the camera.*/ var bool bDisableZoom;
/**Maximum factor limit applied to zoom in/out.*/ var float MaxZoomFactor;
/**Minimum factor limit applied to zoom in/out.*/ var float MinZoomFactor;
    /**Fixed amount used to modify camera zoom.*/ var float ZoomIncrement;
      /**Current factor applied to camera zoom.*/ var float ZoomFactor;

/**If true, camera location is adjusted if solid geometry is detected.*/ var bool bEnableCollision;
                                  /**Radius of camera collision check.*/ var float CollisionRadius;

struct TTargetData
{
                                         /**Name of camera target mode.*/ var name Style;

       /**Maximum allowed values for each component of target location.*/ var vector MaxLocation;
       /**Minimum allowed values for each component of target location.*/ var vector MinLocation;

/**If style is FixedPoint, target location is fixed at the given point.*/ var vector FixedLocation;
       /**Target location uses this offset relative to target location.*/ var vector OffsetVector;

            /**If true, target's velocity modifies camera location too.*/ var bool bVelocityModsCamera;
                           /**A fraction of target's velocity (factors
                              applied to XYZ) modifies target location.*/ var vector VelocityFactors;
                         /**Current offset from target due to velocity.*/ var vector VelocityOffset;
              /**Target's velocity smooth rate, 0 means no smooth rate.*/ var float VelocitySmoothRate;

    structdefaultproperties
    {
        MaxLocation=(X=999999.0,Y=999999.0,Z=999999.0)
        MinLocation=(X=-999999.0,Y=-999999.0,Z=-999999.0)
    }
};
/**Settings used to calculate camera target location.*/ var TTargetData TargetData;

/**If true, this camera is frozen.*/ var bool bFrozen;
          /**Frozen point of view.*/ var TPOV FrozenPOV;


/**
 * Does this camera allow blends?
 * @return  true if blends are allowed
 */
function bool AllowBlend()
{
    return !default.bResetCameraInterpolation;
}

/**
 * Does this camera allow zooms in/out?
 * @return  true if zooms are allowed
 */
function bool AllowZoom()
{
    return !bDisableZoom;
}

/**
 * Calculates the desired location of this camera; delegated to subclasses which should call this version.
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
    OutCameraLocation.X = FClamp(OutCameraLocation.X,MinLocation.X,MaxLocation.X);
    OutCameraLocation.Y = FClamp(OutCameraLocation.Y,MinLocation.Y,MaxLocation.Y);
    OutCameraLocation.Z = FClamp(OutCameraLocation.Z,MinLocation.Z,MaxLocation.Z);

    OutCameraLocation += (ViewTarget.Target.Location - OutCameraLocation) * ZoomFactor;
}

/**
 * Player wants to look down quickly.
 */
function FixedLookDown()
{
    VerticalLookFactor = FClamp(VerticalLookFactor + VerticalLookIncrement,
                                MinVerticalLookFactor,MaxVerticalLookFactor);
}

/**
 * Player wants to reset camera pitch rotation.
 */
function FixedLookReset()
{
    VerticalLookFactor = InitialVerticalLookFactor;
}

/**
 * Player wants to look up quickly.
 */
function FixedLookUp()
{
    VerticalLookFactor = FClamp(VerticalLookFactor - VerticalLookIncrement,
                                MinVerticalLookFactor,MaxVerticalLookFactor);
}

/**
 * Freezes this camera's point of view.
 */
function Freeze()
{
    bFrozen = true;

    PlayerCamera.GetCameraViewPoint(FrozenPOV.Location,FrozenPOV.Rotation);
    FrozenPOV.FOV = PlayerCamera.GetFOVAngle();
}

/**
 * Gets the location and rotation of the target of this camera.
 * @param DeltaTime          contains the amount of time in seconds that has passed since the last tick
 * @param ViewTarget         ViewTarget responsible for providing the camera with a target
 * @param OutTargetLocation  location of camera target
 * @param OutTargetRotation  rotation of camera target
 */
function GetTargetLocationRotation(float DeltaTime,TViewTarget ViewTarget,
                                   out vector OutTargetLocation,out rotator OutTargetRotation)
{
    local SGDKPlayerPawn P;
    local vector Offset,TargetLocation;

    P = SGDKPlayerPawn(ViewTarget.Target);

    if (P != none)
    {
        OutTargetLocation = P.GetCameraTarget();
        OutTargetRotation = P.GetSmoothRotation();

        Offset = -P.GetGravityDirection();
    }
    else
    {
        OutTargetLocation = ViewTarget.Target.Location;
        OutTargetRotation = ViewTarget.Target.Rotation;

        Offset = vect(0,0,1) >> OutTargetRotation;
    }

    TargetLocation = OutTargetLocation;

    if (!IsZero(ViewTarget.Target.Velocity))
        VerticalLookFactor = Lerp(VerticalLookFactor,0.0,DeltaTime);

    if (SmoothLocationRate > 0.0 || bResetCameraInterpolation)
        CurrentVerticalLookFactor = VerticalLookFactor;
    else
        CurrentVerticalLookFactor = Lerp(CurrentVerticalLookFactor,VerticalLookFactor,FMin(DeltaTime * 10.0,1.0));

    OutTargetLocation += Offset * (CurrentVerticalLookFactor * -150.0);

    if (TargetData.bVelocityModsCamera && !IsZero(TargetData.VelocityFactors))
    {
        if (P != none)
            Offset = P.GetVelocity() * TargetData.VelocityFactors;
        else
            Offset = ViewTarget.Target.Velocity * TargetData.VelocityFactors;

        if (TargetData.VelocitySmoothRate == 0.0)
            TargetData.VelocityOffset = Offset;
        else
            TargetData.VelocityOffset = VLerp(TargetData.VelocityOffset,Offset,
                                              FMin(DeltaTime * TargetData.VelocitySmoothRate,1.0));

        OutTargetLocation += TargetData.VelocityOffset;
    }

    switch (TargetData.Style)
    {
        case 'AbsoluteOffset':
            OutTargetLocation += TargetData.OffsetVector;

            break;

        case 'RelativeOffset':
            OutTargetLocation += (TargetData.OffsetVector >> OutTargetRotation);

            break;

        case 'FixedPoint':
            OutTargetLocation = TargetData.FixedLocation;

            break;

        case 'Kismet':
            OutTargetLocation = CameraInformation.Location + vector(CameraInformation.Rotation);
    }

    OutTargetLocation.X = FClamp(OutTargetLocation.X,TargetData.MinLocation.X,TargetData.MaxLocation.X);
    OutTargetLocation.Y = FClamp(OutTargetLocation.Y,TargetData.MinLocation.Y,TargetData.MaxLocation.Y);
    OutTargetLocation.Z = FClamp(OutTargetLocation.Z,TargetData.MinLocation.Z,TargetData.MaxLocation.Z);

    OutTargetLocation += (TargetLocation - OutTargetLocation) * ZoomFactor;
}

/**
 * Called when this camera mode becomes active.
 * @param PreviousCamera  the previous active camera
 */
function OnBecomeActive(GameCameraBase PreviousCamera)
{
    bFrozen = false;

    if (PreviousCamera == none || !SGDKCameraBase(PreviousCamera).AllowBlend())
        bResetCameraInterpolation = true;
    else
        bResetCameraInterpolation = default.bResetCameraInterpolation;

    CameraInformation = SGDKPlayerController(PlayerCamera.PCOwner).CurrentCameraInfo;

    if (CameraInformation != none)
    {
        FieldOfView = CameraInformation.CameraFieldOfView;
        RollRotation = CameraInformation.CameraRollRotation * DegToUnrRot;

        if (FieldOfView == 0.0)
            FieldOfView = PlayerCamera.DefaultFOV;

        if (CameraInformation.CameraMaxLocation.X != 0.0)
            MaxLocation.X = CameraInformation.CameraMaxLocation.X;
        if (CameraInformation.CameraMaxLocation.Y != 0.0)
            MaxLocation.Y = CameraInformation.CameraMaxLocation.Y;
        if (CameraInformation.CameraMaxLocation.Z != 0.0)
            MaxLocation.Z = CameraInformation.CameraMaxLocation.Z;

        if (CameraInformation.CameraMinLocation.X != 0.0)
            MinLocation.X = CameraInformation.CameraMinLocation.X;
        if (CameraInformation.CameraMinLocation.Y != 0.0)
            MinLocation.Y = CameraInformation.CameraMinLocation.Y;
        if (CameraInformation.CameraMinLocation.Z != 0.0)
            MinLocation.Z = CameraInformation.CameraMinLocation.Z;

        if (CameraInformation.TargetMaxLocation.X != 0.0)
            TargetData.MaxLocation.X = CameraInformation.TargetMaxLocation.X;
        if (CameraInformation.TargetMaxLocation.Y != 0.0)
            TargetData.MaxLocation.Y = CameraInformation.TargetMaxLocation.Y;
        if (CameraInformation.TargetMaxLocation.Z != 0.0)
            TargetData.MaxLocation.Z = CameraInformation.TargetMaxLocation.Z;

        if (CameraInformation.TargetMinLocation.X != 0.0)
            TargetData.MinLocation.X = CameraInformation.TargetMinLocation.X;
        if (CameraInformation.TargetMinLocation.Y != 0.0)
            TargetData.MinLocation.Y = CameraInformation.TargetMinLocation.Y;
        if (CameraInformation.TargetMinLocation.Z != 0.0)
            TargetData.MinLocation.Z = CameraInformation.TargetMinLocation.Z;

        SmoothLocationRate = CameraInformation.SmoothLocationRate;
        SmoothRotationRate = CameraInformation.SmoothRotationRate;

        CurrentVerticalLookFactor = CameraInformation.InitialVerticalLookFactor;
        InitialVerticalLookFactor = CameraInformation.InitialVerticalLookFactor;
        MaxVerticalLookFactor = CameraInformation.MaxVerticalLookFactor;
        MinVerticalLookFactor = CameraInformation.MinVerticalLookFactor;
        VerticalLookFactor = CameraInformation.InitialVerticalLookFactor;
        VerticalLookIncrement = CameraInformation.VerticalLookIncrement;

        bDisableZoom = CameraInformation.bDisableZoom;
        MaxZoomFactor = CameraInformation.MaxZoomFactor;
        MinZoomFactor = CameraInformation.MinZoomFactor;

        bEnableCollision = CameraInformation.bEnableCollision;
        CollisionRadius = CameraInformation.CollisionRadius;

        TargetData.Style = CameraInformation.GetTargetStyle();

        TargetData.FixedLocation = CameraInformation.TargetFixedLocation;
        TargetData.OffsetVector = CameraInformation.TargetOffsetVector;

        TargetData.bVelocityModsCamera = CameraInformation.bTargetVelocityModsCamera;
        TargetData.VelocityFactors = CameraInformation.TargetVelocityFactors;
        TargetData.VelocityOffset = vect(0,0,0);
        TargetData.VelocitySmoothRate = CameraInformation.TargetVelocitySmoothRate;
    }
    else
        FieldOfView = PlayerCamera.DefaultFOV;
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
    if (DeltaRotation.Pitch != 0)
        VerticalLookFactor = FClamp(VerticalLookFactor + DeltaRotation.Pitch * -UnrRotToRad,
                                    MinVerticalLookFactor,MaxVerticalLookFactor);
}

/**
 * Provides a point of view (POV) with camera location, rotation and FOV.
 * @param P              target pawn
 * @param PlayerCam      the PlayerCamera that owns this object
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param OutViewTarget  ViewTarget responsible for providing the camera with a point of view
 */
function UpdateCamera(Pawn P,GamePlayerCamera PlayerCam,float DeltaTime,out TViewTarget OutViewTarget)
{
    if (!bFrozen)
    {
        OutViewTarget.POV.FOV = FieldOfView;

        UpdateViewTarget(DeltaTime,OutViewTarget);
    }
    else
    {
        OutViewTarget.POV.FOV = FrozenPOV.FOV;
        OutViewTarget.POV.Location = FrozenPOV.Location;
        OutViewTarget.POV.Rotation = FrozenPOV.Rotation;
    }
}

/**
 * Provides a point of view (POV) with camera location, rotation and FOV.
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param OutViewTarget  ViewTarget responsible for providing the camera with a point of view
 */
function UpdateViewTarget(float DeltaTime,out TViewTarget OutViewTarget)
{
    local vector CameraLocation,TargetLocation,HitLocation,HitNormal;
    local rotator CameraRotation,TargetRotation;

    GetTargetLocationRotation(DeltaTime,OutViewTarget,TargetLocation,TargetRotation);

    CalculateCameraLocation(DeltaTime,OutViewTarget,TargetLocation,TargetRotation,CameraLocation);

    if (bResetCameraInterpolation || SmoothLocationRate == 0.0)
        OutViewTarget.POV.Location = CameraLocation;
    else
        OutViewTarget.POV.Location = VLerp(CameraLocation,OutViewTarget.POV.Location,
                                           0.5 ** (DeltaTime * SmoothLocationRate));

    if (bEnableCollision &&
        OutViewTarget.Target.Trace(HitLocation,HitNormal,OutViewTarget.POV.Location,TargetLocation,true,
                                   vect(1,1,1) * CollisionRadius,,class'Actor'.const.TRACEFLAG_Blocking) != none)
        OutViewTarget.POV.Location = HitLocation;

    CameraRotation = rotator(TargetLocation - OutViewTarget.POV.Location);
    CameraRotation.Roll = RollRotation;

    if (bResetCameraInterpolation || SmoothRotationRate == 0.0)
        OutViewTarget.POV.Rotation = CameraRotation;
    else
        OutViewTarget.POV.Rotation = RLerp(OutViewTarget.POV.Rotation,CameraRotation,
                                           FMin(DeltaTime * SmoothRotationRate,1.0),true);

    PlayerCamera.ApplyCameraModifiers(DeltaTime,OutViewTarget.POV);

    bResetCameraInterpolation = false;
}

/**
 * Zooms in camera.
 */
function ZoomIn()
{
    if (AllowZoom())
        ZoomFactor = FMin(ZoomFactor + ZoomIncrement,MaxZoomFactor);
}

/**
 * Zooms out camera.
 */
function ZoomOut()
{
    if (AllowZoom())
        ZoomFactor = FMax(MinZoomFactor,ZoomFactor - ZoomIncrement);
}


defaultproperties
{
    FieldOfView=90
    RollRotation=0

    MaxLocation=(X=999999.0,Y=999999.0,Z=999999.0)
    MinLocation=(X=-999999.0,Y=-999999.0,Z=-999999.0)

    SmoothLocationRate=5.0
    SmoothRotationRate=5.0

    InitialVerticalLookFactor=0.0
    MaxVerticalLookFactor=1.0
    MinVerticalLookFactor=-1.0
    VerticalLookFactor=0.0
    VerticalLookIncrement=1.0

    bDisableZoom=true
    MaxZoomFactor=1.0
    MinZoomFactor=0.0
    ZoomIncrement=0.05
    ZoomFactor=0.0

    bEnableCollision=false
    CollisionRadius=12.0
}
