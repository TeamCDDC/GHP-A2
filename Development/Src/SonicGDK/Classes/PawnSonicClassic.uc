//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Pawn Sonic Classic > PawnSonic > SGDKPlayerPawn > SGDKPawn > UTPawn > UDKPawn >
//     > GamePawn > Pawn > Actor
//
// The Pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
// This class is for Classic Sonic character.
//================================================================================
class PawnSonicClassic extends PawnSonic;


defaultproperties
{
    PhysicsData[0]=(RunningAcceleration=400.0, RunningBrakingStrength=4000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=800.0, RunningSlopeBonus=600.0,RunningTopSpeed=1600.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=360.0,FallingGravityAccel=520.0,FallingReferenceSpeed=800.0,JumpingNormalStrength=640.0,JumpingTopStrength=960.0)
    PhysicsData[1]=(RunningAcceleration=200.0, RunningBrakingStrength=2000.0,RunningGroundFriction=200.0,RunningReferenceSpeed=400.0, RunningSlopeBonus=600.0,RunningTopSpeed=1600.0,RollingBrakingStrength=1500.0,RollingGroundFriction=100.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=180.0,FallingGravityAccel=150.0,FallingReferenceSpeed=400.0,JumpingNormalStrength=430.0,JumpingTopStrength=960.0)
    PhysicsData[2]=(RunningAcceleration=1600.0,RunningBrakingStrength=8000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=1350.0,RunningSlopeBonus=600.0,RunningTopSpeed=2500.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=720.0,FallingGravityAccel=520.0,FallingReferenceSpeed=800.0,JumpingNormalStrength=800.0,JumpingTopStrength=1200.0)
    PhysicsData[3]=(RunningAcceleration=800.0, RunningBrakingStrength=4000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=700.0, RunningSlopeBonus=600.0,RunningTopSpeed=2500.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=360.0,FallingGravityAccel=150.0,FallingReferenceSpeed=700.0,JumpingNormalStrength=540.0,JumpingTopStrength=1200.0)
    PhysicsData[4]=(RunningAcceleration=1600.0,RunningBrakingStrength=8000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=1350.0,RunningSlopeBonus=600.0,RunningTopSpeed=2500.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=720.0,FallingGravityAccel=520.0,FallingReferenceSpeed=800.0,JumpingNormalStrength=800.0,JumpingTopStrength=1200.0)
    PhysicsData[5]=(RunningAcceleration=800.0, RunningBrakingStrength=4000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=700.0, RunningSlopeBonus=600.0,RunningTopSpeed=2500.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=360.0,FallingGravityAccel=150.0,FallingReferenceSpeed=700.0,JumpingNormalStrength=540.0,JumpingTopStrength=1200.0)

    bCanHomingDash=false
    bCanJumpDash=false
    bCanLightDash=false
    bCanMachDash=false
    bCanQuickStep=false
    bCanSpeedDash=false
    bCanStomp=false
    bClassicSlopes=true
    bClassicSpinDash=true
    AdhesionPct=0.8
    AerialActionsJump.Empty
    AerialActionsJump[0]=SA_ShieldMove
    AerialActionsJump[1]=SA_SuperTransform
    AerialActionsSpecialMove.Empty
    AerialActionsSpecialMove[0]=SA_ShieldMove
    AerialActionsSpecialMove[1]=SA_SuperTransform
    AirDragFactor=0.98
    BubbleBounceFactor=1.15
    BubbleSpeedBoost=800.0
    FlameGravityScale=1.0
    FlameHomingRadius=0.0
    FlameSpeedBoost=1000.0
    FootstepDefaultSound=none
    FootstepSounds.Empty
    JumpingSound=SoundCue'SonicGDKPackSounds.ClassicJumpSoundCue'
    LandingDefaultSound=none
    LandingSounds.Empty
    MagneticRingsRadius=120.0
    MagneticSpeedBoost=540.0
    MaxJumpImpulseTime=0.15
    MinRollingSpeed=100.0
    RollingSound=SoundCue'SonicGDKPackSounds.ClassicRollSoundCue'
    SkiddingDefaultSound=SoundCue'SonicGDKPackSounds.ClassicSkiddingSoundCue'
    SkiddingSounds.Empty
    SpinDashChargeDefaultSound=SoundCue'SonicGDKPackSounds.ClassicSpinDashChargeSoundCue'
    SpinDashChargeSounds.Empty
    SpinDashDecreaseTime=0.2
    SpinDashReleaseSound=SoundCue'SonicGDKPackSounds.ClassicSpinDashReleaseSoundCue'
    SpinDashSpeedPct=0.66
}
