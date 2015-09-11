//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// GFx Menu Main > SGDKMenuGFxMovie > SGDKGFxMovie > GFxMoviePlayer > Object
//
// A Scaleform GFx movie; this class is the main menu.
//================================================================================
class GFxMenuMain extends SGDKMenuGFxMovie;


/**Generic list of standard screen resolutions.*/ var const array<string> StandardResolutions;

/**Objects that manage data saved in files.*/ var SaveDataObject PersistentData[6];
              /**Index of chosen save slot.*/ var int SlotIndex;

struct TOptionData
{
/**Long description of the option.*/ var string Description;
       /**Unique ID of the option.*/ var string Id;
   /**Label displayed in the list.*/ var string Label;
};
        /**Array of data structures used for characters list.*/ var array<TOptionData> AvailableChars;
              /**Array of data structures used for maps list.*/ var array<TOptionData> AvailableMaps;
/**Array of data structures used for screen resolutions list.*/ var array<TOptionData> ScreenResolutions;
              /**Array of data structures used for maps list.*/ var array<TOptionData> SelectableMaps;

/**CLIK widget associated to characters option.*/ var GFxClikWidget CharOption;

                       /**If true, a custom maps list is defined.*/ var bool bCustomMapsList;
                            /**If true, the chosen map is locked.*/ var bool bLockedMap;
/**CLIK widgets associated to the data related to the chosen map.*/ var GFxClikWidget MapDataText[6];
/**CLIK widget associated to the image related to the chosen map.*/ var GFxClikWidget MapImage;
                                          /**Index of chosen map.*/ var int MapIndex;
         /**CLIK widget associated to the name of the chosen map.*/ var GFxClikWidget MapNameText;
                         /**Array of stored data related to maps.*/ var array<TMapData> MapsData;

/**Index of applied screen resolution.*/ var int AppliedResIndex;
         /**Initial screen resolution.*/ var string Resolution;
 /**Index of chosen screen resolution.*/ var int ResolutionIndex;

      /**If true, screen is in fullscreen mode.*/ var bool bFullscreen;
/**CLIK widget associated to fullscreen option.*/ var GFxClikWidget FullscreenOption;

/**Index of chosen graphics bucket.*/ var int GraphicsIndex;

/**If true, vertical synchronization is enabled to prevent screen tearing.*/ var bool bVsync;


/**
 * Called when a movie is closed to allow cleanup and handling.
 */
event OnClose()
{
    PersistentData[0] = none;
    PersistentData[1] = none;
    PersistentData[2] = none;
    PersistentData[3] = none;
    PersistentData[4] = none;
    PersistentData[5] = none;

    super.OnClose();
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
    local GFxClikWidget ClikWidget;
    local int i;
    local GFxObject DataProvider,DataSlot;
    local JsonObject SavedData;

    ClikWidget = GFxClikWidget(Widget);

    if (ClikWidget != none)
    {
        ClikWidget.SetString("name",string(WidgetName));

        switch (WidgetName)
        {
            case 'ApplyButton':
            case 'ExitButton':
            case 'FpsButton':
            case 'InfoButton':
            case 'LaunchButton':
            case 'Load1Button':
            case 'Load2Button':
            case 'Load3Button':
            case 'Load4Button':
            case 'Load5Button':
            case 'Load6Button':
                ClikWidget.AddEventListener('CLIK_click',ButtonPressed);

                break;

            case 'CharOption':
                DataProvider = CreateArray();

                for (i = 0; i < AvailableChars.Length; i++)
                {
                    DataSlot = CreateObject("Object");

                    DataSlot.SetString("name",AvailableChars[i].Id);
                    DataSlot.SetString("label",AvailableChars[i].Label);
                    DataSlot.SetString("desc",AvailableChars[i].Description);

                    DataProvider.SetElementObject(i,DataSlot);
                }

                ClikWidget.SetObject("dataProvider",DataProvider);
                ClikWidget.SetInt("selectedIndex",0);

                CharOption = ClikWidget;

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

            case 'MapDataText1':
                MapDataText[0] = ClikWidget;

                MapChanged();

                break;

            case 'MapDataText2':
                MapDataText[1] = ClikWidget;

                MapChanged();

                break;

            case 'MapDataText3':
                MapDataText[2] = ClikWidget;

                MapChanged();

                break;

            case 'MapDataText4':
                MapDataText[3] = ClikWidget;

                MapChanged();

                break;

            case 'MapDataText5':
                MapDataText[4] = ClikWidget;

                MapChanged();

                break;

            case 'MapDataText6':
                MapDataText[5] = ClikWidget;

                MapChanged();

                break;

            case 'MapImageLoader':
                ClikWidget.SetString("source","img://" $
                                     SGDKGameInfo(class'WorldInfo'.static.GetWorldInfo().Game).DefaultMapPreviewImage);

                MapImage = ClikWidget;

                MapChanged();

                break;

            case 'MapNameText':
                MapNameText = ClikWidget;

                MapChanged();

                break;

            case 'MapOption':
                DataProvider = CreateArray();
                SelectableMaps = AvailableMaps;

                if (bCustomMapsList)
                {
                    if (SlotIndex >= 0 && PersistentData[SlotIndex] != none)
                    {
                        SavedData = PersistentData[SlotIndex].GetData();

                        if (SavedData.HasKey("Maps"))
                        {
                            for (i = 0; i < SelectableMaps.Length; i++)
                                if (InStr(SavedData.GetStringValue("Maps"),
                                          "." $ SelectableMaps[i].Id $ ".",,true) == INDEX_NONE)
                                {
                                    SelectableMaps.Length = i + 1;

                                    break;
                                }
                        }
                        else
                            SelectableMaps.Length = 1;
                    }
                    else
                        SelectableMaps.Length = 1;
                }

                for (i = 0; i < SelectableMaps.Length; i++)
                {
                    DataSlot = CreateObject("Object");

                    DataSlot.SetString("name",SelectableMaps[i].Id);
                    DataSlot.SetString("label",SelectableMaps[i].Label);
                    DataSlot.SetString("desc",SelectableMaps[i].Description);

                    DataProvider.SetElementObject(i,DataSlot);
                }

                ClikWidget.SetObject("dataProvider",DataProvider);
                ClikWidget.SetInt("selectedIndex",MapIndex);

                ClikWidget.AddEventListener('CLIK_change',OptionChanged);

                break;

            case 'NoLoadButton':
                CharOption = none;
                MapDataText[0] = none;
                MapDataText[1] = none;
                MapDataText[2] = none;
                MapDataText[3] = none;
                MapDataText[4] = none;
                MapDataText[5] = none;
                MapImage = none;
                MapNameText = none;

                ClikWidget.AddEventListener('CLIK_click',ButtonPressed);

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

                break;

            case 'Slot1Text1':
                if (PersistentData[0] != none)
                {
                    SavedData = PersistentData[0].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Levels")));
                }

                break;

            case 'Slot1Text2':
                if (PersistentData[0] != none)
                {
                    SavedData = PersistentData[0].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Lives")));
                }

                break;

            case 'Slot1Text3':
                if (PersistentData[0] != none)
                {
                    SavedData = PersistentData[0].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Emeralds")));
                }

                break;

            case 'Slot2Text1':
                if (PersistentData[1] != none)
                {
                    SavedData = PersistentData[1].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Levels")));
                }

                break;

            case 'Slot2Text2':
                if (PersistentData[1] != none)
                {
                    SavedData = PersistentData[1].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Lives")));
                }

                break;

            case 'Slot2Text3':
                if (PersistentData[1] != none)
                {
                    SavedData = PersistentData[1].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Emeralds")));
                }

                break;

            case 'Slot3Text1':
                if (PersistentData[2] != none)
                {
                    SavedData = PersistentData[2].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Levels")));
                }

                break;

            case 'Slot3Text2':
                if (PersistentData[2] != none)
                {
                    SavedData = PersistentData[2].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Lives")));
                }

                break;

            case 'Slot3Text3':
                if (PersistentData[2] != none)
                {
                    SavedData = PersistentData[2].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Emeralds")));
                }

                break;

            case 'Slot4Text1':
                if (PersistentData[3] != none)
                {
                    SavedData = PersistentData[3].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Levels")));
                }

                break;

            case 'Slot4Text2':
                if (PersistentData[3] != none)
                {
                    SavedData = PersistentData[3].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Lives")));
                }

                break;

            case 'Slot4Text3':
                if (PersistentData[3] != none)
                {
                    SavedData = PersistentData[3].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Emeralds")));
                }

                break;

            case 'Slot5Text1':
                if (PersistentData[4] != none)
                {
                    SavedData = PersistentData[4].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Levels")));
                }

                break;

            case 'Slot5Text2':
                if (PersistentData[4] != none)
                {
                    SavedData = PersistentData[4].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Lives")));
                }

                break;

            case 'Slot5Text3':
                if (PersistentData[4] != none)
                {
                    SavedData = PersistentData[4].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Emeralds")));
                }

                break;

            case 'Slot6Text1':
                if (PersistentData[5] != none)
                {
                    SavedData = PersistentData[5].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Levels")));
                }

                break;

            case 'Slot6Text2':
                if (PersistentData[5] != none)
                {
                    SavedData = PersistentData[5].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Lives")));
                }

                break;

            case 'Slot6Text3':
                if (PersistentData[5] != none)
                {
                    SavedData = PersistentData[5].GetData();

                    ClikWidget.SetString("text",string(SavedData.GetIntValue("Emeralds")));
                }

                break;

            case 'VsyncOption':
                ClikWidget.SetBool("selected",bVsync);

                ClikWidget.AddEventListener('CLIK_click',OptionChanged);
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
                SGDKGameInfo(PC.WorldInfo.Game).ExitGame();

                break;

            case "FpsButton":
                PC.ConsoleCommand("stat fps");
                PC.ConsoleCommand("stat unit");

                break;

            case "InfoButton":
                class'Engine'.static.LaunchURL("http://info.sonicretro.org/SonicGDK");

                break;

            case "LaunchButton":
                if (!bLockedMap)
                    LaunchMap();

                break;

            case "Load1Button":
                MapIndex = 0;
                SlotIndex = 0;

                break;

            case "Load2Button":
                MapIndex = 0;
                SlotIndex = 1;

                break;

            case "Load3Button":
                MapIndex = 0;
                SlotIndex = 2;

                break;

            case "Load4Button":
                MapIndex = 0;
                SlotIndex = 3;

                break;

            case "Load5Button":
                MapIndex = 0;
                SlotIndex = 4;

                break;

            case "Load6Button":
                MapIndex = 0;
                SlotIndex = 5;

                break;

            case "NoLoadButton":
                MapIndex = 0;
                SlotIndex = -1;
        }
    }
}

/**
 * Opens the selected map.
 */
function LaunchMap()
{
    local string Switches;

    Switches = "?Pawn=" $ AvailableChars[CharOption.GetInt("selectedIndex")].Id;

    if (SlotIndex >= 0)
        Switches $= "?Save=" $ (SlotIndex + 1) $ "?Game=Default";
    else
        Switches $= "?Game=Default";

    ConsoleCommand("open" @ SelectableMaps[MapIndex].Id $ Switches);
}

/**
 * Called when a map has been selected.
 */
function MapChanged()
{
    local bool bFound;
    local float ElapsedTime;
    local int Minutes,Seconds,CentiSeconds,i,j,Emeralds,RedRings;
    local JsonObject SavedData;
    local SGDKGameInfo Game;

    if (MapDataText[0] != none && MapDataText[1] != none && MapDataText[2] != none &&
        MapDataText[3] != none && MapDataText[4] != none && MapDataText[5] != none &&
        MapImage != none && MapNameText != none)
    {
        if (SlotIndex > -1 && PersistentData[SlotIndex] != none)
        {
            SavedData = PersistentData[SlotIndex].GetData();

            MapDataText[0].SetString("text","" $ SavedData.GetIntValue("Lives"));

            if (!SavedData.HasKey(SelectableMaps[MapIndex].Id $ ".Rank"))
                MapDataText[1].SetString("text","?");
            else
                MapDataText[1].SetString("text",SavedData.GetStringValue(SelectableMaps[MapIndex].Id $ ".Rank"));

            MapDataText[2].SetString("text","" $ SavedData.GetIntValue(SelectableMaps[MapIndex].Id $ ".Score"));

            if (!SavedData.HasKey(SelectableMaps[MapIndex].Id $ ".Time"))
                MapDataText[3].SetString("text","-");
            else
            {
                ElapsedTime = SavedData.GetFloatValue(SelectableMaps[MapIndex].Id $ ".Time");

                Minutes = ElapsedTime / 60;
                Seconds = ElapsedTime - Minutes * 60;
                CentiSeconds = (ElapsedTime - int(ElapsedTime)) * 100;

                MapDataText[3].SetString("text","" $ Minutes $ "'" $ Seconds $ "\"" $ CentiSeconds);
            }

            MapDataText[4].SetString("text","" $ SavedData.GetIntValue(SelectableMaps[MapIndex].Id $ ".Rings"));

            if (!SavedData.HasKey(SelectableMaps[MapIndex].Id $ ".RedRings"))
                MapDataText[5].SetString("text","?");
            else
            {
                i = 0;

                while (SavedData.HasKey(SelectableMaps[MapIndex].Id $ ".RedRing" $ i))
                {
                    if (SavedData.GetBoolValue(SelectableMaps[MapIndex].Id $ ".RedRing" $ i))
                        RedRings++;

                    i++;
                }

                MapDataText[5].SetString("text","" $ RedRings $ "/" $
                                                SavedData.GetIntValue(SelectableMaps[MapIndex].Id $ ".RedRings"));
            }

            Emeralds = SavedData.GetIntValue("Emeralds");
            RedRings = 0;

            for (i = 0; i < SelectableMaps.Length; i++)
                if (SavedData.HasKey(SelectableMaps[i].Id $ ".RedRings"))
                {
                    j = 0;

                    while (SavedData.HasKey(SelectableMaps[i].Id $ ".RedRing" $ j))
                    {
                        if (SavedData.GetBoolValue(SelectableMaps[i].Id $ ".RedRing" $ j))
                            RedRings++;

                        j++;
                    }
                }
        }

        bLockedMap = false;
        Game = SGDKGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);

        for (i = 0; i < MapsData.Length; i++)
            if (MapsData[i].PackageName ~= SelectableMaps[MapIndex].Id)
            {
                bFound = true;

                if (MapsData[i].UnlockEmeralds <= Emeralds && MapsData[i].UnlockRedRings <= RedRings)
                {
                    MapImage.SetString("source","img://" $ MapsData[i].PreviewImage);
                    MapNameText.SetString("text",MapsData[i].ReadableName);
                }
                else
                {
                    MapImage.SetString("source","img://" $ Game.DefaultMapPreviewImage);

                    if (MapsData[i].UnlockEmeralds > Emeralds)
                        MapNameText.SetString("text",Game.NotEnoughEmeraldsText);
                    else
                        MapNameText.SetString("text",Game.NotEnoughRedRingsText);

                    bLockedMap = true;
                }

                break;
            }

        if (!bFound)
        {
            MapImage.SetString("source","img://" $ Game.DefaultMapPreviewImage);
            MapNameText.SetString("text"," ");
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

            case "MapOption":
                MapIndex = Option.GetInt("selectedIndex");

                MapChanged();

                break;

            case "ResolutionOption":
                ResolutionIndex = Option.GetInt("selectedIndex");

                if (ResolutionIndex == 0)
                    FullscreenOption.SetBool("selected",false);

                break;

            case "VsyncOption":
                bVsync = Option.GetBool("selected");

                GetPC().ConsoleCommand("scale set usevsync" @ bVsync);
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
    local int i,j;
    local array<UDKUIResourceDataProvider> MapDataProviders;
    local string MapName,DumpedResolutions,AvailableResolutions;
    local GameViewportClient GVC;
    local vector2d ViewportSize;
    local array<string> Resolutions;

    super.PreStarted();

    World = class'WorldInfo'.static.GetWorldInfo();
    Game = SGDKGameInfo(World.Game);

    if (!World.IsPlayInEditor() && !World.IsPlayInPreview())
        for (i = 0; i < 6; i++)
        {
            PersistentData[i] = new class'SaveDataObject';

            if (!PersistentData[i].LoadData("slot" $ (i + 1)))
                PersistentData[i] = none;
        }

    for (i = 0; i < Game.AvailableChars.Length; i++)
    {
        AvailableChars.Add(1);

        AvailableChars[AvailableChars.Length - 1].Description = Game.AvailableChars[i].ReadableName;
        AvailableChars[AvailableChars.Length - 1].Id = Game.AvailableChars[i].ClassName;
        AvailableChars[AvailableChars.Length - 1].Label = Game.AvailableChars[i].ReadableName;
    }

    MapsData = Game.MapsData;

    if (Game.MapsSequence.Length == 0)
    {
        class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo',
                                                                          MapDataProviders);

        for (i = 0; i < MapDataProviders.Length; i++)
        {
            MapName = UTUIDataProvider_MapInfo(MapDataProviders[i]).MapName;

            if (InStr(MapName,Game.GetMapFileName(),,true) == INDEX_NONE)
            {
                AvailableMaps.Add(1);

                AvailableMaps[AvailableMaps.Length - 1].Description = MapName;
                AvailableMaps[AvailableMaps.Length - 1].Id = MapName;
                AvailableMaps[AvailableMaps.Length - 1].Label = MapName;

                for (j = 0; j < MapsData.Length; j++)
                    if (MapsData[j].PackageName ~= MapName)
                    {
                        if (MapsData[j].TinyName != "")
                            AvailableMaps[AvailableMaps.Length - 1].Label = MapsData[j].TinyName;

                        break;
                    }
            }
        }
    }
    else
    {
        bCustomMapsList = true;

        for (i = 0; i < Game.MapsSequence.Length; i++)
        {
            MapName = Game.MapsSequence[i];

            AvailableMaps.Add(1);

            AvailableMaps[AvailableMaps.Length - 1].Description = MapName;
            AvailableMaps[AvailableMaps.Length - 1].Id = MapName;
            AvailableMaps[AvailableMaps.Length - 1].Label = MapName;

            for (j = 0; j < MapsData.Length; j++)
                if (MapsData[j].PackageName ~= MapName)
                {
                    if (MapsData[j].TinyName != "")
                        AvailableMaps[AvailableMaps.Length - 1].Label = MapsData[j].TinyName;

                    break;
                }
        }
    }

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

    bVsync = class'Engine'.static.GetEngine().GetSystemSettingBool("UseVsync");

    AppliedResIndex = ResolutionIndex;
}


defaultproperties
{
    MovieInfo=SwfMovie'SonicGDKPackUserInterface.Flash.MainMenu'
    WidgetBindings.Add((WidgetName="ApplyButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="CharOption",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="ExitButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="FpsButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="FullscreenOption",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="GraphicsOption",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="InfoButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="LaunchButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Load1Button",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Load2Button",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Load3Button",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Load4Button",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Load5Button",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Load6Button",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapDataText1",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapDataText2",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapDataText3",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapDataText4",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapDataText5",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapDataText6",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapImageLoader",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapNameText",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="MapOption",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="NoLoadButton",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="ResolutionOption",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot1Text1",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot1Text2",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot1Text3",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot2Text1",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot2Text2",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot2Text3",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot3Text1",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot3Text2",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot3Text3",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot4Text1",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot4Text2",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot4Text3",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot5Text1",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot5Text2",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot5Text3",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot6Text1",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot6Text2",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="Slot6Text3",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="VsyncOption",WidgetClass=class'GFxCLIKWidget'))

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
