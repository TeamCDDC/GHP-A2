//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Set Camera Style > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action sets the style of a player's camera.
//================================================================================
class SeqAct_SetCameraStyle extends SequenceAction;


/**Reference to the associated camera information object.*/ var CameraInfo CamInfo;

   /**Exponent, used by certain blend functions to control the shape of the curve.*/ var() float BlendExponent;
                    /**Function to apply to interpolation of the blend parameters.*/ var() EViewTargetBlendFunction BlendFunction;
/**Total duration in seconds of blend to pending view target; 0 means no blending.*/ var() float BlendTime;

     /**If true, enables blending (from previous camera) for horizontal field of view.*/ var() bool bBlendFOV;
                     /**If true, enables blending (from previous camera) for location.*/ var() bool bBlendLocation;
                     /**If true, enables blending (from previous camera) for rotation.*/ var() bool bBlendRotation;
/**If true, locks the outgoing previous camera position and orientation for the blend.*/ var() bool bLockOutgoing;


defaultproperties
{
    ObjCategory="SGDK"         //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Set Camera Style" //Text label that describes this object.
    VariableLinks[1]=(ExpectedType=class'SeqVar_Object',LinkDesc="Camera Info",MinVars=0,MaxVars=1,PropertyName=CamInfo)

    BlendExponent=4.0
    BlendFunction=VTBlend_EaseInOut
    BlendTime=1.0

    bBlendFOV=true
    bBlendLocation=true
    bBlendRotation=true
    bLockOutgoing=false
}
