//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action End Game > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action ends the game level.
//================================================================================
class SeqAct_EndGame extends SequenceAction;


/**How much time the screen takes to fade to white.*/ var() float ScreenFadeDurationTime;

/**Name of the map to show.*/ var() string MapName;

/**Ring bonus score points are calculated with this factor.*/ var() int RingBonusFactor;

struct TTimeBonusData
{
/**Amount of points granted if the clock reads a value less than the associated time.*/ var() int Points;
                                                       /**Associated time in seconds.*/ var() float Time;
};
/**Time bonus score points are calculated with this data.*/ var() array<TTimeBonusData> TimeBonusData;

struct TRankData
{
/**Minimum number of score points needed to obtain the rank.*/ var() int Points;
                                  /**Identifier of the rank.*/ var() string Rank;
};
/**Ranks are obtained according to this data.*/ var() TRankData RankData[6];

      /**Victory music starts after this time passes.*/ var() float Reward1DelayTime;
 /**First reward is displayed after this time passes.*/ var() float Reward2DelayTime;
/**Second reward is displayed after this time passes.*/ var() float Reward3DelayTime;
     /**Count sequence starts after this time passes.*/ var() float Reward4DelayTime;
       /**Count sequence ends after this time passes.*/ var() float Reward5DelayTime;
         /**Rank is displayed after this time passes.*/ var() float Reward6DelayTime;

 /**The first sound to play while rewarding.*/ var() SoundCue Reward1Sound;
/**The second sound to play while rewarding.*/ var() SoundCue Reward2Sound;
 /**The third sound to play while rewarding.*/ var() SoundCue Reward3Sound;
/**The fourth sound to play while rewarding.*/ var() SoundCue Reward4Sound;


defaultproperties
{
    ObjCategory="SGDK" //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="End Game" //Text label that describes this object.

    MapName="new level"
    RankData[0]=(Points=40000,Rank="S")
    RankData[1]=(Points=20000,Rank="A")
    RankData[2]=(Points=10000,Rank="B")
    RankData[3]=(Points=5000, Rank="C")
    RankData[4]=(Points=2000, Rank="D")
    RankData[5]=(Points=0,    Rank="E")
    Reward1DelayTime=0.5
    Reward1Sound=SoundCue'SonicGDKPackSounds.EndLevel1SoundCue'
    Reward2DelayTime=2.5
    Reward2Sound=SoundCue'SonicGDKPackSounds.EndLevel2SoundCue'
    Reward3DelayTime=0.5
    Reward3Sound=SoundCue'SonicGDKPackSounds.EndLevel3SoundCue'
    Reward4DelayTime=1.0
    Reward4Sound=SoundCue'SonicGDKPackSounds.EndLevel4SoundCue'
    Reward5DelayTime=3.0
    Reward6DelayTime=2.0
    RingBonusFactor=100
    ScreenFadeDurationTime=1.0
    TimeBonusData.Add((Points=50000,Time=60.0))
    TimeBonusData.Add((Points=10000,Time=90.0))
    TimeBonusData.Add((Points=5000, Time=120.0))
    TimeBonusData.Add((Points=4000, Time=150.0))
    TimeBonusData.Add((Points=2000, Time=180.0))
    TimeBonusData.Add((Points=1000, Time=210.0))
}
