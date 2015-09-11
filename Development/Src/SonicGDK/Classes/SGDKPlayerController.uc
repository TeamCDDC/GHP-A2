//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Player Controller > UTPlayerController > UDKPlayerController >
//     > GamePlayerController > PlayerController > Controller > Actor
//
// Controllers are non-physical actors that can be attached to a pawn to control
// its actions.
// Controllers take control of a pawn using their Possess() method, and relinquish
// control of the pawn by calling UnPossess().
// Controllers receive notifications for many of the events occuring for the Pawn
// they are controlling. This gives the controller the opportunity to implement
// the behavior in response to this event, intercepting the event and superceding
// the Pawn's default behavior.
// PlayerControllers are used by human players to control pawns.
//================================================================================
class SGDKPlayerController extends UTPlayerController;


/**Encoding of camera view rotation for proper interpolation.*/ var vector ViewX,ViewY,ViewZ;

                      /**If greater than 0, directional movement input is ignored.*/ var byte bIgnoreDirInput;
                        /**If true, forward button/key is being forced to be held.*/ var bool bKeepForward;
 /**Player input control flag; if true, player pressed the SpecialMove button/key.*/ var bool bSpecialMove;
       /**Player input control flag; if true, player released the jump button/key.*/ var bool bUnJump;
/**Player input control flag; if true, player released the SpecialMove button/key.*/ var bool bUnSpecialMove;
       /**Last time fixed look input has been triggered with an analog thumbstick.*/ var float LastFixedLookTime;

    /**If true, player is watching a cinematic sequence.*/ var bool bMatineeMode;
/**Object that holds current camera related information.*/ var CameraInfo CurrentCameraInfo;

           /**If true, backward button/key forces the pawn to
                  crouch when classic movement mode is active.*/ var bool bBackwardDucks;
          /**Percent of acceleration rate due to analog input.*/ var float AnalogAccelPct;
/**Maximum absolute magnitude for basic movement player input.*/ var float MaxPlayerInput;

/**Direction of movement for dodging.*/ var EDoubleClickDir DodgeDirection;

/**Bounce velocity calculated for forced falls.*/ var vector ForcedFallVelocity;

/**Number of Chaos Emeralds that the player has collected.*/ var byte ChaosEmeralds;
                             /**Number of remaining lives.*/ var int Lives;
                                /**Number of score points.*/ var int Score;

      /**End of level Kismet sequence action.*/ var SeqAct_EndGame EndGameAction;
/**Rank obtained with the total score points.*/ var string Rank;
                  /**Ring bonus score points.*/ var int RingBonus;
                  /**Time bonus score points.*/ var int TimeBonus;
               /**Running total score points.*/ var int TotalScore;

/**Field of view angle in degrees used for Special Stage.*/ var float SpecialStageFOV;

        /**If true, player should be able to turn.*/ var bool bBoardAtCrossroads;
                      /**If true, player can turn.*/ var bool bBoardCanTurn;
        /**Stores old value of bBoardRunBackwards.*/ var bool bBoardOldRunBackwards;
          /**If true, player is running backwards.*/ var bool bBoardRunBackwards;
/**Last time movement direction has been reversed.*/ var float BoardLastReverseTime;
             /**Stores the last pressed direction.*/ var float BoardLastStrafe;
 /**Last time the player has turned left or right.*/ var float BoardLastTurnTime;
                         /**Direction of movement.*/ var vector BoardMoveDirection;
        /**Magnitude of the vertical jump impulse.*/ var float BoardMoveJumpZ;
            /**Speed value reachable when running.*/ var float BoardMoveSpeed2D;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    //Hides crosshair.
    bNoCrosshair = true;

    DataLoad();
    StatusLoad();
}

/**
 * Called to retrieve player's actual point of view (POV).
 * @param POVLocation  camera location
 * @param POVRotation  camera rotation
 */
simulated event GetPlayerViewPoint(out vector POVLocation,out rotator POVRotation)
{
    local SGDKPlayerPawn P;
    local float DeltaTime;

    if (IsLocalPlayerController())
        P = SGDKPlayerPawn(CalcViewActor);

    if (LastCameraTimeStamp == WorldInfo.TimeSeconds && CalcViewActor == ViewTarget && CalcViewActor != none &&
        CalcViewActor.Location == CalcViewActorLocation && CalcViewActor.Rotation == CalcViewActorRotation &&
        (P == none || (P.EyeHeight == CalcEyeHeight && P.WalkBob == CalcWalkBob)))
    {
        //Use the cached data.
        POVLocation = CalcViewLocation;
        POVRotation = CalcViewRotation;
    }
    else
    {
        DeltaTime = WorldInfo.TimeSeconds - LastCameraTimeStamp;
        LastCameraTimeStamp = WorldInfo.TimeSeconds;

        if (ViewTarget == none)
            CalcCamera(DeltaTime,POVLocation,POVRotation,FOVAngle);
        else
        {
            if (PlayerCamera != none)
                PlayerCamera.GetCameraViewPoint(POVLocation,POVRotation);
            else
            {
                POVRotation = Rotation;

                ViewTarget.CalcCamera(DeltaTime,POVLocation,POVRotation,FOVAngle);

                if (bFreeCamera)
                    POVRotation = Rotation;
            }

            //Apply view shake if needed.
            POVRotation = Normalize(POVRotation + ShakeRot);
            POVLocation += ShakeOffset >> Rotation;

            if (CameraEffect != none)
                CameraEffect.UpdateLocation(POVLocation,POVRotation,GetFOVAngle());

            //Cache results.
            CalcViewActor = ViewTarget;
            CalcViewActorLocation = ViewTarget.Location;
            CalcViewActorRotation = ViewTarget.Rotation;
            CalcViewLocation = POVLocation;
            CalcViewRotation = POVRotation;

            if (P != none)
            {
                CalcEyeHeight = P.EyeHeight;
                CalcWalkBob = P.WalkBob;
            }
        }
    }
}

/**
 * Called when a matinee director track starts or stops controlling the ViewTarget.
 * @param bControlling  true if matinee director track controls view
 * @param Action        the related Kismet sequence action
 */
event NotifyDirectorControl(bool bControlling,SeqAct_Interp Action)
{
    super.NotifyDirectorControl(bControlling,Action);

    if (bControlling != bMatineeMode)
    {
        if (!bControlling)
            SetMatineeMode(false);
        else
            SetMatineeMode(true);
    }
}

/**
 * Called when the pawn collides with a blocking piece of world geometry.
 * @param HitNormal  the surface normal of the hit actor/level geometry
 * @param WallActor  the hit actor
 * @return           true to prevent hit wall notification on the pawn
 */
event bool NotifyHitWall(vector HitNormal,Actor WallActor)
{
    return !(Pawn != none && Pawn.Health > 0);
}

/**
 * Called when the pawn has landed from a fall.
 * @param HitNormal   the surface normal of the actor/level geometry landed on
 * @param FloorActor  the actor landed on
 * @return            true to prevent landed notification on the pawn
 */
event bool NotifyLanded(vector HitNormal,Actor FloorActor)
{
    //If double click move direction is active...
    if (DoubleClickDir == DCLICK_Active)
    {
        //Flag the variable as done.
        DoubleClickDir = DCLICK_Done;
        ClearDoubleClick();
    }
    else
        //Reset the flag.
        DoubleClickDir = DCLICK_None;

    return false;
}

/**
 * Called when the pawn enters a new physics volume; delegated to states.
 * @param NewVolume  the physics volume in which the pawn is standing in
 */
event NotifyPhysicsVolumeChange(PhysicsVolume NewVolume);

/**
 * Called when the player receives a localized message. Most messages deal with 0 to 2 related PRIs.
 * @param InMessageClass  specifies the message class that should be broadcasted
 * @param MessageSwitch   switch parameter for displaying completely different messages
 * @param RelatedPRI_1    holds information about a player
 * @param RelatedPRI_2    holds information about another player
 * @param AnObject        an optional object for additional information
 */
reliable client event ReceiveLocalizedMessage(class<LocalMessage> InMessageClass,optional int MessageSwitch,
                                              optional PlayerReplicationInfo RelatedPRI_1,
                                              optional PlayerReplicationInfo RelatedPRI_2,optional Object AnObject)
{
    //Disable all unwanted messages.
    if (!ClassIsChildOf(InMessageClass,class'GameMessage') && InMessageClass != class'UTDeathMessage' &&
        InMessageClass != class'UTStartupMessage' && InMessageClass != class'UTTeamGameMessage')
        super.ReceiveLocalizedMessage(InMessageClass,MessageSwitch,RelatedPRI_1,RelatedPRI_2,AnObject);
}

/**
 * Resets the camera mode.
 */
event ResetCameraMode()
{
    //Disabled.
}

/**
 * Called after startup to create an associated camera.
 */
event SpawnPlayerCamera()
{
    if (CameraClass != none && IsLocalPlayerController())
    {
        PlayerCamera = Spawn(CameraClass,self);

        if (PlayerCamera != none)
            PlayerCamera.InitializeFor(self);
    }
}

/**
 * Adds lives to the lives counter.
 * @param LivesAmount  amount of lives to add
 */
function AddLives(int LivesAmount)
{
    Lives = Clamp(Lives + LivesAmount,0,99);
}

/**
 * Adds points to the score counter.
 * @param ScoreAmount  amount of score points to add
 */
function AddScore(int ScoreAmount)
{
    Score = Clamp(Score + ScoreAmount,0,9999999);
}

/**
 * Can the game be paused?
 * @return  true if the game can be paused
 */
function bool CanPauseGame()
{
    return GetHud().CanPauseGame();
}

/**
 * Called to handle jump and special move buttons which are pressed/released.
 */
function CheckJumpOrDuck()
{
    //If pawn is alive...
    if (Pawn != none && Pawn.Health > 0)
    {
        //If movement input controls aren't blocked...
        if (!IsMoveInputIgnored())
        {
            //If jump key/button has been pressed...
            if (bPressedJump)
                //Try to jump.
                Pawn.DoJump(false);
            else
                //If jump key/button has been released...
                if (bUnJump)
                {
                    //Notify pawn.
                    SGDKPlayerPawn(Pawn).Jump(false);

                    bUnJump = false;
                }

            //Try to crouch if pressing duck key/button.
            Pawn.ShouldCrouch(bDuck != 0);

            //If special move key/button has been pressed...
            if (bSpecialMove)
                //Try to perform special move.
                SGDKPlayerPawn(Pawn).SpecialMove(true);
            else
                //If special move key/button has been released...
                if (bUnSpecialMove)
                {
                    //Notify pawn.
                    SGDKPlayerPawn(Pawn).SpecialMove(false);

                    bUnSpecialMove = false;
                }
        }

        //Unset flags.
        bSpecialMove = false;
    }
}

/**
 * Toggles look input on client.
 * @param bIgnore  true to ignore look input
 */
reliable client function ClientIgnoreLookInput(bool bIgnore)
{
    //Disabled.
}

/**
 * Toggles movement input on client.
 * @param bIgnore  true to ignore movement input
 */
reliable client function ClientIgnoreMoveInput(bool bIgnore)
{
    //Disabled.
}

/**
 * Called by the server to synchronize cinematic transitions with the client.
 * @param bInCinematicMode  true if the player is entering cinematic mode
 * @param bAffectsMovement  true to disable movement in cinematic mode
 * @param bAffectsTurning   true to disable turning in cinematic mode
 * @param bAffectsHUD       true if the HUD must be shown/hidden to match the value of bCinematicMode
 */
reliable client function ClientSetCinematicMode(bool bInCinematicMode,bool bAffectsMovement,
                                                bool bAffectsTurning,bool bAffectsHUD)
{
    if (MyHUD != none && bAffectsHUD)
        GetHud().SetVisible(!bCinematicMode);
}

/**
 * Sets the pawn and controller rotations.
 * @param NewRotation   amount of time in seconds passed before unblocking player input controls
 * @param bResetCamera  true to reset pitch rotation of the camera
 */
reliable client function ClientSetRotation(rotator NewRotation,optional bool bResetCamera)
{
    if (Pawn != none)
        SGDKPlayerPawn(Pawn).ForceRotation(NewRotation,true,bResetCamera);
    else
        ForceRotation(NewRotation);
}

/**
 * Inserts the relevant values in the persistent data.
 */
function DataInsert()
{
    local SGDKGameInfo Game;
    local JsonObject Data;
    local string MapName,SavedRank;

    Game = SGDKGameInfo(WorldInfo.Game);
    Data = Game.PersistentData.GetData();
    MapName = Game.GetMapFileName();

    Data.SetIntValue("Emeralds",ChaosEmeralds);

    if (!IsSplitscreenPlayer())
    {
        Data.SetIntValue("Lives",Lives);

        if (Rank == "-" || Rank == "S" || !Data.HasKey(MapName $ ".Rank"))
            Data.SetStringValue(MapName $ ".Rank",Rank);
        else
        {
            SavedRank = Data.GetStringValue(MapName $ ".Rank");

            if (SavedRank != "S" && Rank < SavedRank)
                Data.SetStringValue(MapName $ ".Rank",Rank);
        }

        if (!Data.HasKey(MapName $ ".Score") || TotalScore > Data.GetIntValue(MapName $ ".Score"))
            Data.SetIntValue(MapName $ ".Score",TotalScore);

        if (!Data.HasKey(MapName $ ".Time") || GetHud().ElapsedTime < Data.GetFloatValue(MapName $ ".Time"))
            Data.SetFloatValue(MapName $ ".Time",GetHud().ElapsedTime);

        if (Pawn != none && (!Data.HasKey(MapName $ ".Rings") || Pawn.Health - 1 > Data.GetIntValue(MapName $ ".Rings")))
            Data.SetIntValue(MapName $ ".Rings",Pawn.Health - 1);
    }

    if (!Data.HasKey(MapName $ ".RedRings"))
        Data.SetIntValue(MapName $ ".RedRings",0);

    MapName = "." $ MapName $ ".";

    if (!Data.HasKey("Levels"))
    {
        Data.SetIntValue("Levels",1);
        Data.SetStringValue("Maps",MapName);
    }
    else
        if (InStr(Data.GetStringValue("Maps"),MapName,,true) == INDEX_NONE)
        {
            Data.SetIntValue("Levels",Data.GetIntValue("Levels") + 1);
            Data.SetStringValue("Maps",Data.GetStringValue("Maps") $ MapName);
        }

    Game.PersistentData.InsertData(Data);
}

/**
 * Loads the needed values from the persistent data.
 */
function DataLoad()
{
    local SGDKGameInfo Game;
    local JsonObject Data;

    Game = SGDKGameInfo(WorldInfo.Game);
    Data = Game.PersistentData.GetData();

    if (Data.HasKey("Emeralds"))
        ChaosEmeralds = Data.GetIntValue("Emeralds");

    if (Data.HasKey("Lives"))
        Lives = Max(default.Lives,Data.GetIntValue("Lives"));
}

/**
 * Disables movement player input for a while.
 * @param DisabledInputTime  amount of time in seconds passed before unblocking player input controls
 */
function DisableMoveInput(float DisabledInputTime = 0.0)
{
    if (DisabledInputTime > 0.0)
    {
        //If movement input controls aren't blocked, block them.
        if (!IsMoveInputIgnored())
            IgnoreMoveInput(true);

        //If pawn is alive...
        if (Pawn != none && Pawn.Health > 0)
            //Try to uncrouch.
            Pawn.ShouldCrouch(false);

        //Sets a timer to unblock movement input controls later.
        SetTimer(DisabledInputTime,false,NameOf(DisableMoveInput));
    }
    else
        //If movement input controls are blocked, unblock them.
        if (IsMoveInputIgnored())
            IgnoreMoveInput(false);
}

/**
 * Player wants to perform a left dodge.
 */
exec function DodgeLeft()
{
    //If game isn't paused, movement input controls aren't blocked and pawn is alive, set dodge direction value.
    if (!IsPaused() && !IsMoveInputIgnored() && Pawn != none && Pawn.Health > 0)
        DodgeDirection = DCLICK_Left;
}

/**
 * Player wants to perform a left dodge.
 */
exec function DodgeRight()
{
    //If game isn't paused, movement input controls aren't blocked and pawn is alive, set dodge direction value.
    if (!IsPaused() && !IsMoveInputIgnored() && Pawn != none && Pawn.Health > 0)
        DodgeDirection = DCLICK_Right;
}

/**
 * Player wants to escape the game.
 */
exec function Escape()
{
    if (bMatineeMode && !IsPaused())
        SkipMatinee();
    else
        if (!WorldInfo.IsPlayInEditor())
            GetHud().ShowMenu();
        else
            SGDKGameInfo(WorldInfo.Game).ExitGame();
}

/**
 * Called when returning to the main menu, after OnlineSubsystem game cleanup has completed.
 */
function FinishQuitToMainMenu()
{
    local int PlayerIndex,PlayerCount,i;
    local SGDKGameViewportClient SGVC;

    if (Player != none && LocalPlayer(Player) != none && IsSplitscreenPlayer(PlayerIndex) && PlayerIndex == 0)
    {
        PlayerCount = GetSplitscreenPlayerCount();
        SGVC = SGDKGameViewportClient(LocalPlayer(Player).ViewportClient);

        for (i = 1; i < PlayerCount; i++)
            SGVC.PlayerRemove();
    }

    super.FinishQuitToMainMenu();
}

/**
 * Player wants to look down quickly.
 */
exec function FixedLookDown()
{
    //If game isn't paused and pawn is alive, look down.
    if (!IsPaused() && Pawn != none && Pawn.Health > 0 && PlayerCamera != none)
        GetPlayerCamera().FixedLookDown();
}

/**
 * Player wants to reset pitch view rotation.
 */
exec function FixedLookReset()
{
    //If game isn't paused and pawn is alive, reset accumulated pitch view rotation.
    if (!IsPaused() && Pawn != none && Pawn.Health > 0 && PlayerCamera != none)
        GetPlayerCamera().FixedLookReset();
}

/**
 * Player wants to look up quickly.
 */
exec function FixedLookUp()
{
    //If game isn't paused and pawn is alive, look up.
    if (!IsPaused() && Pawn != none && Pawn.Health > 0 && PlayerCamera != none)
        GetPlayerCamera().FixedLookUp();
}

/**
 * Applies properly a new rotation to this controller.
 * @param NewRotation  desired rotation for this controller
 */
function ForceRotation(rotator NewRotation)
{
    GetAxes(NewRotation,ViewX,ViewY,ViewZ);

    SetRotation(NewRotation);
}

/**
 * Sets a new horizontal field of view angle.
 * @param NewFOV  new horizontal field of view angle in degrees
 */
exec function FOV(float NewFOV)
{
    NewFOV = FClamp(NewFOV,10.0,179.0);

    if (PlayerCamera != none)
        PlayerCamera.SetFOV(NewFOV);
    else
    {
        OnFootDefaultFOV = NewFOV;

        if (Vehicle(Pawn) == none)
            FixFOV();
    }
}

/**
 * Called from GameInfo upon end of the game, used to transition to proper state.
 * @param EndGameFocus  camera should focus on this actor
 * @param bIsWinner     true if this controller is the winner
 */
function GameHasEnded(optional Actor EndGameFocus,optional bool bIsWinner)
{
    IgnoreMoveInput(true);

    GetMusicManager().StopMusic(1.0);
    GetHud().GotoState('EndLevelState');

    SGDKPlayerPawn(Pawn).CancelSuperForms();
    SGDKPlayerPawn(Pawn).DiscardExpiringItems();
    SGDKPlayerPawn(Pawn).VictoryPose();

    GrantScoreBonuses();

    DataInsert();
}

/**
 * Gets the associated HUD object.
 * @return  SGDKHud object
 */
function SGDKHud GetHud()
{
    return SGDKHud(MyHUD);
}

/**
 * Gets the associated MusicManager object.
 * @return  SGDKMusicManager object
 */
function SGDKMusicManager GetMusicManager()
{
    return SGDKMusicManager(MusicManager);
}

/**
 * Gets the associated PlayerCamera object.
 * @return  SGDKPlayerCamera object
 */
function SGDKPlayerCamera GetPlayerCamera()
{
    return SGDKPlayerCamera(PlayerCamera);
}

/**
 * Gets the current pressed direction; only valid while processing movement!
 * @param bIgnoreUp  true if up axis needs to be ignored
 * @param bClassic   true if movement is constrained to 2.5D path
 * @return           normalized vector which faces pressed direction
 */
function vector GetPressedDirection(bool bIgnoreUp = true,bool bClassic = false)
{
    if (!bClassic)
    {
        if (bIgnoreUp)
            //Up axis is ignored.
            return Normal(PlayerInput.aForward * ViewX + PlayerInput.aStrafe * ViewY);
        else
            //Up axis isn't ignored.
            return Normal(PlayerInput.aForward * ViewX + PlayerInput.aStrafe * ViewY + PlayerInput.aUp * ViewZ);
    }
    else
    {
        if (bIgnoreUp)
            //Up axis is ignored.
            return Normal(PlayerInput.aStrafe * ViewY);
        else
            //Up axis isn't ignored.
            return Normal(PlayerInput.aForward * ViewZ + PlayerInput.aStrafe * ViewY);
    }
}

/**
 * Called from a Scaleform menu when a button is pressed.
 * @param ButtonId  name that identifies the button
 */
function GFxButtonPressed(string ButtonId)
{
    switch (ButtonId)
    {
        case "PauseMenu.ExitButton":
            if (!WorldInfo.IsPlayInEditor())
                QuitToMainMenu();
            else
                SGDKGameInfo(WorldInfo.Game).ExitGame();

            break;

        case "PauseMenu.RestartButton":
            RestartLevel();

            break;

        case "PauseMenu.ResumeButton":
            GetHud().TogglePauseMenu();
    }
}

/**
 * Grants bonus score points.
 */
function GrantScoreBonuses()
{
    local float ElapsedTime;
    local int i;

    Rank = "-";
    RingBonus = (Pawn.Health - 1) * EndGameAction.RingBonusFactor;
    TimeBonus = 0;

    ElapsedTime = GetHud().ElapsedTime;

    for (i = 0; i < EndGameAction.TimeBonusData.Length; i++)
        if (ElapsedTime < EndGameAction.TimeBonusData[i].Time)
        {
            TimeBonus = EndGameAction.TimeBonusData[i].Points;

            break;
        }

    TotalScore = Score + RingBonus + TimeBonus;

    for (i = 0; i < 6; i++)
        if (TotalScore >= EndGameAction.RankData[i].Points)
        {
            Rank = EndGameAction.RankData[i].Rank;

            break;
        }
}

/**
 * Called whenever the pawn runs over a new pickup.
 */
function HandlePickup(Inventory Inv)
{
    if (Inv.MessageClass != none)
        ReceiveLocalizedMessage(Inv.MessageClass,,,,Inv.Class);
}

/**
 * Toggles directional movement input; uses stacked state storage.
 * @param bNewDirInput  if true, directional movement input will be ignored
 */
function IgnoreDirInput(bool bNewDirInput)
{
    bIgnoreDirInput = Max(0,bIgnoreDirInput + (bNewDirInput ? 1 : -1));
}

/**
 * Is directional movement input being ignored?
 * @return  true if directional movement input is ignored
 */
function bool IsDirInputIgnored()
{
    return (bIgnoreDirInput > 0);
}

/**
 * Player is forced to run forward for a while.
 * @param DisabledInputTime  amount of time in seconds passed before unforcing player to run forward
 */
function KeepRunning(float DisabledInputTime = 0.0)
{
    if (DisabledInputTime > 0.0)
    {
        //Set keep forward flag.
        bKeepForward = true;

        //If directional movement input controls aren't blocked, block them.
        if (!IsDirInputIgnored())
            IgnoreDirInput(true);

        //Sets a timer to unblock directional movement input controls later.
        SetTimer(DisabledInputTime,false,NameOf(KeepRunning));
    }
    else
    {
        //Set keep forward flag.
        bKeepForward = false;

        //If directional movement input controls are blocked, unblock them.
        if (IsDirInputIgnored())
            IgnoreDirInput(false);

        //Clears a previously set timer.
        ClearTimer(NameOf(KeepRunning));
    }
}

/**
 * Zooms out camera location or switches to next inventory group weapon.
 */
exec function NextWeapon()
{
    if (!IsPaused())
    {
        //If pawn doesn't exist or is a vehicle...
        if (Pawn == none || Vehicle(Pawn) != none)
            //Zoom out camera without saving.
            AdjustCameraScale(false);
        else
            //If pawn has no weapons or is feigning death...
            if (Pawn.Weapon == none || Pawn.IsInState('FeigningDeath'))
                //Zoom out camera.
                ZoomOut();
            else
                //Otherwise change to next inventory weapon.
                if (Pawn.InvManager != none)
                    Pawn.InvManager.NextWeapon();
    }
}

/**
 * Notification from the game that a pawn has been killed.
 * @param Killer       the controller responsible for the damage
 * @param Killed       the controller which owned the killed pawn
 * @param KilledPawn   the killed pawn
 * @param DamageClass  class describing the damage that was done
 */
function NotifyKilled(Controller Killer,Controller Killed,Pawn KilledPawn,class<DamageType> DamageClass)
{
    super.NotifyKilled(Killer,Killed,KilledPawn,DamageClass);

    if (Killed != self && !Killed.bPendingDelete && Pawn != none &&
        Pawn.Health > 0 && SGDKPlayerPawn(KilledPawn) != none)
        Pawn.Suicide();
}

/**
 * Function handler for SeqAct_EndGame Kismet sequence action.
 * @param Action  the related Kismet sequence action
 */
function OnEndGame(SeqAct_EndGame Action)
{
    EndGameAction = Action;

    WorldInfo.Game.EndGame(none,"Triggered");
}

/**
 * Function handler for SeqAct_QuitToMainMenu Kismet sequence action.
 * @param Action  the related Kismet sequence action
 */
function OnQuitToMainMenu(SeqAct_QuitToMainMenu Action)
{
    if (!WorldInfo.IsPlayInEditor())
        QuitToMainMenu();
    else
        SGDKGameInfo(WorldInfo.Game).ExitGame();
}

/**
 * Function handler for SeqAct_SetCameraStyle Kismet sequence action.
 * @param Action  the related Kismet sequence action
 */
function OnSetCameraStyle(SeqAct_SetCameraStyle Action)
{
    local ViewTargetTransitionParams BlendParams;
    local TBlendData MoreBlendParams;

    if (PlayerCamera != none && Action.CamInfo != none && CurrentCameraInfo != Action.CamInfo)
    {
        BlendParams.bLockOutgoing = Action.bLockOutgoing;
        BlendParams.BlendExp = Action.BlendExponent;
        BlendParams.BlendFunction = Action.BlendFunction;
        BlendParams.BlendTime = Action.BlendTime;

        MoreBlendParams.bBlendFOV = Action.bBlendFOV;
        MoreBlendParams.bBlendLocation = Action.bBlendLocation;
        MoreBlendParams.bBlendRotation = Action.bBlendRotation;

        CurrentCameraInfo = Action.CamInfo;

        GetPlayerCamera().SetCameraStyle(Action.CamInfo.GetCameraStyle(),BlendParams,MoreBlendParams);
    }
}

/**
 * Function handler for SeqAct_SetSoundMode Kismet sequence action.
 * @param Action  the related Kismet sequence action
 */
function OnSetSoundMode(SeqAct_SetSoundMode Action)
{
    if (Action.InputLinks[0].bHasImpulse && Action.SoundMode != none)
        SetSoundMode(Action.SoundMode.Name);
    else
        SetSoundMode('Default');
}

/**
 * Function handler for SeqAct_ToggleHUD Kismet sequence action.
 * @param Action  the related Kismet sequence action
 */
simulated function OnToggleHUD(SeqAct_ToggleHUD Action)
{
    if (MyHUD != none)
    {
        if (Action.InputLinks[0].bHasImpulse)
            GetHud().SetVisible(true);
        else
            if (Action.InputLinks[1].bHasImpulse)
                GetHud().SetVisible(false);
            else
                if (Action.InputLinks[2].bHasImpulse)
                    GetHud().SetVisible(!MyHUD.bShowHUD);
    }
}

/**
 * An announcer plays a localized message sound.
 * @param InMessageClass  specifies the message class that should be broadcasted
 * @param MessageSwitch   switch parameter for displaying completely different messages
 * @param RelatedPRI      holds information about a player
 * @param AnObject        an optional object for additional information
 */
function PlayAnnouncement(class<UTLocalMessage> InMessageClass,int MessageSwitch,
                          optional PlayerReplicationInfo RelatedPRI,optional Object AnObject)
{
    //Disabled.
}

/**
 * Every tick, figures out the new acceleration and rotation for pawn; delegated to states.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last tick
 */
function PlayerMove(float DeltaTime);

/**
 * Shows a startup message according to game status.
 * @param StartupStage  byte switch which has the status of game match
 */
reliable client function PlayStartupMessage(byte StartupStage)
{
    //Disabled.
}

/**
 * Zooms in camera location or switches to previous inventory group weapon.
 */
exec function PrevWeapon()
{
    if (!IsPaused())
    {
        //If pawn doesn't exist or is a vehicle...
        if (Pawn == none || Vehicle(Pawn) != none)
            //Zoom in camera without saving.
            AdjustCameraScale(true);
        else
            //If pawn has no weapons or is feigning death...
            if (Pawn.Weapon == none || Pawn.IsInState('FeigningDeath'))
                //Zoom in camera.
                ZoomIn();
            else
                //Otherwise change to previous inventory weapon.
                if (Pawn.InvManager != none)
                    Pawn.InvManager.PrevWeapon();
    }
}

/**
 * Every tick, applies the new acceleration and rotation to pawn; usually overriden by states.
 * @param DeltaTime        contains the amount of time in seconds that has passed since the last tick
 * @param NewAccel         new acceleration to apply to pawn
 * @param DoubleClickMove  holds double-press state of movement keys/buttons
 * @param DeltaRotation    contains the variation of rotation between old and new rotations
 */
function ProcessMove(float DeltaTime,vector NewAccel,eDoubleClickDir DoubleClickMove,rotator DeltaRotation)
{
    if (Pawn != none && Pawn.Acceleration != NewAccel)
        Pawn.Acceleration = NewAccel;
}

/**
 * Processes the player view rotation.
 * Adds delta rotation from player input to current rotation and applies any limits and post-processing.
 * Returns the final rotation to be used for player camera.
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param ViewRotation   current player view rotation
 * @param DeltaRotation  player input added to view rotation
 */
simulated function ProcessViewRotation(float DeltaTime,out rotator ViewRotation,rotator DeltaRotation)
{
    if (PlayerCamera != none)
        //Give the camera a chance to modify view rotation and delta rotation.
        PlayerCamera.ProcessViewRotation(DeltaTime,ViewRotation,DeltaRotation);
    else
        //If pawn exists...
        if (Pawn != none)
            //Pawn does the job.
            Pawn.ProcessViewRotation(DeltaTime,ViewRotation,DeltaRotation);
        else
            //Adds delta rotation and limits view.
            ViewRotation = LimitViewRotation(ViewRotation + DeltaRotation,-16384,16383);
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    CurrentCameraInfo = none;

    super(UDKPlayerController).Reset();

    if (bKeepForward)
        KeepRunning();

    GetHud().GotoState('Auto');

    StatusLoad();

    SpawnPlayerCamera();
}

/**
 * Resets input to defaults.
 */
function ResetPlayerMovementInput()
{
    super.ResetPlayerMovementInput();

    bIgnoreDirInput = default.bIgnoreDirInput;
    bKeepForward = default.bKeepForward;
    bSpecialMove = false;
    DodgeDirection = DCLICK_None;
}

/**
 * Fades the screen pixel colors to a different uniform color.
 * @param FadeColor     target uniform color
 * @param FadeDuration  duration of the fade transition
 */
function ScreenFadeToColor(LinearColor FadeColor,optional float FadeDuration)
{
    GetHud().ScreenFadeToColor(FadeColor,FadeDuration);
}

/**
 * Sets or unsets third person view mode.
 * @param bNewBehindView  sets/unsets third person view mode
 */
function SetBehindView(bool bNewBehindView)
{
    //Disabled.
}

/**
 * Set a new camera mode.
 * @param NewCamMode  new camera mode
 */
function SetCameraMode(name NewCamMode)
{
    //Disabled.
}

/**
 * Sets or unsets Matinee (cinematics) mode.
 * @param bSet  sets/unsets Matinee mode
 */
function SetMatineeMode(bool bSet)
{
    bMatineeMode = bSet;

    if (!bMatineeMode && WorldInfo.Game.bWaitingToStartMatch)
        WorldInfo.Game.StartMatch();
}

/**
 * Tries to pause/unpause the game.
 * @param bPause              true if the player wants to pause the game
 * @param CanUnpauseDelegate  function that determines if unpause can happen
 * @return                    true if the game is paused
 */
function bool SetPause(bool bPause,optional delegate<CanUnpause> CanUnpauseDelegate = CanUnpause)
{
    local bool bResult;

    bResult = super.SetPause(bPause,CanUnpauseDelegate);

    GetMusicManager().Pause(bResult);

    return bResult;
}

/**
 * Skips current matinee.
 * @param Seconds  seconds into the matinee the player must be before the skip will work
 */
exec function SkipMatinee(optional float Seconds)
{
    local Sequence GameSequence;
    local array<SequenceObject> Matinees;
    local SeqAct_Interp Matinee;
    local int i,j,k;
    local bool bBreakWhile;

    GameSequence = WorldInfo.GetGameSequence();

    if (GameSequence != none)
    {
        GameSequence.FindSeqObjectsByClass(class'SeqAct_Interp',true,Matinees);

        while (!bBreakWhile && i < Matinees.Length)
        {
            Matinee = SeqAct_Interp(Matinees[i]);

            if (Matinee.bIsPlaying && Matinee.bIsSkippable && Matinee.InterpData != none &&
                Matinee.GroupInst.Length > 0 && (Matinee.bClientSideOnly || WorldInfo.NetMode != NM_Client))
            {
                for (j = 0; j < Matinee.GroupInst.Length; j++)
                    if (PlayerController(Matinee.GroupInst[j].GroupActor) != none)
                    {
                        for (k = 0; k < Matinee.InterpData.InterpGroups.Length; k++)
                            if (InterpGroupDirector(Matinee.InterpData.InterpGroups[k]) != none)
                            {
                                bBreakWhile = true;

                                if (Matinee.bLooping || Matinee.Position >= Seconds)
                                {
                                    Matinee.SetPosition(Matinee.InterpData.InterpLength,true);

                                    Matinee.Stop();
                                    Matinee.OutputLinks[0].bHasImpulse = true;

                                    if (PlayerController(Matinee.GroupInst[j].GroupActor).bCinematicMode)
                                        WorldInfo.Game.MatineeCancelled();
                                }

                                break;
                            }

                        break;
                    }
            }

            i++;
        }
    }
}

/**
 * The player wants to fire.
 * @param FireMode  mode of fire; primary or secondary
 */
exec function StartFire(optional byte FireMode)
{
    if (Pawn != none && !bCinematicMode && !WorldInfo.bPlayersOnly)
        Pawn.StartFire(FireMode);
}

/**
 * Loads its previously saved status.
 */
function StatusLoad()
{
}

/**
 * Saves its status for checkpoints.
 */
function StatusSave()
{
    GetHud().SaveTime();
}

/**
 * Updates camera and pawn rotations.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last tick
 */
function UpdateRotation(float DeltaTime)
{
    local rotator DeltaRotation,ViewRotation;

    //Calculate delta rotation for new view rotation.
    DeltaRotation.Pitch = PlayerInput.aLookUp;
    DeltaRotation.Yaw = PlayerInput.aTurn;

    //If not in free camera mode...
    if (!bDebugFreeCam)
    {
        //Use current rotation as reference.
        ViewRotation = Rotation;

        //Process view rotation.
        ProcessViewRotation(DeltaTime,ViewRotation,DeltaRotation);

        //Save new view rotation.
        ForceRotation(ViewRotation);

        //Shake camera if needed.
        ViewShake(DeltaTime);

        //If pawn exists and is alive...
        if (Pawn != none && Pawn.Health > 0)
            //Apply new non-shaken rotation to pawn's rotation.
            Pawn.FaceRotation(ViewRotation,DeltaTime);
    }
    else
        //Process view rotation for free camera.
        ProcessViewRotation(DeltaTime,DebugFreeCamRot,DeltaRotation);
}

/**
 * Zooms in camera.
 */
exec function ZoomIn()
{
    //If game isn't paused and view target exists...
    if (!IsPaused() && ViewTarget != none)
    {
        if (PlayerCamera != none)
            GetPlayerCamera().ZoomIn();
        else
            AdjustCameraScale(true);
    }
}

/**
 * Zooms out camera.
 */
exec function ZoomOut()
{
    //If game isn't paused and view target exists...
    if (!IsPaused() && ViewTarget != none)
    {
        if (PlayerCamera != none)
            GetPlayerCamera().ZoomOut();
        else
            AdjustCameraScale(false);
    }
}


//Player is standing, walking, running or falling (Sonic Physics mode is not included).
state PlayerWalking
{
    ignores Bump,HearNoise,SeePlayer;

    event BeginState(name PreviousStateName)
    {
        local Actor PawnBase;
        local vector PawnFloor;

        //If previous state wasn't Sonic Physics mode.
        if (PreviousStateName != 'PlayerSonicPhysics')
        {
            //Set some values.
            DoubleClickDir = DCLICK_None;
            bPressedJump = false;
        }

        //If pawn exists...
        if (Pawn != none)
        {
            PawnBase = Pawn.Base;
            PawnFloor = Pawn.Floor;

            //If pawn was flying (or in Sonic Physics mode) or spidering...
            if (Pawn.Physics == PHYS_Flying || Pawn.Physics == PHYS_Spider)
            {
                //If pawn is near the ground...
                if (SGDKPlayerPawn(Pawn).IsNearGround())
                    //Set walking physics.
                    Pawn.SetPhysics(Pawn.WalkingPhysics);
                else
                {
                    //Call falling event manually; the physics engine won't trigger it.
                    Pawn.Falling();

                    //Apply a little impulse to avoid returning to Sonic Physics mode in the next Tick.
                    Pawn.Velocity.Z -= Pawn.GetGravityZ() * 0.2;

                    //Set falling physics.
                    Pawn.SetPhysics(PHYS_Falling);
                }
            }
            else
                //Epic Games' hack; if pawn isn't falling or ragdollized, set walking physics.
                if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody)
                    Pawn.SetPhysics(Pawn.WalkingPhysics);

            if (Pawn.Physics == PHYS_Walking)
                //Set a valid base for walking physics.
                Pawn.SetBase(PawnBase,PawnFloor);
        }
    }

    event EndState(name NextStateName)
    {
        ClearTimer(NameOf(ForceFall));
    }

    event bool NotifyLanded(vector HitNormal,Actor FloorActor)
    {
        //If world gravity direction is reversed and pawn landed on a walkable floor for PHYS_Walking...
        if (SGDKPlayerPawn(Pawn).bReverseGravity && HitNormal dot vect(0,0,1) > Pawn.WalkableFloorZ)
        {
            //Call hit wall event manually; the physics engine won't trigger it.
            if (!bNotifyFallingHitWall)
            {
                if (!NotifyHitWall(HitNormal,FloorActor))
                    Pawn.HitWall(HitNormal,FloorActor,FloorActor.CollisionComponent);
            }
            else
            {
                NotifyFallingHitWall(HitNormal,FloorActor);
                Pawn.HitWall(HitNormal,FloorActor,FloorActor.CollisionComponent);
            }

            //Calculate a bounce velocity for the pawn.
            ForcedFallVelocity = Pawn.Velocity;
            ForcedFallVelocity.Z *= -0.5;

            //Set falling physics for the pawn because the floor must not be walkable.
            //It's delayed so that it isn't ignored by the native physics engine.
            SetTimer(0.01,false,NameOf(ForceFall));

            //Prevent landed notification on the pawn.
            return true;
        }

        //Call non-state version of the function.
        return global.NotifyLanded(HitNormal,FloorActor);
    }

    event NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
    {
        //If a physics volume is entered and pawn collides with world...
        if (NewVolume.bWaterVolume && Pawn.bCollideWorld)
            //Go to water movement state.
            GotoState(Pawn.WaterMovementState);
    }

    function ForceFall()
    {
        if (Pawn.Physics == Pawn.WalkingPhysics)
        {
            //Set falling physics and a bounce velocity for the pawn.
            Pawn.Velocity = ForcedFallVelocity;
            Pawn.SetPhysics(PHYS_Falling);
        }
    }

    function PlayerMove(float DeltaTime)
    {
        local SGDKPlayerPawn P;
        local vector NewAccel;
        local rotator OldRotation;
        local bool bSaveJump;
        local eDoubleClickDir DoubleClickMove;

        //Set a value.
        GroundPitch = 0;

        if (Pawn != none)
        {
            P = SGDKPlayerPawn(Pawn);

            //Update acceleration.
            if (PlayerCamera != none)
                NewAccel = GetPlayerCamera().GetAccelerationInput(P,SGDKPlayerInput(PlayerInput),ViewX,ViewY,ViewZ);
            else
                NewAccel = P.GetAccelerationInput(SGDKPlayerInput(PlayerInput),ViewX,ViewY,ViewZ);

            if (Pawn.Physics == PHYS_Walking)
            {
                if (!IsZero(Pawn.Velocity))
                {
                    if (!P.IsRolling())
                    {
                        if (IsZero(NewAccel))
                        {
                            NewAccel = Normal(Pawn.Velocity) * Pawn.AccelRate;

                            P.OnGroundState(1);
                        }
                        else
                            if (Normal(NewAccel) dot Normal(Pawn.Velocity) < -0.7)
                            {
                                NewAccel = Normal(Pawn.Velocity) * Pawn.AccelRate;

                                P.OnGroundState(2);
                            }
                            else
                                P.OnGroundState(0);
                    }
                    else
                    {
                        if (!IsZero(NewAccel) && Normal(NewAccel) dot Normal(Pawn.Velocity) < -0.5)
                        {
                            P.OnGroundState(2);

                            NewAccel = vect(0,0,0);
                        }
                        else
                            P.OnGroundState(1);

                        NewAccel = Normal(Pawn.Velocity + NewAccel * (DeltaTime * 10.0) +
                                          P.SlopeDirection * (DeltaTime * 20000.0)) * MaxPlayerInput;
                    }
                }
                else
                    P.OnGroundState(IsZero(NewAccel) ? 1 : 0);
            }
            else
                NewAccel *= Pawn.AirControl;

            DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime / WorldInfo.TimeDilation);

            //Update rotation.
            OldRotation = Rotation;
            UpdateRotation(DeltaTime);

            bDoubleJump = false;

            if (bPressedJump && Pawn.CannotJumpNow())
            {
                bSaveJump = true;
                bPressedJump = false;
            }
            else
                bSaveJump = false;

            ProcessMove(DeltaTime,NewAccel,DoubleClickMove,OldRotation - Rotation);

            bPressedJump = bSaveJump;
        }
        else
            GotoState('Dead');
    }

    function ProcessMove(float DeltaTime,vector NewAccel,eDoubleClickDir DoubleClickMove,rotator DeltaRotation)
    {
        //Set a value.
        if (DoubleClickMove == DCLICK_Active && Pawn.Physics == PHYS_Falling)
            DoubleClickDir = DCLICK_Active;
        else
            //Make pawn dodge if necessary.
            if (DoubleClickMove != DCLICK_None && DoubleClickMove < DCLICK_Active &&
                SGDKPlayerPawn(Pawn).Dodge(DoubleClickMove))
                DoubleClickDir = DCLICK_Active;
            else
                if (DodgeDirection != DCLICK_None && SGDKPlayerPawn(Pawn).Dodge(DodgeDirection))
                    DoubleClickDir = DCLICK_Active;

        //Unset a value.
        DodgeDirection = DCLICK_None;

        //Assign new acceleration and check for jump/duck/special move.
        if (Pawn != none)
        {
            Pawn.Acceleration = NewAccel;
            CheckJumpOrDuck();
        }
    }
}


//Player is in Sonic Physics mode.
state PlayerSonicPhysics
{
    ignores Bump,HearNoise,SeePlayer;

    event BeginState(name PreviousStateName)
    {
        Pawn.AirSpeed = SGDKPlayerPawn(Pawn).GetGroundSpeed();
        Pawn.SetPhysics(PHYS_Flying);
    }

    event EndState(name NextStateName)
    {
        if (Pawn != none)
            Pawn.AirSpeed = Pawn.default.AirSpeed;
    }

    function PlayerMove(float DeltaTime)
    {
        local SGDKPlayerPawn P;
        local vector X,Y,Z,NewAccel;
        local rotator OldRotation;
        local bool bSaveJump;
        local float CurrentSpeed;
        local eDoubleClickDir DoubleClickMove;

        P = SGDKPlayerPawn(Pawn);

        Z = P.GetFloorNormal();
        Y = Normal(Z cross ViewX);
        X = Normal(Y cross Z);

        //Update acceleration.
        if (PlayerCamera != none)
            NewAccel = GetPlayerCamera().GetAccelerationInput(P,SGDKPlayerInput(PlayerInput),X,Y,Z);
        else
            NewAccel = P.GetAccelerationInput(SGDKPlayerInput(PlayerInput),X,Y,Z);

        CurrentSpeed = VSize(Pawn.Velocity);

        if (CurrentSpeed > 0.0)
        {
            if (!P.IsRolling())
            {
                if (IsZero(P.SlopeDirection))
                {
                    if (IsZero(NewAccel))
                    {
                        NewAccel = Normal(Pawn.Velocity) * Pawn.AccelRate;

                        P.OnGroundState(1);
                    }
                    else
                    {
                        if (Normal(NewAccel) dot Normal(Pawn.Velocity) < -0.7)
                        {
                            NewAccel = Normal(Pawn.Velocity) * Pawn.AccelRate;

                            P.OnGroundState(2);
                        }
                        else
                            P.OnGroundState(0);

                        Pawn.Velocity = Normal(Normal(Pawn.Velocity) * (0.1 / DeltaTime) +
                                               Normal(NewAccel)) * CurrentSpeed;
                    }
                }
                else
                {
                    if (IsZero(NewAccel))
                    {
                        NewAccel = ClampLength(Normal(Pawn.Velocity) * Pawn.AccelRate +
                                               P.SlopeDirection * MaxPlayerInput * 1.5,MaxPlayerInput);

                        P.OnGroundState(1);
                    }
                    else
                    {
                        if (Normal(NewAccel) dot Normal(Pawn.Velocity) < -0.7)
                        {
                            NewAccel = ClampLength(Normal(Pawn.Velocity) * Pawn.AccelRate +
                                                   P.SlopeDirection * MaxPlayerInput,MaxPlayerInput);

                            if (Normal(NewAccel) dot P.SlopeDirection < 0.0)
                                P.OnGroundState(2);
                            else
                                P.OnGroundState(0);
                        }
                        else
                        {
                            NewAccel += P.SlopeDirection * Pawn.AccelRate * 3.0 *
                                        (1.0 - (Normal(Pawn.Velocity) dot P.SlopeDirection));
                            NewAccel = ClampLength(NewAccel,MaxPlayerInput);

                            P.OnGroundState(0);
                        }
                    }

                    Pawn.Velocity = Normal(Normal(Pawn.Velocity) * (0.1 / DeltaTime) +
                                           Normal(NewAccel)) * CurrentSpeed;
                }
            }
            else
            {
                if (!IsZero(NewAccel) && Normal(NewAccel) dot Normal(Pawn.Velocity) < -0.5)
                {
                    P.OnGroundState(2);

                    NewAccel = vect(0,0,0);
                }
                else
                    P.OnGroundState(1);

                NewAccel = Normal(Pawn.Velocity + NewAccel * (DeltaTime * 200.0) +
                                  P.SlopeDirection * (DeltaTime * 20000.0)) * MaxPlayerInput;
            }
        }
        else
        {
            if (!IsZero(P.SlopeDirection))
                NewAccel = P.SlopeDirection * MaxPlayerInput;

            P.OnGroundState(IsZero(NewAccel) ? 1 : 0);
        }

        DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime / WorldInfo.TimeDilation);

        //Update rotation.
        OldRotation = Rotation;
        UpdateRotation(DeltaTime);

        bDoubleJump = false;

        if (bPressedJump && Pawn.CannotJumpNow())
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        ProcessMove(DeltaTime,NewAccel,DoubleClickMove,OldRotation - Rotation);

        bPressedJump = bSaveJump;
    }

    function ProcessMove(float DeltaTime,vector NewAccel,eDoubleClickDir DoubleClickMove,rotator DeltaRotation)
    {
        //Make pawn dodge if necessary.
        if (DoubleClickMove != DCLICK_None && DoubleClickMove < DCLICK_Active &&
            SGDKPlayerPawn(Pawn).Dodge(DoubleClickMove))
            DoubleClickDir = DCLICK_Active;
        else
            if (DodgeDirection != DCLICK_None && SGDKPlayerPawn(Pawn).Dodge(DodgeDirection))
                DoubleClickDir = DCLICK_Active;

        //Unset a value.
        DodgeDirection = DCLICK_None;

        //Assign new acceleration and check for jump/duck/special move.
        if (Pawn != none)
        {
            Pawn.Acceleration = NewAccel;
            CheckJumpOrDuck();

            if (Pawn.Physics == PHYS_Falling)
                GotoState(Pawn.LandMovementState);
        }
    }
}


//Player is sticking easily to world geometry.
state PlayerSpidering
{
    ignores Bump,HearNoise,SeePlayer;

    event BeginState(name PreviousStateName)
    {
        bPressedJump = false;
        DoubleClickDir = DCLICK_None;

        Pawn.ShouldCrouch(false);
        Pawn.SetPhysics(PHYS_Spider);

        GroundPitch = 0;
    }

    event EndState(name NextStateName)
    {
        GroundPitch = 0;

        if (Pawn != none)
            Pawn.ShouldCrouch(false);
    }

    function PlayerMove(float DeltaTime)
    {
        local SGDKPlayerPawn P;
        local vector X,Y,Z,NewAccel;
        local rotator OldRotation;
        local bool bSaveJump;

        //Set a value.
        GroundPitch = 0;

        P = SGDKPlayerPawn(Pawn);

        Z = P.GetFloorNormal();
        Y = Normal(Z cross ViewX);
        X = Normal(Y cross Z);

        //Update acceleration.
        if (PlayerCamera != none)
            NewAccel = GetPlayerCamera().GetAccelerationInput(P,SGDKPlayerInput(PlayerInput),X,Y,Z);
        else
            NewAccel = P.GetAccelerationInput(SGDKPlayerInput(PlayerInput),X,Y,Z);

        if (IsZero(NewAccel) || Normal(NewAccel) dot Normal(Pawn.Velocity) < -0.7)
        {
            NewAccel = Normal(Pawn.Velocity) * Pawn.AccelRate;

            P.OnGroundState(2);
        }
        else
            P.OnGroundState(0);

        //Update rotation.
        OldRotation = Rotation;
        UpdateRotation(DeltaTime);

        bDoubleJump = false;

        if (bPressedJump && Pawn.CannotJumpNow())
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        ProcessMove(DeltaTime,NewAccel,DCLICK_None,OldRotation - Rotation);

        bPressedJump = bSaveJump;
    }

    function ProcessMove(float DeltaTime,vector NewAccel,eDoubleClickDir DoubleClickMove,rotator DeltaRotation)
    {
        //Unset a value.
        DodgeDirection = DCLICK_None;

        //Assign new acceleration and check for jump/duck/special move.
        if (Pawn != none)
        {
            Pawn.Acceleration = NewAccel;
            CheckJumpOrDuck();

            if (Pawn.Physics == PHYS_Falling)
                GotoState(Pawn.LandMovementState);
        }
    }
}


//Player is playing a SpecialStageActor.
state PlayerPlayingSpecial
{
    event float GetFOVAngle()
    {
        return SpecialStageFOV;
    }

    simulated event GetPlayerViewPoint(out vector POVLocation,out rotator POVRotation)
    {
        local float CalcViewFOV;

        if (CalcViewActor != none && SGDKGameInfo(WorldInfo.Game).SpecialStage != none)
        {
            if (LastCameraTimeStamp != WorldInfo.TimeSeconds)
            {
                if (SGDKGameInfo(WorldInfo.Game).SpecialStage.CalcCamera(WorldInfo.TimeSeconds - LastCameraTimeStamp,
                                                                         CalcViewLocation,CalcViewRotation,CalcViewFOV))
                {
                    POVLocation = CalcViewLocation;
                    POVRotation = CalcViewRotation;

                    SpecialStageFOV = CalcViewFOV;
                }
                else
                    global.GetPlayerViewPoint(POVLocation,POVRotation);

                LastCameraTimeStamp = WorldInfo.TimeSeconds;
            }
            else
            {
                POVLocation = CalcViewLocation;
                POVRotation = CalcViewRotation;
            }
        }
        else
            global.GetPlayerViewPoint(POVLocation,POVRotation);
    }
}


//Player is playing a BoardSpecialStage.
state PlayerPlayingBoard extends PlayerPlayingSpecial
{
    ignores Bump,HearNoise,SeePlayer;

    event BeginState(name PreviousStateName)
    {
        bPressedJump = false;
        bSpecialMove = false;
        bUnJump = false;
        bUnSpecialMove = false;

        DoubleClickDir = DCLICK_None;
        GroundPitch = 0;

        GetHud().GotoState('SpecialStageState');

        bBoardRunBackwards = false;
        bBoardOldRunBackwards = bBoardRunBackwards;
        BoardLastStrafe = 0.0;
        BoardMoveDirection = vect(0,0,0);
    }

    event EndState(name NextStateName)
    {
        GetHud().GotoState('Auto');
    }

    function CheckJumpOrDuck()
    {
        local SGDKPlayerPawn P;

        //If pawn is alive and movement input controls aren't blocked...
        if (Pawn != none && Pawn.Health > 0 && !IsMoveInputIgnored())
        {
            //If jump key/button has been pressed and pawn is walking...
            if (bPressedJump && Pawn.Physics == PHYS_Walking)
            {
                P = SGDKPlayerPawn(Pawn);

                //Set values.
                P.bDoubleGravity = false;
                P.bReadyToDoubleJump = true;

                //Set falling physics properly.
                P.AerialBoost(Pawn.Velocity + vect(0,0,1) * BoardMoveJumpZ,false,self,'Jump');

                P.PlayJumpingSound();
            }

            //Try to uncrouch.
            Pawn.ShouldCrouch(false);

            //Unset flags.
            bSpecialMove = false;
            bUnJump = false;
            bUnSpecialMove = false;
        }
    }

    function PlayerMove(float DeltaTime)
    {
        local SGDKPlayerPawn P;
        local vector NewAccel;
        local rotator OldRotation;
        local bool bSaveJump;

        //Set a value.
        GroundPitch = 0;

        P = SGDKPlayerPawn(Pawn);

        bBoardCanTurn = (Pawn.Physics == PHYS_Walking && bBoardAtCrossroads &&
                        (Pawn.Touching.Length == 0 || BoardSphereActorBumper(Pawn.Touching[0]) == none));

        if (Pawn.Physics == PHYS_Walking || P.HasJumped())
            BoardMoveSpeed2D = default.BoardMoveSpeed2D;
        else
            BoardMoveSpeed2D = default.BoardMoveSpeed2D * 2.0;

        if (PlayerInput.aForward > 0.0 && IsZero(BoardMoveDirection) && Pawn.Physics == PHYS_Walking)
            BoardMoveDirection = ViewX;

        if (PlayerInput.aTurn != 0.0 && PlayerInput.aStrafe == 0.0)
            PlayerInput.aStrafe = PlayerInput.aTurn;

        if (PlayerInput.aStrafe != 0.0 && WorldInfo.TimeSeconds - BoardLastTurnTime > 0.33)
            BoardLastStrafe = FClamp(PlayerInput.aStrafe * 100.0,-1.0,1.0);

        if (!IsZero(BoardMoveDirection))
        {
            if (bBoardOldRunBackwards != bBoardRunBackwards)
            {
                bBoardOldRunBackwards = bBoardRunBackwards;
                BoardLastReverseTime = WorldInfo.TimeSeconds;

                BoardMoveDirection *= -1;
            }

            if (bBoardRunBackwards && PlayerInput.aForward > 0.0 && Pawn.Physics == PHYS_Walking &&
                WorldInfo.TimeSeconds - BoardLastReverseTime > 0.2)
            {
                bBoardRunBackwards = false;
                bBoardOldRunBackwards = bBoardRunBackwards;
                BoardLastReverseTime = WorldInfo.TimeSeconds;

                BoardMoveDirection *= -1;
            }

            if (bBoardCanTurn && BoardLastStrafe != 0.0)
            {
                BoardLastTurnTime = WorldInfo.TimeSeconds;

                ForceRotation(Normalize(Rotation + MakeRotator(0,16384 * BoardLastStrafe,0)));

                BoardMoveDirection = ViewX;

                if (bBoardRunBackwards)
                    BoardMoveDirection *= -1;

                BoardLastStrafe = 0.0;
            }

            if (WorldInfo.TimeSeconds - BoardLastTurnTime > 0.15)
                NewAccel = BoardMoveDirection * BoardMoveSpeed2D;
        }
        else
            if (BoardLastStrafe != 0.0)
            {
                BoardLastTurnTime = WorldInfo.TimeSeconds;

                ForceRotation(Normalize(Rotation + MakeRotator(0,16384 * BoardLastStrafe,0)));

                BoardLastStrafe = 0.0;
            }

        if (Pawn.Physics == PHYS_Walking)
            P.OnGroundState(0);

        P.ApexGroundSpeed = BoardMoveSpeed2D;
        P.RefAerialSpeed = BoardMoveSpeed2D;

        //Update rotation.
        OldRotation = Rotation;
        UpdateRotation(DeltaTime);

        bDoubleJump = false;

        if (bPressedJump && Pawn.CannotJumpNow())
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        ProcessMove(DeltaTime,NewAccel,DCLICK_None,OldRotation - Rotation);

        bPressedJump = bSaveJump;
    }

    function ProcessMove(float DeltaTime,vector NewAccel,eDoubleClickDir DoubleClickMove,rotator DeltaRotation)
    {
        //Unset a value.
        DodgeDirection = DCLICK_None;

        //Assign new acceleration and check for jump/duck/special move.
        if (Pawn != none)
        {
            Pawn.Velocity.X = NewAccel.X;
            Pawn.Velocity.Y = NewAccel.Y;

            if (Abs(Pawn.Velocity.X) < 10.0)
                Pawn.Velocity.X = 0.0;

            if (Abs(Pawn.Velocity.Y) < 10.0)
                Pawn.Velocity.Y = 0.0;

            Pawn.Acceleration = NewAccel;
            CheckJumpOrDuck();
        }
    }

    simulated function ProcessViewRotation(float DeltaTime,out rotator ViewRotation,rotator DeltaRotation)
    {
        //Disabled.
    }
}


//Player is dead.
state Dead
{
    /**
     * Forces player to respawn if it isn't frozen.
     */
    function DoForcedRespawn()
    {
        ClearTimer(NameOf(DoForcedRespawn));

        if (Lives > 0)
            WorldInfo.Game.ResetLevel();
        else
            GetHud().GotoState('GameOverState');
    }

    /**
     * Finds a good camera view.
     */
    function FindGoodView()
    {
        //Disabled.
    }

    /**
     * Processes the player view rotation.
     * Adds delta rotation from player input to current rotation and applies any limits and post-processing.
     * Returns the final rotation to be used for player camera.
     * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
     * @param ViewRotation   current player view rotation
     * @param DeltaRotation  player input added to view rotation
     */
    simulated function ProcessViewRotation(float DeltaTime,out rotator ViewRotation,rotator DeltaRotation)
    {
        //Disabled.
    }

    /**
     * The player wants to fire.
     * @param FireModeNum  fire mode number
     */
    exec function StartFire(optional byte FireModeNum)
    {
        //Disabled.
    }

Begin:
    GetHud().PauseTime(true);
    GetMusicManager().StopMusic(MinRespawnDelay);

    Sleep(MinRespawnDelay - 1.0);

    if (Lives > 0)
        ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,1.0),1.0);
}


defaultproperties
{
    CameraClass=class'SGDKPlayerCamera' //Class of the PlayerCamera object.
    CheatClass=class'SGDKCheatManager'  //Class of the CheatManager object.
    InputClass=class'SGDKPlayerInput'   //Class of the PlayerInput object.

    MinHitWall=0.0 //Minimum dot product value between HitNormal and Velocity vectors to get HitWall events from the physics; 0.0 equals to 90° angle.

    bBehindView=true    //Third person camera as default camera mode.
    MinRespawnDelay=5.0 //Minimum time before player can respawn after dying.

    bIgnoreLookInput=1 //Ignores look input; uses stacked state storage.
    bIgnoreMoveInput=1 //Ignores movement input; uses stacked state storage.

    bSpecialMove=false
    bUnJump=false
    bUnSpecialMove=false

    bBackwardDucks=true
    MaxPlayerInput=118000.0

    ChaosEmeralds=0
    Lives=3
    Score=0

    SpecialStageFOV=90.0

    BoardMoveJumpZ=384.0
    BoardMoveSpeed2D=400.0
}
