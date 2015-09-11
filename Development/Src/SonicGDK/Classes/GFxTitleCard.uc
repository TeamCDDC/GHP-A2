//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// GFx Title Card > SGDKGFxMovie > GFxMoviePlayer > Object
//
// A Scaleform GFx movie; this class is the title card.
//================================================================================
class GFxTitleCard extends SGDKGFxMovie;


/**Name of the act to show.*/ var string ActName;
/**Name of the map to show.*/ var string LevelName;


/**
 * Called when a CLIK widget with enableInitCallback set to true is initialized.
 * @param WidgetName  name of the CLIK widget
 * @param WidgetPath  full path to the CLIK widget
 * @param Widget      the CLIK widget object
 * @return            true if the widget was handled, false if not
 */
event bool WidgetInitialized(name WidgetName,name WidgetPath,GFxObject Widget)
{
    local GFxClikWidget ClikWidget;

    ClikWidget = GFxClikWidget(Widget);

    if (ClikWidget != none)
    {
        ClikWidget.SetString("name",string(WidgetName));

        switch (WidgetName)
        {
            case 'ActText':
                ClikWidget.SetString("text",ActName);

                break;

            case 'LevelText':
                ClikWidget.SetString("text",LevelName);
        }

        return true;
    }

    return false;
}


defaultproperties
{
    bCaptureInput=false         //Doesn't capture player key input.
    bCaptureMouseInput=false    //Doesn't capture player mouse input.
    bDisplayWithHudOff=true     //The movie will be rendered if the HUD is hidden.
    bIgnoreMouseInput=true      //Ignores player mouse input.
    bPauseGameWhileActive=false //The game won't pause while the movie is active.
    TimingMode=TM_Real          //Pausing the game doesn't pause the movie.
    WidgetBindings.Add((WidgetName="ActText",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="LevelText",WidgetClass=class'GFxCLIKWidget'))
}
