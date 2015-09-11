//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Pawn Tails > SGDKPlayerPawn > SGDKPawn > UTPawn > UDKPawn > GamePawn > Pawn >
//     > Actor
//
// The Pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
// This class is for Tails character.
//================================================================================
class PawnTails extends SGDKPlayerPawn
    placeable;


defaultproperties
{
    Begin Object Name=WPawnSkeletalMeshComponent
        AnimSets[0]=AnimSet'SonicGDKPackSkeletalMeshes.Animation.SonicAnimSet'
        AnimTreeTemplate=AnimTree'SonicGDKPackSkeletalMeshes.Animation.SonicAnimTree'
        PhysicsAsset=PhysicsAsset'SonicGDKPackSkeletalMeshes.PhysicsAssets.SonicPhysicsAsset'
        SkeletalMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.SonicSkeletalMesh'
        Scale=1.0
    End Object
    Mesh=WPawnSkeletalMeshComponent
    VisibleMesh=WPawnSkeletalMeshComponent


    PhysicsData[0]=(RunningAcceleration=500.0, RunningBrakingStrength=3250.0,RunningGroundFriction=500.0,RunningReferenceSpeed=1300.0,RunningSlopeBonus=325.0, RunningTopSpeed=2000.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=2500.0,FallingAirAcceleration=500.0, FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=650.0,JumpingTopStrength=1100.0)
    PhysicsData[1]=(RunningAcceleration=375.0, RunningBrakingStrength=2437.5,RunningGroundFriction=375.0,RunningReferenceSpeed=975.0, RunningSlopeBonus=243.75,RunningTopSpeed=1500.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=1875.0,FallingAirAcceleration=375.0, FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=552.5,JumpingTopStrength=935.0)
    PhysicsData[2]=(RunningAcceleration=1000.0,RunningBrakingStrength=6500.0,RunningGroundFriction=750.0,RunningReferenceSpeed=1700.0,RunningSlopeBonus=325.0, RunningTopSpeed=2300.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=2500.0,FallingAirAcceleration=1000.0,FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=800.0,JumpingTopStrength=1100.0)
    PhysicsData[3]=(RunningAcceleration=750.0, RunningBrakingStrength=4875.0,RunningGroundFriction=562.5,RunningReferenceSpeed=1275.0,RunningSlopeBonus=243.75,RunningTopSpeed=1725.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=1875.0,FallingAirAcceleration=750.0, FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=680.0,JumpingTopStrength=935.0)
    PhysicsData[4]=(RunningAcceleration=1000.0,RunningBrakingStrength=6500.0,RunningGroundFriction=750.0,RunningReferenceSpeed=1700.0,RunningSlopeBonus=325.0, RunningTopSpeed=2300.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=2500.0,FallingAirAcceleration=1000.0,FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=800.0,JumpingTopStrength=1100.0)
    PhysicsData[5]=(RunningAcceleration=750.0, RunningBrakingStrength=4875.0,RunningGroundFriction=562.5,RunningReferenceSpeed=1275.0,RunningSlopeBonus=243.75,RunningTopSpeed=1725.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=1875.0,FallingAirAcceleration=750.0, FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=680.0,JumpingTopStrength=935.0)

    FamilyInfoClass=class'FamilyInfoTails'
    MeshDuckingOffset=0.0
    SuperAnimSet=none
    SuperLightBrightness=2.5
    HyperLightBrightness=1.5
    SuperLightColor=(R=255,G=255,B=0)
    HyperLightColor=(R=255,G=255,B=255)
    SuperParticleSystem=none
    HyperParticleSystem=ParticleSystem'SonicGDKPackParticles.Particles.HyperParticleSystem'
    SuperSkeletalMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.SuperSonicSkeletalMesh'
    HyperSkeletalMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.HyperSonicSkeletalMesh'

    AerialActionsJump.Empty
    AerialActionsJump[0]=SA_CharacterMove
    AerialActionsSpecialMove.Empty
    AerialActionsSpecialMove[0]=SA_SuperTransform
    AerialActionsSpecialMove[1]=SA_CharacterMove
}
