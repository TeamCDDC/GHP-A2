//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Start Animation > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action plays/stops an animation.
//================================================================================
class SeqAct_StartAnimation extends SequenceAction;


      /**The name of the animation to play.*/ var() name AnimationName;
   /**Blend duration to play the animation.*/ var() float BlendInTime;
/**Time to blend out before animation ends.*/ var() float BlendOutTime;

/**Whether or not to play the animation over again even if it's already being played.*/ var() bool bOverride;

              /**Whether or not to loop the animation.*/ var() bool bLoop;
/**Duration of the looping animation; 0 means forever.*/ var() float LoopTime;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Pawn P;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        P = GetPawn(Actor(ObjectVar.GetObjectValue()));

        if (P != none && SGDKPawn(P) != none)
        {
            if (InputLinks[0].bHasImpulse)
            {
                SGDKPawn(P).StartAnimation(AnimationName,1.0,BlendInTime,BlendOutTime,bLoop,bOverride,LoopTime);

                OutputLinks[0].bHasImpulse = true;
            }
            else
            {
                SGDKPawn(P).StopAnimation(AnimationName);

                OutputLinks[1].bHasImpulse = true;
            }
        }
    }
}


defaultproperties
{
    bAutoActivateOutputLinks=false      //All output links won't automatically be activated when this op has finished executing.
    bCallHandler=false                  //The handler function won't be called on all targeted actors.
    InputLinks[0]=(LinkDesc="Play")     //Input link containing a connection; activated if the animation must be played.
    InputLinks[1]=(LinkDesc="Stop")     //Input link containing a connection; activated if the animation must be stopped.
    ObjCategory="SGDK"                  //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Start Animation"           //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Played")  //Output link containing a connection; activated if the animation is played.
    OutputLinks[1]=(LinkDesc="Stopped") //Output link containing a connection; activated if the animation is stopped.

    bOverride=true
    BlendInTime=0.2
    BlendOutTime=0.2
}
