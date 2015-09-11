//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Music Manager > UTMusicManager > Info > Actor
//
// Classes based on Info hold only information.
// This class holds information related to music tracks management.
//================================================================================
class SGDKMusicManager extends UTMusicManager;


  /**Pre-computed MusicVolume/CrossFadeTime DeltaTime multiplier for cross-fading.*/ var float CurrentFadeFactor;
/**This is the tempo (in Beats Per Minute) of the track that is currently playing.*/ var float CurrentTempo;
                                                   /**Last time audio was updated.*/ var float LastAudioTime;
                         /**Music starts playing after this amount of time passes.*/ var float MusicDelayTime;

/**If true, the fading out ambient music track is stopped.*/ var bool bForceStopTrack;
            /**If true, player pawn has super form status.*/ var bool bSuperForm;

/**Pre-computed deltatime multiplier for pitch increase/decrease.*/ var float PitchChangeFactor;
                /**Desired pitch multiplier for all music tracks.*/ var float PitchMultiplier;
        /**Previous music state; reflects which track was active.*/ var EMusicState PreviousState;

             /**Stack of custom music tracks.*/ var array<SoundCue> CustomMusicTracks;
      /**The lack of air warning music track.*/ var SoundCue DrowningMusicTrack;
 /**Music track for the Chaos Emerald pickup.*/ var SoundCue EmeraldMusicTrack;
              /**Music track for extra lives.*/ var SoundCue ExtraLifeMusicTrack;
     /**Music track for the Game Over screen.*/ var SoundCue GameOverMusicTrack;
/**Music track for the invincibility powerup.*/ var SoundCue InvincibleMusicTrack;
  /**Music track for the speed boots powerup.*/ var SoundCue SpeedBootsMusicTrack;
               /**The super form music track.*/ var SoundCue SuperMusicTrack;
         /**Music track for the end of level.*/ var SoundCue VictoryMusicTrack;
               /**An audio-muted music track.*/ var SoundCue VoidMusicTrack;

/**Stores the music for the map.*/ var MusicForAMap MapMusic;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    local bool bError;
    local UTMapInfo MapInformation;
    local MusicInfo MusicInformation;
    local int PlayerIndex;

    LastAudioTime = WorldInfo.AudioTimeSeconds;
    PlayerOwner = UTPlayerController(Owner);

    bError = false;

    foreach AllActors(class'MusicInfo',MusicInformation)
        break;

    if (MusicInformation != none)
    {
        DrowningMusicTrack = MusicInformation.DrowningTrack;
        EmeraldMusicTrack = MusicInformation.ChaosEmeraldTrack;
        ExtraLifeMusicTrack = MusicInformation.ExtraLifeTrack;
        GameOverMusicTrack = MusicInformation.GameOverTrack;
        InvincibleMusicTrack = MusicInformation.InvincibleTrack;
        SpeedBootsMusicTrack = MusicInformation.SpeedBootsTrack;
        SuperMusicTrack = MusicInformation.SuperFormTrack;
        VictoryMusicTrack = MusicInformation.VictoryTrack;

        MusicDelayTime = FMax(0.01,MusicInformation.StartMusicDelayTime);

        MapMusic.Ambient.TheCue = MusicInformation.AmbientLoopTrack;
        MapMusic.Intro.TheCue = MusicInformation.AmbientIntroTrack;
        MapMusic.Tension.TheCue = SuperMusicTrack;
    }
    else
    {
        MapInformation = UTMapInfo(WorldInfo.GetMapInfo());

        if (MapInformation != none && MapInformation.MapMusicInfo != none)
        {
            MapMusic = MapInformation.MapMusicInfo.MapMusic;

            MapMusic.Tension.TheCue = SuperMusicTrack;
        }
        else
            bError = true;
    }

    if (!bError && PlayerOwner.IsSplitscreenPlayer(PlayerIndex) && PlayerIndex > 0)
        bError = true;

    if (!bError)
    {
        if (MapMusic.Ambient.TheCue == none)
            MapMusic.Ambient.TheCue = VoidMusicTrack;

        MapMusic.Action.CrossfadeToMeNumMeasuresDuration = 1;
        MapMusic.Ambient.CrossfadeToMeNumMeasuresDuration = 1;
        MapMusic.Intro.CrossfadeToMeNumMeasuresDuration = 1;
        MapMusic.Suspense.CrossfadeToMeNumMeasuresDuration = 1;
        MapMusic.Tension.CrossfadeToMeNumMeasuresDuration = 1;
        MapMusic.Victory.CrossfadeToMeNumMeasuresDuration = 1;

        if (MusicInformation != none && MusicInformation.bStartMusicAtLevelLoad)
            StartMusic();
    }
    else
        InitialState = 'Disabled';
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    local int i;

    DeltaTime = WorldInfo.AudioTimeSeconds - LastAudioTime;

    if (DeltaTime > 0.0)
    {
        LastAudioTime = WorldInfo.AudioTimeSeconds;

        if (CurrentTrack != none && CurrentTrack.VolumeMultiplier < MusicVolume)
            //Ramp up current track.
            CurrentTrack.VolumeMultiplier = FMin(MusicVolume,
                                                 CurrentTrack.VolumeMultiplier + CurrentFadeFactor * DeltaTime);

        for (i = 0; i < 6; i++)
        {
            //Ramp down other tracks.
            if (MusicTracks[i] != none && MusicTracks[i] != CurrentTrack && MusicTracks[i].VolumeMultiplier > 0.0)
            {
                MusicTracks[i].VolumeMultiplier = MusicTracks[i].VolumeMultiplier - CurrentFadeFactor * DeltaTime;

                if (MusicTracks[i].VolumeMultiplier <= 0.0)
                {
                    MusicTracks[i].VolumeMultiplier = 0.0;

                    if (i > 1)
                        MusicTracks[i].Stop();
                    else
                        if (bForceStopTrack)
                        {
                            bForceStopTrack = false;

                            MusicTracks[i].Stop();
                        }
                }
            }
        }

        LastBeat = int((WorldInfo.AudioTimeSeconds - MusicStartTime) * CurrentTempo / 60.0);

        if (PlayerOwner != none && PlayerOwner.Pawn != none && SGDKPlayerPawn(PlayerOwner.Pawn) != none)
        {
            if (!bSuperForm)
            {
                if (CurrentState != MST_Tension && SGDKPlayerPawn(PlayerOwner.Pawn).bSuperForm)
                {
                    bForceStopTrack = true;
                    bSuperForm = true;

                    if (CustomMusicTracks.Length == 0)
                        ChangeTrack(MST_Tension);
                }
            }
            else
                if (CurrentState != MST_Ambient && !SGDKPlayerPawn(PlayerOwner.Pawn).bSuperForm)
                {
                    bForceStopTrack = true;
                    bSuperForm = false;

                    if (CustomMusicTracks.Length == 0)
                        ChangeTrack(MST_Ambient);
                }
        }

        if (CurrentTrack != none && CurrentTrack.PitchMultiplier != PitchMultiplier)
        {
            if (CurrentTrack.PitchMultiplier < PitchMultiplier)
                CurrentTrack.PitchMultiplier = FMin(CurrentTrack.PitchMultiplier + PitchChangeFactor * DeltaTime,
                                                    PitchMultiplier);
            else
                CurrentTrack.PitchMultiplier = FMax(CurrentTrack.PitchMultiplier + PitchChangeFactor * DeltaTime,
                                                    PitchMultiplier);
        }
    }
}

/**
 * Changes the current music track that is being played.
 * @param NewState  new music state (track of slot to ramp up)
 */
function ChangeTrack(EMusicState NewState)
{
    local AudioComponent NewTrack;

    if (CurrentState != NewState)
    {
        ClearTimer(NameOf(PlayAmbientTrack));

        CurrentState = NewState;

        //Select appropriate track.
        switch (CurrentState)
        {
            case MST_Ambient:
                if (MusicTracks[0] == none) 
                {
                    if (CurrentTrack != none && CurrentTrack.SoundCue == MapMusic.Ambient.TheCue)
                        MusicTracks[0] = CurrentTrack;
                    else
                        MusicTracks[0] = CreateNewTrack(MapMusic.Ambient.TheCue);
                }

                NewTrack = MusicTracks[0];

                CurrentFadeFactor = MusicVolume / MapMusic.Ambient.CrossfadeToMeNumMeasuresDuration;
                CurrentTempo = MapMusic.Tempo;

                break;

            case MST_Tension:
                if (MusicTracks[1] == none) 
                {
                    if (CurrentTrack != none && CurrentTrack.SoundCue == MapMusic.Tension.TheCue)
                        MusicTracks[1] = CurrentTrack;
                    else
                        MusicTracks[1] = CreateNewTrack(MapMusic.Tension.TheCue);
                }

                NewTrack = MusicTracks[1];

                CurrentFadeFactor = MusicVolume / MapMusic.Tension.CrossfadeToMeNumMeasuresDuration;
                CurrentTempo = MapMusic.Tempo;

                break;

            case MST_Suspense:
                if (MusicTracks[2] == none) 
                {
                    if (CurrentTrack != none && CurrentTrack.SoundCue == MapMusic.Suspense.TheCue)
                        MusicTracks[2] = CurrentTrack;
                    else
                        MusicTracks[2] = CreateNewTrack(MapMusic.Suspense.TheCue);
                }

                NewTrack = MusicTracks[2];

                CurrentFadeFactor = MusicVolume / MapMusic.Suspense.CrossfadeToMeNumMeasuresDuration;
                CurrentTempo = MapMusic.Tempo;

                break;

            case MST_Action:
                if (MusicTracks[3] == none) 
                {
                    if (CurrentTrack != none && CurrentTrack.SoundCue == MapMusic.Action.TheCue)
                        MusicTracks[3] = CurrentTrack;
                    else
                        MusicTracks[3] = CreateNewTrack(MapMusic.Action.TheCue);
                }

                NewTrack = MusicTracks[3];

                CurrentFadeFactor = MusicVolume / MapMusic.Action.CrossfadeToMeNumMeasuresDuration;
                CurrentTempo = MapMusic.Tempo;

                break;

            case MST_Victory:
                if (MusicTracks[4] == none) 
                {
                    if (CurrentTrack != none && CurrentTrack.SoundCue == MapMusic.Victory.TheCue)
                        MusicTracks[4] = CurrentTrack;
                    else
                        MusicTracks[4] = CreateNewTrack(MapMusic.Victory.TheCue);
                }

                NewTrack = MusicTracks[4];

                CurrentFadeFactor = MusicVolume / MapMusic.Victory.CrossfadeToMeNumMeasuresDuration;
                CurrentTempo = MapMusic.Tempo;
        }

        if (CurrentTrack == none || CurrentTrack != NewTrack || !CurrentTrack.bWasPlaying)
        {
            CurrentTrack = NewTrack;
            LastBeat = 0;

            if (CurrentTrack != none)
            {
                CurrentTrack.PitchMultiplier = PitchMultiplier;
                CurrentTrack.VolumeMultiplier = 0.0;

                if (!CurrentTrack.IsPlaying())
                    CurrentTrack.Play();
            }

            MusicStartTime = WorldInfo.AudioTimeSeconds;
        }
    }
}

/**
 * Called when the intro music track has completed.
 * @param AC  the completed music track
 */
function IntroFinished(AudioComponent AC)
{
    if (AC == MusicTracks[5] && CurrentTrack == AC && CurrentState == MST_Ambient)
        PlayAmbientTrack();
}

/**
 * Called when gameplay actually starts.
 */
function MatchStarting()
{
    if (CurrentTrack == none && !IsTimerActive(NameOf(StartMusic)))
        SetTimer(MusicDelayTime,false,NameOf(StartMusic));
}

/**
 * Interface for musical events.
 * @param NewEventIndex  identification flag for an event
 */
function MusicEvent(int NewEventIndex)
{
    //Disabled.
}

/**
 * Pauses/unpauses music management.
 * @param bPause  true if the game is paused
 */
function Pause(bool bPause)
{
    local TimerData Timer;

    foreach Timers(Timer)
        PauseTimer(bPause && !WorldInfo.bGameplayFramePause,Timer.FuncName);
}

/**
 * Plays the loopable ambient music track.
 */
function PlayAmbientTrack()
{
    if (MusicTracks[0] == none)
        MusicTracks[0] = CreateNewTrack(MapMusic.Ambient.TheCue);

    if (MusicTracks[0] != none)
    {
        CurrentState = MST_Ambient;
        CurrentTrack = MusicTracks[0];
        LastBeat = 0;

        MusicTracks[0].PitchMultiplier = PitchMultiplier;
        MusicTracks[0].VolumeMultiplier = MusicVolume;
        MusicTracks[0].Play();

        CurrentFadeFactor = MusicVolume / MapMusic.Ambient.CrossfadeToMeNumMeasuresDuration;
        CurrentTempo = MapMusic.Tempo;

        MusicStartTime = WorldInfo.AudioTimeSeconds;
    }
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    local int i;

    super.Reset();

    ClearTimer(NameOf(PlayAmbientTrack));

    if (MusicTracks[5] != none)
        MusicTracks[5].OnAudioFinished = none;

    for (i = 0; i < 6; i++)
        if (MusicTracks[i] != none)
        {
            MusicTracks[i].Stop();
            MusicTracks[i] = none;
        }

    bForceStopTrack = false;
    bSuperForm = false;
    CurrentTrack = none;
    CustomMusicTracks.Length = 0;
    LastActionEventTime = default.LastActionEventTime;

    SetPitch(default.PitchMultiplier,0.0);

    SetTimer(MusicDelayTime,false,NameOf(StartMusic));
}

/**
 * Sets a new pitch multiplier for the current music track.
 * @param NewPitch    the new pitch multiplier
 * @param ChangeTime  time taken to change current pitch multiplier to the new one
 */
function SetPitch(float NewPitch,float ChangeTime)
{
    PitchMultiplier = NewPitch;

    if (CurrentTrack != none)
    {
        if (ChangeTime > 0.0)
            PitchChangeFactor = (PitchMultiplier - CurrentTrack.PitchMultiplier) / ChangeTime;
        else
            CurrentTrack.PitchMultiplier = PitchMultiplier;

        if (IsTimerActive(NameOf(PlayAmbientTrack)) && MusicTracks[5] != none)
            ClearTimer(NameOf(PlayAmbientTrack));
    }
}

/**
 * Starts the intro (or ambient) track.
 */
function StartMusic()
{
    if (MapMusic.Intro.TheCue != none)
    {
        if (MusicTracks[5] == none)
            MusicTracks[5] = CreateNewTrack(MapMusic.Intro.TheCue);

        CurrentState = MST_Ambient;
        CurrentTrack = MusicTracks[5];
        LastBeat = 0;

        if (MusicTracks[5] != none)
        {
            MusicTracks[5].OnAudioFinished = IntroFinished;
            MusicTracks[5].VolumeMultiplier = MusicVolume;
            MusicTracks[5].Play();
        }

        CurrentFadeFactor = MusicVolume / MapMusic.Intro.CrossfadeToMeNumMeasuresDuration;
        CurrentTempo = MapMusic.Tempo;

        SetTimer(MapMusic.Intro.TheCue.Duration,false,NameOf(PlayAmbientTrack));
    }
    else
    {
        if (MusicTracks[0] == none)
            MusicTracks[0] = CreateNewTrack(MapMusic.Ambient.TheCue);

        CurrentState = MST_Ambient;
        CurrentTrack = MusicTracks[0];
        LastBeat = 0;

        if (MusicTracks[0] != none)
        {
            MusicTracks[0].VolumeMultiplier = MusicVolume;
            MusicTracks[0].Play();
        }

        CurrentFadeFactor = MusicVolume / MapMusic.Ambient.CrossfadeToMeNumMeasuresDuration;
        CurrentTempo = MapMusic.Tempo;
    }

    MusicStartTime = WorldInfo.AudioTimeSeconds;
}

/**
 * Starts/plays a music track.
 * @param MusicSoundCue  the sound cue to use
 * @param CrossfadeTime  time taken to fade one source out while fading another source in
 */
function StartMusicTrack(SoundCue MusicSoundCue,float CrossfadeTime)
{
    ClearTimer(NameOf(PlayAmbientTrack));

    if (CustomMusicTracks.Length == 0 || CustomMusicTracks.Find(MusicSoundCue) == INDEX_NONE)
    {
        CustomMusicTracks[CustomMusicTracks.Length] = MusicSoundCue;

        CrossfadeTime = FMax(0.01,CrossfadeTime);
        MusicVolume /= CrossfadeTime;

        if (CurrentState != MST_Suspense)
        {
            MapMusic.Suspense.TheCue = MusicSoundCue;

            if (MusicTracks[2] != none)
            {
                MusicTracks[2].Stop();
                MusicTracks[2] = none;
            }

            ChangeTrack(MST_Suspense);
        }
        else
        {
            MapMusic.Action.TheCue = MusicSoundCue;

            if (MusicTracks[3] != none)
            {
                MusicTracks[3].Stop();
                MusicTracks[3] = none;
            }

            ChangeTrack(MST_Action);
        }

        MusicVolume *= CrossfadeTime;
    }
    else
        if (CurrentTrack != none && CustomMusicTracks[CustomMusicTracks.Length - 1] == MusicSoundCue)
        {
            CurrentTrack.Stop();
            CurrentTrack.Play();

            LastBeat = 0;
            MusicStartTime = WorldInfo.AudioTimeSeconds;
        }
}

/**
 * Stops all music tracks.
 * @param FadeTime  time taken to fade the current music track out
 */
function StopMusic(float FadeTime)
{
    StartMusicTrack(VoidMusicTrack,FadeTime);

    CurrentTrack = none;
    CustomMusicTracks.Length = 0;
}

/**
 * Stops playing a music track.
 * @param MusicSoundCue  the sound cue used for the music track
 * @param CrossfadeTime  time taken to fade one source out while fading another source in
 */
function StopMusicTrack(SoundCue MusicSoundCue,float CrossfadeTime)
{
    if (CustomMusicTracks.Length > 0)
    {
        if (CustomMusicTracks[CustomMusicTracks.Length - 1] == MusicSoundCue)
        {
            CrossfadeTime = FMax(0.01,CrossfadeTime);

            CustomMusicTracks.RemoveItem(MusicSoundCue);

            if (CustomMusicTracks.Length > 0)
            {
                MusicSoundCue = CustomMusicTracks[CustomMusicTracks.Length - 1];

                CustomMusicTracks.RemoveItem(MusicSoundCue);

                StartMusicTrack(MusicSoundCue,CrossfadeTime);
            }
            else
            {
                MusicVolume /= CrossfadeTime;

                if (!bSuperForm)
                    ChangeTrack(MST_Ambient);
                else
                    ChangeTrack(MST_Tension);

                MusicVolume *= CrossfadeTime;
            }
        }
        else
            CustomMusicTracks.RemoveItem(MusicSoundCue);
    }
}


//The music manager is disabled.
state Disabled
{
    event Tick(float DeltaTime)
    {
    }

    function ChangeTrack(EMusicState NewState)
    {
    }

    function MatchStarting()
    {
    }

    function Reset()
    {
    }

    function StartMusic()
    {
    }

    function StartMusicTrack(SoundCue MusicSoundCue,float CrossfadeTime)
    {
    }

    function StopMusicTrack(SoundCue MusicSoundCue,float CrossfadeTime)
    {
    }
}


defaultproperties
{
    bAlwaysTick=true //Updated even when the game is paused.

    bForceStopTrack=false
    bSuperForm=false
    DrowningMusicTrack=SoundCue'SonicGDKPackMusic.DrowningSoundCue'
    EmeraldMusicTrack=SoundCue'SonicGDKPackMusic.ChaosEmeraldSoundCue'
    ExtraLifeMusicTrack=SoundCue'SonicGDKPackMusic.LifeSoundCue'
    GameOverMusicTrack=SoundCue'SonicGDKPackMusic.GameOverSoundCue'
    InvincibleMusicTrack=SoundCue'SonicGDKPackMusic.InvincibilitySoundCue'
    MusicDelayTime=1.0
    PitchMultiplier=1.0
    SpeedBootsMusicTrack=none
    SuperMusicTrack=SoundCue'SonicGDKPackMusic.SuperSonicSoundCue'
    VictoryMusicTrack=SoundCue'SonicGDKPackMusic.ActClearSoundCue'
    VoidMusicTrack=SoundCue'SonicGDKPackMusic.VoidSoundCue'
}
