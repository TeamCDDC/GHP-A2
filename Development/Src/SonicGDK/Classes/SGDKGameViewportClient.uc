//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Game Viewport Client > UTGameViewportClient > UDKGameViewportClient >
//     > GameViewportClient > ScriptViewportClient > Object
//
// A game viewport is a high-level abstract interface for the platform specific
// rendering, audio and input subsystems. GameViewportClient is the engine's
// interface to a game viewport.
//================================================================================
class SGDKGameViewportClient extends UTGameViewportClient;


/**If true, a custom loading movie is being played.*/ var bool bPlayingLoadingMovie;

struct TLoadingMovieData
{
/**File name of the custom loading movie of a map.*/ var string LoadingMovie;
                            /**File name of a map.*/ var string PackageName;
};
/**Array of data structures used for loading movies list.*/ var array<TLoadingMovieData> LoadingMovies;


/**
 * Displays the transition screen.
 * @param C  the canvas to use for rendering
 */
function DrawTransition(Canvas C)
{
    local int i;

    if (Outer.TransitionType == TT_Loading && LoadingMovies.Length > 0 && GamePlayers[0].Actor != none)
        for (i = 0; i < LoadingMovies.Length; i++)
            if (LoadingMovies[i].PackageName ~= Outer.TransitionDescription)
            {
                bPlayingLoadingMovie = true;

                SGDKPlayerController(GamePlayers[0].Actor).ClientPlayMovie(LoadingMovies[i].LoadingMovie,
                                                                           -1,-1,false,false,false);

                break;
            }
}

/**
 * Manages all custom loading movies if there are any.
 * @param Game  a reference to the game info
 * @param PC    the related player controller
 */
function ManageLoadingMovies(SGDKGameInfo Game,SGDKPlayerController PC)
{
    local int i;

    if (bPlayingLoadingMovie)
    {
        PC.ClientStopMovie(0.01,false,true,true);

        bPlayingLoadingMovie = false;
    }

    if (LoadingMovies.Length == 0)
        for (i = 0; i < Game.MapsData.Length; i++)
            if (Game.MapsData[i].LoadingMovie != "")
            {
                LoadingMovies.Add(1);

                LoadingMovies[LoadingMovies.Length - 1].LoadingMovie = Game.MapsData[i].LoadingMovie;
                LoadingMovies[LoadingMovies.Length - 1].PackageName = Game.MapsData[i].PackageName;
            }
}

/**
 * Adds a player.
 */
exec function PlayerAdd()
{
    local string Error;

    if (LocalPlayerClass != none && GamePlayers.Length < 4)
	    CreatePlayer(GamePlayers.Length,Error,true);
}

/**
 * Executes a console command for a determined player.
 * @param PlayerIndex  index of the player
 * @param Command      the command to execute
 */
exec function PlayerConsoleCommand(int PlayerIndex,string Command)
{
    GamePlayers[PlayerIndex].Actor.ConsoleCommand(Command);
}

/**
 * Removes a player.
 */
exec function PlayerRemove()
{
    local LocalPlayer ExPlayer;

    if (GamePlayers.Length > 1)
    {
        ExPlayer = FindPlayerByControllerId(GamePlayers.Length - 1);

        if (ExPlayer != none)
            RemovePlayer(ExPlayer);
    }
}

/**
 * Rotates controller device among players.
 */
exec function PlayerSwapControls()
{
    local int Id,i;

    if (GamePlayers.Length > 1)
    {
        Id = GamePlayers[GamePlayers.Length - 1].ControllerId;

        for (i = GamePlayers.Length - 1; i > 0; i--)
            GamePlayers[i].ControllerId = GamePlayers[i - 1].ControllerId;

        GamePlayers[0].ControllerId = Id;
    }
}


defaultproperties
{
    bPlayingLoadingMovie=false
}
