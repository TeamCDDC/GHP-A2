//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Show Title Card > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action shows the title card of the current level on screen.
//================================================================================
class SeqAct_ShowTitleCard extends SequenceAction;


/**If true, the node won't be activated if "Play in Editor" mode is detected.*/ var() bool bDisableWithPIE;

/**Flash SWF movie used for the title card.*/ var() SwfMovie CardSwfMovie;
                /**Name of the map to show.*/ var() string MapName;
          /**Extra name of the map to show.*/ var() string SubMapName;

/**Screen starts to fade from black after this time passes.*/ var() float ScreenFadeDelayTime;
      /**How much time the screen takes to fade from black.*/ var() float ScreenFadeDurationTime;
            /**Controls are enabled after this time passes.*/ var() float ToggleControlsDelayTime;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Controller C;

    if (!bDisableWithPIE || !GetWorldInfo().IsPlayInEditor())
    {
        foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
        {
            C = GetController(Actor(ObjectVar.GetObjectValue()));

            if (C != none && SGDKPlayerController(C) != none)
                SGDKPlayerController(C).GetHud().OnShowTitleCard(self);
        }
    }
}


defaultproperties
{
    bCallHandler=false        //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"        //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Show Title Card" //Text label that describes this object.

    bDisableWithPIE=true
    CardSwfMovie=SwfMovie'SonicGDKPackUserInterface.Flash.TitleCard'
    MapName="new level"
    ScreenFadeDelayTime=1.0
    ScreenFadeDurationTime=1.0
    ToggleControlsDelayTime=0.5
}
