//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK HUD > UTHUD > UDKHUD > MobileHUD > HUD > Actor
//
// The HUD (Heads-Up Display) is the method by which information is visually
// relayed to the player as part of a game's user interface.
// The HUD is frequently used to simultaneously display several pieces of
// information including the main character's health, items, and an indication of
// game progression (such as score).
//================================================================================
class SGDKHud extends UTHUD;


           /**Value that determines the opacity of the HUD.*/ var byte HudAlpha;
/**Multiplier to scale the size of the custom HUD graphics.*/ var float HudScale;
      /**The texture which has all the custom HUD graphics.*/ var Texture2D HudTexture;

      /**HUD created with Scaleform Flash.*/ var SGDKHudGFxMovie HudMovie;
                /**Class of the Flash HUD.*/ var class<SGDKHudGFxMovie> HudMovieClass;
/**Flash SWF movie used for the Flash HUD.*/ var SwfMovie HudSwfMovie;

  /**Stores the previous value of bShowHUD.*/ var bool bOldShowHud;
/**Pause menu created with Scaleform Flash.*/ var SGDKMenuGFxMovie PauseMenu;
                /**Class of the pause menu.*/ var class<SGDKMenuGFxMovie> PauseMenuClass;
/**Flash SWF movie used for the pause menu.*/ var SwfMovie PauseSwfMovie;

/**Title card created with Scaleform Flash.*/ var GFxTitleCard TitleCard;
      /**Title card Kismet sequence action.*/ var SeqAct_ShowTitleCard TitleCardAction;

/**List of drawable objects contained in the level.*/ var array<DrawableEntity> Drawables;
                  /**Points to the SGDK pawn owner.*/ var SGDKPlayerPawn SGDKPawnOwner;
     /**Points to the SGDK player controller owner.*/ var SGDKPlayerController SGDKPlayerOwner;

                    /**If true, the time counter is paused.*/ var bool bPausedTime;
/**The amount of time elapsed since the start of the level.*/ var float ElapsedTime;
   /**The amount of time elapsed since the timer is paused.*/ var float PausedTime;
                       /**The saved elapsed amount of time.*/ var float SavedElapsedTime;
             /**The temporary saved elapsed amount of time.*/ var float TempSavedElapsedTime;

/**If true, most graphics aren't drawn.*/ var bool bDisableGraphics;

    /**Count looping sound of the end of level sequence.*/ var AudioComponent EndSequenceCountSound;
/**Initial timestamp used for the end of level sequence.*/ var float EndSequenceCountTime;
       /**Stores the state of the end of level sequence.*/ var byte EndSequenceState;
     /**Stores total score of the end of level sequence.*/ var int EndSequenceTotal;

      /**Coordinates for mapping the large black background texture.*/ var TextureCoordinates BackgroundLCoords;
     /**Coordinates for mapping the medium black background texture.*/ var TextureCoordinates BackgroundMCoords;
      /**Coordinates for mapping the short black background texture.*/ var TextureCoordinates BackgroundSCoords;
/**Coordinates for mapping the extra-large black background texture.*/ var TextureCoordinates BackgroundXLCoords;
/**Coordinates for mapping the estra-short black background texture.*/ var TextureCoordinates BackgroundXSCoords;
           /**Coordinates for mapping the bonus stage words texture.*/ var TextureCoordinates BonusStageCoords;
         /**Coordinates for mapping the first Chaos Emerald texture.*/ var TextureCoordinates ChaosEmeraldsCoords;
      /**Coordinates for mapping the double-prime character texture.*/ var TextureCoordinates DoublePrimeCoords;
             /**Coordinates for mapping the game over words texture.*/ var TextureCoordinates GameOverCoords;
           /**Coordinates for mapping the got through words texture.*/ var TextureCoordinates GotThroughCoords;
                  /**Coordinates for mapping the lives icon texture.*/ var TextureCoordinates LivesCoords;
                /**Coordinates for mapping the first number texture.*/ var TextureCoordinates NumbersCoords;
                  /**Coordinates for mapping the pause word texture.*/ var TextureCoordinates PauseCoords;
             /**Coordinates for mapping the prime character texture.*/ var TextureCoordinates PrimeCoords;
                      /**Coordinates for mapping the rank A texture.*/ var TextureCoordinates RankACoords;
                      /**Coordinates for mapping the rank B texture.*/ var TextureCoordinates RankBCoords;
                      /**Coordinates for mapping the rank C texture.*/ var TextureCoordinates RankCCoords;
                      /**Coordinates for mapping the rank D texture.*/ var TextureCoordinates RankDCoords;
                      /**Coordinates for mapping the rank E texture.*/ var TextureCoordinates RankECoords;
                      /**Coordinates for mapping the rank S texture.*/ var TextureCoordinates RankSCoords;
            /**Coordinates for mapping the ring bonus words texture.*/ var TextureCoordinates RingBonusCoords;
                  /**Coordinates for mapping the rings word texture.*/ var TextureCoordinates RingsCoords;
                  /**Coordinates for mapping the score word texture.*/ var TextureCoordinates ScoreCoords;
         /**Coordinates for mapping the special stage words texture.*/ var TextureCoordinates SpecialStageCoords;
            /**Coordinates for mapping the time bonus words texture.*/ var TextureCoordinates TimeBonusCoords;
                   /**Coordinates for mapping the time word texture.*/ var TextureCoordinates TimerCoords;
                  /**Coordinates for mapping the total word texture.*/ var TextureCoordinates TotalCoords;
              /**Coordinates for mapping the red rings word texture.*/ var TextureCoordinates WarnRingsCoords;
               /**Coordinates for mapping the red time word texture.*/ var TextureCoordinates WarnTimerCoords;

/**Screen position of the game over words.*/ var vector2d GameOverPosition;
  /**Screen position of the lives counter.*/ var vector2d LivesPosition;
     /**Screen position of the pause word.*/ var vector2d PausePosition;
   /**Screen position of the ring counter.*/ var vector2d RingsPosition;
  /**Screen position of the score counter.*/ var vector2d ScorePosition;
   /**Screen position of the time counter.*/ var vector2d TimerPosition;

          /**The parent material used by fading screen transition.*/ var Material FadeMaterial;
        /**The material instance used by fading screen transition.*/ var MaterialInstanceConstant FadeMIC;
                 /**Current color of the fading material instance.*/ var LinearColor FadeMICCurrentColor;
              /**The source color of the fading material instance.*/ var LinearColor FadeMICFromColor;
              /**The target color of the fading material instance.*/ var LinearColor FadeMICToColor;
   /**The elapsed time since the fading screen transition started.*/ var float FadeMICPartialTime;
/**Total time that takes to complete the fading screen transition.*/ var float FadeMICTotalTime;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    local HudInfo HudInformation;
    local RedRingActor RedRing;

    super.PostBeginPlay();

    foreach AllActors(class'HudInfo',HudInformation)
        break;

    if (HudInformation != none)
    {
        bDisableGraphics = HudInformation.bHideScriptedHud;
        HudTexture = HudInformation.HudTexture;

        HudMovieClass = HudInformation.HudMovieClass;
        HudSwfMovie = HudInformation.HudSwfMovie;

        PauseMenuClass = HudInformation.PauseMenuClass;
        PauseSwfMovie = HudInformation.PauseSwfMovie;
    }

    if (HudSwfMovie != none)
    {
        HudMovie = new HudMovieClass;
        HudMovie.SetMovieInfo(HudSwfMovie);
        HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
    }

    foreach DynamicActors(class'RedRingActor',RedRing)
        Drawables.AddItem(RedRing);

    FadeMIC = new(self) class'MaterialInstanceConstant';
    FadeMIC.SetParent(FadeMaterial);

    FadeMICCurrentColor = MakeLinearColor(0.0,0.0,0.0,0.0);
    FadeMICToColor = FadeMICCurrentColor;
    FadeMIC.SetVectorParameterValue('ColorParameter',FadeMICCurrentColor);

    PauseTime(true);
    ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,1.0),0.0);
}

/**
 * Called immediately before destroying this actor.
 */
event Destroyed()
{
    if (HudMovie != none)
    {
        HudMovie.Close(true);
        HudMovie = none;
    }

    super.Destroyed();
}

/**
 * Can the game be paused?
 * @return  true if the game can be paused
 */
function bool CanPauseGame()
{
    return true;
}

/**
 * Tracks when a hit is scored and displays damage indicators.
 * @param HitDirection  the vector to which the hit came at
 * @param DamageAmount  the base damage to apply
 * @param DamageClass   class describing the damage that was done
 */
function DisplayHit(vector HitDirection,int DamageAmount,class<DamageType> DamageClass)
{
    //Disabled.
}

/**
 * Displays a special type of message with some graphics on screen.
 * @param Message     the text to display
 * @param XOffsetPct  percent of left space within canvas to keep empty
 * @param YOffsetPct  percent of top space within canvas to keep empty
 */
function DisplayHudMessage(string Message,optional float XOffsetPct = 0.05,optional float YOffsetPct = 0.05)
{
    //Disabled.
}

/**
 * Draws debug information.
 */
function DrawDebug()
{
    local float XL,YL,YPos;

    Canvas.Font = GetFontSizeIndex(0);
    Canvas.DrawColor = ConsoleColor;
    Canvas.StrLen("X",XL,YL);

    YPos = 0;

    PlayerOwner.ViewTarget.DisplayDebug(self,YL,YPos);

    if (ShouldDisplayDebug('AI') && Pawn(PlayerOwner.ViewTarget) != none)
        DrawRoute(Pawn(PlayerOwner.ViewTarget));
}

/**
 * Draws the fading screen transition.
 */
function DrawFadingScreen()
{
    if (FadeMICCurrentColor.A > 0.0)
    {
        Canvas.SetPos(0.0,0.0);
        Canvas.DrawMaterialTile(FadeMIC,Canvas.SizeX,Canvas.SizeY,0.0,0.0,1.0,1.0);
    }
}

/**
 * This function is called to draw the HUD while the game is still in progress.
 */
function DrawGameHud()
{
    SGDKPawnOwner = SGDKPlayerPawn(UTPawnOwner);
    SGDKPlayerOwner = SGDKPlayerController(PlayerOwner);

    if (!bShowDebugInfo)
    {
        if (bShowAllAI)
            DrawAIOverlays();

        DisplayConsoleMessages();

        if (!bDisableGraphics)
        {
            DisplayLocalMessages();

            DrawGraphics();
        }
    }
    else
        DrawDebug();
}

/**
 * Draws the HUD graphics.
 */
function DrawGraphics()
{
    DrawScore();
    DrawTime();
    DrawRings();
    DrawLives();
    DrawOther();

    DrawPause();
    DrawFadingScreen();
}

/**
 * Draws a standard element that displays information.
 * @param Position          screen position
 * @param bAlignRight       true for right alignment
 * @param BackgroundCoords  texture coords of the background
 * @param TagCoords         texture coords of the tag
 * @param TagOffset         screen offset of the tag
 * @param Number            numeric information
 */
function DrawInfoElement(vector2d Position,bool bAlignRight,TextureCoordinates BackgroundCoords,
                         TextureCoordinates TagCoords,vector2d TagOffset,int Number)
{
    if (Position.Y < 0.0)
    {
        if (!bIsSplitScreen)
            Position.Y += 768.0;
        else
            Position.Y += 384.0;
    }

    Position.X *= ResolutionScaleX;
    Position.Y *= ResolutionScale;

    ResolutionScale *= HudScale;

    if (bAlignRight)
        Position.X -= (BackgroundCoords.UL * ResolutionScale);

    Canvas.DrawColor = GetDrawColor();

    //Draw the black background.
    Canvas.SetPos(Position.X,Position.Y);
    Canvas.DrawTile(HudTexture,BackgroundCoords.UL * ResolutionScale,
                    BackgroundCoords.VL * ResolutionScale,BackgroundCoords.U,
                    BackgroundCoords.V,BackgroundCoords.UL,BackgroundCoords.VL);

    if (SGDKPawnOwner != none)
    {
        //Draw the icon.
        Canvas.SetPos(Position.X + (BackgroundCoords.UL - 88.0) * ResolutionScale,
                      Position.Y - 20.0 * ResolutionScale);
        Canvas.DrawTile(HudTexture,SGDKPawnOwner.HudDecorationCoords.UL * ResolutionScale,
                        SGDKPawnOwner.HudDecorationCoords.VL * ResolutionScale,
                        SGDKPawnOwner.HudDecorationCoords.U,SGDKPawnOwner.HudDecorationCoords.V,
                        SGDKPawnOwner.HudDecorationCoords.UL,SGDKPawnOwner.HudDecorationCoords.VL);
    }

    //Draw the tag.
    Canvas.SetPos(Position.X + TagOffset.X * ResolutionScale,Position.Y + TagOffset.Y * ResolutionScale);
    Canvas.DrawTile(HudTexture,TagCoords.UL * ResolutionScale,TagCoords.VL * ResolutionScale,
                    TagCoords.U,TagCoords.V,TagCoords.UL,TagCoords.VL);

    Position.X += (BackgroundCoords.UL - 88.0) * ResolutionScale;
    Position.Y -= 4.0 * ResolutionScale;
    Canvas.SetPos(Position.X,Position.Y);

    ResolutionScale /= HudScale;

    if (Number > -1)
        //Draw the digits.
        DrawInteger(Number);
}

/**
 * Draws an integer.
 * @param Number  the number to display
 */
function DrawInteger(int Number)
{
    ResolutionScale *= HudScale;

    Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                    NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                    ((Number > 9) ? (Number - ((Number / 10) * 10)) : Number) * 36.0,
                    NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

    if (Number > 9)
    {
        Canvas.SetPos(Canvas.CurX - NumbersCoords.UL * 2.0 * ResolutionScale,Canvas.CurY);

        Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                        NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                        ((Number > 99) ? ((Number - ((Number / 100) * 100)) / 10) : (Number / 10)) * 36.0,
                        NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

        if (Number > 99)
        {
            Canvas.SetPos(Canvas.CurX - NumbersCoords.UL * 2.0 * ResolutionScale,Canvas.CurY);

            Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                            NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                            ((Number > 999) ? ((Number - ((Number / 1000) * 1000)) / 100) : (Number / 100)) * 36.0,
                            NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

            if (Number > 999)
            {
                Canvas.SetPos(Canvas.CurX - NumbersCoords.UL * 2.0 * ResolutionScale,Canvas.CurY);

                Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                                NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                                ((Number > 9999) ? ((Number - ((Number / 10000) * 10000)) / 1000) : (Number / 1000)) * 36.0,
                                NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

                if (Number > 9999)
                {
                    Canvas.SetPos(Canvas.CurX - NumbersCoords.UL * 2.0 * ResolutionScale,Canvas.CurY);

                    Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                                    NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                                    ((Number > 99999) ? ((Number - ((Number / 100000) * 100000)) / 10000) : (Number / 10000)) * 36.0,
                                    NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

                    if (Number > 99999)
                    {
                        Canvas.SetPos(Canvas.CurX - NumbersCoords.UL * 2.0 * ResolutionScale,Canvas.CurY);

                        Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                                        NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                                        ((Number > 999999) ? ((Number - ((Number / 1000000) * 1000000)) / 100000) : (Number / 100000)) * 36.0,
                                        NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

                        if (Number > 999999)
                        {
                            Canvas.SetPos(Canvas.CurX - NumbersCoords.UL * 2.0 * ResolutionScale,Canvas.CurY);

                            Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                                            NumbersCoords.VL * ResolutionScale,
                                            NumbersCoords.U + (Number / 1000000) * 36.0,
                                            NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);
                        }
                    }
                }
            }
        }
    }

    ResolutionScale /= HudScale;
}

/**
 * Draws the lives counter.
 */
function DrawLives()
{
    DrawInfoElement(LivesPosition,LivesPosition.X > 512.0,BackgroundSCoords,
                    LivesCoords,vect2d(12,-16),SGDKPlayerOwner.Lives);
}

/**
 * Draws other types of graphics.
 */
function DrawOther()
{
    local DrawableEntity Drawable;

    foreach Drawables(Drawable)
        Drawable.HudGraphicsDraw(self);

    if (SGDKPawnOwner != none)
        SGDKPawnOwner.HudGraphicsDraw(self);
}

/**
 * Draws the pause graphics.
 */
function DrawPause()
{
    local float PositionY;

    if (PlayerOwner.IsPaused() && !WorldInfo.bGameplayFramePause)
    {
        if (!bIsSplitScreen)
            PositionY = PausePosition.Y;
        else
            PositionY = PausePosition.Y * 0.5;

        ResolutionScale *= HudScale;

        Canvas.DrawColor = GetDrawColor();

        //Draw the PAUSE word.
        Canvas.SetPos((PausePosition.X * ResolutionScaleX - PauseCoords.UL * 0.5 * ResolutionScale),
                      (PositionY / HudScale - PauseCoords.VL * 0.5) * ResolutionScale);
        Canvas.DrawTile(HudTexture,PauseCoords.UL * ResolutionScale,
                        PauseCoords.VL * ResolutionScale,PauseCoords.U,
                        PauseCoords.V,PauseCoords.UL,PauseCoords.VL);

        ResolutionScale /= HudScale;
    }
}

/**
 * This function is called to draw the HUD when the game match is over.
 */
function DrawPostGameHud()
{
    DrawGameHud();
}

/**
 * Draws the ring counter.
 */
function DrawRings()
{
    local int Rings;

    if (SGDKPawnOwner != none)
    {
        Rings = Max(0,SGDKPawnOwner.Health - 1);

        if (Rings > 0 || WorldInfo.TimeSeconds % 1.0 < 0.5)
            DrawInfoElement(RingsPosition,false,BackgroundLCoords,RingsCoords,vect2d(12,-8),Rings);
        else
            DrawInfoElement(RingsPosition,false,BackgroundLCoords,WarnRingsCoords,vect2d(12,-8),Rings);
    }
}

/**
 * Draws the score counter.
 * @param bForceDraw  true to force drawing
 */
function DrawScore(optional bool bForceDraw)
{
    if (!bIsSplitScreen || bForceDraw)
        DrawInfoElement(ScorePosition,false,BackgroundXLCoords,ScoreCoords,vect2d(12,-8),SGDKPlayerOwner.Score);
}

/**
 * Draws the time counter.
 * @param bForceDraw  true to force drawing
 */
function DrawTime(optional bool bForceDraw)
{
    if (!bIsSplitScreen || bForceDraw)
    {
        DrawInfoElement(TimerPosition,false,BackgroundXLCoords,TimerCoords,vect2d(12,-8),-1);

        DrawTimestamp(ElapsedTime);
    }
}

/**
 * Draws a timestamp properly.
 * @param Time  timestamp in seconds
 */
function DrawTimestamp(float Time)
{
    local int Minutes,Seconds,CentiSeconds;
    local vector2d Position;

    ResolutionScale *= HudScale;

    Minutes = Time / 60;
    Seconds = Time - Minutes * 60;
    CentiSeconds = (Time - int(Time)) * 100;

    Position.X = Canvas.CurX;
    Position.Y = Canvas.CurY;

    //Draw the centiseconds digits.
    Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                    NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                    ((CentiSeconds > 9) ? CentiSeconds - ((CentiSeconds / 10) * 10) : CentiSeconds) * 36.0,
                    NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

    Position.X -= NumbersCoords.UL * ResolutionScale;
    Canvas.SetPos(Position.X,Position.Y);

    Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                    NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                    ((CentiSeconds > 9) ? (CentiSeconds / 10) : 0) * 36.0,
                    NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

    //Draw the double prime symbol.
    Position.X -= NumbersCoords.UL * ResolutionScale;
    Canvas.SetPos(Position.X - 4.0 * ResolutionScale,Position.Y - 8.0 * ResolutionScale);

    Canvas.DrawTile(HudTexture,DoublePrimeCoords.UL * ResolutionScale,
                    DoublePrimeCoords.VL * ResolutionScale,DoublePrimeCoords.U,
                    DoublePrimeCoords.V,DoublePrimeCoords.UL,DoublePrimeCoords.VL);

    //Draw the seconds digits.
    Position.X -= NumbersCoords.UL * ResolutionScale;
    Canvas.SetPos(Position.X,Position.Y);

    Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                    NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                    ((Seconds > 9) ? (Seconds - ((Seconds / 10) * 10)) : Seconds) * 36.0,
                    NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

    Position.X -= NumbersCoords.UL * ResolutionScale;
    Canvas.SetPos(Position.X,Position.Y);

    Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                    NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                    ((Seconds > 9) ? (Seconds / 10) : 0) * 36.0,
                    NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

    //Draw the prime symbol.
    Position.X -= NumbersCoords.UL * ResolutionScale;
    Canvas.SetPos(Position.X - 4.0 * ResolutionScale,Position.Y - 8.0 * ResolutionScale);

    Canvas.DrawTile(HudTexture,PrimeCoords.UL * ResolutionScale,
                    PrimeCoords.VL * ResolutionScale,PrimeCoords.U,
                    PrimeCoords.V,PrimeCoords.UL,PrimeCoords.VL);

    //Draw the minutes digits.
    Position.X -= NumbersCoords.UL * ResolutionScale;
    Canvas.SetPos(Position.X,Position.Y);

    Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                    NumbersCoords.VL * ResolutionScale,NumbersCoords.U +
                    ((Minutes > 9) ? (Minutes - ((Minutes / 10) * 10)) : Minutes) * 36.0,
                    NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);

    if (Minutes > 9)
    {
        Position.X -= NumbersCoords.UL * ResolutionScale;
        Canvas.SetPos(Position.X,Position.Y);

        Canvas.DrawTile(HudTexture,NumbersCoords.UL * ResolutionScale,
                        NumbersCoords.VL * ResolutionScale,
                        NumbersCoords.U + (Minutes / 10) * 36.0,
                        NumbersCoords.V,NumbersCoords.UL,NumbersCoords.VL);
    }

    ResolutionScale /= HudScale;
}

/**
 * Gets the standard drawing color that tints the HUD graphics.
 * @return  drawing color
 */
function Color GetDrawColor()
{
    return MakeColor(255,255,255,HudAlpha);
}

/**
 * Kills the title card.
 */
function KillTitleCard()
{
    ClearTimer(NameOf(KillTitleCard));

    if (TitleCard != none)
    {
        TitleCard.Close(true);

        TitleCard = none;
    }
}

/**
 * Loads the saved value of the timer.
 */
function LoadTime()
{
    if (TempSavedElapsedTime == 0.0)
        ElapsedTime = SavedElapsedTime;
    else
    {
        ElapsedTime = TempSavedElapsedTime;
        TempSavedElapsedTime = 0.0;
    }

    PausedTime = WorldInfo.TimeSeconds - ElapsedTime;
}

/**
 * The postprocessing chain has changed and postprocess effects can be bound.
 */
function NotifyBindPostProcessEffects()
{
    super.NotifyBindPostProcessEffects();

    SGDKPlayerController(PlayerOwner).GetPlayerCamera().NotifyBindPostProcessEffects();
}

/**
 * Function handler for SeqAct_ShowTitleCard Kismet sequence action.
 * @param Action  the related Kismet sequence action
 */
function OnShowTitleCard(SeqAct_ShowTitleCard Action)
{
    KillTitleCard();

    TitleCard = new class'GFxTitleCard';
    TitleCard.SetMovieInfo(Action.CardSwfMovie);

    TitleCard.ActName = Action.SubMapName;
    TitleCard.LevelName = Action.MapName;

    TitleCard.Init(class'Engine'.static.GetEngine().GamePlayers[TitleCard.LocalPlayerOwnerIndex]);

    SetTimer(Action.ScreenFadeDelayTime + Action.ScreenFadeDurationTime + Action.ToggleControlsDelayTime + 3.0,
             false,NameOf(KillTitleCard));

    TitleCardAction = Action;

    GotoState('TitleCardState');
}

/**
 * Pauses or unpauses the timer.
 * @param bPause  pauses/unpauses the timer
 */
function PauseTime(bool bPause)
{
    if (!bPause)
    {
        bPausedTime = false;
        PausedTime = WorldInfo.TimeSeconds - ElapsedTime;
    }
    else
        bPausedTime = true;
}

/**
 * Plays a sound effect.
 * @param Sound  the sound to play
 */
function PlaySoundEffect(SoundCue Sound)
{
    if (HudAlpha > 0 && !bIsSplitScreen)
        PlaySound(Sound);
}

/**
 * Saves the value of the timer.
 * @param bSingleUse  true if value needs to be loaded only once
 */
function SaveTime(optional bool bSingleUse)
{
    if (!bSingleUse)
        SavedElapsedTime = ElapsedTime;
    else
        TempSavedElapsedTime = ElapsedTime;
}

/**
 * Fades the screen pixel colors to a different uniform color.
 * @param FadeColor     target uniform color
 * @param FadeDuration  duration of the fade transition
 */
function ScreenFadeToColor(LinearColor FadeColor,optional float FadeDuration)
{
    if (FadeDuration > 0.0)
    {
        FadeMICPartialTime = 0.0;
        FadeMICTotalTime = FadeDuration;

        FadeMICFromColor = FadeMICCurrentColor;
        FadeMICToColor = FadeColor;
    }
    else
    {
        FadeMICCurrentColor = FadeColor;
        FadeMICToColor = FadeMICCurrentColor;

        FadeMIC.SetVectorParameterValue('ColorParameter',FadeMICCurrentColor);
    }
}

/**
 * Should the HUD list a type of variables on canvas?
 * @param DebugType  name of type
 * @return           true to list the type
 */
function bool ShouldDisplayDebug(name DebugType)
{
    //Always display debug information related to these subjects:
    if (DebugType == 'camera' || DebugType == 'collision' || DebugType == 'input' || DebugType == 'physics')
        return true;

    return super.ShouldDisplayDebug(DebugType);
}

/**
 * Toggles the pause menu on or off.
 */
function TogglePauseMenu()
{
    if (PauseMenu == none)
    {
        if (PauseSwfMovie != none && SGDKGameInfo(WorldInfo.Game).AllowPausing(PlayerOwner))
        {
            CloseOtherMenus();

            PauseMenu = new PauseMenuClass;
            PauseMenu.SetMovieInfo(PauseSwfMovie);

            PauseMenu.Init(class'Engine'.static.GetEngine().GamePlayers[PauseMenu.LocalPlayerOwnerIndex]);

            bOldShowHud = bShowHUD;
            SetVisible(false);
        }
    }
    else
    {
        PauseMenu.Close(true);
        PauseMenu = none;

        SetVisible(bOldShowHud);
    }
}

/**
 * Updates the damage indicator; it always needs to be called.
 */
function UpdateDamage()
{
    super.UpdateDamage();

    UpdateValues(RenderDelta);
}

/**
 * Updates the values related to the fading screen transition.
 * @param DeltaTime  time since last render
 */
function UpdateFadingScreen(float DeltaTime)
{
    if (FadeMICCurrentColor != FadeMICToColor)
    {
        if (FadeMICPartialTime < FadeMICTotalTime)
        {
            FadeMICPartialTime = FMin(FadeMICPartialTime + DeltaTime,FadeMICTotalTime);

            FadeMICCurrentColor.R = Lerp(FadeMICFromColor.R,FadeMICToColor.R,FadeMICPartialTime / FadeMICTotalTime);
            FadeMICCurrentColor.G = Lerp(FadeMICFromColor.G,FadeMICToColor.G,FadeMICPartialTime / FadeMICTotalTime);
            FadeMICCurrentColor.B = Lerp(FadeMICFromColor.B,FadeMICToColor.B,FadeMICPartialTime / FadeMICTotalTime);
            FadeMICCurrentColor.A = Lerp(FadeMICFromColor.A,FadeMICToColor.A,FadeMICPartialTime / FadeMICTotalTime);
        }
        else
            FadeMICCurrentColor = FadeMICToColor;

        FadeMIC.SetVectorParameterValue('ColorParameter',FadeMICCurrentColor);
    }
}

/**
 * Updates the values related to the timer.
 * @param DeltaTime  time since last render
 */
function UpdateTime(float DeltaTime)
{
    if (!bPausedTime)
        ElapsedTime = WorldInfo.TimeSeconds - PausedTime;
}

/**
 * Updates all values safely.
 * @param DeltaTime  time in seconds since last render
 */
function UpdateValues(float DeltaTime)
{
    local DrawableEntity Drawable;

    HudScale = default.HudScale;

    if (!bIsSplitScreen)
        RingsPosition = default.RingsPosition;
    else
    {
        RingsPosition.Y = ScorePosition.Y;

        if (PlayerOwner.GetSplitscreenPlayerCount() > 2)
            HudScale *= 0.75;
    }

    UpdateFadingScreen(DeltaTime);
    UpdateTime(DeltaTime);

    foreach Drawables(Drawable)
        Drawable.HudGraphicsUpdate(DeltaTime,self);

    if (SGDKPawnOwner != none)
        SGDKPawnOwner.HudGraphicsUpdate(DeltaTime,self);

    if (HudMovie != none && HudMovie.bMovieIsOpen)
        HudMovie.Update(DeltaTime,self);
}


auto state LevelLoadedState
{
    function bool CanPauseGame()
    {
        return false;
    }

    function UpdateValues(float DeltaTime)
    {
        global.UpdateValues(DeltaTime);

        if (!WorldInfo.Game.bWaitingToStartMatch)
            GotoState('StartLevelState');
    }
}


state StartLevelState
{
    function bool CanPauseGame()
    {
        return false;
    }

Begin:
    Sleep(0.1);

    LoadTime();

    ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,0.0),0.9);

    Sleep(0.9);

    GotoState('NormalState');
}


state TitleCardState extends StartLevelState
{
Begin:
    Sleep(0.01);

    LoadTime();

    Sleep(TitleCardAction.ScreenFadeDelayTime);

    ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,0.0),TitleCardAction.ScreenFadeDurationTime);

    Sleep(TitleCardAction.ScreenFadeDurationTime + TitleCardAction.ToggleControlsDelayTime);

    GotoState('NormalState');
}


state NormalState
{
    event BeginState(name PreviousStateName)
    {
        PauseTime(false);

        PlayerOwner.IgnoreLookInput(false);
        PlayerOwner.IgnoreMoveInput(false);
    }
}


state SpecialStageState
{
    function DrawGraphics()
    {
        if (SGDKGameInfo(WorldInfo.Game).SpecialStage.DrawGlobalGraphics())
            global.DrawGraphics();

        SGDKGameInfo(WorldInfo.Game).SpecialStage.HudGraphicsDraw(self);
    }

    function UpdateValues(float DeltaTime)
    {
        global.UpdateValues(DeltaTime);

        SGDKGameInfo(WorldInfo.Game).SpecialStage.HudGraphicsUpdate(DeltaTime,self);
    }
}


state EndLevelState
{
    event BeginState(name PreviousStateName)
    {
        PauseTime(true);

        EndSequenceState = 0;
        EndSequenceTotal = SGDKPlayerOwner.Score;
    }

    function bool CanPauseGame()
    {
        return (EndSequenceState > 6);
    }

    function DrawGraphics()
    {
        if (EndSequenceState == 0)
            global.DrawGraphics();
        else
        {
            if (!bIsSplitScreen)
            {
                DrawTitle();
                DrawScore();
                DrawTime();
                DrawRings();
                DrawTimeBonus();
                DrawRingBonus();
                DrawTotal();

                if (EndSequenceState > 5)
                    DrawRank();
            }

            DrawFadingScreen();
        }
    }

    function DrawRank()
    {
        local TextureCoordinates RankCoords;

        if (SGDKPlayerOwner.Rank != "-")
        {
            switch (SGDKPlayerOwner.Rank)
            {
                case "A":
                    RankCoords = RankACoords;

                    break;

                case "B":
                    RankCoords = RankBCoords;

                    break;

                case "C":
                    RankCoords = RankCCoords;

                    break;

                case "D":
                    RankCoords = RankDCoords;

                    break;

                case "E":
                    RankCoords = RankECoords;

                    break;

                default:
                    RankCoords = RankSCoords;
            }

            Canvas.DrawColor = GetDrawColor();

            Canvas.SetPos(200.0 * ResolutionScaleX,500.0 * ResolutionScale);
            Canvas.DrawTile(HudTexture,RankCoords.UL * ResolutionScale,
                            RankCoords.VL * ResolutionScale,
                            RankCoords.U,RankCoords.V,RankCoords.UL,RankCoords.VL);
        }
    }

    function DrawRingBonus()
    {
        DrawInfoElement(vect2d(949.0,600.0),true,BackgroundXLCoords,RingBonusCoords,
                        vect2d(128.0 - RingBonusCoords.UL,-8.0),
                        (EndSequenceState > 2) ? SGDKPlayerOwner.RingBonus : -1);
    }

    function DrawRings()
    {
        if (EndSequenceState == 0)
            global.DrawRings();
        else
            if (SGDKPawnOwner != none)
                DrawInfoElement(vect2d(949.0,475.0),true,BackgroundXLCoords,RingsCoords,
                                vect2d(128.0 - RingsCoords.UL,-8.0),Max(0,SGDKPawnOwner.Health - 1));
    }

    function DrawScore(optional bool bForceDraw)
    {
        if (EndSequenceState == 0)
            global.DrawScore();
        else
            DrawInfoElement(vect2d(949.0,375.0),true,BackgroundXLCoords,ScoreCoords,
                            vect2d(128.0 - ScoreCoords.UL,-8.0),SGDKPlayerOwner.Score);
    }

    function DrawTime(optional bool bForceDraw)
    {
        if (EndSequenceState == 0)
            global.DrawTime(bForceDraw);
        else
        {
            DrawInfoElement(vect2d(949.0,425.0),true,BackgroundXLCoords,TimerCoords,
                            vect2d(128.0 - TimerCoords.UL,-8.0),-1);

            DrawTimestamp(ElapsedTime);
        }
    }

    function DrawTimeBonus()
    {
        DrawInfoElement(vect2d(949.0,550.0),true,BackgroundXLCoords,TimeBonusCoords,
                        vect2d(128.0 - TimeBonusCoords.UL,-8.0),
                        (EndSequenceState > 1) ? SGDKPlayerOwner.TimeBonus : -1);
    }

    function DrawTitle()
    {
        local FontRenderInfo FRI;
        local float XL,YL;

        Canvas.DrawColor = GetDrawColor();

        //Draw the got through text.
        Canvas.SetPos(120.0 * ResolutionScaleX,120.0 * ResolutionScale);

        Canvas.DrawTile(HudTexture,GotThroughCoords.UL * ResolutionScale,GotThroughCoords.VL * ResolutionScale,
                        GotThroughCoords.U,GotThroughCoords.V,GotThroughCoords.UL,GotThroughCoords.VL);

        if (SGDKPawnOwner != none)
        {
            //Draw the character name.
            Canvas.SetPos(75.0 * ResolutionScaleX,50.0 * ResolutionScale);

            Canvas.DrawTile(HudTexture,SGDKPawnOwner.HudCharNameCoords.UL * ResolutionScale,
                            SGDKPawnOwner.HudCharNameCoords.VL * ResolutionScale,
                            SGDKPawnOwner.HudCharNameCoords.U,SGDKPawnOwner.HudCharNameCoords.V,
                            SGDKPawnOwner.HudCharNameCoords.UL,SGDKPawnOwner.HudCharNameCoords.VL);
        }

        FRI.bClipText = true;
        Canvas.Font = HudFonts[5];
        Canvas.TextSize(SGDKPlayerOwner.EndGameAction.MapName,XL,YL,ResolutionScale,ResolutionScale);

        //Draw the level name (black layer).
        Canvas.DrawColor = MakeColor(0,0,0,HudAlpha);
        Canvas.SetPos(515.0 * ResolutionScaleX - XL * 0.5,228.0 * ResolutionScale);
        Canvas.DrawText(SGDKPlayerOwner.EndGameAction.MapName,,ResolutionScale,ResolutionScale,FRI);

        //Draw the level name (white layer).
        Canvas.DrawColor = GetDrawColor();
        Canvas.SetPos(512.0 * ResolutionScaleX - XL * 0.5,225.0 * ResolutionScale);
        Canvas.DrawText(SGDKPlayerOwner.EndGameAction.MapName,,ResolutionScale,ResolutionScale,FRI);
    }

    function DrawTotal()
    {
        DrawInfoElement(vect2d(949.0,675.0),true,BackgroundXLCoords,TotalCoords,
                        vect2d(128.0 - TotalCoords.UL,-8.0),EndSequenceTotal);
    }

    function UpdateValues(float DeltaTime)
    {
        global.UpdateValues(DeltaTime);

        if (EndSequenceState == 4)
            EndSequenceTotal = Lerp(SGDKPlayerOwner.Score,SGDKPlayerOwner.TotalScore,
                                    FMin((WorldInfo.TimeSeconds - EndSequenceCountTime) /
                                         SGDKPlayerOwner.EndGameAction.Reward5DelayTime,1.0));
    }

Begin:
    ScreenFadeToColor(MakeLinearColor(1.0,1.0,1.0,1.0),
        SGDKPlayerOwner.EndGameAction.ScreenFadeDurationTime);

    Sleep(SGDKPlayerOwner.EndGameAction.ScreenFadeDurationTime);

    EndSequenceState = 1;

    Sleep(0.25);

    ScreenFadeToColor(MakeLinearColor(1.0,1.0,1.0,0.0),0.25);

    Sleep(SGDKPlayerOwner.EndGameAction.Reward1DelayTime);

    SGDKPlayerOwner.GetMusicManager().StartMusicTrack(SGDKPlayerOwner.GetMusicManager().VictoryMusicTrack,0.0);

    Sleep(SGDKPlayerOwner.EndGameAction.Reward2DelayTime);

    EndSequenceState = 2;
    PlaySoundEffect(SGDKPlayerOwner.EndGameAction.Reward1Sound);

    Sleep(SGDKPlayerOwner.EndGameAction.Reward3DelayTime);

    EndSequenceState = 3;
    PlaySoundEffect(SGDKPlayerOwner.EndGameAction.Reward1Sound);

    Sleep(SGDKPlayerOwner.EndGameAction.Reward4DelayTime);

    if (SGDKPlayerOwner.RingBonus > 0 || SGDKPlayerOwner.TimeBonus > 0)
    {
        EndSequenceState = 4;
        EndSequenceCountTime = WorldInfo.TimeSeconds;

        if (HudAlpha > 0 && !bIsSplitScreen)
            EndSequenceCountSound = CreateAudioComponent(SGDKPlayerOwner.EndGameAction.Reward2Sound);

        if (EndSequenceCountSound != none)
        {
            EndSequenceCountSound.bAllowSpatialization = false;
            EndSequenceCountSound.bAutoDestroy = true;
            EndSequenceCountSound.Play();
        }

        Sleep(SGDKPlayerOwner.EndGameAction.Reward5DelayTime);

        if (EndSequenceCountSound != none)
        {
            EndSequenceCountSound.Stop();
            DetachComponent(EndSequenceCountSound);
            EndSequenceCountSound = none;
        }

        PlaySoundEffect(SGDKPlayerOwner.EndGameAction.Reward3Sound);
    }
    else
        PlaySoundEffect(SGDKPlayerOwner.EndGameAction.Reward3Sound);

    EndSequenceState = 5;
    EndSequenceTotal = SGDKPlayerOwner.TotalScore;

    if (SGDKPlayerOwner.Rank != "-")
    {
        Sleep(SGDKPlayerOwner.EndGameAction.Reward6DelayTime);

        EndSequenceState = 6;

        PlaySoundEffect(SGDKPlayerOwner.EndGameAction.Reward4Sound);
    }

    Sleep(1.0);

    EndSequenceState = 7;
}


state GameOverState
{
    event BeginState(name PreviousStateName)
    {
        SGDKGameInfo(WorldInfo.Game).bForceRespawn = false;

        SGDKPlayerOwner.GetMusicManager().StartMusicTrack(SGDKPlayerOwner.GetMusicManager().GameOverMusicTrack,0.0);
    }

    function bool CanPauseGame()
    {
        return false;
    }

    function DrawGraphics()
    {
        local float PositionY;

        if (!bIsSplitScreen)
            PositionY = GameOverPosition.Y;
        else
            PositionY = GameOverPosition.Y * 0.5;

        ResolutionScale *= HudScale;

        Canvas.DrawColor = GetDrawColor();

        //Draw the GAME OVER words.
        Canvas.SetPos((GameOverPosition.X * ResolutionScaleX - GameOverCoords.UL * 0.5 * ResolutionScale),
                      (PositionY / HudScale - GameOverCoords.VL * 0.5) * ResolutionScale);
        Canvas.DrawTile(HudTexture,GameOverCoords.UL * ResolutionScale,
                        GameOverCoords.VL * ResolutionScale,GameOverCoords.U,
                        GameOverCoords.V,GameOverCoords.UL,GameOverCoords.VL);

        ResolutionScale /= HudScale;
    }

Begin:
    Sleep(SGDKPlayerOwner.GetMusicManager().GameOverMusicTrack.Duration + 1.0);

    if (!WorldInfo.IsPlayInEditor())
        SGDKPlayerOwner.QuitToMainMenu();
}


defaultproperties
{
    bHasLeaderboard=false                                       //Hides leader board.
    bShowFragCount=false                                        //Hides frag count.
    HudFonts[4]=Font'SonicGDKPackUserInterface.HUD.Andes48Font' //Andes 48pt true type font.
    HudFonts[5]=Font'SonicGDKPackUserInterface.HUD.Andes72Font' //Andes 72pt true type font.
    MusicManagerClass=class'SGDKMusicManager'                   //Class of dynamic music manager.

    HudAlpha=255
    HudScale=0.7
    HudTexture=Texture2D'SonicGDKPackUserInterface.HUD.BaseHUD'

    HudMovieClass=class'SGDKHudGFxMovie'
    HudSwfMovie=none

    PauseMenuClass=class'GFxMenuPause'
    PauseSwfMovie=SwfMovie'SonicGDKPackUserInterface.Flash.PauseMenu'

    SavedElapsedTime=0.0

    bDisableGraphics=false

    BackgroundMCoords=(U=674,V=142,UL=340,VL=52)
    BackgroundLCoords=(U=594,V=80,UL=420,VL=52)
    BackgroundSCoords=(U=754,V=204,UL=260,VL=52)
    BackgroundXLCoords=(U=514,V=18,UL=500,VL=52)
    BackgroundXSCoords=(U=834,V=266,UL=180,VL=52)
    BonusStageCoords=(U=568,V=653,UL=446,VL=90)
    ChaosEmeraldsCoords=(U=464,V=488,UL=70,VL=70)
    DoublePrimeCoords=(U=435,V=18,UL=28,VL=25)
    GameOverCoords=(U=10,V=756,UL=382,VL=83)
    GotThroughCoords=(U=10,V=940,UL=664,VL=75)
    LivesCoords=(U=624,V=248,UL=84,VL=70)
    NumbersCoords=(U=10,V=18,UL=32,VL=52)
    PauseCoords=(U=841,V=849,UL=173,VL=81)
    PrimeCoords=(U=376,V=18,UL=22,VL=25)
    RankACoords=(U=160,V=456,UL=140,VL=140)
    RankBCoords=(U=310,V=456,UL=140,VL=140)
    RankCCoords=(U=10,V=606,UL=140,VL=140)
    RankDCoords=(U=160,V=606,UL=140,VL=140)
    RankECoords=(U=310,V=606,UL=140,VL=140)
    RankSCoords=(U=10,V=456,UL=140,VL=140)
    RingBonusCoords=(U=306,V=220,UL=307,VL=60)
    RingsCoords=(U=144,V=80,UL=152,VL=60)
    ScoreCoords=(U=306,V=80,UL=160,VL=60)
    SpecialStageCoords=(U=565,V=753,UL=449,VL=86)
    TimeBonusCoords=(U=306,V=150,UL=311,VL=60)
    TimerCoords=(U=10,V=80,UL=124,VL=60)
    TotalCoords=(U=136,V=220,UL=160,VL=60)
    WarnRingsCoords=(U=144,V=150,UL=152,VL=60)
    WarnTimerCoords=(U=10,V=150,UL=124,VL=60)

    GameOverPosition=(X=512,Y=480)
    LivesPosition=(X=1008,Y=24)
    PausePosition=(X=512,Y=384)
    RingsPosition=(X=16,Y=124)
    ScorePosition=(X=16,Y=24)
    TimerPosition=(X=16,Y=74)

    FadeMaterial=Material'SonicGDKPackUserInterface.HUD.FadeHUDMaterial'
}
