//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Menu GFx Movie > SGDKGFxMovie > GFxMoviePlayer > Object
//
// The GFxMoviePlayer class is the base class of all classes responsible for
// initializing and playing a Scaleform GFx movie. This class should be subclassed
// in order to implement specialized functionality unique to the individual movie
// for which the player is responsible.
//================================================================================
class SGDKMenuGFxMovie extends SGDKGFxMovie;


/**Unique name that identifies this menu.*/ var() string MenuName;


/**
 * Starts playing the movie.
 * @param bStartPaused  true if the movie needs to be paused upon startup
 * @return              false if there were load errors
 */
event bool Start(optional bool bStartPaused = false)
{
    if (super.Start(bStartPaused))
    {
        PreStarted();

        Advance(0.0);

        PostStarted();

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
    if (GFxClikWidget(Widget) != none)
    {
        GFxClikWidget(Widget).SetString("name",string(WidgetName));

        if (GetAVMVersion() == 1)
            GFxClikWidget(Widget).AddEventListener('CLIK_press',ButtonPressed);
        else
            GFxClikWidget(Widget).AddEventListener('CLIK_buttonPress',ButtonPressed);

        return true;
    }

    return false;
}

/**
 * Listener for the button's "pressed" event.
 * @param Data  event data from CLIK component
 */
function ButtonPressed(EventData Data)
{
    local GFxObject Button;
    local SGDKPlayerController PC;

    Button = Data._this.GetObject("target");
    PC = SGDKPlayerController(GetPC());

    if (Button != none && PC != none)
        PC.GFxButtonPressed(MenuName $ "." $ Button.GetString("name"));
}

/**
 * Should be called manually when a new movie is created.
 * @param LP  the LocalPlayer that owns this movie
 */
function Init(optional LocalPlayer LP)
{
    if (LP != none)
    {
        LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LP);

        if (LocalPlayerOwnerIndex == INDEX_NONE)
            LocalPlayerOwnerIndex = 0;
    }
    else
        LocalPlayerOwnerIndex = 0;

    if (MovieInfo != none && bAutoPlay)
        Start();
}

/**
 * Called after the movie starts playing.
 */
function PostStarted()
{
}

/**
 * Called before the movie starts playing.
 */
function PreStarted()
{
}


defaultproperties
{
    bCaptureInput=true             //Captures player key input.
    bCaptureMouseInput=true        //Captures player mouse input.
    bDisplayWithHudOff=true        //The movie will be rendered if the HUD is hidden.
    bIgnoreMouseInput=false        //Doesn't ignore player mouse input.
    bPauseGameWhileActive=true     //The game will pause while the movie is active.
    bShowHardwareMouseCursor=false //Doesn't show the hardware mouse cursor.
    TimingMode=TM_Real             //Pausing the game doesn't pause the movie.
}
