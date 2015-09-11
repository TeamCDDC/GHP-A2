//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Pawn Sonic Modern > PawnSonic > SGDKPlayerPawn > SGDKPawn > UTPawn > UDKPawn >
//     > GamePawn > Pawn > Actor
//
// The Pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
// This class is for Modern Sonic character.
//================================================================================
class PawnSonicModern extends PawnSonic;


defaultproperties
{
    PhysicsData[0]=(RunningAcceleration=1000.0,RunningBrakingStrength=4000.0,RunningGroundFriction=1000.0,RunningReferenceSpeed=2000.0,RunningSlopeBonus=500.0,RunningTopSpeed=4000.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=4000.0,FallingAirAcceleration=750.0, FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=650.0,JumpingTopStrength=4000.0)
    PhysicsData[1]=(RunningAcceleration=750.0, RunningBrakingStrength=3000.0,RunningGroundFriction=750.0, RunningReferenceSpeed=1500.0,RunningSlopeBonus=375.0,RunningTopSpeed=3000.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=3000.0,FallingAirAcceleration=562.5, FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=552.5,JumpingTopStrength=3000.0)
    PhysicsData[2]=(RunningAcceleration=2000.0,RunningBrakingStrength=8000.0,RunningGroundFriction=1500.0,RunningReferenceSpeed=3000.0,RunningSlopeBonus=500.0,RunningTopSpeed=4000.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=4000.0,FallingAirAcceleration=1500.0,FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=800.0,JumpingTopStrength=4000.0)
    PhysicsData[3]=(RunningAcceleration=1500.0,RunningBrakingStrength=6000.0,RunningGroundFriction=1125.0,RunningReferenceSpeed=2250.0,RunningSlopeBonus=375.0,RunningTopSpeed=3000.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=3000.0,FallingAirAcceleration=1125.0,FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=680.0,JumpingTopStrength=3000.0)
    PhysicsData[4]=(RunningAcceleration=2000.0,RunningBrakingStrength=8000.0,RunningGroundFriction=1500.0,RunningReferenceSpeed=3000.0,RunningSlopeBonus=500.0,RunningTopSpeed=4000.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=4000.0,FallingAirAcceleration=1500.0,FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=800.0,JumpingTopStrength=4000.0)
    PhysicsData[5]=(RunningAcceleration=1500.0,RunningBrakingStrength=6000.0,RunningGroundFriction=1125.0,RunningReferenceSpeed=2250.0,RunningSlopeBonus=375.0,RunningTopSpeed=3000.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=3000.0,FallingAirAcceleration=1125.0,FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=680.0,JumpingTopStrength=3000.0)

    bCanSpeedDash=false
    bCanUnRoll=true
    bDropAllRings=false
    bHomingDashNeedsJump=false
    bJumpDashNeedsJump=false
    bLimitRollingJump=false
    bMachDashMagnetizes=true
    bStompNeedsJump=false
    HomingDashRadius=750.0
    HomingDashSpeed=2000.0
    LightDashRadius=400.0
}
