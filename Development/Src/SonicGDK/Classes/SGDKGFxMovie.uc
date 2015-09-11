//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK GFx Movie > GFxMoviePlayer > Object
//
// The GFxMoviePlayer class is the base class of all classes responsible for
// initializing and playing a Scaleform GFx movie.
//================================================================================
class SGDKGFxMovie extends GFxMoviePlayer;


/**
 * Hides the movie.
 */
function Hide()
{
    if (GetAVMVersion() == 1)
        GetVariableObject("_root").SetVisible(false);
    else
        GetVariableObject("root").SetVisible(false);
}

/**
 * Shows the movie.
 */
function Show()
{
    if (GetAVMVersion() == 1)
        GetVariableObject("_root").SetVisible(true);
    else
        GetVariableObject("root").SetVisible(true);
}


defaultproperties
{
    bAutoPlay=true               //The movie will be played immediately after loading.
    bEnableGammaCorrection=false //Doesn't correct the gamma of the movie.
    MovieInfo=none               //Reference to the movie that will be played.
}
