//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Player Camera > GamePlayerCamera > Camera > Actor
//
// When it exists, defines the master camera that the player actually uses to look
// through.
//================================================================================
class SGDKPlayerCamera extends GamePlayerCamera;


struct TCameraData
{
         /**Class of camera mode.*/ var class<GameCameraBase> CameraClass;
          /**Name of camera mode.*/ var name CameraName;
/**The actual camera mode object.*/ var GameCameraBase GameCamera;
};
/**Holds all types of camera modes.*/ var array<TCameraData> GameCameras;

struct TBlendData
{
     /**If true, blending is applied to camera FOV.*/ var() bool bBlendFOV;
/**If true, blending is applied to camera location.*/ var() bool bBlendLocation;
/**If true, blending is applied to camera rotation.*/ var() bool bBlendRotation;

    structdefaultproperties
    {
        bBlendFOV=true
        bBlendLocation=true
        bBlendRotation=true
    }
};
/**Additional settings for camera blending.*/ var TBlendData MoreBlendParams;

          /**If true, blending between two cameras.*/ var bool bBlendingCameras;
/**If true, the current camera is being calculated.*/ var bool bCalcCurrentCam;
             /**Which camera is about to be active.*/ var GameCameraBase PendingCamera;

struct TControlData
{
         /**Class of control mode.*/ var class<SGDKControlBase> ControlClass;
          /**Name of control mode.*/ var name ControlName;
/**The actual control mode object.*/ var SGDKControlBase GameControl;
};
/**The currently used control mode object.*/ var SGDKControlBase ControlManager;
      /**Holds all types of control modes.*/ var array<TControlData> GameControls;

/**Reference to the water volume that activates a SoundMode.*/ var SGDKWaterVolume UnderwaterVolume;

         /**Reference to the wavy distortion effect.*/ var MaterialEffect WavyDistortionEffect;
/**Material instance for the wavy distortion effect.*/ var transient MaterialInstanceConstant WavyDistortionEffectMIC;
/**Volume that activates the wavy distortion effect.*/ var SGDKPostProcessVolume WavyPostProcessVolume;


/**
 * Creates and adds a camera base object for a new camera mode.
 * @param CameraName   name of camera mode
 * @param CameraClass  class of camera mode
 * @return             camera mode object
 */
function GameCameraBase AddCameraMode(name CameraName,optional class<GameCameraBase> CameraClass)
{
    local CameraInfo CamInfo;
    local int i;
    local TCameraData NewCamera;

    if (CameraClass == none)
    {
        CamInfo = SGDKPlayerController(PCOwner).CurrentCameraInfo;

        if (CamInfo != none)
        {
            for (i = 0; i < CamInfo.CameraClassLinks.Length; i++)
                if (CameraName == CamInfo.GetStyleNamePD(CamInfo.CameraClassLinks[i].PointDefinition))
                {
                    CameraClass = CamInfo.CameraClassLinks[i].CameraClass;

                    break;
                }
        }
    }

    if (CameraClass == none)
        CameraClass = class'CameraDefault';

    NewCamera.GameCamera = CreateCamera(CameraClass);

    NewCamera.CameraClass = CameraClass;
    NewCamera.CameraName = CameraName;

    GameCameras.AddItem(NewCamera);

    return NewCamera.GameCamera;
}

/**
 * Creates and adds a control base object for a new control mode.
 * @param ControlName   name of control mode
 * @param ControlClass  class of control mode
 * @return              control mode object
 */
function SGDKControlBase AddControlMode(name ControlName,optional class<SGDKControlBase> ControlClass)
{
    local CameraInfo CamInfo;
    local int i;
    local TControlData NewControl;

    if (ControlClass == none)
    {
        CamInfo = SGDKPlayerController(PCOwner).CurrentCameraInfo;

        if (CamInfo != none)
        {
            for (i = 0; i < CamInfo.ControlClassLinks.Length; i++)
                if (ControlName == CamInfo.GetStyleNameMD(CamInfo.ControlClassLinks[i].MovementDefinition))
                {
                    ControlClass = CamInfo.ControlClassLinks[i].ControlClass;

                    break;
                }
        }
    }

    if (ControlClass == none)
        ControlClass = class'ControlDefault';

    NewControl.GameControl = CreateControl(ControlClass);

    NewControl.ControlClass = ControlClass;
    NewControl.ControlName = ControlName;

    GameControls.AddItem(NewControl);

    return NewControl.GameControl;
}

/**
 * Creates and initializes a new control mode of the specified class.
 * @param ControlClass  class of control mode
 * @return              control mode object
 */
function SGDKControlBase CreateControl(class<SGDKControlBase> ControlClass)
{
    local SGDKControlBase NewControl;

    NewControl = new(Outer) ControlClass;
    NewControl.PlayerCamera = self;
    NewControl.Init();

    return NewControl;
}

/**
 * Performs camera update; called once per frame after all actors have been ticked.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last camera update
 */
simulated function DoUpdateCamera(float DeltaTime)
{
    local float BlendPct,DurationPct;
    local TPOV NewPOV;

    //Reset aspect ratio and postprocess override associated with CameraActor.
    bConstrainAspectRatio = false;
    CamOverridePostProcessAlpha = 0.0;

    bCalcCurrentCam = true;

    //Update current viewtarget.
    CheckViewTarget(ViewTarget);
    UpdateViewTarget(ViewTarget,DeltaTime);

    bCalcCurrentCam = false;

    //Our camera is now viewing there.
    NewPOV = ViewTarget.POV;

    ConstrainedAspectRatio = ViewTarget.AspectRatio;

    //If we have a pending view target, perform transition from one to another.
    if (bBlendingCameras)
    {
        BlendTimeToGo -= DeltaTime;

        //Reset aspect ratio; the call to UpdateViewTarget() may turn this back on.
        bConstrainAspectRatio = false;

        //Update pending viewtarget.
        CheckViewTarget(PendingViewTarget);
        UpdateViewTarget(PendingViewTarget,DeltaTime);

        if (BlendTimeToGo > 0.0)
        {
            //Blend now.
            DurationPct = (BlendParams.BlendTime - BlendTimeToGo) / BlendParams.BlendTime;

            switch (BlendParams.BlendFunction)
            {
                case VTBlend_Linear:
                    BlendPct = Lerp(0.0,1.0,DurationPct);

                    break;

                case VTBlend_Cubic:
                    BlendPct = FCubicInterp(0.0,0.0,1.0,0.0,DurationPct);

                    break;

                case VTBlend_EaseIn:
                    BlendPct = FInterpEaseIn(0.0,1.0,DurationPct,BlendParams.BlendExp);

                    break;

                case VTBlend_EaseOut:
                    BlendPct = FInterpEaseOut(0.0,1.0,DurationPct,BlendParams.BlendExp);

                    break;

                case VTBlend_EaseInOut:
                    BlendPct = FInterpEaseInOut(0.0,1.0,DurationPct,BlendParams.BlendExp);
            }

            if (MoreBlendParams.bBlendFOV)
                NewPOV.FOV = Lerp(ViewTarget.POV.FOV,PendingViewTarget.POV.FOV,BlendPct);
            else
                NewPOV.FOV = PendingViewTarget.POV.FOV;

            if (MoreBlendParams.bBlendLocation)
                NewPOV.Location = VLerp(ViewTarget.POV.Location,PendingViewTarget.POV.Location,BlendPct);
            else
                NewPOV.Location = PendingViewTarget.POV.Location;

            if (MoreBlendParams.bBlendRotation)
                NewPOV.Rotation = RLerp(ViewTarget.POV.Rotation,PendingViewTarget.POV.Rotation,BlendPct,true);
            else
                NewPOV.Rotation = PendingViewTarget.POV.Rotation;
        }
        else
        {
            //We're done blending, set new viewtarget.
            ViewTarget = PendingViewTarget;

            //Clear pending viewtarget.
            PendingViewTarget.Controller = none;
            PendingViewTarget.Target = none;

            bBlendingCameras = false;
            BlendTimeToGo = 0.0;

            //Our camera is now viewing there.
            NewPOV = PendingViewTarget.POV;

            if (CurrentCamera != none)
            {
                CurrentCamera.OnBecomeInactive(PendingCamera);

                RemoveCameraMode(CurrentCamera);
            }

            CurrentCamera = PendingCamera;
            PendingCamera = none;
        }

        if (bConstrainAspectRatio)
            //Don't interpolate aspect ratio.
            ConstrainedAspectRatio = PendingViewTarget.AspectRatio;
    }

    UpdateUnderwaterSound(NewPOV.Location);
    UpdateWavyDistortion(NewPOV.Location);

    //Cache results.
    FillCameraCache(NewPOV);

    //Update color scale interpolation.
    if (bEnableColorScaleInterp)
    {
        BlendPct = FClamp((WorldInfo.TimeSeconds - ColorScaleInterpStartTime) / ColorScaleInterpDuration,0.0,1.0);
        ColorScale = VLerp(OriginalColorScale,DesiredColorScale,BlendPct);

        //If we've maxed...
        if (BlendPct == 1.0)
            //Disable further interpolation.
            bEnableColorScaleInterp = false;
    }

    if (bEnableFading && FadeTimeRemaining > 0.0)
    {
        FadeTimeRemaining = FMax(0.0,FadeTimeRemaining - DeltaTime);

        if (FadeTime > 0.0)
            FadeAmount = FadeAlpha.X + ((1.0 - FadeTimeRemaining / FadeTime) * (FadeAlpha.Y - FadeAlpha.X));

        if (bFadeAudio)
        {
            ApplyAudioFade();

            if (FadeAmount == 0)
                bFadeAudio = false;
        }
    }
}

/**
 * Player wants to look down quickly.
 */
function FixedLookDown()
{
    if (CurrentCamera != none)
        SGDKCameraBase(CurrentCamera).FixedLookDown();
}

/**
 * Player wants to reset camera pitch rotation.
 */
function FixedLookReset()
{
    if (CurrentCamera != none)
        SGDKCameraBase(CurrentCamera).FixedLookReset();
}

/**
 * Player wants to look up quickly.
 */
function FixedLookUp()
{
    if (CurrentCamera != none)
        SGDKCameraBase(CurrentCamera).FixedLookUp();
}

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
    if (ControlManager != none)
        return ControlManager.GetAccelerationInput(P,InputManager,ControllerX,ControllerY,ControllerZ);
    else
        return vect(0,0,0);
}

/**
 * Retrieves camera's actual location.
 * @return  camera location
 */
final function vector GetCameraLocation()
{
    return CameraCache.POV.Location;
}

/**
 * Initializes this camera for the associated PlayerController.
 * @param PC  the associated PlayerController
 */
function InitializeFor(PlayerController PC)
{
    DefaultFOV = SGDKPlayerController(PC).OnFootDefaultFOV;

    super.InitializeFor(PC);

    CurrentCamera = AddCameraMode('');
    ControlManager = AddControlMode('');
}

/**
 * The postprocessing chain has changed and postprocess effects can be bound.
 */
function NotifyBindPostProcessEffects()
{
    WavyDistortionEffect = MaterialEffect(LocalPlayer(PCOwner.Player).PlayerPostProcess.FindPostProcessEffect('WavyEffect'));

    if (WavyDistortionEffect != none)
    {
        if (MaterialInstanceConstant(WavyDistortionEffect.Material) != none &&
            WavyDistortionEffect.Material.GetPackageName() == 'Transient')
            //The runtime material already exists, grab it.
            WavyDistortionEffectMIC = MaterialInstanceConstant(WavyDistortionEffect.Material);
        else
        {
            WavyDistortionEffectMIC = new(WavyDistortionEffect) class'MaterialInstanceConstant';
            WavyDistortionEffectMIC.SetParent(WavyDistortionEffect.Material);
            WavyDistortionEffect.Material = WavyDistortionEffectMIC;
        }

        WavyDistortionEffect.bShowInGame = false;
    }
}

/**
 * Gives cameras and controls a chance to influence player view rotation.
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param ViewRotation   current player view rotation
 * @param DeltaRotation  player input added to view rotation
 */
function ProcessViewRotation(float DeltaTime,out rotator ViewRotation,out rotator DeltaRotation)
{
    if (CurrentCamera != none)
        CurrentCamera.ProcessViewRotation(DeltaTime,ViewTarget.Target,ViewRotation,DeltaRotation);

    if (ControlManager != none)
        ControlManager.ProcessViewRotation(DeltaTime,ViewTarget.Target,ViewRotation,DeltaRotation);

    if (Pawn(ViewTarget.Target) != none)
        Pawn(ViewTarget.Target).ProcessViewRotation(DeltaTime,ViewRotation,DeltaRotation);
}

/**
 * Removes a camera mode object.
 * @param CameraMode  camera mode object
 */
function RemoveCameraMode(GameCameraBase CameraMode)
{
    local int i;

    for (i = 0; i < GameCameras.Length; i++)
        if (GameCameras[i].GameCamera == CameraMode)
        {
            GameCameras.Remove(i,1);

            break;
        }
}

/**
 * Removes a control mode object.
 * @param ControlMode  control mode object
 */
function RemoveControlMode(SGDKControlBase ControlMode)
{
    local int i;

    for (i = 0; i < GameControls.Length; i++)
        if (GameControls[i].GameControl == ControlMode)
        {
            GameControls.Remove(i,1);

            break;
        }
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    ResetCameraStyle();
}

/**
 * Resets the active camera mode.
 */
function ResetCameraStyle()
{
    GameCameras.Length = 0;
    GameControls.Length = 0;

    ControlManager = none;
    CurrentCamera = none;
    PendingCamera = none;

    bBlendingCameras = false;
    BlendTimeToGo = 0.0;

    PendingViewTarget.Controller = none;
    PendingViewTarget.Target = none;

    ViewTarget.Controller = none;
    ViewTarget.Target = none;

    CameraStyle = default.CameraStyle;

    CurrentCamera = AddCameraMode('');
    ControlManager = AddControlMode('');
}

/**
 * Sets a new camera mode as active.
 * @param NewCameraStyle      name of new camera mode
 * @param NewBlendParams      blending parameters
 * @param NewMoreBlendParams  more blending parameters
 */
function SetCameraStyle(name NewCameraStyle,optional ViewTargetTransitionParams NewBlendParams,
                        optional TBlendData NewMoreBlendParams)
{
    local SGDKControlBase NewControlMode;

    if (bBlendingCameras)
    {
        if (CurrentCamera != none)
        {
            CurrentCamera.OnBecomeInactive(PendingCamera);

            RemoveCameraMode(CurrentCamera);
        }

        CurrentCamera = PendingCamera;

        NewBlendParams.BlendTime *= 0.5;

        SGDKCameraBase(CurrentCamera).Freeze();
    }

    BlendParams = NewBlendParams;
    PendingCamera = AddCameraMode(NewCameraStyle);

    if (bInterpolateCamChanges && BlendParams.BlendTime > 0.0 && CurrentCamera != none &&
        SGDKCameraBase(CurrentCamera).AllowBlend() && SGDKCameraBase(PendingCamera).AllowBlend())
    {
        bBlendingCameras = true;

        MoreBlendParams = NewMoreBlendParams;

        BlendTimeToGo = BlendParams.BlendTime;
        PendingViewTarget = ViewTarget;

        if (BlendParams.bLockOutgoing)
            SGDKCameraBase(CurrentCamera).Freeze();

        PendingCamera.OnBecomeActive(CurrentCamera);
    }
    else
    {
        bBlendingCameras = false;
        BlendTimeToGo = 0.0;

        PendingViewTarget.Controller = none;
        PendingViewTarget.Target = none;

        if (CurrentCamera != none)
        {
            CurrentCamera.OnBecomeInactive(PendingCamera);

            RemoveCameraMode(CurrentCamera);
        }

        PendingCamera.OnBecomeActive(CurrentCamera);
        PendingCamera.ResetInterpolation();

        CurrentCamera = PendingCamera;
        PendingCamera = none;
    }

    CameraStyle = NewCameraStyle;

    if (SGDKPlayerController(PCOwner).CurrentCameraInfo != none)
    {
        NewControlMode = AddControlMode(SGDKPlayerController(PCOwner).CurrentCameraInfo.GetControlStyle());

        if (ControlManager != none)
        {
            ControlManager.OnBecomeInactive(NewControlMode);

            RemoveControlMode(ControlManager);
        }

        NewControlMode.OnBecomeActive(ControlManager);

        ControlManager = NewControlMode;
    }
}

/**
 * Sets a new horizontal field of view angle.
 * @param NewFOV  new horizontal field of view angle in degrees
 */
function SetFOV(float NewFOV)
{
    if (CurrentCamera != none)
        SGDKCameraBase(CurrentCamera).FieldOfView = NewFOV;
    else
        if (NewFOV < 10 || NewFOV > 179.0)
            bLockedFOV = false;
        else
        {
            bLockedFOV = true;
            LockedFOV = NewFOV;
        }
}

/**
 * Should the player view rotation be allowed to be modified?
 * @param P  pawn currently being moved
 * @return   true if view rotation (controls) can be rotated
 */
function bool ShouldViewRotate(SGDKPlayerPawn P)
{
    if (ControlManager != none)
        return ControlManager.ShouldViewRotate(P);
    else
        return false;
}

/**
 * Updates the underwater sound mode.
 * @param CameraLocation  current location of the camera
 */
function UpdateUnderwaterSound(vector CameraLocation)
{
    local SGDKWaterVolume V;

    if (PCOwner.Pawn != none && PCOwner.Pawn.PhysicsVolume != none)
    {
        V = SGDKWaterVolume(PCOwner.Pawn.PhysicsVolume);

        if (V != none && V.UnderwaterSoundMode != '' && V.UnderwaterSoundMode != 'Default' &&
            V.EncompassesPoint(CameraLocation))
        {
            if (UnderwaterVolume == none || V != UnderwaterVolume)
            {
                UnderwaterVolume = V;

                SGDKPlayerController(PCOwner).SetSoundMode(V.UnderwaterSoundMode);
            }
        }
        else
            if (UnderwaterVolume != none)
            {
                SGDKPlayerController(PCOwner).SetSoundMode('Default');

                UnderwaterVolume = none;
            }
    }
    else
        if (UnderwaterVolume != none)
        {
            SGDKPlayerController(PCOwner).SetSoundMode('Default');

            UnderwaterVolume = none;
        }
}

/**
 * Queries ViewTarget and returns a Point of View.
 * @param OutViewTarget  ViewTarget to use
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last camera update
 */
function UpdateViewTarget(out TViewTarget OutViewTarget,float DeltaTime)
{
    local GameCameraBase CameraBase;
    local CameraActor CamActor;

    //Make sure we have a valid target.
    if (OutViewTarget.Target == none)
        `log("PlayerCamera UpdateViewTarget OutViewTarget.Target = None");
    else
    {
        if (bCalcCurrentCam)
            CameraBase = CurrentCamera;
        else
            CameraBase = PendingCamera;

        //Update point of view of camera.
        if (CameraBase != none)
        {
            CamActor = CameraActor(OutViewTarget.Target);

            if (CamActor != none)
            {
                CamActor.GetCameraView(DeltaTime,OutViewTarget.POV);

                ApplyCameraModifiers(DeltaTime,OutViewTarget.POV);

                //Check to see if we should be constraining the viewport aspect.
                //Only allows aspect ratio constraints for fixed cameras.
                if (CamActor.bConstrainAspectRatio)
                {
                    bConstrainAspectRatio = true;
                    OutViewTarget.AspectRatio = CamActor.AspectRatio;
                }

                //See if the CameraActor wants to override the postprocess settings used.
                CamOverridePostProcessAlpha = CamActor.CamOverridePostProcessAlpha;

                if (CamOverridePostProcessAlpha > 0.0)
                    CamPostProcessSettings = CamActor.CamOverridePostProcess;
            }
            else
                CameraBase.UpdateCamera(Pawn(OutViewTarget.Target),self,DeltaTime,OutViewTarget);
        }
        else
            OutViewTarget.POV.FOV = DefaultFOV;

        //Check for forced FOV.
        if (bUseForcedCamFOV)
            OutViewTarget.POV.FOV = ForcedCamFOV;

        //Adjust FOV for splitscreen, 4:3...
        OutViewTarget.POV.FOV = AdjustFOVForViewport(OutViewTarget.POV.FOV,Pawn(OutViewTarget.Target));

        //Set camera's location and rotation, to handle cases where the camera isn't locked to view target.
        SetRotation(OutViewTarget.POV.Rotation);
        SetLocation(OutViewTarget.POV.Location);

        UpdateCameraLensEffects(OutViewTarget);

        //Store info about the target's base, to handle targets that are standing on moving geometry.
        CacheLastTargetBaseInfo(OutViewTarget.Target.Base);
    }
}

/**
 * Updates the wavy distortion effect.
 * @param CameraLocation  current location of the camera
 */
function UpdateWavyDistortion(vector CameraLocation)
{
    local PostProcessVolume PPVolume;
    local SGDKPostProcessVolume SGDKPPVolume;

    if (WavyDistortionEffect != none)
    {
        PPVolume = WorldInfo.HighestPriorityPostProcessVolume;

        while (PPVolume != none)
            if (PPVolume.bEnabled && SGDKPostProcessVolume(PPVolume) != none &&
                SGDKPostProcessVolume(PPVolume).MoreSettings.bEnableWavyDistortion &&
                PPVolume.EncompassesPoint(CameraLocation))
            {
                SGDKPPVolume = SGDKPostProcessVolume(PPVolume);

                break;
            }
            else
                PPVolume = PPVolume.NextLowerPriorityVolume;

        if (SGDKPPVolume == none)
        {
            WavyDistortionEffect.bShowInGame = false;
            WavyPostProcessVolume = none;
        }
        else
            if (SGDKPPVolume != WavyPostProcessVolume)
            {
                if (!WorldInfo.IsPlayInEditor())
                    WavyDistortionEffectMIC.SetScalarParameterValue('Amount',SGDKPPVolume.MoreSettings.Wavy_Amount);
                else
                    WavyDistortionEffectMIC.SetScalarParameterValue('Amount',SGDKPPVolume.MoreSettings.Wavy_Amount * 0.5);

                WavyDistortionEffectMIC.SetScalarParameterValue('PanningSpeed',SGDKPPVolume.MoreSettings.Wavy_PanningSpeed);

                WavyDistortionEffect.bShowInGame = true;
                WavyPostProcessVolume = SGDKPPVolume;
            }
    }
}

/**
 * Zooms in camera.
 */
function ZoomIn()
{
    if (CurrentCamera != none)
        SGDKCameraBase(CurrentCamera).ZoomIn();

    if (PendingCamera != none)
        SGDKCameraBase(PendingCamera).ZoomIn();
}

/**
 * Zooms out camera.
 */
function ZoomOut()
{
    if (CurrentCamera != none)
        SGDKCameraBase(CurrentCamera).ZoomOut();

    if (PendingCamera != none)
        SGDKCameraBase(PendingCamera).ZoomOut();
}


defaultproperties
{
    bConstrainAspectRatio=false //Doesn't insert black areas to constrain aspect ratio of the camera.
    bInterpolateCamChanges=true //Allows interpolation between camera mode changes.
    FixedCameraClass=none       //Ignore.
    ThirdPersonCameraClass=none //Ignore.
}
