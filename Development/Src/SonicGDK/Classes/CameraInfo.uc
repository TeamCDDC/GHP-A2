//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Camera Info > Info > Actor
//
// Classes based on Info hold only information.
// This class holds information related to a camera behavior.
//================================================================================
class CameraInfo extends Info
    ClassGroup(SGDK,Invisible)
    placeable
    hidecategories(Debug,Display,Mobile,Physics)
    showcategories(Movement);


enum EPointDefinition
{
                 /**No point defined, uses default one calculated by the game.*/ PD_Default,
                           /**Uses a constant offset from the target location.*/ PD_AbsoluteOffset,
/**Uses an offset from the target location taking into account an orientation.*/ PD_RelativeOffset,
                                               /**Uses a fixed point in space.*/ PD_FixedPoint,
               /**Uses a straight line path defined by CameraInfo orientation.*/ PD_StraightPath,
 /**Uses location and rotation parameters of CameraInfo manipulated by Kismet.*/ PD_Kismet,
                                                                  /**Not used.*/ PD_Custom1,
                                                                  /**Not used.*/ PD_Custom2,
                                                                  /**Not used.*/ PD_Custom3,
                                                                  /**Not used.*/ PD_Custom4,
                                                                  /**Not used.*/ PD_Custom5,
                                                                  /**Not used.*/ PD_Custom6,
                                                                  /**Not used.*/ PD_Custom7,
                                                                  /**Not used.*/ PD_Custom8,
                                                                  /**Not used.*/ PD_Custom9,
};
       /**Defines the position of the camera.*/ var(CameraInfo,Camera) EPointDefinition CameraPointDefinition;
/**Defines the position of the camera target.*/ var(CameraInfo,Target) EPointDefinition TargetPointDefinition;

struct TCameraClassLink
{
                                   /**Camera class type.*/ var() class<SGDKCameraBase> CameraClass;
/**Camera style name that activates a camera class type.*/ var() EPointDefinition PointDefinition;

    structdefaultproperties
    {
        CameraClass=class'CameraDefault'
        PointDefinition=PD_Default
    }
};
/**Relationships between each camera
    class type and camera style name.*/ var(CameraInfo,Camera) array<TCameraClassLink> CameraClassLinks;

  /**If true and CameraPointDefinition is FixedPoint, camera location
               at the moment of activation is used as the fixed point.*/ var(CameraInfo,Camera) bool bCameraCalcLocation;
/**If true and CameraPointDefinition is StraightPath, target location
                  Z component is used for camera location Z component.*/ var(CameraInfo,Camera) bool bCameraFlexiblePath;
       /**If true and CameraPointDefinition is RelativeOffset, camera
          location uses camera rotation instead of target orientation.*/ var(CameraInfo,Camera) bool bCameraRotationOffset;
      /**If CameraPointDefinition is AbsoluteOffset or RelativeOffset,
         camera location uses this offset relative to target location.*/ var(CameraInfo,Camera) vector CameraOffsetVector;

/**Horizontal field of view angle uses this value
      (in degrees), 0 means default value is used.*/ var(CameraInfo,Camera) byte CameraFieldOfView <ClampMin=0 | ClampMax=179>;
             /**Roll component of camera rotation
                     uses this value (in degrees).*/ var(CameraInfo,Camera) int CameraRollRotation;

/**Maximum allowed values for each component
        of camera location, 0 means no limit.*/ var(CameraInfo,Camera) vector CameraMaxLocation;
/**Minimum allowed values for each component
        of camera location, 0 means no limit.*/ var(CameraInfo,Camera) vector CameraMinLocation;

/**Camera smooth movement rate,
        0 means no smooth rate.*/ var(CameraInfo,Camera) float SmoothLocationRate <ClampMin=0.0 | ClampMax=100.0>;
/**Camera smooth rotation rate,
        0 means no smooth rate.*/ var(CameraInfo,Camera) float SmoothRotationRate <ClampMin=0.0 | ClampMax=100.0>;

/**Vertical look factor that modifies camera and/or target location.*/ var(CameraInfo,Camera) float InitialVerticalLookFactor;
                            /**Maximum allowed vertical look factor.*/ var(CameraInfo,Camera) float MaxVerticalLookFactor;
                            /**Minimum allowed vertical look factor.*/ var(CameraInfo,Camera) float MinVerticalLookFactor;
        /**Fixed amount used to harshly modify vertical look factor.*/ var(CameraInfo,Camera) float VerticalLookIncrement;

/**If true, disables zoom in/out of the camera.*/ var(CameraInfo,Camera) bool bDisableZoom;
/**Maximum factor limit applied to zoom in/out.*/ var(CameraInfo,Camera) float MaxZoomFactor;
/**Minimum factor limit applied to zoom in/out.*/ var(CameraInfo,Camera) float MinZoomFactor;

/**If true, camera is adjusted if solid geometry is detected
                 between camera location and target location.*/ var(CameraInfo,Camera) bool bEnableCollision;
                         /**Radius of camera collision check.*/ var(CameraInfo,Camera) float CollisionRadius;

              /**If TargetPointDefinition is FixedPoint, target
                           location is fixed at the given point.*/ var(CameraInfo,Target) vector TargetFixedLocation;
/**If TargetPointDefinition is AbsoluteOffset or RelativeOffset,
   target location uses this offset relative to target location.*/ var(CameraInfo,Target) vector TargetOffsetVector;

/**If true, target's velocity modifies camera location too.*/ var(CameraInfo,Target) bool bTargetVelocityModsCamera;
               /**A fraction of target's velocity (factors
                  applied to XYZ) modifies target location.*/ var(CameraInfo,Target) vector TargetVelocityFactors;
  /**Target's velocity smooth rate, 0 means no smooth rate.*/ var(CameraInfo,Target) float TargetVelocitySmoothRate <ClampMin=0.0 | ClampMax=100.0>;

/**Maximum allowed values for each component
        of target location, 0 means no limit.*/ var(CameraInfo,Target) vector TargetMaxLocation;
/**Minimum allowed values for each component
        of target location, 0 means no limit.*/ var(CameraInfo,Target) vector TargetMinLocation;

enum EMoveDefinition
{
/**No constrained or limited movement, default 3D movement.*/ MD_Default,
                               /**Movement is very limited.*/ MD_Limited,
              /**Classic movement constrained to 2.5D path.*/ MD_Classic2dot5d,
                 /**Runway movement constrained to 3D path.*/ MD_Runway3d,
                                               /**Not used.*/ MD_Custom1,
                                               /**Not used.*/ MD_Custom2,
                                               /**Not used.*/ MD_Custom3,
                                               /**Not used.*/ MD_Custom4,
                                               /**Not used.*/ MD_Custom5,
                                               /**Not used.*/ MD_Custom6,
                                               /**Not used.*/ MD_Custom7,
                                               /**Not used.*/ MD_Custom8,
                                               /**Not used.*/ MD_Custom9,
};
/**Indicates the type of allowed movement.*/ var(CameraInfo,Controls) EMoveDefinition MovementDefinition;

struct TControlClassLink
{
                                    /**Control class type.*/ var() class<SGDKControlBase> ControlClass;
/**Control style name that activates a control class type.*/ var() EMoveDefinition MovementDefinition;

    structdefaultproperties
    {
        ControlClass=class'ControlDefault'
        MovementDefinition=MD_Default
    }
};
/**Relationships between each control
     class type and control style name.*/ var(CameraInfo,Controls) array<TControlClassLink> ControlClassLinks;

/**If true, disables controls related to turning left/right.*/ var(CameraInfo,Controls) bool bDisableTurning;
         /**If true and MovementDefinition is Classic2dot5d,
                   forward key input can be used to advance.*/ var(CameraInfo,Controls) bool bForwardAdvances;


/**
 * Called immediately before gameplay begins.
 */
simulated event PreBeginPlay()
{
    super.PreBeginPlay();

    if (CameraFieldOfView < 10)
        CameraFieldOfView = 0;
}

/**
 * Gets the name of the desired camera mode.
 * @return  name of camera mode
 */
function name GetCameraStyle()
{
    return GetStyleNamePD(CameraPointDefinition);
}

/**
 * Gets the name of the desired control mode.
 * @return  name of control mode
 */
function name GetControlStyle()
{
    return GetStyleNameMD(MovementDefinition);
}

/**
 * Gets the name from EMoveDefinition enumeration.
 * @param MoveDefinition  chosen option
 * @return                name conversion
 */
static function name GetStyleNameMD(EMoveDefinition MoveDefinition)
{
    return name(Mid(string(MoveDefinition),3));
}

/**
 * Gets the name from EPointDefinition enumeration.
 * @param PointDefinition  chosen option
 * @return                 name conversion
 */
static function name GetStyleNamePD(EPointDefinition PointDefinition)
{
    return name(Mid(string(PointDefinition),3));
}

/**
 * Gets the name of the camera target mode.
 * @return  name of camera target mode
 */
function name GetTargetStyle()
{
    return GetStyleNamePD(TargetPointDefinition);
}


defaultproperties
{
    Components.Remove(Sprite)


    Begin Object Class=ArrowComponent Name=Arrow
        bTreatAsASprite=true
        ArrowColor=(R=255,G=0,B=0,A=255)
        ArrowSize=10.0
        SpriteCategoryName="Info"
    End Object
    Components.Add(Arrow)


    Begin Object Class=DynamicLightEnvironmentComponent Name=CameraLightEnvironment
        bCastShadows=false
        bDynamic=false
    End Object
    Components.Add(CameraLightEnvironment)


    Begin Object Class=StaticMeshComponent Name=CameraStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.CameraStaticMesh'
        LightEnvironment=CameraLightEnvironment
        CastShadow=false
        CollideActors=false
        HiddenGame=true
    End Object
    Components.Add(CameraStaticMesh)


    bEdShouldSnap=true         //It snaps to the grid in the editor.
    Physics=PHYS_Interpolating //Can be moved with Matinee.

    CameraPointDefinition=PD_Default
    TargetPointDefinition=PD_Default

    CameraClassLinks.Add((CameraClass=class'CameraDefault',PointDefinition=PD_Default))
    CameraClassLinks.Add((CameraClass=class'CameraOffsetAbsolute',PointDefinition=PD_AbsoluteOffset))
    CameraClassLinks.Add((CameraClass=class'CameraOffsetRelative',PointDefinition=PD_RelativeOffset))
    CameraClassLinks.Add((CameraClass=class'CameraFixedPoint',PointDefinition=PD_FixedPoint))
    CameraClassLinks.Add((CameraClass=class'CameraStraightPath',PointDefinition=PD_StraightPath))
    CameraClassLinks.Add((CameraClass=class'CameraKismet',PointDefinition=PD_Kismet))

    bCameraCalcLocation=false
    bCameraFlexiblePath=false
    bCameraRotationOffset=true
    CameraOffsetVector=(X=0.0,Y=0.0,Z=0.0)

    CameraFieldOfView=90
    CameraRollRotation=0

    TargetFixedLocation=(X=0.0,Y=0.0,Z=0.0)
    TargetOffsetVector=(X=0.0,Y=0.0,Z=0.0)

    bTargetVelocityModsCamera=false
    TargetVelocityFactors=(X=1.0,Y=1.0,Z=1.0)
    TargetVelocitySmoothRate=2.5

    SmoothLocationRate=5.0
    SmoothRotationRate=5.0

    InitialVerticalLookFactor=0.0
    MaxVerticalLookFactor=0.0
    MinVerticalLookFactor=0.0
    VerticalLookIncrement=1.0

    bDisableZoom=true
    MaxZoomFactor=1.0
    MinZoomFactor=0.0

    bEnableCollision=false
    CollisionRadius=12.0

    MovementDefinition=MD_Default

    ControlClassLinks.Add((ControlClass=class'ControlDefault',MovementDefinition=MD_Default))
    ControlClassLinks.Add((ControlClass=class'ControlLimited',MovementDefinition=MD_Limited))
    ControlClassLinks.Add((ControlClass=class'ControlClassic2D',MovementDefinition=MD_Classic2dot5d))
    ControlClassLinks.Add((ControlClass=class'ControlRunway3D',MovementDefinition=MD_Runway3d))

    bDisableTurning=true
    bForwardAdvances=true
}
