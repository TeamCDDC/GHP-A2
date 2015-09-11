//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//================================================================================
// SonicGDK is a codebase, a collection of source codes, which allows anyone to
// create 3D platformer video games based on the Sonic the Hedgehog franchise. It
// can be freely modified and is integrated with the UDK, providing you with a
// modern game engine in which to develop your game.
//
// Unreal Development Kit (UDK) is the Unreal Engine 3, a complete professional
// development framework used to create games on the PC. Visit www.udk.com for
// more information.
//
// The custom assets bundled with SonicGDK were created by several contributors
// and supplied for testing purposes. The map, models, animations and textures can
// be reused without given explicit permission; permission is required to reuse
// the music tracks and sound effects.
//
// The use of copyrighted content and/or ripped content from games in conjunction
// with SonicGDK is strongly disapproved of.
//================================================================================
// Permission is granted to anyone to use this software for any purpose, excluding
// commercial applications, and to alter it and redistribute it freely, subject to
// the following restrictions:
// 1. The origin of this software must not be misrepresented; you must not claim
//    that you wrote the original software. If you use this software in a product,
//    an acknowledgement in the product documentation is required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. All notices including this one may not be removed or altered from any binary
//    or source distribution.
//
// This software is freeware, and is therefore provided 'as-is', without any
// express or implied warranty. In no event will the author be held liable for any
// damages arising from the use of this software.
//
// All characters and materials in relation to the Sonic the Hedgehog video game
// series franchise are copyrights/trademarks of SEGA Corporation. This software
// has been developed without permission of SEGA, therefore it's prohibited to
// sell/make profit of it.
//
// SEGA and Sonic the Hedgehog are either registered trademarks or trademarks of
// SEGA Corporation. © SEGA 1991-2014 All Rights Reserved.
//
// This software was not developed by, cannot be supported by and is not endorsed
// by Epic Games, Inc.
//
// Epic, Epic Games, Unreal, Unreal Development Kit, Unreal Engine, Unreal
// Technology and the Unreal Development Kit logo are trademarks or registered
// trademarks of Epic Games, Inc. in the United States of America and elsewhere.
// © 2009-2014 Epic Games, Inc.
//================================================================================
// SGDK Game Info > UTTeamGame > UTDeathmatch > UTGame > UDKGame > SimpleGame >
//     > FrameworkGame > GameInfo > Info > Actor
//
// The GameInfo defines the game being played: the game rules, scoring, which
// actors are allowed to exist in this game type, and who may enter the game.
//================================================================================
class SGDKGameInfo extends UTTeamGame;


struct TCharacterData
{
  /**Exact name of pawn class.*/ var string ClassName;
/**Readable name of character.*/ var string ReadableName;
};
/**List of available playable pawn characters.*/ var globalconfig array<TCharacterData> AvailableChars;

struct TMapData
{
/**File name of the custom loading movie of the map.*/ var string LoadingMovie;
                            /**File name of the map.*/ var string PackageName;
                        /**Preview image of the map.*/ var string PreviewImage;
                        /**Readable name of the map.*/ var string ReadableName;
                      /**Very short name of the map.*/ var string TinyName;
 /**Amount of Chaos Emeralds needed to play the map.*/ var int UnlockEmeralds;
      /**Amount of red rings needed to play the map.*/ var int UnlockRedRings;
};
/**List of stored data related to maps.*/ var globalconfig array<TMapData> MapsData;

         /**Location of the default image of maps in its package.*/ var globalconfig string DefaultMapPreviewImage;
/**List of map names that create a sequence of unlockable levels.*/ var globalconfig array<string> MapsSequence;
       /**Text to display when there isn't enough Chaos Emeralds.*/ var globalconfig string NotEnoughEmeraldsText;
            /**Text to display when there isn't enough red rings.*/ var globalconfig string NotEnoughRedRingsText;
           /**Index of the bucket which contains system settings.*/ var globalconfig int SettingsBucket;

  /**If true, data won't be saved in a file.*/ var bool bNoSave;
/**Object that manages data saved in a file.*/ var SaveDataObject PersistentData;
  /**Special stage that is currently active.*/ var SpecialStageActor SpecialStage;


/**
 * Initializes parameters, spawns helper classes and parses option values from the command line.
 * It's called before any other scripts (including PreBeginPlay).
 * @param Options       holds the commandline option values
 * @param ErrorMessage  can be used to return an error message
 */
event InitGame(string Options,out string ErrorMessage)
{
    local SGDKPlayerPawn P;

    super.InitGame(Options,ErrorMessage);

    //Force dead players to respawn immediately.
    bForceRespawn = true;

    //Set restart wait time to a ridiculously high value.
    RestartWait = 999;

    //Set time limit to a ridiculously high value.
    TimeLimit = 999;

    //Change the default class of the player pawn with a template.
    foreach DynamicActors(class'SGDKPlayerPawn',P)
        if (P.IsTemplate() && P.bDefaultPawnClass)
        {
            DefaultPawnClass = P.Class;

            break;
        }

    //Change the default class of the player pawn with the commandline.
    ParsePlayerPawnClass(Options);

    //Select the correct save slot with the commandline.
    ParseSaveSlot(Options);
}

/**
 * Logs a player in; fails login if the ErrorMessage string is set.
 * @param Options       holds the commandline option values
 * @param ErrorMessage  can be used to return an error message
 * @return              spawned player controller
 */
event PlayerController Login(string Portal,string Options,const UniqueNetId UniqueId,out string ErrorMessage)
{
    local PlayerController PC;

    PC = super.Login(Portal,Options,UniqueId,ErrorMessage);

    SGDKGameViewportClient(class'Engine'.static.GetEngine().GameViewport).ManageLoadingMovies(
        self,SGDKPlayerController(PC));

    return PC;
}

/**
 * Returns the class of GameInfo to spawn for the game on the specified map and the specified options.
 * @param MapName  complete map name
 * @param Options  options inserted through the command line
 * @param Portal   ignore it
 * @return         the class of the GameInfo class to spawn
 */
static event class<GameInfo> SetGameType(string MapName,string Options,string Portal)
{
    //Don't override this gametype if chosen as DefaultGameType in .ini or on command line.
    return default.Class;
}

/**
 * Spawns any default inventory for all pawns.
 * @param P  a pawn
 */
function AddDefaultInventory(Pawn P)
{
    //Remove any inventory class from the array first.
    DefaultInventory.Length = 0;

    super.AddDefaultInventory(P);
}

/**
 * Is a player allowed to use cheats?
 * @param PC  the controller that wants to cheat
 * @return    true if the player is allowed to cheat
 */
function bool AllowCheats(PlayerController PC)
{
`if(`isdefined(NO_CHEATS))
    return false;
`endif

    return super.AllowCheats(PC);
}

/**
 * Is a player allowed to pause the game?
 * @param PC  the controller that wants to pause the game
 * @return    true if the player is allowed to pause the game
 */
function bool AllowPausing(optional PlayerController PC)
{
    if (PC != none)
        return (bPauseable && SGDKPlayerController(PC).CanPauseGame());
    else
        return bPauseable;
}

/**
 * Ends the game level.
 * @param Winner  info of the player responsible for ending the game level
 * @param Reason  the reason of the end
 */
function EndGame(PlayerReplicationInfo Winner,string Reason)
{
    local Sequence GameSequence;
    local array<SequenceObject> Events;
    local int i;

    if (Reason ~= "Triggered")
    {
        bGameEnded = true;
        EndLogging(Reason);

        GameSequence = WorldInfo.GetGameSequence();

        if (GameSequence != none)
        {
            GameSequence.FindSeqObjectsByClass(class'UTSeqEvent_GameEnded',true,Events);

            for (i = 0; i < Events.Length; i++)
                UTSeqEvent_GameEnded(Events[i]).CheckActivate(self,none);
        }

        GotoState('MatchOver');
    }
}

/**
 * Ends a killing spree and notifies so to all players.
 * @param Killer  info of the player responsible for ending the killing spree
 * @param Other   info of the player responsible for the killing spree
 */
function EndSpree(UTPlayerReplicationInfo Killer,UTPlayerReplicationInfo Other)
{
    //Disabled.
}

/**
 * Closes the game.
 */
exec function ExitGame()
{
    ConsoleCommand("exit");

    GetALocalPlayerController().ConsoleCommand("closeeditorviewport");
}

/**
 * Pauses the visuals of the game for a while.
 * @param Seconds  after this time, the game is unpaused
 */
function FramePauseGame(float Seconds)
{
    WorldInfo.bGameplayFramePause = true;
    GetALocalPlayerController().SetPause(true);
    WorldInfo.RealTimeToUnPause = WorldInfo.RealTimeSeconds + Seconds;
}

/**
 * Gets the name of the file loaded for the current persistent map; it doesn't have extension.
 * @return  name of the file of the current map
 */
static function string GetMapFileName()
{
    return Locs(StripPlayOnPrefix(string(class'WorldInfo'.static.GetWorldInfo().GetPackageName())));
}

/**
 * Returns the recommended amount of players (including bots) for the level.
 * @return  the recommended amount of players
 */
function int LevelRecommendedPlayers()
{
    return 1;
}

/**
 * Notifies killings to all players.
 * @param Killer       the controller responsible for the killing
 * @param Killed       the controller whose pawn got killed
 * @param KilledPawn   the killed pawn
 * @param DamageClass  class describing the damage that was done
 */
function NotifyKilled(Controller Killer,Controller Killed,Pawn KilledPawn,class<DamageType> DamageClass)
{
    local Controller C;

    foreach WorldInfo.AllControllers(class'Controller',C)
        C.NotifyKilled(Killer,Killed,KilledPawn,DamageClass);
}

/**
 * Notifies killing sprees to all players.
 * @param Other  info of the player responsible for the killing spree
 * @param Num    amount of consecutive kills
 */
function NotifySpree(UTPlayerReplicationInfo Other,int Num)
{
    //Disabled.
}

/**
 * Opens the next map of the game.
 * @param MapsList  ordered list of map file names without extension
 * @return          true if a map is loaded
 */
static function bool OpenNextMap(array<string> MapsList)
{
    local string CurrentMap;
    local int i;

    CurrentMap = GetMapFileName();

    for (i = 0; i < MapsList.Length - 1; i++)
        if (InStr(CurrentMap,MapsList[i],,true) != INDEX_NONE)
        {
            class'WorldInfo'.static.GetWorldInfo().Game.ConsoleCommand("open" @ MapsList[i + 1]);

            return true;
        }

    return false;
}

/**
 * Finds pawn option in the options string and changes the default player pawn class.
 * @param Options  holds the commandline option values
 */
function ParsePlayerPawnClass(string Options)
{
    local string InOption;

    InOption = ParseOption(Options,"Pawn");

    if (InOption != "")
        DefaultPawnClass = class<SGDKPawn>(DynamicLoadObject(InOption,class'Class'));
}

/**
 * Finds save slot option in the options string and loads the corresponding file.
 * @param Options  holds the commandline option values
 */
function ParseSaveSlot(string Options)
{
    local string InOption;

    //Creates the object that manages data saved in a file.
    PersistentData = new class'SaveDataObject';

    if (!WorldInfo.IsPlayInEditor() && !WorldInfo.IsPlayInPreview())
        InOption = ParseOption(Options,"Save");

    if (InOption != "")
        PersistentData.LoadData("slot" $ InOption);
    else
    {
        bNoSave = true;

        PersistentData.LoadData("noslot");
    }
}

/**
 * Tries to pause/unpause the game.
 * @param bPause  true if the player wants to pause the game
 */
exec function PauseGame(bool bPause)
{
    GetALocalPlayerController().SetPause(bPause);
}

/**
 * Reduces damage for gametype modifications.
 * @param DamageAmount     the base damage to apply
 * @param Injured          the injured pawn
 * @param EventInstigator  the controller responsible for the damage
 * @param HitLocation      world location where the hit occurred
 * @param Momentum         force/impulse caused by this hit
 * @param DamageClass      class describing the damage that was done
 * @param DamageCauser     the actor that directly caused the damage
 */
function ReduceDamage(out int DamageAmount,Pawn Injured,Controller EventInstigator,vector HitLocation,
                      out vector Momentum,class<DamageType> DamageClass,Actor DamageCauser)
{
    local class<UTDamageType> UTDamageClass;
    local int OriginalDamage;

    UTDamageClass = class<UTDamageType>(DamageClass);

    if (UTDamageClass != none && UTDamageClass.default.bDontHurtInstigator &&
        EventInstigator != none && EventInstigator == Injured.Controller)
        DamageAmount = 0;
    else
        if (Injured.PhysicsVolume.bNeutralZone || Injured.InGodMode())
            DamageAmount = 0;

    if (DamageAmount > 0 && BaseMutator != none)
    {
        OriginalDamage = DamageAmount;
        BaseMutator.NetDamage(OriginalDamage,DamageAmount,Injured,EventInstigator,HitLocation,Momentum,DamageClass,DamageCauser);
    }
}

/**
 * Restarts a player.
 * @param C  a controller
 */
function RestartPlayer(Controller C)
{
    super.RestartPlayer(C);

    if (C.Pawn != none && SGDKPlayerController(C) != none && SGDKPlayerStart(C.Pawn.Anchor) != none)
        SGDKPlayerStart(C.Pawn.Anchor).PlayerSpawned(C.Pawn);
}

/**
 * Manages scoring when a player is killed.
 * @param Killer  the controller responsible for the killing
 * @param Killed  the controller whose pawn got killed
 */
function ScoreKill(Controller Killer,Controller Killed)
{
    if (SGDKPlayerController(Killed) != none)
        SGDKPlayerController(Killed).AddLives(-1);
}

/**
 * Sets gameplay speed.
 * @param NewGameSpeed  the new gameplay speed
 */
function SetGameSpeed(float NewGameSpeed)
{
    GameSpeed = FMax(0.00001,NewGameSpeed);
    WorldInfo.TimeDilation = GameSpeed;

    SetTimer(WorldInfo.TimeDilation,true);
}

/**
 * Modifies startup properties for all pawns.
 * @param P  a pawn
 */
function SetPlayerDefaults(Pawn P)
{
    //Disabled.
}

/**
 * Applies the system settings defined in a bucket.
 * @param Bucket  the index of a bucket which contains system settings
 */
exec function SystemSettings(int Bucket)
{
    Bucket = Clamp(Bucket,1,6);

    WorldInfo.ConsoleCommand("scale bucket bucket" $ Bucket);

    SettingsBucket = Bucket;

    SaveConfig();
}

/**
 * Is the world streaming any piece of level?
 * @return  true if the game is using streaming
 */
static function bool WorldIsStreamingLevels()
{
    local int i;
    local WorldInfo World;

    World = class'WorldInfo'.static.GetWorldInfo();

    for (i = 0; i < World.StreamingLevels.Length; i++)
        if (World.StreamingLevels[i].bHasLoadRequestPending)
            return true;

    return false;
}


//Default state; the match didn't start yet.
auto state PendingMatch
{
    event BeginState(name PreviousStateName)
    {
        bQuickStart = false;
        bWaitingToStartMatch = true;
        StartupStage = 0;
    }

    event EndState(name NextStateName)
    {
        if (DemoPrefix != "")
            ConsoleCommand("demorec" @ DemoPrefix $ "-%td");
    }

    function RestartPlayer(Controller C)
    {
    }

    event Timer()
    {
        local bool bStartMatch;
        local SGDKPlayerController C;

        global.Timer();

        bStartMatch = true;

        foreach WorldInfo.AllControllers(class'SGDKPlayerController',C)
            if (C.bMatineeMode)
            {
                bStartMatch = false;

                break;
            }

        if (bStartMatch && !WorldIsStreamingLevels())
            StartMatch();
    }

Begin:
    Sleep(0.01);

    AddInitialBots();
}


//The match is over.
state MatchOver
{
    event BeginState(name PreviousStateName)
    {
        local SGDKEnemyPawn P;
        local SGDKPlayerController C;

        GameReplicationInfo.bStopCountDown = true;

        foreach WorldInfo.AllPawns(class'SGDKEnemyPawn',P)
            P.TurnOff();

        foreach WorldInfo.AllControllers(class'SGDKPlayerController',C)
            C.GameHasEnded(C.Pawn,true);

        if (!bNoSave)
            PersistentData.SaveData();
    }
}


defaultproperties
{
    bFirstBlood=true                                  //Disables "First Blood" message.
    bPauseable=true                                   //The game is pauseable.
    bUseClassicHUD=true                               //Uses classic UTHud system.
    DefaultPawnClass=class'PawnSonicReimagined'                 //The default pawn class associated to players.
    HUDType=class'SGDKHud'                            //HUD class this game uses.
    PlayerControllerClass=class'SGDKPlayerController' //Type of player controller to spawn for players.
}
