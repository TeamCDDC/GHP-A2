//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Music Info > Info > Actor
//
// Classes based on Info hold only information.
// This class holds information related to music tracks.
//================================================================================
class MusicInfo extends Info
    ClassGroup(SGDK,Invisible)
    hidecategories(Attachment,Debug,Display,Mobile,Physics)
    placeable;


            /**Intro music track for the level.*/ var() SoundCue AmbientIntroTrack;
         /**Loopable music track for the level.*/ var() SoundCue AmbientLoopTrack;
   /**Music track for the Chaos Emerald pickup.*/ var() SoundCue ChaosEmeraldTrack;
    /**Music track for the lack of air warning.*/ var() SoundCue DrowningTrack;
                /**Music track for extra lives.*/ var() SoundCue ExtraLifeTrack;
       /**Music track for the Game Over screen.*/ var() SoundCue GameOverTrack;
/**Music track for the invulnerability powerup.*/ var() SoundCue InvincibleTrack;
    /**Music track for the speed boots powerup.*/ var() SoundCue SpeedBootsTrack;
        /**Loopable music track for super form.*/ var() SoundCue SuperFormTrack;
           /**Music track for the end of level.*/ var() SoundCue VictoryTrack;

    /**If true, upon level load music will start playing.*/ var() bool bStartMusicAtLevelLoad;
/**Music starts playing after this amount of time passes.*/ var() float StartMusicDelayTime;


defaultproperties
{
    Begin Object Name=Sprite
        Sprite=Texture2D'EditorResources.AmbientSoundIcons.S_Ambient_Sound_Simple'
        SpriteCategoryName="Info"
    End Object


    ChaosEmeraldTrack=SoundCue'SonicGDKPackMusic.ChaosEmeraldSoundCue'
    DrowningTrack=SoundCue'SonicGDKPackMusic.DrowningSoundCue'
    ExtraLifeTrack=SoundCue'SonicGDKPackMusic.LifeSoundCue'
    GameOverTrack=SoundCue'SonicGDKPackMusic.GameOverSoundCue'
    InvincibleTrack=SoundCue'SonicGDKPackMusic.InvincibilitySoundCue'
    SpeedBootsTrack=none
    SuperFormTrack=SoundCue'SonicGDKPackMusic.SuperSonicSoundCue'
    VictoryTrack=SoundCue'SonicGDKPackMusic.ActClearSoundCue'

    bStartMusicAtLevelLoad=false
    StartMusicDelayTime=1.0
}
