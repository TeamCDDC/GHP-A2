//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// HUD Info > Info > Actor
//
// Classes based on Info hold only information.
// This class holds information related to the HUD (Heads-Up Display).
//================================================================================
class HudInfo extends Info
    ClassGroup(SGDK,Invisible)
    hidecategories(Attachment,Debug,Display,Mobile,Physics)
    placeable;


/**If true, most graphics of the scripted HUD aren't drawn.*/ var() bool bHideScriptedHud;
      /**The texture which has all the custom HUD graphics.*/ var() Texture2D HudTexture;

                /**Class of the Flash HUD.*/ var() class<SGDKHudGFxMovie> HudMovieClass;
/**Flash SWF movie used for the Flash HUD.*/ var() SwfMovie HudSwfMovie;

                /**Class of the pause menu.*/ var() class<SGDKMenuGFxMovie> PauseMenuClass;
/**Flash SWF movie used for the pause menu.*/ var() SwfMovie PauseSwfMovie;


defaultproperties
{
    Begin Object Name=Sprite
        Sprite=Texture2D'UDKHUD.cursor_png'
        SpriteCategoryName="Info"
        Scale=4.0
    End Object


    bHideScriptedHud=false
    HudTexture=Texture2D'SonicGDKPackUserInterface.HUD.BaseHUD'

    HudMovieClass=class'SGDKHudGFxMovie'
    HudSwfMovie=none

    PauseMenuClass=class'GFxMenuPause'
    PauseSwfMovie=SwfMovie'SonicGDKPackUserInterface.Flash.PauseMenu'
}
