//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK HUD GFx Movie > SGDKGFxMovie > GFxMoviePlayer > Object
//
// The GFxMoviePlayer class is the base class of all classes responsible for
// initializing and playing a Scaleform GFx movie. This class should be subclassed
// in order to implement specialized functionality unique to the individual movie
// for which the player is responsible. The HUD class may have any number of these
// referenced at any time to play the various elements of the user interface.
//================================================================================
class SGDKHudGFxMovie extends SGDKGFxMovie;


/**
 * Starts playing the movie.
 * @param bStartPaused  true if the movie needs to be paused upon startup
 * @return              false if there were load errors
 */
event bool Start(optional bool bStartPaused = false)
{
    if (super.Start(bStartPaused))
    {
        //Use these options for Flash HUDs.
        SetViewScaleMode(SM_ShowAll);
        SetAlignment(Align_TopLeft);

        return true;
    }

    return false;
}

/**
 * Called when a CLIK widget with enableInitCallback set to true is initialized.
 * @param WidgetName  name of the CLIK widget
 * @param WidgetPath  full path to the CLIK widget
 * @param Widget      the CLIK widget object
 * @return            true if the widget was handled, false if not
 */
event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
    return false;
}

/**
 * Called whenever time passes to update graphics.
 * @param DeltaTime  time in seconds since last render
 * @param TheHud     the HUD
 */
function Update(float DeltaTime,SGDKHud TheHud)
{
}


defaultproperties
{
    bCaptureInput=false         //Doesn't capture player key input.
    bCaptureMouseInput=false    //Doesn't capture player mouse input.
    bDisplayWithHudOff=false    //The movie won't be rendered if the HUD is hidden.
    bIgnoreMouseInput=true      //Ignores player mouse input.
    bPauseGameWhileActive=false //The game won't pause while the movie is active.
    TimingMode=TM_Game          //Pausing the game pauses the movie.
}
