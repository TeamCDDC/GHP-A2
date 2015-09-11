//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Board Special Stage > SpecialStageActor > SGDKActor > Actor
//
// This class is the gigantic checkered globe found in the Sonic 3 & Knuckles game
// as the Special Stage.
//================================================================================
class BoardSpecialStage extends SpecialStageActor
    placeable;


/**The board visual static mesh.*/ var() editconst StaticMeshComponent BoardMesh;
  /**The sky visual static mesh.*/ var() editconst StaticMeshComponent SkyMesh;

/**Array of strings which represent boards with their pickups.*/ var() string Boards[14];
/**Amount of ring items which can be collected for each board.*/ var() int Rings[14];

/**Forcefully loads a board by indicating its index; -1 means no forced board.*/ var() int ForcedBoard;

   /**Intro music track for this Special Stage.*/ var() SoundCue AmbientIntroTrack;
/**Loopable music track for this Special Stage.*/ var() SoundCue AmbientLoopTrack;

/**Perfect bonus text message.*/ var localized string PerfectBonusMessage;

                /**Amount of Chaos Emeralds to show.*/ var byte ChaosEmeralds;
        /**Screen position of the instructions text.*/ var vector2d InstructionsPosition;
        /**Horizontal size of the instructions text.*/ var float InstructionsSize;
                 /**Stores the number of rings left.*/ var int RingsCounter;
  /**Coordinates for mapping the rings icon texture.*/ var TextureCoordinates RingsHudCoords;
            /**Screen position of the rings counter.*/ var vector2d RingsHudPosition;
               /**Aspect ratio of screen dimensions.*/ var float ScreenAspectRatio;
      /**Screen position of the special stage words.*/ var vector2d SpecialStagePosition;
          /**Stores the number of blue spheres left.*/ var int SpheresCounter;
/**Coordinates for mapping the spheres icon texture.*/ var TextureCoordinates SpheresHudCoords;
          /**Screen position of the spheres counter.*/ var vector2d SpheresHudPosition;
 /**Stores the state of the starting title sequence.*/ var byte StartState;
        /**Stores the state of the results sequence.*/ var byte StatsState;

                      /**Index of the active board.*/ var byte ActiveBoard;
/**The circular blob shadow attached to the player.*/ var BlobShadowActor BlobShadow;
       /**The material assigned to the blob shadow.*/ var MaterialInterface BlobShadowMaterial;
          /**The Chaos Emerald given to the player.*/ var ChaosEmeraldActor ChaosEmerald;
             /**The maximum accelerated game speed.*/ var float MaxGameSpeed;
      /**Pitch multiplier used for the music track.*/ var float MusicPitchMultiplier;
                         /**The initial game speed.*/ var float OldGameSpeed;
         /**Holds a reference to the original pawn.*/ var SGDKPlayerPawn OldPlayerPawn;
               /**The bounds of the playable board.*/ var float PawnMaxX,PawnMaxY,PawnMinX,PawnMinY;
                    /**The pawn playing this board.*/ var SGDKPlayerPawn PlayerPawn;
                 /**Side length of a single square.*/ var float SquareDistance;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    SetRotation(rot(0,0,0));

    PawnMaxX = Location.X + 15.5 * SquareDistance;
    PawnMinX = Location.X - 16.5 * SquareDistance;
    PawnMaxY = Location.Y + 15.5 * SquareDistance;
    PawnMinY = Location.Y - 16.5 * SquareDistance;
}

/**
 * Calculates camera view point.
 * @param DeltaTime       contains the amount of time in seconds that has passed since the last tick
 * @param OutCamLocation  camera location
 * @param OutCamRotation  camera rotation
 * @param OutFOV          field of view angle of camera
 * @return                true if this actor should provide the camera point of view
 */
simulated function bool CalcCamera(float DeltaTime,out vector OutCamLocation,
                                   out rotator OutCamRotation,out float OutFOV)
{
    local int CameraPitchRotation;

    CameraPitchRotation = -9216 - ((AspectRatio16x9 - ScreenAspectRatio) * 2304);

    OutCamRotation = RLerp(OutCamRotation,PlayerPawn.Controller.Rotation + MakeRotator(CameraPitchRotation,0,0),
                           FMin(DeltaTime * 10.0,1.0),true);

    OutCamLocation = PlayerPawn.Location * vect(1,1,0) + Location * vect(0,0,1) + (vect(-250,0,75) >> OutCamRotation);

    OutFOV = 90.0;

    return true;
}

/**
 * Should the HUD draw the default graphics?
 * @return  true if the HUD should draw the default graphics
 */
function bool DrawGlobalGraphics()
{
    return bHidden;
}

/**
 * Called when the player receives a localized message. Most messages deal with 0 to 2 related PRIs.
 * @param MessageSwitch  switch parameter for displaying completely different messages
 * @param RelatedPRI_1   holds information about a player
 * @param RelatedPRI_2   holds information about another player
 */
static function string GetLocalString(optional int MessageSwitch,optional PlayerReplicationInfo RelatedPRI_1,
                                      optional PlayerReplicationInfo RelatedPRI_2)
{
    return default.PerfectBonusMessage;
}

/**
 * Draws the HUD graphics.
 * @param TheHud  the HUD
 */
function HudGraphicsDraw(SGDKHud TheHud)
{
    ScreenAspectRatio = float(TheHud.Canvas.SizeX) / TheHud.Canvas.SizeY;

    if (!bHidden)
    {
        //Draw spheres stuff.
        TheHud.DrawInfoElement(SpheresHudPosition,false,TheHud.BackgroundSCoords,
                               SpheresHudCoords,vect2d(12,-16),SpheresCounter);

        //Draw rings stuff.
        TheHud.DrawInfoElement(RingsHudPosition,true,TheHud.BackgroundSCoords,
                               RingsHudCoords,vect2d(12,-16),RingsCounter);
    }
}

/**
 * Increases the pitch multiplier used for the ambient music track.
 */
function IncreaseMusicPitch()
{
    MusicPitchMultiplier += 0.0025;
    SGDKPlayerController(PlayerPawn.Controller).GetMusicManager().SetPitch(MusicPitchMultiplier,4.0);
}

/**
 * Loads a new board with its pickups.
 */
function LoadBoard()
{
    local array<string> Squares;
    local vector V;
    local int i,j,k;
    local BoardSphereActorBlue BlueSphere;

    if (ForcedBoard < 0)
        ActiveBoard = SGDKPlayerController(PlayerPawn.Controller).ChaosEmeralds;
    else
        ActiveBoard = ForcedBoard;

    Squares = SplitString(Boards[ActiveBoard],"-");

    SpheresCounter = 0;

    V = Location + vect(0,0,24) + vect(1,1,0) * (-16.0 * SquareDistance);
    i = 0;

    for (j = 31; j >= 0; j--)
        for (k = 0; k < 32; k++)
        {
            if (Squares[i] == "0" || Squares[i] == "^")
            {
            }
            else
                if (Squares[i] == "1")
                {
                    Spawn(class'BoardSphereActorBlue',self,,
                          V + vect(1,0,0) * (j * SquareDistance) + vect(0,1,0) * (k * SquareDistance));

                    SpheresCounter++;
                }
                else
                    if (Squares[i] == "2")
                        Spawn(class'BoardSphereActorRed',self,,
                              V + vect(1,0,0) * (j * SquareDistance) + vect(0,1,0) * (k * SquareDistance));
                    else
                        if (Squares[i] == "3")
                            Spawn(class'BoardSphereActorBumper',self,,
                                  V + vect(1,0,0) * (j * SquareDistance) + vect(0,1,0) * (k * SquareDistance));
                        else
                            if (Squares[i] == "4")
                                Spawn(class'BoardSphereActorYellow',self,,
                                      V + vect(1,0,0) * (j * SquareDistance) + vect(0,1,0) * (k * SquareDistance));
                            else
                                if (Squares[i] == "5")
                                    Spawn(class'BoardSphereActorRing',self,,
                                          V + vect(1,0,0) * (j * SquareDistance) + vect(0,1,0) * (k * SquareDistance));
                                else
                                    if (Squares[i] == "6")
                                    {
                                        BlueSphere = Spawn(class'BoardSphereActorBlue',self,,V + vect(1,0,0) *
                                                           (j * SquareDistance) + vect(0,1,0) * (k * SquareDistance));

                                        BlueSphere.bDumb = true;

                                        SpheresCounter++;
                                    }

            i++;
        }

    foreach DynamicActors(class'BoardSphereActorBlue',BlueSphere)
        BlueSphere.FindFriends();

    RingsCounter = Rings[ActiveBoard];
}

/**
 * Manages a pawn to start playing the special stage.
 * @param P  the pawn to manage
 */
function ManagePawn(SGDKPlayerPawn P)
{
    if (!P.HasAllEmeralds())
    {
        PlayerPawn = P;

        GotoState('Start');
    }
}

/**
 * Plays the loopable ambient music track.
 */
function PlayAmbientTrack()
{
    SGDKPlayerController(PlayerPawn.Controller).GetMusicManager().StartMusicTrack(AmbientLoopTrack,0.0);
    SGDKPlayerController(PlayerPawn.Controller).GetMusicManager().StopMusicTrack(AmbientIntroTrack,0.0);

    SetTimer(30.0,true,NameOf(IncreaseMusicPitch));
}

/**
 * Called when a pawn touches a sphere.
 * @param Sphere  the touched sphere
 */
function SphereTouched(BoardSphereActor Sphere)
{
    if (BoardSphereActorBlue(Sphere) != none)
    {
        SpheresCounter--;

        if (SpheresCounter == 0)
            GotoState('Success');
    }
    else
        if (BoardSphereActorRed(Sphere) != none)
            GotoState('Fail');
        else
            if (BoardSphereActorRing(Sphere) != none)
            {
                RingsCounter--;

                if (RingsCounter == 0)
                {
                    SGDKPlayerController(PlayerPawn.Controller).AddLives(3);

                    PlayerPawn.PlaySound(SoundCue'SonicGDKPackSounds.PerfectBonusSoundCue');

                    SGDKPlayerController(PlayerPawn.Controller).ReceiveLocalizedMessage(class'UTPickupMessage',,,,Class);
                }
            }
}

/**
 * Unloads an existing board.
 */
function UnloadBoard()
{
    local BoardSphereActor Sphere;

    foreach DynamicActors(class'BoardSphereActor',Sphere)
        Sphere.Destroy();
}


auto state Sleeping
{
}


state Playing
{
    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        local vector V;
        local float ModuloX,ModuloY;

        if (!bHidden)
        {
            if (PlayerPawn != none)
            {
                V = PlayerPawn.Location;

                if (V.X < PawnMinX)
                {
                    V.X = PawnMaxX + (V.X - PawnMinX);

                    PlayerPawn.SetLocation(V);
                }
                else
                    if (V.X > PawnMaxX)
                    {
                        V.X = PawnMinX + (V.X - PawnMaxX);

                        PlayerPawn.SetLocation(V);
                    }
                    else
                        if (V.Y < PawnMinY)
                        {
                            V.Y = PawnMaxY + (V.Y - PawnMinY);

                            PlayerPawn.SetLocation(V);
                        }
                        else
                            if (V.Y > PawnMaxY)
                            {
                                V.Y = PawnMinY + (V.Y - PawnMaxY);

                                PlayerPawn.SetLocation(V);
                            }

                if (!IsZero(PlayerPawn.Velocity))
                {
                    if (PlayerPawn.Velocity.X == 0.0)
                    {
                        V.X = Location.X + SquareDistance * Round((V.X - Location.X) / SquareDistance);

                        PlayerPawn.Move((V - PlayerPawn.Location) * FMin(DeltaTime * 5.0,1.0));

                        V = PlayerPawn.Location;
                    }
                    else
                        if (PlayerPawn.Velocity.Y == 0.0)
                        {
                            V.Y = Location.Y + SquareDistance * Round((V.Y - Location.Y) / SquareDistance);

                            PlayerPawn.Move((V - PlayerPawn.Location) * FMin(DeltaTime * 5.0,1.0));

                            V = PlayerPawn.Location;
                        }

                    ModuloX = Abs(Location.X - V.X) % SquareDistance;
                    ModuloY = Abs(Location.Y - V.Y) % SquareDistance;

                    if ((ModuloX < 16.0 || ModuloX > SquareDistance - 16.0) &&
                        (ModuloY < 16.0 || ModuloY > SquareDistance - 16.0))
                        SGDKPlayerController(PlayerPawn.Controller).bBoardAtCrossroads = true;
                    else
                        SGDKPlayerController(PlayerPawn.Controller).bBoardAtCrossroads = false;
                }
            }
            else
                GotoState('Sleeping');
        }
    }

    /**
     * Draws the HUD graphics.
     * @param TheHud  the HUD
     */
    function HudGraphicsDraw(SGDKHud TheHud)
    {
        global.HudGraphicsDraw(TheHud);

        if (!bHidden)
        {
            TheHud.DrawPause();
            TheHud.DrawFadingScreen();
        }
    }

Begin:
    Sleep(15.0);

Accelerate:
    WorldInfo.Game.SetGameSpeed(FMin(WorldInfo.Game.GameSpeed + 0.1,MaxGameSpeed));

    if (WorldInfo.Game.GameSpeed < MaxGameSpeed)
    {
        Sleep(12.5);

        Goto('Accelerate');
    }
}


state Start extends Playing
{
    event BeginState(name PreviousStateName)
    {
        local SGDKPlayerController PC;

        WorldInfo.Game.bPauseable = false;

        PlayerPawn.CancelMoves();
        PlayerPawn.TurnOff();
        PlayerPawn.SetCollision(false,false);
        PlayerPawn.bAmbientCreature = true;
        PlayerPawn.PlaySound(SoundCue'SonicGDKPackSounds.TeleportSoundCue');

        PC = SGDKPlayerController(PlayerPawn.Controller);
        PC.GetHud().PauseTime(true);
        PC.GetHud().SaveTime(true);
        PC.GetMusicManager().StopMusic(0.0);
        PC.ScreenFadeToColor(MakeLinearColor(1.0,1.0,1.0,1.0),0.5);

        StartState = 255;
    }

    event EndState(name NextStateName)
    {
        WorldInfo.Game.bPauseable = WorldInfo.Game.default.bPauseable;
    }

    /**
     * Draws the HUD graphics.
     * @param TheHud  the HUD
     */
    function HudGraphicsDraw(SGDKHud TheHud)
    {
        local FontRenderInfo FRI;
        local float SizeY;

        global.HudGraphicsDraw(TheHud);

        if (!bHidden)
        {
            TheHud.DrawPause();
            TheHud.DrawFadingScreen();

            TheHud.ResolutionScale *= TheHud.HudScale;

            TheHud.Canvas.DrawColor = TheHud.WhiteColor;

            //Draw the title.
            TheHud.Canvas.SetPos(SpecialStagePosition.X * TheHud.ResolutionScaleX,
                                 SpecialStagePosition.Y * TheHud.ResolutionScale);
            TheHud.Canvas.DrawTile(TheHud.HudTexture,TheHud.SpecialStageCoords.UL * TheHud.ResolutionScale,
                                   TheHud.SpecialStageCoords.VL * TheHud.ResolutionScale,TheHud.SpecialStageCoords.U,
                                   TheHud.SpecialStageCoords.V,TheHud.SpecialStageCoords.UL,TheHud.SpecialStageCoords.VL);

            FRI.bClipText = true;
            TheHud.Canvas.Font = TheHud.HudFonts[5];

            if (InstructionsSize == 0.0)
                TheHud.Canvas.TextSize("get blue spheres!",InstructionsSize,SizeY,
                                       TheHud.ResolutionScale,TheHud.ResolutionScale);

            //Draw the instructions (black layer).
            TheHud.Canvas.DrawColor = TheHud.BlackColor;
            TheHud.Canvas.SetPos(InstructionsPosition.X * TheHud.ResolutionScaleX + 2.0,
                                 InstructionsPosition.Y * TheHud.ResolutionScale + 2.0);
            TheHud.Canvas.DrawText("get blue spheres!",,TheHud.ResolutionScale,TheHud.ResolutionScale,FRI);

            //Draw the instructions (white layer).
            TheHud.Canvas.DrawColor = TheHud.WhiteColor;
            TheHud.Canvas.SetPos(InstructionsPosition.X * TheHud.ResolutionScaleX,
                                 InstructionsPosition.Y * TheHud.ResolutionScale);
            TheHud.Canvas.DrawText("get blue spheres!",,TheHud.ResolutionScale,TheHud.ResolutionScale,FRI);

            TheHud.ResolutionScale /= TheHud.HudScale;
        }
    }

    /**
     * Updates all graphics' values safely.
     * @param DeltaTime  time since last render of the HUD
     * @param TheHud     the HUD
     */
    function HudGraphicsUpdate(float DeltaTime,SGDKHud TheHud)
    {
        switch (StartState)
        {
            case 0:
                SpecialStagePosition.X = FMax(512.0 - TheHud.SpecialStageCoords.UL * 0.5 *
                                              TheHud.ResolutionScale * TheHud.HudScale / TheHud.ResolutionScaleX,
                                              SpecialStagePosition.X - DeltaTime * 1024.0);

                InstructionsPosition.X = FMax(512.0 - InstructionsSize * 0.5 / TheHud.ResolutionScaleX,
                                              InstructionsPosition.X - DeltaTime * 1024.0);

                break;

            case 1:
                SpecialStagePosition.X = FMax(-512.0 * TheHud.ResolutionScaleX,
                                              SpecialStagePosition.X - DeltaTime * 2048.0);

                InstructionsPosition.Y = FMin(InstructionsPosition.Y + DeltaTime * 2048.0,2048.0);
        }
    }

    /**
     * Teleports the player to this special stage and loads a board.
     */
    function TeleportPlayer()
    {
        local SGDKPlayerController PC;
        local PointLightBoard BoardLight;
        local LightingChannelContainer LightingChannels;

        SGDKGameInfo(WorldInfo.Game).SpecialStage = self;

        OldPlayerPawn = PlayerPawn;
        PC = SGDKPlayerController(PlayerPawn.Controller);

        OldPlayerPawn.CancelSuperForms();
        OldPlayerPawn.DiscardExpiringItems();
        OldPlayerPawn.SetHidden(true);

        TriggerEventClass(class'SeqEvent_SpecialStage',OldPlayerPawn,0);

        PlayerPawn = Spawn(PlayerPawn.Class,,,Location + vect(0,0,1) * PlayerPawn.GetCollisionHeight());
        PlayerPawn.LastStartTime = WorldInfo.TimeSeconds;

        PC.Unpossess();
        PC.Possess(PlayerPawn,false);
        PC.GotoState('PlayerPlayingBoard');

        PlayerPawn.ForceRotation(rot(0,0,0),true,true);

        PlayerPawn.bDisableBlobShadows = true;
        PlayerPawn.UpdateShadowSettings(false);

        BlobShadow = Spawn(class'BlobShadowActor',PlayerPawn,,PlayerPawn.Location,rotator(vect(0,0,-1)));
        BlobShadow.SetMaterial(BlobShadowMaterial);
        BlobShadow.SetBase(PlayerPawn);
        BlobShadow.SetHidden(false);

        LoadBoard();

        BoardLight = Spawn(class'PointLightBoard',self);
        PlayerPawn.AttachToRoot(BoardLight,vect(1,0,0) * PlayerPawn.GetCollisionRadius() +
                                           vect(0,0,1) * PlayerPawn.GetCollisionHeight());

        LightingChannels.Gameplay_4 = true;
        LightingChannels.bInitialized = true;
        PlayerPawn.Mesh.SetLightingChannels(LightingChannels);

        PlayerPawn.bDisableSonicPhysics = true;
        PlayerPawn.AirDragFactor = 0.0;
        PlayerPawn.GotoState('NoDuckJumpSpecial');

        MusicPitchMultiplier = 1.0;
        OldGameSpeed = WorldInfo.Game.GameSpeed;

        SetHidden(false);

        TriggerEventClass(class'SeqEvent_SpecialStage',PlayerPawn,1);
    }

Begin:
    Sleep(0.5);

    SGDKPlayerController(PlayerPawn.Controller).ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,1.0),0.5);

    Sleep(0.5);

    TeleportPlayer();

    SpecialStagePosition.X = 1280.0;
    InstructionsPosition.X = 2048.0;
    InstructionsPosition.Y = default.InstructionsPosition.Y;

    StartState = 0;

    Sleep(0.25);

    SGDKPlayerController(PlayerPawn.Controller).GetMusicManager().StartMusicTrack(AmbientIntroTrack,0.0);
    SetTimer(AmbientIntroTrack.Duration,false,NameOf(PlayAmbientTrack));

    Sleep(1.75);

    SGDKPlayerController(PlayerPawn.Controller).ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,0.0),1.0);

    Sleep(1.0);

    StartState = 1;

    Sleep(1.0);

    SGDKPlayerController(PlayerPawn.Controller).IgnoreLookInput(false);
    SGDKPlayerController(PlayerPawn.Controller).IgnoreMoveInput(false);

    GotoState('Playing');
}


state Fail extends Playing
{
    event BeginState(name PreviousStateName)
    {
        local SGDKPlayerController PC;

        ClearAllTimers();

        WorldInfo.Game.bPauseable = false;
        WorldInfo.Game.SetGameSpeed(OldGameSpeed);

        PC = SGDKPlayerController(PlayerPawn.Controller);

        PC.GetMusicManager().SetPitch(1.0,0.0);
        PC.GetMusicManager().StopMusic(0.0);
        PC.ScreenFadeToColor(MakeLinearColor(1.0,0.0,0.0,1.0),0.5);

        PC.BoardMoveDirection = vect(0,0,0);
        PC.IgnoreLookInput(true);
        PC.IgnoreMoveInput(true);
    }

    event EndState(name NextStateName)
    {
        local SGDKPlayerController PC;

        TriggerEventClass(class'SeqEvent_SpecialStage',PlayerPawn,2);

        UnloadBoard();

        SetHidden(true);

        PC = SGDKPlayerController(PlayerPawn.Controller);

        OldPlayerPawn.LastStartTime = WorldInfo.TimeSeconds;

        PC.Unpossess();
        PC.Possess(OldPlayerPawn,false);

        PC.GetMusicManager().Reset();

        OldPlayerPawn.SetHidden(false);
        OldPlayerPawn.TurnOn();
        OldPlayerPawn.bAmbientCreature = false;
        OldPlayerPawn.ForceRotation(OldPlayerPawn.GetRotation(),true,true);

        TriggerEventClass(class'SeqEvent_SpecialStage',OldPlayerPawn,3);

        BlobShadow.Destroy();
        BlobShadow = none;

        PlayerPawn.Destroy();
        PlayerPawn = none;

        WorldInfo.Game.bPauseable = WorldInfo.Game.default.bPauseable;
        SGDKGameInfo(WorldInfo.Game).SpecialStage = none;
    }

Begin:
    Sleep(1.0);

    SGDKPlayerController(PlayerPawn.Controller).ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,1.0),1.0);

    Sleep(2.0);

    GotoState('Auto');
}


state Success extends Playing
{
    event BeginState(name PreviousStateName)
    {
        local SGDKPlayerController PC;

        ClearAllTimers();

        WorldInfo.Game.bPauseable = false;
        WorldInfo.Game.SetGameSpeed(OldGameSpeed);

        PlayerPawn.PlaySound(SoundCue'SonicGDKPackSounds.TeleportSoundCue');

        PC = SGDKPlayerController(PlayerPawn.Controller);

        PC.GetMusicManager().SetPitch(1.0,0.0);
        PC.GetMusicManager().StopMusic(0.5);
        PC.ScreenFadeToColor(MakeLinearColor(1.0,1.0,1.0,1.0),0.5);

        PC.BoardMoveDirection = vect(0,0,0);
        PC.IgnoreLookInput(true);
        PC.IgnoreMoveInput(true);

        ChaosEmeralds = PC.ChaosEmeralds + 1;
        StatsState = 255;
    }

    event EndState(name NextStateName)
    {
        local SGDKPlayerController PC;

        TriggerEventClass(class'SeqEvent_SpecialStage',PlayerPawn,2);

        UnloadBoard();

        SetHidden(true);

        PC = SGDKPlayerController(PlayerPawn.Controller);

        OldPlayerPawn.LastStartTime = WorldInfo.TimeSeconds;

        PC.Unpossess();
        PC.Possess(OldPlayerPawn,false);

        PC.GetMusicManager().Reset();

        OldPlayerPawn.SetHidden(false);
        OldPlayerPawn.TurnOn();
        OldPlayerPawn.bAmbientCreature = false;
        OldPlayerPawn.ForceRotation(OldPlayerPawn.GetRotation(),true,true);

        TriggerEventClass(class'SeqEvent_SpecialStage',OldPlayerPawn,3);

        BlobShadow.Destroy();
        BlobShadow = none;

        PlayerPawn.Destroy();
        PlayerPawn = none;

        WorldInfo.Game.bPauseable = WorldInfo.Game.default.bPauseable;
        SGDKGameInfo(WorldInfo.Game).SpecialStage = none;
    }

    /**
     * Draws the HUD graphics.
     * @param TheHud  the HUD
     */
    function HudGraphicsDraw(SGDKHud TheHud)
    {
        local int i;

        global.HudGraphicsDraw(TheHud);

        if (!bHidden)
        {
            TheHud.DrawPause();
            TheHud.DrawFadingScreen();

            if (StatsState != 255)
            {
                TheHud.ResolutionScale *= TheHud.HudScale;

                TheHud.Canvas.Font = TheHud.HudFonts[5];
                TheHud.Canvas.DrawColor = TheHud.BlackColor;

                TheHud.Canvas.SetPos(80.0 * TheHud.ResolutionScaleX,100.0 * TheHud.ResolutionScale);

                if (ChaosEmeralds < 8)
                    //Draw the got a Chaos Emerald text.
                    TheHud.Canvas.DrawText("you got a chaos emerald",,TheHud.ResolutionScale,TheHud.ResolutionScale);
                else
                    //Draw the got a Super Emerald text.
                    TheHud.Canvas.DrawText("you got a super emerald",,TheHud.ResolutionScale,TheHud.ResolutionScale);

                if (ChaosEmeralds > 6)
                {
                    TheHud.Canvas.SetPos(80.0 * TheHud.ResolutionScaleX,TheHud.Canvas.SizeY - 200.0 * TheHud.ResolutionScale);

                    if (ChaosEmeralds < 14 || !PlayerPawn.bHasHyperForm)
                        //Draw the become super form text.
                        TheHud.Canvas.DrawText("you can become super",,TheHud.ResolutionScale,TheHud.ResolutionScale);
                    else
                        //Draw the become hyper form text.
                        TheHud.Canvas.DrawText("you can become hyper",,TheHud.ResolutionScale,TheHud.ResolutionScale);
                }

                if (WorldInfo.TimeSeconds % 0.05 < 0.025)
                {
                    TheHud.Canvas.DrawColor = TheHud.WhiteColor;

                    for (i = 0; i < ChaosEmeralds; i++)
                    {
                        if (i > 6)
                            break;
                        else
                            if (i > ChaosEmeralds - 8)
                            {
                                //Draw a Chaos Emerald.
                                TheHud.Canvas.SetPos(TheHud.Canvas.SizeX * ((i + 1) * 0.125) -
                                                     TheHud.ChaosEmeraldsCoords.UL * 0.5 * TheHud.ResolutionScaleX,
                                                     TheHud.Canvas.SizeY * 0.5 -
                                                     TheHud.ChaosEmeraldsCoords.VL * 0.5 * TheHud.ResolutionScale);
                                TheHud.Canvas.DrawTile(TheHud.HudTexture,
                                                       TheHud.ChaosEmeraldsCoords.UL * TheHud.ResolutionScale * 2.0,
                                                       TheHud.ChaosEmeraldsCoords.VL * TheHud.ResolutionScale * 2.0,
                                                       TheHud.ChaosEmeraldsCoords.U + i * 80.0,TheHud.ChaosEmeraldsCoords.V,
                                                       TheHud.ChaosEmeraldsCoords.UL,TheHud.ChaosEmeraldsCoords.VL);
                            }
                            else
                            {
                                //Draw a Super Emerald.
                                TheHud.Canvas.SetPos(TheHud.Canvas.SizeX * ((i + 1) * 0.125) -
                                                     TheHud.ChaosEmeraldsCoords.UL * TheHud.ResolutionScaleX,
                                                     TheHud.Canvas.SizeY * 0.5 -
                                                     TheHud.ChaosEmeraldsCoords.VL * 2.0 * TheHud.ResolutionScale);
                                TheHud.Canvas.DrawTile(TheHud.HudTexture,
                                                       TheHud.ChaosEmeraldsCoords.UL * TheHud.ResolutionScale * 4.0,
                                                       TheHud.ChaosEmeraldsCoords.VL * TheHud.ResolutionScale * 4.0,
                                                       TheHud.ChaosEmeraldsCoords.U + i * 80.0,TheHud.ChaosEmeraldsCoords.V,
                                                       TheHud.ChaosEmeraldsCoords.UL,TheHud.ChaosEmeraldsCoords.VL);
                            }
                    }
                }

                TheHud.ResolutionScale /= TheHud.HudScale;
            }
        }
    }

Begin:
    Sleep(1.0);

    StatsState = 0;

    ChaosEmerald = Spawn(class'ChaosEmeraldActor',PlayerPawn,,PlayerPawn.Location);
    ChaosEmerald.Touch(PlayerPawn,PlayerPawn.CollisionComponent,vect(0,0,0),vect(0,0,0));

    Sleep(ChaosEmerald.EmeraldSoundCue.Duration - 1.5);

    SGDKPlayerController(PlayerPawn.Controller).GetMusicManager().StopMusic(1.5);

    Sleep(3.5);

    StatsState = 255;

    ChaosEmerald.Destroy();
    SGDKPlayerController(PlayerPawn.Controller).ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,1.0),0.5);

    Sleep(0.5);

    GotoState('Auto');
}


defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=BoardActorMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SpecialBoardStaticMesh'
        bAcceptsLights=false
        bAllowApproximateOcclusion=true
        bCastDynamicShadow=false
        bForceDirectLightMap=true
        bUsePrecomputedShadows=true
        BlockActors=true
        BlockRigidBody=true
        CastShadow=false
        CollideActors=true
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    CollisionComponent=BoardActorMesh
    BoardMesh=BoardActorMesh
    Components.Add(BoardActorMesh)


    Begin Object Class=StaticMeshComponent Name=SkyActorMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SpecialBoardStaticMesh'
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.SpecialBoardSkyMaterial'
        bAcceptsLights=false
        bAllowApproximateOcclusion=true
        bCastDynamicShadow=false
        bForceDirectLightMap=true
        bUsePrecomputedShadows=false
        BlockActors=false
        BlockRigidBody=false
        BoundsScale=10.0
        CastShadow=false
        CollideActors=false
        Rotation=(Pitch=32768,Yaw=0,Roll=0)
        Scale=2.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=3072.0)
    End Object
    SkyMesh=SkyActorMesh
    Components.Add(SkyActorMesh)


    Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorMaterials.TargetIcon'
        HiddenGame=true
        Scale=2.0
    End Object
    Components.Add(Sprite)


    bBlockActors=true          //Blocks other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bHidden=true               //Actor isn't displayed from start.
    bMovable=true              //Actor can be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPathColliding=true        //Blocks paths during AI path building in the editor. 
    bPushedByEncroachers=false //Whether encroachers can push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    AmbientIntroTrack=SoundCue'SonicGDKPackMusic.SpecialBoardIntroSoundCue'
    AmbientLoopTrack=SoundCue'SonicGDKPackMusic.SpecialBoardLoopSoundCue'
    BlobShadowMaterial=DecalMaterial'SonicGDKPackSkeletalMeshes.Materials.BlobShadowMaterialB'
    Boards[0]="2-2-2-2-2-2-2-2-2-0-0-3-1-1-3-0-0-2-2-2-2-0-0-3-1-1-3-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-3-1-3-0-0-2-2-2-2-0-0-3-1-3-3-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-1-1-3-0-0-2-2-2-2-0-0-3-1-1-3-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-1-3-3-0-0-2-2-2-2-0-0-3-3-1-3-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-1-1-3-0-0-2-2-2-2-0-0-3-1-1-3-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-3-1-3-0-0-2-2-2-2-0-0-3-1-3-3-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-2-2-2-0-0-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-0-0-0-0-0-0-0-1-1-1-1-0-0-2-2-2-2-0-0-1-1-1-1-0-0-0-0-0-0-0-3-3-0-0-0-1-1-0-0-1-1-1-1-0-0-2-2-2-2-0-0-1-1-1-1-0-0-1-1-0-0-0-3-3-0-0-0-1-1-0-0-1-1-1-1-0-0-2-2-2-2-0-0-1-1-1-1-0-0-1-1-0-0-0-2-2-0-0-0-0-0-0-0-1-1-1-1-0-0-2-2-2-2-0-0-1-1-1-1-0-0-0-0-0-0-0-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-4-0-3-3-0-0-0-0-0-0-0-0-0-0-0-0-^-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-3-0-4-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-0-0-0-0-0-0-0-1-1-1-1-0-0-2-2-2-2-0-0-1-1-1-1-0-0-0-0-0-0-0-3-3-0-0-0-1-1-0-0-1-1-1-1-0-0-2-2-2-2-0-0-1-1-1-1-0-0-1-1-0-0-0-3-3-0-0-0-1-1-0-0-1-1-1-1-0-0-2-2-2-2-0-0-1-1-1-1-0-0-1-1-0-0-0-2-2-0-0-0-0-0-0-0-1-1-1-1-0-0-2-2-2-2-0-0-1-1-1-1-0-0-0-0-0-0-0-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-1-3-3-0-0-2-2-2-2-0-0-3-3-1-3-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-1-3-3-0-0-2-2-2-2-0-0-3-3-1-3-0-0-2-2-2"
    Boards[1]="2-2-2-2-0-0-0-0-0-0-3-3-3-0-0-0-1-1-1-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-1-1-1-0-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-0-0-0-2-2-2-0-0-0-0-0-0-0-1-1-1-0-2-2-3-3-3-3-3-3-3-3-3-3-1-1-1-0-0-0-2-3-2-0-0-0-0-0-0-0-0-0-0-0-2-2-3-1-1-1-1-1-1-1-1-1-3-3-0-0-0-0-2-2-2-0-0-0-2-2-2-0-0-0-0-0-2-2-3-1-3-3-3-3-3-3-3-3-2-2-0-2-0-0-0-0-0-0-0-0-2-3-2-0-0-0-0-0-2-2-3-1-3-2-2-2-2-2-2-2-0-0-0-2-3-0-0-0-0-0-0-0-2-2-2-0-0-0-3-3-2-3-3-1-3-2-2-2-2-2-2-2-0-2-2-2-3-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-3-5-0-0-0-0-0-0-2-2-2-2-0-2-2-2-3-0-0-0-3-1-3-0-0-0-0-0-0-0-3-3-2-3-5-2-2-2-2-0-2-2-2-2-0-0-2-2-0-0-0-0-1-5-1-0-0-0-0-0-0-0-0-0-2-2-3-2-2-2-2-0-3-3-3-3-1-0-2-2-0-0-0-0-3-1-3-0-0-0-2-2-2-0-0-0-2-2-2-2-2-2-2-0-1-1-1-1-1-0-2-2-0-0-0-0-0-0-0-0-0-0-2-3-2-0-0-0-2-2-2-2-2-2-2-0-1-1-1-1-1-0-2-2-3-1-3-0-0-0-0-0-0-0-2-2-2-0-0-0-2-2-2-2-2-2-2-0-1-1-1-1-1-0-2-2-3-5-1-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-0-1-1-1-1-0-0-2-2-3-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-^-0-0-0-2-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-2-0-0-0-0-0-0-0-0-0-0-0-3-3-0-0-0-0-4-4-4-4-4-0-0-4-4-4-4-4-0-0-2-0-3-3-3-3-3-3-3-3-3-3-1-3-0-0-0-0-4-1-1-1-4-0-0-4-2-2-2-4-0-0-2-0-5-1-3-1-1-1-1-1-1-1-1-3-0-0-0-0-4-1-1-1-4-0-0-4-2-2-2-4-0-0-2-0-3-1-3-3-3-3-3-3-3-3-1-3-0-0-0-0-4-1-1-1-4-0-0-4-2-2-2-4-0-0-2-0-3-1-3-1-3-1-1-1-1-3-1-3-0-0-0-0-4-4-4-4-4-1-1-4-4-4-4-4-0-0-2-0-3-1-3-1-3-3-3-3-1-3-1-3-0-0-0-0-0-0-0-0-1-5-5-1-0-0-0-0-0-0-2-0-3-1-3-1-3-1-4-3-1-3-1-3-0-0-0-0-0-0-0-0-1-5-5-1-0-0-0-0-0-0-2-0-3-1-3-1-3-1-1-3-1-3-1-3-0-0-0-0-4-4-4-4-4-1-1-4-4-4-4-4-0-0-2-0-3-1-3-1-3-3-3-3-1-3-1-3-0-0-0-0-4-2-2-2-4-0-0-4-1-1-1-4-0-0-2-0-3-1-3-1-1-1-1-1-1-3-1-3-0-0-0-0-4-2-2-2-4-0-0-4-1-1-1-4-0-0-2-0-3-1-3-3-3-3-3-3-3-3-1-3-0-0-0-0-4-2-2-2-4-0-0-4-1-1-1-4-0-0-2-0-3-1-1-1-1-1-1-1-1-1-3-3-0-0-0-0-4-4-4-4-4-0-0-4-4-4-4-4-0-0-2-0-3-3-3-3-3-3-3-3-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-2-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-3-3-3-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2"
    Boards[2]="2-2-2-2-2-2-2-2-2-3-3-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-3-3-1-1-1-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-1-1-1-0-0-1-1-0-2-2-2-2-2-2-2-2-2-2-5-0-0-5-2-2-2-5-0-0-0-0-3-3-1-1-1-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-4-2-2-0-2-2-2-0-2-2-2-2-2-3-3-3-3-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-3-2-2-0-2-2-2-4-2-2-2-2-2-3-3-3-3-0-0-2-2-2-2-2-2-2-2-2-2-5-0-0-1-0-0-5-2-2-2-2-2-2-2-2-2-3-3-5-5-0-0-5-5-2-2-2-2-2-2-2-2-0-2-2-3-2-2-2-2-5-2-2-2-2-2-2-2-3-3-5-5-0-0-5-5-2-2-2-2-2-5-4-3-1-3-2-4-0-0-0-0-0-2-2-2-2-2-2-2-3-3-3-3-0-0-2-2-2-2-2-2-2-0-2-2-0-2-2-4-2-2-2-2-0-2-2-2-2-2-2-2-3-3-3-3-0-0-2-2-2-2-2-2-2-0-2-2-0-2-2-0-2-2-2-2-5-2-4-2-0-0-0-3-3-1-1-1-0-0-0-0-0-0-2-2-2-0-2-2-0-2-2-5-0-0-0-0-2-2-0-2-0-0-0-3-3-1-1-1-0-0-1-1-1-0-2-2-2-0-2-2-0-2-2-2-2-2-2-2-0-0-5-2-0-0-0-3-3-1-1-1-0-0-0-0-0-0-2-2-2-0-2-2-5-0-4-2-2-2-2-4-2-2-2-2-2-2-2-2-2-3-3-3-2-2-2-0-0-0-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-5-0-0-0-2-2-2-2-2-2-2-3-3-3-3-2-2-2-2-2-2-2-2-2-0-0-0-^-0-0-0-3-3-0-0-0-0-0-0-0-3-3-3-3-3-3-3-2-2-2-2-2-2-2-2-2-0-1-0-1-0-1-0-3-3-2-2-2-0-3-3-3-3-3-3-3-3-3-3-2-2-5-5-5-5-5-2-2-0-1-0-1-0-1-0-3-3-2-2-2-0-5-0-3-3-3-3-3-3-3-3-2-2-5-3-3-3-5-2-2-0-1-0-1-0-1-0-3-3-2-2-2-0-1-0-3-3-3-3-3-3-3-3-2-2-5-3-0-3-5-2-2-0-5-0-5-0-5-0-3-3-2-2-2-0-5-0-3-3-3-3-3-3-3-3-2-2-5-3-3-3-5-2-2-0-1-0-1-0-1-0-3-3-2-2-2-0-3-3-3-3-3-3-3-3-3-3-2-2-5-5-5-5-5-2-2-0-1-0-1-0-1-0-3-3-2-2-2-0-1-1-1-1-3-3-3-3-3-0-2-2-2-2-2-2-2-2-2-0-1-0-1-0-1-0-3-3-2-2-2-0-1-1-1-1-3-3-0-0-3-0-2-2-2-2-2-2-2-2-2-0-5-0-5-0-5-0-3-3-2-2-2-0-1-1-1-1-3-0-1-5-3-0-0-0-0-0-0-0-0-0-0-0-1-0-1-0-1-0-3-3-2-2-2-0-1-1-1-1-3-5-0-0-0-0-0-1-1-1-5-1-1-1-5-1-1-0-1-0-1-0-3-3-2-2-2-0-0-0-0-0-0-0-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-1-0-1-0-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-1-1-1-5-1-1-1-5-1-1-1-1-0-5-0-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-1-0-3-3-2-2-2-2-2-2-2-2-2-2-3-3-3-3-0-1-1-1-5-1-1-1-5-1-1-1-5-1-1-0-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-3-3-3-3-3-3-3-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2"
    Boards[3]="3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-0-0-0-0-0-1-1-1-1-1-1-0-0-0-3-3-3-3-3-3-3-3-3-3-3-3-3-3-0-0-0-0-0-5-5-5-0-1-0-0-0-0-1-0-0-0-3-3-3-3-3-0-0-0-1-0-0-0-0-0-3-3-3-3-0-0-0-0-0-1-1-1-1-1-1-0-0-0-3-3-3-3-3-0-0-0-1-3-3-3-3-3-3-3-3-3-3-3-1-1-1-3-3-3-3-3-3-1-1-1-3-3-3-3-3-0-0-0-1-3-3-3-3-3-3-3-3-3-3-3-1-0-1-3-3-3-3-3-3-1-0-1-3-3-3-3-3-1-1-1-1-1-1-1-3-3-3-3-3-3-3-3-1-0-1-3-3-2-2-3-3-1-0-1-3-3-3-3-3-0-3-3-1-3-3-1-3-3-3-3-3-3-3-3-1-0-1-3-3-2-2-3-3-1-0-1-3-3-3-3-3-0-3-3-1-3-3-1-3-3-1-3-3-3-3-3-1-0-1-3-3-3-3-3-3-1-0-1-3-3-3-3-3-0-3-3-1-1-1-1-1-1-1-3-3-3-3-3-1-1-1-3-3-3-3-3-3-1-1-1-3-3-3-3-3-0-3-3-3-3-3-1-3-3-1-3-3-3-3-3-0-0-0-1-1-1-1-1-1-0-0-0-3-3-3-3-3-0-3-3-3-3-3-1-3-3-5-3-3-3-3-3-0-0-0-1-0-0-0-0-1-0-5-0-3-3-3-3-3-0-3-3-3-3-3-1-1-1-3-3-3-3-3-3-0-0-0-1-1-1-1-1-1-0-5-0-3-3-3-3-3-0-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-0-5-0-3-3-3-3-3-0-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-0-0-0-3-3-3-3-3-0-3-3-3-3-3-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-^-0-2-2-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-0-5-0-2-2-2-2-0-0-0-2-2-2-3-3-3-2-0-0-0-0-2-2-2-2-2-2-2-0-1-0-3-0-0-0-2-2-2-2-0-0-0-0-0-0-1-1-1-0-0-0-0-0-2-2-2-2-0-0-0-0-0-0-2-2-2-2-2-2-2-2-0-1-1-1-0-0-1-1-1-0-0-0-0-0-2-2-2-2-0-1-0-2-2-2-2-2-2-3-3-3-2-2-0-0-0-0-0-0-1-1-1-0-2-2-2-0-2-2-2-2-0-0-0-3-0-0-0-2-2-3-3-3-2-2-2-2-2-2-2-2-3-3-3-3-2-2-2-0-2-2-2-2-2-2-2-2-0-1-0-2-2-3-3-3-2-2-2-2-2-2-2-2-3-3-3-3-2-2-2-0-2-2-2-2-2-0-0-0-0-0-0-3-5-5-5-2-2-2-2-2-5-5-0-0-5-5-3-3-2-2-2-0-2-2-2-2-2-0-1-0-2-2-2-2-2-2-5-2-2-2-2-2-5-5-0-0-5-5-3-3-2-2-2-0-2-2-2-2-2-0-0-0-0-0-0-2-2-2-5-2-2-2-2-2-2-2-2-2-3-3-3-3-2-2-2-0-2-2-2-2-2-2-2-2-0-1-0-2-2-2-3-2-2-2-2-2-2-2-2-2-3-3-3-3-3-0-0-0-0-0-0-2-0-0-0-3-0-0-0-2-2-2-5-2-2-2-2-0-0-0-0-0-1-1-1-3-0-0-0-0-0-5-0-3-0-1-0-2-2-2-2-2-2-2-5-2-2-2-2-0-1-1-0-0-1-1-1-0-3-0-0-0-0-0-0-2-0-0-0-3-0-0-0-0-5-5-5-2-2-2-2-0-0-0-0-0-1-1-1-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3"
    Boards[4]="3-3-3-0-2-2-2-2-2-2-2-5-5-5-2-2-2-2-2-2-0-3-3-3-0-0-0-0-0-0-0-0-0-3-3-0-0-0-0-0-2-2-2-5-1-5-2-2-2-2-2-2-0-3-3-0-0-0-0-0-0-0-0-0-0-0-3-0-0-3-3-0-0-0-0-5-5-5-2-2-2-2-2-2-0-3-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-0-0-0-0-1-1-1-1-1-1-1-1-0-0-0-0-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-0-0-0-0-1-6-6-6-6-6-6-1-0-0-0-0-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-0-0-0-0-1-6-4-4-4-4-6-1-0-0-0-0-2-2-2-2-2-2-0-0-0-1-0-0-0-5-3-2-0-0-0-0-2-6-4-1-1-4-6-2-0-0-0-0-2-2-2-2-2-0-0-2-2-0-2-2-0-2-2-2-0-0-0-0-2-6-4-1-1-4-6-2-0-0-0-0-2-2-2-2-0-0-2-2-2-0-2-2-0-2-2-2-0-0-0-0-1-6-4-4-4-4-6-1-0-0-0-0-2-2-2-2-0-2-2-2-0-0-2-2-0-2-2-2-0-0-0-0-1-6-6-6-6-6-6-1-0-0-0-0-2-2-2-2-0-2-2-0-0-2-2-2-0-2-2-2-0-0-0-0-1-1-1-1-1-1-1-1-0-0-3-0-2-2-0-0-1-0-0-0-2-2-2-2-0-2-2-2-0-3-0-0-0-0-0-0-0-0-0-0-0-3-3-0-2-2-0-2-0-2-2-2-2-2-2-0-0-0-2-2-0-3-3-0-0-0-0-0-0-0-0-0-3-3-3-0-2-2-0-0-0-2-2-2-2-2-2-0-1-0-2-2-0-3-3-3-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-^-0-2-2-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-1-0-2-2-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-0-0-0-3-3-3-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-1-0-2-2-2-0-2-2-2-2-2-0-0-1-1-1-3-2-2-2-2-2-2-2-2-0-2-2-2-0-2-2-0-0-2-2-2-0-2-2-2-2-2-2-3-1-1-1-3-2-2-2-2-2-2-2-2-0-2-2-2-0-2-2-2-0-0-2-2-0-2-2-2-2-2-2-3-1-1-1-0-0-0-0-2-2-2-2-2-0-2-2-2-0-0-2-2-2-0-2-2-0-2-2-2-2-2-2-3-3-3-0-5-1-5-0-2-2-2-2-2-0-2-2-2-2-0-0-2-2-0-2-2-0-2-2-2-2-2-2-2-2-2-0-1-1-1-0-2-3-3-2-2-0-2-2-2-2-0-1-0-0-3-0-0-0-5-3-2-2-2-2-2-2-2-0-5-1-5-0-3-1-3-2-2-0-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-1-1-1-3-2-2-0-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-1-1-1-0-0-0-0-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-1-1-0-0-0-0-0-3-3-0-2-2-2-5-5-5-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-0-0-0-0-0-0-0-0-2-2-2-5-1-5-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-5-5-5-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0"
    Boards[5]="2-2-2-2-3-3-3-3-3-3-3-3-3-0-0-1-2-2-1-0-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-0-0-3-3-3-3-3-3-3-3-0-0-2-1-1-2-0-2-2-0-0-0-0-0-2-2-2-2-3-4-1-1-0-0-3-3-3-3-3-3-3-3-0-0-2-1-1-2-0-2-2-0-1-1-1-0-2-2-2-2-3-3-3-3-0-0-0-0-0-0-0-0-0-0-0-0-1-2-2-1-0-2-2-0-1-1-1-0-2-2-2-2-3-2-2-2-0-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-2-2-0-1-1-1-0-2-2-2-2-2-2-2-2-0-0-0-0-0-0-5-2-0-1-0-2-2-2-2-2-2-2-2-0-0-0-0-0-3-0-0-0-0-3-2-2-0-0-3-3-3-0-5-2-0-1-0-2-5-0-3-3-3-2-2-2-2-2-2-3-2-2-2-3-1-3-2-2-0-0-3-3-3-0-5-2-0-1-0-2-5-0-3-3-3-2-2-2-2-2-2-0-2-2-2-3-3-2-2-2-0-0-0-0-0-0-5-2-0-1-0-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-4-2-2-2-0-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-2-2-2-2-2-2-0-3-3-2-2-2-2-2-2-0-3-3-3-3-3-3-3-3-3-3-0-1-2-2-1-0-2-2-3-3-3-2-0-1-3-4-2-2-0-0-0-0-3-3-3-3-3-3-3-3-3-3-0-2-1-1-2-0-2-2-3-4-3-2-2-3-3-2-2-2-0-2-2-2-3-3-2-2-2-2-2-2-3-3-0-2-1-1-2-0-2-2-3-1-3-2-2-2-2-2-2-2-0-2-2-2-3-3-3-3-3-3-3-3-3-3-0-1-2-2-1-0-2-2-3-1-3-2-2-2-2-2-2-2-0-2-2-2-3-3-3-3-3-3-3-3-3-3-0-0-0-0-0-0-2-2-0-0-0-0-0-0-0-0-0-0-2-2-2-2-3-3-3-3-0-0-0-0-0-0-0-0-^-0-3-3-2-2-0-0-0-2-2-2-2-2-2-3-2-2-2-2-3-2-2-3-0-0-0-3-3-3-3-0-0-0-3-3-2-2-0-0-0-2-2-2-2-2-2-2-0-0-2-2-3-2-2-3-0-0-0-3-4-4-3-0-0-0-3-3-2-2-0-0-0-2-2-3-0-0-0-3-1-0-2-2-3-3-3-3-0-0-0-3-3-3-3-0-0-0-3-3-2-2-0-0-0-2-2-0-0-3-0-3-3-3-2-2-0-0-0-0-2-2-2-0-0-0-0-1-1-1-0-0-2-2-3-3-3-2-2-0-3-0-0-3-0-0-2-2-0-0-0-0-2-1-1-0-0-0-0-2-1-1-0-0-2-2-0-1-0-2-2-0-0-0-3-0-0-0-2-2-0-0-0-0-2-1-1-0-0-0-0-2-2-1-0-0-2-2-0-1-0-2-2-3-0-0-0-3-0-3-2-2-0-3-3-3-0-0-0-3-3-3-3-0-0-0-3-3-2-2-3-3-3-2-2-0-0-3-0-0-0-0-2-2-0-3-4-3-0-0-0-3-4-4-3-0-0-0-3-3-2-2-0-0-0-5-5-0-0-0-0-3-2-2-2-2-0-3-4-3-0-0-0-3-4-4-3-0-0-0-3-3-2-2-0-0-0-2-2-5-2-2-2-2-2-2-2-2-0-3-3-3-0-0-0-3-3-3-3-0-0-0-3-3-2-2-0-0-0-2-2-5-2-2-2-2-0-0-0-0-0-0-0-0-1-2-2-0-0-0-0-1-1-1-0-0-2-2-0-0-0-0-0-0-3-0-0-3-0-0-0-0-0-0-0-0-1-1-2-0-0-0-0-1-5-1-0-0-2-2-0-0-0-0-0-0-3-1-1-3-0-0-0-0-0-0-0-0-1-1-1-0-0-0-0-1-1-1-0-0-2-2-0-0-0-0-0-0-3-0-0-3-2-2-2-2-3-3-3-3-0-0-0-3-3-3-3-0-0-0-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-3-0-0-0-3-3-3-3-0-0-0-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-3-3-3-3-3-3-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2"
    Boards[6]="2-2-2-2-3-3-0-0-0-0-0-2-1-0-0-0-0-0-1-3-2-2-2-2-2-2-2-3-3-3-3-3-0-0-0-0-0-3-0-3-3-3-0-3-0-3-3-2-3-3-0-3-2-2-2-2-2-2-2-3-1-1-1-3-0-0-0-0-0-0-0-3-0-0-0-3-0-3-3-0-0-0-0-3-2-2-2-2-2-2-2-3-1-1-1-3-0-0-0-0-0-3-3-3-0-3-3-3-0-3-3-0-3-3-2-3-2-2-2-2-1-2-2-0-1-1-1-3-1-2-2-2-3-3-3-3-0-3-0-0-0-2-2-0-0-0-0-3-2-2-2-2-2-2-2-3-3-3-3-3-2-2-2-2-3-3-3-3-0-0-0-3-2-3-3-3-3-3-0-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-3-2-3-3-3-0-0-0-3-3-3-0-3-2-3-3-3-0-3-2-2-2-2-2-2-1-2-2-2-3-3-3-3-2-3-3-3-0-3-0-3-3-3-0-3-2-3-1-1-1-3-2-2-2-2-2-2-2-2-2-2-3-1-0-0-0-0-0-0-0-2-0-0-0-0-1-3-2-3-1-1-1-3-2-2-2-2-4-2-0-0-2-2-3-0-3-3-3-3-3-3-3-3-3-3-3-3-3-3-2-3-1-1-1-3-2-2-2-4-0-0-1-0-2-2-3-0-3-3-3-3-3-3-3-3-3-3-3-3-3-3-2-3-3-3-3-3-2-2-2-2-0-1-1-0-2-2-3-0-3-0-0-0-2-2-0-0-0-0-1-3-3-3-2-2-0-0-0-1-2-2-1-2-0-1-0-0-2-2-3-0-3-0-3-0-3-3-0-3-3-3-5-3-3-3-2-2-0-0-0-2-2-2-2-2-0-0-2-2-2-2-3-1-0-0-2-0-0-0-0-3-3-3-5-3-3-3-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-2-3-3-3-3-3-3-3-3-3-3-3-0-0-0-3-3-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-^-0-2-2-2-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-1-0-0-0-2-2-2-0-3-3-3-3-3-3-3-3-2-2-2-2-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-3-5-0-0-0-0-0-1-0-0-4-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-3-3-3-3-3-3-3-3-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-3-3-3-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-3-3-1-3-3-2-2-2-2-0-3-2-2-2-2-2-2-3-2-2-2-2-2-2-2-3-0-5-4-2-2-2-4-0-0-1-3-2-2-2-3-5-0-0-0-0-0-1-0-0-3-2-2-2-2-2-2-2-0-2-2-2-2-2-3-3-1-3-3-2-2-2-2-0-3-2-2-2-2-2-2-3-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-3-3-3-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-1-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-3-3-3-3-3-3-3-3-2-2-2-2-2-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-3-5-0-0-0-0-0-1-0-0-4-2-2-2-2-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-3-3-3-3-3-3-3-3-2-2-2-2-2-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2"
    Boards[7]="0-0-0-0-0-0-3-2-2-2-2-3-0-0-0-0-3-3-3-0-0-0-0-3-2-2-2-2-2-2-3-0-0-0-0-0-0-3-2-2-2-2-2-2-3-0-0-0-0-3-0-0-0-0-3-2-2-2-3-2-2-2-2-3-3-0-0-0-3-2-2-2-2-2-2-2-2-3-0-0-0-0-0-0-0-3-2-2-2-3-0-3-2-2-2-2-2-3-4-3-2-2-2-3-2-2-2-2-3-0-0-0-0-0-0-0-3-2-2-2-3-0-0-0-3-2-2-2-2-2-3-2-2-2-3-4-3-2-2-3-0-0-0-0-0-0-0-3-2-2-2-3-0-0-0-0-0-3-2-2-2-2-2-2-2-3-0-0-0-3-3-0-0-0-0-3-0-0-0-0-3-2-3-0-0-0-0-0-0-0-3-2-2-2-2-2-3-0-0-0-0-0-0-0-0-0-3-3-3-0-0-0-0-3-0-0-0-3-1-3-0-0-0-3-3-2-2-3-0-0-0-0-0-0-0-0-0-3-1-1-1-1-0-0-0-0-0-0-0-1-5-1-0-0-0-4-2-2-3-0-0-0-3-1-3-0-0-0-3-3-1-1-1-1-3-0-0-0-0-0-0-3-1-3-0-0-0-3-2-3-4-0-0-0-1-5-1-0-0-0-0-3-1-1-1-1-3-3-0-0-0-0-0-0-0-0-0-0-3-2-2-2-3-0-0-0-3-1-3-0-0-0-0-0-1-1-1-1-3-0-0-0-0-0-0-0-0-0-0-3-2-2-2-2-2-3-0-0-0-0-0-0-0-0-0-0-0-3-3-3-0-0-0-0-0-0-0-0-0-0-3-2-2-2-2-2-2-2-3-0-0-0-0-0-0-0-0-0-0-0-3-0-0-0-0-3-0-0-0-0-0-3-2-2-2-2-2-2-2-2-2-3-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-2-3-0-0-0-3-2-2-2-2-2-2-2-3-2-2-2-3-0-0-0-3-3-0-0-0-0-0-0-0-3-2-2-2-3-0-0-0-3-2-2-2-2-2-3-4-3-2-2-2-3-0-3-2-2-3-0-0-0-^-0-3-2-2-2-3-0-0-0-0-0-3-2-2-2-3-0-0-0-3-2-2-2-3-2-2-2-2-3-0-0-0-0-0-3-2-3-0-0-0-0-0-0-0-3-2-2-0-0-0-0-0-3-2-2-2-2-2-2-3-0-0-0-3-0-0-0-3-0-0-0-0-3-0-0-0-0-3-3-0-0-0-0-0-0-3-2-2-2-2-3-0-0-0-1-1-1-0-0-0-0-0-0-1-1-1-0-0-0-0-0-0-0-0-0-0-0-0-3-2-2-3-4-0-0-3-1-1-1-3-0-0-0-0-3-1-1-1-3-0-0-0-0-0-0-0-0-0-0-0-0-3-2-2-3-0-0-0-1-1-1-0-0-0-0-0-0-1-1-1-0-0-0-0-3-3-0-0-0-0-0-0-0-4-3-2-2-3-0-0-0-3-0-0-0-3-0-0-0-0-3-0-0-0-0-3-2-3-0-0-0-0-0-0-0-3-2-2-2-2-3-0-0-0-0-0-3-2-3-0-0-0-0-0-0-0-3-2-2-0-0-0-0-0-0-0-3-2-2-2-2-2-3-0-0-0-0-3-2-2-2-3-0-0-0-0-0-3-2-2-3-0-0-0-0-0-0-3-2-2-2-2-2-3-0-0-0-0-0-0-3-2-2-2-3-0-0-0-3-2-2-3-0-0-0-0-0-0-0-0-3-2-2-2-3-0-0-0-0-0-0-0-0-3-2-2-2-3-0-3-2-2-3-0-0-0-0-3-0-0-0-0-0-3-2-3-0-0-0-0-0-3-0-0-0-0-3-2-2-2-3-2-2-3-0-0-0-0-1-1-1-0-0-0-0-0-3-0-0-0-0-0-3-3-3-0-0-0-0-3-2-2-2-2-3-0-0-0-0-3-1-1-1-3-0-0-0-0-0-0-0-0-0-3-1-1-1-1-0-0-0-0-3-2-2-3-4-0-0-0-0-0-1-1-1-0-0-0-0-0-0-0-0-0-3-3-1-1-1-1-3-0-0-0-0-3-2-2-3-0-0-0-0-0-0-3-0-0-0-0-0-3-3-0-0-0-0-3-1-1-1-1-3-3-0-0-0-4-3-2-2-3-0-0-0-0-0-0-0-0-0-0-3-2-2-3-0-0-0-0-1-1-1-1-3-0-0-0-0-3-2-2-2-2-3-0-0"
    Boards[8]="1-0-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-2-2-0-1-1-1-1-1-1-1-1-1-1-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-2-2-0-1-1-1-1-1-1-1-1-1-1-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-2-2-0-1-1-1-1-1-1-1-1-1-1-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-2-2-0-1-1-1-1-1-1-1-1-1-2-0-3-2-0-0-0-0-0-5-1-5-0-0-0-0-0-0-3-3-2-2-0-2-2-2-2-2-2-2-2-2-3-0-3-2-0-0-0-0-0-3-1-1-1-1-0-0-0-0-3-3-2-2-0-3-0-0-0-0-0-0-0-0-0-0-3-2-0-0-0-0-0-3-1-1-1-1-0-0-0-0-3-3-2-2-0-0-3-0-0-5-5-0-0-3-0-0-3-2-0-3-3-3-3-3-1-1-1-1-5-0-0-0-3-3-2-2-0-0-0-3-0-5-5-0-3-0-0-0-3-2-3-3-3-3-3-3-1-1-1-1-1-0-0-0-3-3-2-2-0-0-0-1-3-3-3-3-1-0-0-0-2-2-3-3-3-3-3-3-3-3-3-3-5-0-0-0-3-3-2-2-0-0-0-0-0-0-0-0-0-0-1-1-3-2-3-3-3-3-3-3-3-3-0-0-0-0-0-0-3-3-2-3-1-1-1-0-0-0-0-0-0-1-1-1-3-2-3-3-3-3-3-3-3-3-0-0-0-0-0-0-3-3-2-3-1-1-1-0-2-2-2-2-0-1-1-1-3-2-3-3-3-3-3-3-3-3-0-0-0-0-0-0-3-3-2-3-1-1-1-0-0-0-0-0-0-1-0-0-3-2-3-3-3-3-3-3-3-3-0-0-0-0-0-0-3-3-2-3-0-0-0-0-0-0-0-0-0-0-2-2-3-2-3-3-3-3-3-3-3-0-0-0-0-0-0-0-3-3-2-3-0-0-0-2-2-2-2-2-2-2-0-5-0-0-3-0-0-0-0-0-0-0-0-0-0-0-^-0-0-3-0-5-0-0-0-5-0-5-0-5-0-5-3-5-3-0-0-3-0-0-3-3-3-3-3-3-3-3-0-0-3-0-3-5-3-5-3-5-3-5-3-5-3-5-3-5-3-0-0-0-3-5-5-5-5-5-5-5-5-5-5-3-0-0-3-5-3-5-3-5-3-5-3-5-3-5-3-5-3-0-0-0-5-3-0-0-0-0-0-0-0-0-3-5-0-0-3-5-3-5-3-5-3-5-3-5-3-5-3-5-3-0-0-3-5-0-3-5-5-5-5-5-5-3-0-5-3-0-3-5-3-5-3-5-3-5-3-2-3-5-3-5-3-0-0-3-5-0-5-3-3-3-3-3-3-5-0-5-3-0-3-5-3-5-3-5-3-5-3-2-3-5-3-5-3-0-0-3-5-0-5-3-4-4-4-4-3-5-0-5-3-0-3-5-3-5-3-5-3-5-3-5-3-5-3-5-3-0-0-3-5-0-5-3-4-1-1-4-3-5-0-5-3-0-3-5-3-1-3-5-3-1-3-5-3-1-3-1-3-0-0-3-5-0-5-3-4-1-1-4-3-5-0-5-3-0-3-1-3-5-3-1-3-5-3-1-3-5-3-5-3-0-0-3-5-0-5-3-4-4-4-4-3-5-0-5-3-0-3-5-3-5-3-5-3-5-3-5-3-5-3-5-3-0-0-3-5-0-5-3-3-3-3-3-3-5-0-5-3-0-3-5-3-5-3-5-3-2-3-5-3-5-3-5-3-0-0-3-5-0-3-5-5-5-5-5-5-3-0-5-3-0-3-5-3-5-3-5-3-2-3-5-3-5-3-5-3-0-0-0-5-3-0-0-0-0-0-0-0-0-3-5-0-0-3-5-3-5-3-5-3-5-3-5-3-5-3-5-3-0-0-0-3-5-5-5-5-5-5-5-5-5-5-3-0-0-3-5-3-5-3-5-3-5-3-5-3-5-3-5-3-0-0-3-0-0-3-3-3-3-3-3-3-3-0-0-3-0-3-5-3-5-3-5-3-5-3-5-3-5-0-5-0-0-3-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-0-5-0-5-0-5-0-5-0-5-0-5-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-2-3-3-3-3-3-3-3-3-3-3-3"
    Boards[9]="2-2-2-2-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-0-0-0-0-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-0-0-0-0-0-0-0-0-4-2-2-2-2-4-0-3-0-0-1-2-2-2-2-2-2-2-2-2-0-3-0-0-0-2-2-2-2-0-0-0-3-2-2-2-2-2-2-2-2-2-5-2-2-2-2-2-2-2-2-2-0-3-0-2-2-2-2-2-2-2-3-3-3-2-2-2-2-2-2-2-2-2-5-2-2-2-2-2-2-2-2-2-0-3-5-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-5-2-2-2-2-2-0-0-0-0-1-1-1-5-5-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-5-2-2-2-2-2-0-3-3-3-1-1-1-0-5-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-4-2-2-2-2-2-0-0-0-5-1-1-1-0-5-0-2-2-2-2-2-2-2-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-0-5-0-3-5-0-3-2-2-2-2-2-2-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-0-0-2-2-0-5-0-0-1-1-3-2-2-2-2-2-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-0-5-5-5-1-1-2-2-2-2-2-2-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-0-0-2-2-2-2-2-2-3-3-2-2-2-2-2-2-0-0-0-2-2-2-2-2-3-3-4-3-3-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-2-3-0-0-0-3-2-2-2-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-2-3-0-0-0-3-2-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-2-0-0-^-0-0-2-2-2-0-0-0-0-0-3-2-2-2-2-2-2-2-2-2-2-0-0-0-0-2-2-2-2-2-0-0-0-2-2-2-2-0-0-0-0-0-3-2-2-2-2-0-0-2-2-2-2-2-0-0-0-0-2-2-2-2-2-5-2-2-2-2-2-0-3-1-3-0-3-3-0-0-0-1-0-2-2-2-2-2-0-0-0-0-2-2-2-2-2-5-2-2-2-2-2-0-3-4-3-0-3-3-0-1-1-1-0-2-2-2-2-2-0-0-0-0-2-2-2-2-2-3-2-2-2-2-2-0-3-3-3-0-1-1-0-1-1-1-0-2-2-2-2-2-0-0-0-0-2-2-2-2-2-4-2-2-2-2-2-0-0-0-0-0-3-3-0-1-1-0-0-2-2-2-2-2-0-0-0-0-2-2-2-2-2-3-2-2-2-2-2-0-0-0-0-0-3-3-0-0-0-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-3-3-3-3-1-3-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-3-3-3-3-1-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-0-0-0-0-0-2-2-0-0-0-3-3-0-0-0-0-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-0-3-1-3-0-2-2-0-0-3-4-1-0-0-0-0-2-2-2-2-2-2-2-2-2-3-1-3-2-2-2-2-0-1-1-1-0-2-2-0-0-3-3-3-0-0-0-0-5-5-3-4-3-0-0-0-0-1-0-3-2-2-2-2-0-3-1-3-0-2-2-0-0-3-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-3-3-3-2-2-2-2-0-0-0-0-0-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2"
    Boards[10]="0-0-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-0-1-1-0-0-2-2-0-0-1-1-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-3-0-1-2-0-0-0-2-0-0-1-2-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-3-0-0-0-2-0-0-0-2-0-0-0-2-2-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-3-2-0-0-0-2-0-5-0-2-0-0-0-0-2-2-2-3-0-1-5-0-2-2-2-2-2-2-2-2-2-2-3-2-2-0-0-0-2-0-5-0-2-0-0-0-0-2-2-3-2-0-1-5-0-2-2-2-2-2-2-2-2-2-3-2-2-2-0-5-0-2-0-5-0-2-0-0-0-0-2-3-2-2-0-1-5-0-2-2-2-2-2-2-2-2-3-0-0-0-2-0-5-0-2-0-5-0-2-2-0-0-0-3-2-2-2-0-1-5-0-2-2-2-2-2-2-2-3-0-0-0-0-2-0-5-0-2-0-5-0-0-2-1-0-3-2-2-2-2-0-1-5-0-2-2-2-2-2-2-3-0-1-1-0-0-2-0-5-0-2-0-0-0-1-1-0-3-2-2-2-2-2-0-1-5-0-2-2-2-2-2-3-0-1-2-0-0-0-2-0-5-0-2-0-0-0-0-0-3-2-2-2-2-2-2-0-1-5-0-2-2-2-2-3-0-0-0-2-0-0-0-2-0-0-0-2-2-0-0-0-3-2-2-2-2-2-2-2-0-1-5-0-2-2-2-3-0-0-0-0-2-0-0-0-2-0-0-0-0-3-3-3-3-2-2-2-2-2-2-2-2-0-1-0-0-2-2-3-2-0-0-0-0-2-0-0-0-2-1-0-0-3-3-3-3-2-2-2-2-2-2-2-2-2-0-0-0-0-2-3-2-2-0-0-0-2-2-0-0-1-1-0-0-3-3-3-3-3-3-3-3-3-3-3-3-3-3-0-0-0-0-3-2-2-0-0-0-2-2-2-0-0-0-0-3-3-3-3-2-2-2-2-2-2-2-2-2-3-0-0-^-0-0-3-2-2-0-0-0-2-2-2-2-2-2-3-1-1-1-3-2-3-3-3-3-3-2-2-2-3-0-0-0-0-0-3-2-2-0-0-0-2-2-2-2-2-2-3-1-1-1-3-2-3-1-1-1-3-2-2-2-3-1-3-1-3-1-3-2-2-0-0-0-0-0-0-0-0-0-3-1-1-1-3-2-3-1-1-1-3-2-2-2-2-0-2-0-2-0-2-2-2-0-0-0-0-0-0-0-0-0-3-3-3-3-3-2-3-1-1-1-0-0-0-0-0-0-2-0-2-0-2-2-2-2-2-2-2-2-2-2-2-2-3-0-0-2-2-2-3-3-3-0-2-2-2-2-2-2-2-0-2-0-2-2-2-2-2-2-2-2-2-4-2-2-2-0-0-2-2-2-2-2-2-0-2-2-2-2-2-2-2-0-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-2-2-2-2-2-2-0-2-2-3-3-3-3-3-0-2-0-2-2-2-2-0-0-0-0-0-0-2-4-2-0-0-2-2-2-2-2-2-0-2-2-3-1-1-1-1-0-2-0-2-2-2-2-0-3-3-3-3-0-2-2-2-0-0-2-2-3-3-3-2-0-2-2-3-1-1-1-1-3-2-0-2-2-2-2-0-3-4-4-3-0-2-2-2-0-0-2-2-0-0-1-0-0-2-2-3-1-1-1-1-3-2-0-2-2-2-2-0-3-1-1-3-0-2-2-2-0-0-0-0-0-0-3-2-2-2-2-3-3-3-0-3-3-2-0-2-2-2-2-0-3-1-1-3-0-2-2-2-0-0-0-0-0-0-1-0-0-0-0-4-2-2-0-2-4-0-0-2-2-2-2-0-0-0-0-0-0-2-2-2-0-0-0-0-0-0-3-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-1-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-0-0-0-0-2-2-2-0-0-0-0-0"
    Boards[11]="3-3-3-3-2-2-2-2-2-2-3-1-1-3-2-2-3-3-3-2-3-1-2-2-1-0-3-3-3-3-3-3-0-0-0-0-0-3-0-0-0-0-0-0-0-0-0-0-3-5-3-2-3-2-1-1-2-0-3-5-5-3-0-0-3-3-3-0-0-3-0-0-0-0-2-4-4-2-0-0-3-3-3-2-3-2-1-1-2-0-3-5-5-3-0-3-5-5-3-0-0-3-0-0-0-2-3-3-3-3-2-0-0-0-2-2-3-1-2-2-1-0-3-3-3-3-0-3-5-5-3-3-2-2-0-0-2-2-3-1-1-3-2-2-0-0-2-2-3-0-0-0-0-0-0-0-0-0-0-3-3-3-3-3-3-3-0-2-3-3-3-1-1-3-3-3-2-0-3-3-3-2-2-2-2-2-0-1-2-2-1-3-5-5-3-3-3-1-0-4-3-1-1-4-4-1-1-3-4-0-1-3-3-2-2-2-2-2-0-2-2-2-2-3-5-5-3-3-3-1-0-4-3-1-1-4-4-1-1-3-4-0-1-3-3-2-2-5-2-2-0-2-2-2-2-3-3-3-3-3-3-3-0-2-3-3-3-1-1-3-3-3-2-0-3-3-3-2-2-2-2-2-0-1-2-2-1-3-5-5-3-3-2-2-0-0-2-2-3-1-1-3-2-2-0-0-2-2-3-2-2-2-2-2-0-0-0-0-0-3-5-5-3-3-2-2-0-0-0-2-3-3-3-3-2-0-0-0-2-2-3-2-2-5-2-2-0-1-2-2-1-3-3-3-3-3-2-3-3-3-0-0-2-4-4-2-0-0-0-0-2-2-3-2-2-2-2-2-0-2-1-1-2-3-5-5-3-3-2-3-5-3-0-0-0-0-0-0-0-0-0-0-2-2-3-2-2-2-2-2-0-2-1-1-2-3-5-5-3-3-2-3-3-3-2-2-3-1-1-3-2-3-3-3-2-2-3-2-2-0-0-0-0-1-2-2-1-3-3-3-3-3-2-2-2-2-2-2-3-3-3-3-2-0-0-0-2-2-3-2-0-0-0-3-3-3-3-3-3-3-0-0-0-0-2-2-2-2-2-2-2-3-2-2-2-0-^-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-2-2-2-0-0-0-2-2-2-2-0-0-0-2-2-2-2-0-0-0-0-3-1-3-2-5-2-2-2-2-2-2-2-2-2-0-0-5-0-2-2-2-0-1-0-2-2-2-0-5-0-2-0-3-1-3-2-5-2-2-2-2-2-2-3-3-3-0-2-0-5-0-2-2-0-1-0-2-2-0-5-0-2-2-0-3-1-3-2-5-3-3-3-3-3-3-1-1-3-0-2-2-0-5-0-2-3-1-3-2-0-5-0-2-2-2-0-3-1-3-2-5-4-1-1-1-1-1-1-1-3-0-2-2-2-0-5-0-0-1-0-0-5-0-2-2-2-2-0-3-1-3-2-5-3-1-1-3-3-1-1-1-3-0-2-2-2-2-0-5-0-1-0-5-0-2-2-2-2-2-0-3-1-3-2-5-3-1-1-3-3-1-3-1-3-0-3-0-0-3-0-0-2-1-2-0-0-3-0-0-0-2-0-3-1-3-2-5-3-1-1-3-3-3-3-1-3-0-3-0-1-1-1-1-1-4-1-1-1-1-1-1-0-3-0-3-1-3-3-3-3-1-1-3-5-2-3-1-3-0-3-0-0-3-0-0-2-1-2-0-0-3-0-0-0-2-0-3-1-1-1-3-3-1-1-3-5-2-3-1-3-0-2-2-2-2-0-5-0-1-0-5-0-2-2-2-2-2-0-3-1-1-1-3-3-1-1-3-5-2-3-1-3-0-0-2-2-0-5-0-0-1-0-0-5-0-2-2-2-2-0-3-1-1-1-1-1-1-1-4-5-2-3-1-3-0-0-2-0-5-0-2-3-1-3-2-0-5-0-2-2-2-0-3-3-3-3-3-3-3-3-3-5-2-3-1-3-0-0-0-5-0-2-2-0-1-0-2-2-0-5-0-2-2-0-2-2-2-2-2-2-2-2-2-5-2-3-1-3-0-0-5-0-2-2-2-0-0-0-2-2-2-0-5-0-2-0-2-2-2-2-2-2-2-2-2-5-2-0-0-0-0-0-0-2-2-2-2-3-3-3-2-2-2-2-0-0-2-0-0-0-0-0-0-0-0-0-0-0-0-3-3-3-3-2-2-2-2-2-2-3-3-3-3-2-2-2-2-2-2-3-3-3-3-3-3-3-3-3-3-3-3"
    Boards[12]="2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-2-2-2-2-0-1-1-1-1-0-2-2-2-2-0-2-2-2-2-2-2-2-3-0-0-0-0-0-0-0-0-0-2-2-2-2-0-1-1-1-1-0-2-2-2-2-0-2-2-3-0-1-0-0-0-2-2-2-2-0-0-0-0-0-2-2-2-2-0-1-1-1-1-0-2-2-2-2-1-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-0-2-2-2-2-0-1-1-1-1-0-2-2-2-3-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-0-0-0-0-0-0-2-2-2-2-0-2-2-2-2-2-2-2-4-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-0-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-0-2-2-2-2-0-2-2-2-2-2-2-2-2-3-2-2-2-0-0-0-1-0-0-0-4-2-2-2-2-2-4-0-3-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-2-2-2-0-2-2-2-2-0-2-2-2-2-2-2-2-4-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-1-2-2-2-2-0-0-0-2-2-2-2-3-0-2-4-2-2-2-4-3-0-2-2-2-2-2-2-2-2-2-2-3-2-2-2-2-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-1-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-3-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-^-0-0-0-3-3-0-0-0-3-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-0-0-0-3-2-2-2-2-2-2-2-2-2-2-0-0-0-3-0-0-2-0-0-0-1-0-0-0-0-0-3-3-3-1-3-3-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-1-5-0-0-5-3-0-0-2-0-0-3-2-3-0-3-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-5-3-0-0-2-0-0-0-1-0-0-0-3-2-3-0-3-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-0-0-0-1-5-0-0-5-3-0-0-0-3-2-3-3-3-2-2-2-2-2-2-2-2-2-2-2-0-0-1-5-0-0-5-3-0-0-2-0-0-0-0-0-3-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-3-0-0-2-0-0-0-1-5-0-0-0-0-0-3-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-1-5-0-0-5-3-0-0-2-0-0-0-3-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-5-3-0-0-2-0-0-0-1-5-0-0-0-3-2-2-3-2-2-2-2-2-2-2-2-2-3-3-3-0-0-2-0-0-0-1-5-0-0-5-3-0-0-0-0-3-2-2-0-2-2-2-2-2-2-2-2-3-3-0-0-0-0-0-0-0-5-3-0-0-2-0-0-0-1-0-0-3-2-2-0-2-2-2-2-2-2-3-3-0-1-0-0-0-0-0-0-2-0-0-0-1-5-0-0-5-3-0-0-3-5-0-0-0-0-3-0-0-0-3-0-3-3-0-0-0-0-0-1-0-0-0-5-3-0-0-2-0-0-0-0-3-2-2-0-2-2-2-2-2-2-3-3-2-3-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-2-2-5-2-2-2-2-2-2-2-2-3-3-3-3-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-3-3-3-3-3-3-3-3-3-3-3-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2"
    Boards[13]="2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-5-5-5-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-0-0-1-3-3-1-3-3-1-3-3-1-5-5-5-2-2-2-2-2-2-2-2-2-2-2-2-0-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-5-5-5-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-1-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-0-1-3-3-1-4-2-2-2-3-4-0-2-2-2-2-2-2-2-2-2-2-2-2-4-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-3-2-1-2-2-2-2-2-0-0-0-5-2-2-2-2-2-2-2-2-2-2-2-1-2-2-2-2-2-2-2-2-1-2-3-2-2-2-2-2-4-2-2-0-2-2-2-3-2-2-4-2-2-2-2-2-2-2-2-2-2-2-2-2-3-2-3-2-2-2-2-2-0-2-2-0-2-2-2-0-2-0-1-2-2-2-2-1-2-2-2-2-2-2-2-2-3-2-1-2-2-2-2-3-0-3-0-0-3-2-4-0-0-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-1-2-3-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-0-1-3-3-1-3-3-1-0-0-2-3-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-1-2-2-2-2-2-4-2-2-2-2-2-2-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-0-^-0-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-2-2-2-2-2-2-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-2-5-2-2-2-2-2-2-0-1-0-0-0-2-2-2-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-2-0-3-2-2-2-2-2-0-2-2-2-1-3-2-2-2-2-1-2-2-2-2-3-0-2-4-3-0-0-0-3-0-3-2-2-2-2-2-2-0-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-0-2-2-2-4-2-2-0-2-2-2-2-2-2-2-3-1-3-2-2-0-2-2-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-5-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-5-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-2-1-2-2-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-0-1-0-0-0-0-0-3-2-2-2-2-0-2-2-2-2-2-2-0-2-3-2-2-2-2-2-2-2-2-2-2-2-3-2-2-2-2-0-2-2-2-2-2-0-2-2-2-1-0-0-0-0-2-2-2-2-0-0-0-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-0-2-2-2-2-2-2-0-2-0-0-0-0-0-0-0-2-2-2-2-2-2-2-2-2-2-0-2-2-2-2-2-1-2-2-2-2-2-4-0-0-2-2-2-2-0-0-0-1-0-0-0-0-0-0-0-0-0-0-2-2-2-2-2-0-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-3-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2-2"
    ForcedBoard=-1
    InstructionsPosition=(X=0,Y=682)
    MaxGameSpeed=1.75
    Rings[0]=64
    Rings[1]=56
    Rings[2]=88
    Rings[3]=45
    Rings[4]=88
    Rings[5]=79
    Rings[6]=24
    Rings[7]=61
    Rings[8]=256
    Rings[9]=38
    Rings[10]=48
    Rings[11]=108
    Rings[12]=36
    Rings[13]=13
    RingsHudCoords=(U=864,V=328,UL=70,VL=70)
    RingsHudPosition=(X=1008,Y=24)
    ScreenAspectRatio=AspectRatio16x9
    SpecialStagePosition=(X=0,Y=342)
    SpheresHudCoords=(U=944,V=328,UL=70,VL=70)
    SpheresHudPosition=(X=16,Y=24)
    SquareDistance=128.0
}
