//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// GFx Menu Pause > SGDKMenuGFxMovie > SGDKGFxMovie > GFxMoviePlayer > Object
//
// A Scaleform GFx movie; this class is the pause menu.
//================================================================================
class GFxMenuPause extends SGDKMenuGFxMovie;


/**Generic list of standard screen resolutions.*/ var const array<string> StandardResolutions;

/**Array of data structures used for screen resolutions list.*/ var array<TOptionData> ScreenResolutions;

/**Index of applied screen resolution.*/ var int AppliedResIndex;
         /**Initial screen resolution.*/ var string Resolution;
 /**Index of chosen screen resolution.*/ var int ResolutionIndex;

      /**If true, screen is in fullscreen mode.*/ var bool bFullscreen;
/**CLIK widget associated to fullscreen option.*/ var GFxClikWidget FullscreenOption;

/**Index of chosen graphics bucket.*/ var int GraphicsIndex;


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
    local int i;
    local GFxObject DataProvider,DataSlot;

    ClikWidget = GFxClikWidget(Widget);

    if (ClikWidget != none)
    {
        ClikWidget.SetString("name",string(WidgetName));

        switch (WidgetName)
        {
            case 'ApplyButton':
            case 'ExitButton':
            case 'FpsButton':
            case 'RestartButton':
            case 'ResumeButton':
                ClikWidget.AddEventListener('CLIK_click',ButtonPressed);

                break;

            case 'FullscreenOption':
                ClikWidget.SetBool("selected",bFullscreen);

                ClikWidget.AddEventListener('CLIK_click',OptionChanged);

                FullscreenOption = ClikWidget;

                break;

            case 'GraphicsOption':
                ClikWidget.SetInt("selectedIndex",GraphicsIndex);

                ClikWidget.AddEventListener('CLIK_change',OptionChanged);

                break;

            case 'ResolutionOption':
                DataProvider = CreateArray();

                for (i = 0; i < ScreenResolutions.Length; i++)
                {
                    DataSlot = CreateObject("Object");

                    DataSlot.SetString("name",ScreenResolutions[i].Id);
                    DataSlot.SetString("label",ScreenResolutions[i].Label);
                    DataSlot.SetString("desc",ScreenResolutions[i].Description);

                    DataProvider.SetElementObject(i,DataSlot);
                }

                ClikWidget.SetObject("dataProvider",DataProvider);
                ClikWidget.SetInt("selectedIndex",AppliedResIndex);

                ClikWidget.AddEventListener('CLIK_change',OptionChanged);
        }

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
    {
        switch (Button.GetString("name"))
        {
            case "ApplyButton":
                bFullscreen = FullscreenOption.GetBool("selected");
                AppliedResIndex = ResolutionIndex;

                PC.ConsoleCommand("setres" @ ScreenResolutions[AppliedResIndex].Id $ (bFullscreen ? "f" : "w"));
                PC.ConsoleCommand("scale set fullscreen" @ bFullscreen);

                break;

            case "ExitButton":
                PC.GFxButtonPressed(MenuName $ ".ExitButton");

                break;

            case "FpsButton":
                PC.ConsoleCommand("stat fps");
                PC.ConsoleCommand("stat unit");

                break;

            case "RestartButton":
                PC.GFxButtonPressed(MenuName $ ".RestartButton");

                break;

            case "ResumeButton":
                PC.GFxButtonPressed(MenuName $ ".ResumeButton");
        }
    }
}

/**
 * Listener for the option's "changed" event.
 * @param Data  event data from CLIK component
 */
function OptionChanged(EventData Data)
{
    local GFxObject Option;

    Option = Data._this.GetObject("target");

    if (Option != none)
    {
        switch (Option.GetString("name"))
        {
            case "FullscreenOption":
                if (ResolutionIndex == 0)
                    FullscreenOption.SetBool("selected",false);

                break;

            case "GraphicsOption":
                GraphicsIndex = Option.GetInt("selectedIndex");

                SGDKGameInfo(class'WorldInfo'.static.GetWorldInfo().Game).SystemSettings(GraphicsIndex + 1);

                break;

            case "ResolutionOption":
                ResolutionIndex = Option.GetInt("selectedIndex");

                if (ResolutionIndex == 0)
                    FullscreenOption.SetBool("selected",false);
        }
    }
}

/**
 * Called before the movie starts playing.
 */
function PreStarted()
{
    local WorldInfo World;
    local SGDKGameInfo Game;
    local int i;
    local GameViewportClient GVC;
    local vector2d ViewportSize;
    local string DumpedResolutions,AvailableResolutions;
    local array<string> Resolutions;

    super.PreStarted();

    AddFocusIgnoreKey('Escape');

    World = class'WorldInfo'.static.GetWorldInfo();
    Game = SGDKGameInfo(World.Game);

    GVC = GetLP().ViewportClient;
    GVC.GetViewportSize(ViewportSize);

    bFullscreen = GVC.IsFullScreenViewport();
    Resolution = int(ViewportSize.X) $ "x" $ int(ViewportSize.Y);
    ResolutionIndex = INDEX_NONE;

    DumpedResolutions = GetPC().ConsoleCommand("dumpavailableresolutions",false);

    for (i = 0; i < StandardResolutions.Length; i++)
        if (InStr(DumpedResolutions,StandardResolutions[i]) != INDEX_NONE)
        {
            AvailableResolutions $= StandardResolutions[i] $ "\n";
            DumpedResolutions -= StandardResolutions[i];
        }

    Resolutions = SplitString(AvailableResolutions $ DumpedResolutions,"\n",true);

    if (Resolutions.Length > 1)
        for (i = Resolutions.Length - 1; i > 0; i--)
        {
            if (Resolutions[i - 1] == Resolutions[i])
                Resolutions.Remove(i,1);
        }

    for (i = 0; i < Resolutions.Length; i++)
    {
        ScreenResolutions.Add(1);

        ScreenResolutions[ScreenResolutions.Length - 1].Description = Resolutions[i];
        ScreenResolutions[ScreenResolutions.Length - 1].Id = Resolutions[i];
        ScreenResolutions[ScreenResolutions.Length - 1].Label = Resolutions[i];

        if (Resolutions[i] == Resolution)
            ResolutionIndex = i;
    }

    if (ResolutionIndex == INDEX_NONE)
    {
        ScreenResolutions.Insert(0,1);

        ScreenResolutions[0].Description = Resolution;
        ScreenResolutions[0].Id = Resolution;
        ScreenResolutions[0].Label = Resolution;

        ResolutionIndex = 0;
    }
    else
    {
        ScreenResolutions.Insert(0,1);

        ScreenResolutions[0].Description = "854x480";
        ScreenResolutions[0].Id = "854x480";
        ScreenResolutions[0].Label = "854x480";

        ResolutionIndex++;
    }

    GraphicsIndex = Game.SettingsBucket - 1;

    AppliedResIndex = ResolutionIndex;
}


defaultproperties
{
    bCaptureInput=false
    bShowHardwareMouseCursor=true
    MovieInfo=SwfMovie'SonicGDKPackUserInterface.Flash.PauseMenu'
    WidgetBindings.Add((WidgetName="ApplyButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="ExitButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="FpsButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="FullscreenOption",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="GraphicsOption",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="ResolutionOption",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="RestartButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="ResumeButton",WidgetClass=class'GFxCLIKWidget'))

    MenuName="PauseMenu"
    StandardResolutions.Add("640x480")
    StandardResolutions.Add("720x480")
    StandardResolutions.Add("720x576")
    StandardResolutions.Add("768x480")
    StandardResolutions.Add("800x480")
    StandardResolutions.Add("800x600")
    StandardResolutions.Add("854x480")
    StandardResolutions.Add("960x540")
    StandardResolutions.Add("960x640")
    StandardResolutions.Add("960x720")
    StandardResolutions.Add("1024x576")
    StandardResolutions.Add("1024x600")
    StandardResolutions.Add("1024x640")
    StandardResolutions.Add("1024x768")
    StandardResolutions.Add("1136x640")
    StandardResolutions.Add("1152x720")
    StandardResolutions.Add("1152x768")
    StandardResolutions.Add("1152x864")
    StandardResolutions.Add("1280x720")
    StandardResolutions.Add("1280x768")
    StandardResolutions.Add("1280x800")
    StandardResolutions.Add("1280x864")
    StandardResolutions.Add("1280x960")
    StandardResolutions.Add("1280x1024")
    StandardResolutions.Add("1360x768")
    StandardResolutions.Add("1366x768")
    StandardResolutions.Add("1400x1050")
    StandardResolutions.Add("1440x900")
    StandardResolutions.Add("1440x960")
    StandardResolutions.Add("1600x900")
    StandardResolutions.Add("1600x1024")
    StandardResolutions.Add("1600x1200")
    StandardResolutions.Add("1680x1050")
    StandardResolutions.Add("1792x1344")
    StandardResolutions.Add("1856x1392")
    StandardResolutions.Add("1920x1080")
    StandardResolutions.Add("1920x1200")
    StandardResolutions.Add("1920x1440")
    StandardResolutions.Add("2048x1152")
    StandardResolutions.Add("2048x1536")
    StandardResolutions.Add("2560x1440")
    StandardResolutions.Add("2560x1600")
    StandardResolutions.Add("2560x1920")
    StandardResolutions.Add("2560x2048")
    StandardResolutions.Add("2880x1620")
    StandardResolutions.Add("2880x1800")
    StandardResolutions.Add("3200x1800")
    StandardResolutions.Add("3200x2048")
    StandardResolutions.Add("3200x2400")
    StandardResolutions.Add("3840x2160")
    StandardResolutions.Add("3840x2400")
    StandardResolutions.Add("4096x2160")
    StandardResolutions.Add("4096x2560")
    StandardResolutions.Add("4096x3072")
    StandardResolutions.Add("5120x2160")
    StandardResolutions.Add("5120x2880")
    StandardResolutions.Add("5120x3200")
    StandardResolutions.Add("5120x4096")
    StandardResolutions.Add("5760x3240")
    StandardResolutions.Add("6400x4096")
    StandardResolutions.Add("6400x4800")
    StandardResolutions.Add("7680x4320")
    StandardResolutions.Add("7680x4800")
    StandardResolutions.Add("8192x5120")
    StandardResolutions.Add("10080x4320")
    StandardResolutions.Add("15360x8640")
}
