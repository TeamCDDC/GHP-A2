//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Pawn Sonic Reimagined > PawnSonic > SGDKPlayerPawn > SGDKPawn > UTPawn > UDKPawn >
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
class PawnSonicReimagined extends PawnSonic;


defaultproperties
{
    PhysicsData[0]=(RunningAcceleration=600.0, RunningBrakingStrength=3000.0,RunningGroundFriction=1000.0,RunningReferenceSpeed=1800.0, RunningSlopeBonus=1600.0,RunningTopSpeed=2600.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=2000.0,RollingSlopeUpBonus=2000.0,RollingTopSpeed=5000.0,FallingAirAcceleration=600.0,FallingGravityAccel=520.0,FallingReferenceSpeed=800.0,JumpingNormalStrength=640.0,JumpingTopStrength=960.0)
    PhysicsData[1]=(RunningAcceleration=200.0, RunningBrakingStrength=2000.0,RunningGroundFriction=200.0,RunningReferenceSpeed=400.0, RunningSlopeBonus=600.0,RunningTopSpeed=800.0,RollingBrakingStrength=1500.0,RollingGroundFriction=100.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=180.0,FallingGravityAccel=150.0,FallingReferenceSpeed=200.0,JumpingNormalStrength=430.0,JumpingTopStrength=960.0)
    PhysicsData[2]=(RunningAcceleration=1600.0,RunningBrakingStrength=8000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=3200.0,RunningSlopeBonus=1000.0,RunningTopSpeed=5000.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=7000.0,FallingAirAcceleration=720.0,FallingGravityAccel=520.0,FallingReferenceSpeed=800.0,JumpingNormalStrength=800.0,JumpingTopStrength=1200.0)
    PhysicsData[3]=(RunningAcceleration=800.0, RunningBrakingStrength=4000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=700.0, RunningSlopeBonus=600.0,RunningTopSpeed=2500.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=360.0,FallingGravityAccel=150.0,FallingReferenceSpeed=700.0,JumpingNormalStrength=540.0,JumpingTopStrength=1200.0)
    PhysicsData[4]=(RunningAcceleration=1600.0,RunningBrakingStrength=8000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=1350.0,RunningSlopeBonus=600.0,RunningTopSpeed=2500.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=720.0,FallingGravityAccel=520.0,FallingReferenceSpeed=800.0,JumpingNormalStrength=800.0,JumpingTopStrength=1200.0)
    PhysicsData[5]=(RunningAcceleration=800.0, RunningBrakingStrength=4000.0,RunningGroundFriction=400.0,RunningReferenceSpeed=700.0, RunningSlopeBonus=600.0,RunningTopSpeed=2500.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=1400.0,RollingSlopeUpBonus=900.0,RollingTopSpeed=2500.0,FallingAirAcceleration=360.0,FallingGravityAccel=150.0,FallingReferenceSpeed=700.0,JumpingNormalStrength=540.0,JumpingTopStrength=1200.0)
	
	PhysicsData[6]=(RunningAcceleration=1000.0, RunningBrakingStrength=4000.0,RunningGroundFriction=800.0,RunningReferenceSpeed=6000.0, RunningSlopeBonus=1200.0,RunningTopSpeed=8000.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=2000.0,RollingSlopeUpBonus=2000.0,RollingTopSpeed=10000.0,FallingAirAcceleration=1600.0,FallingGravityAccel=520.0,FallingReferenceSpeed=800.0,JumpingNormalStrength=720.0,JumpingTopStrength=1200.0)
	PhysicsData[7]=(RunningAcceleration=1600.0, RunningBrakingStrength=4000.0,RunningGroundFriction=800.0,RunningReferenceSpeed=8000.0, RunningSlopeBonus=1600.0,RunningTopSpeed=10000.0,RollingBrakingStrength=1500.0,RollingGroundFriction=200.0,RollingSlopeDownBonus=2500.0,RollingSlopeUpBonus=2000.0,RollingTopSpeed=15000.0,FallingAirAcceleration=1600.0,FallingGravityAccel=520.0,FallingReferenceSpeed=800.0,JumpingNormalStrength=800.0,JumpingTopStrength=1400.0)
	
    bCanHomingDash=true
    bCanJumpDash=true
    bCanLightDash=true
    bCanMachDash=false
    bCanQuickStep=false
    bCanSpeedDash=false
    bCanStomp=true
    bClassicSlopes=true
    bClassicSpinDash=false
	bCanUnRoll=true
	bStompNeedsJump=false
	
    AdhesionPct=0.5
    //AerialActionsJump.Empty
    //AerialActionsJump[0]=SA_ShieldMove
    AerialActionsJump[1]=SA_SuperTransform
    AerialActionsSpecialMove.Empty
    AerialActionsSpecialMove[0]=SA_ShieldMove
    AerialActionsSpecialMove[1]=SA_SuperTransform
    AirDragFactor=1
    BubbleBounceFactor=2.0
    BubbleSpeedBoost=800.0
    FlameGravityScale=1.0
    FlameHomingRadius=0.0
    FlameSpeedBoost=2500.0
    FootstepDefaultSound=SoundCue'A_Character_Footsteps.Footsteps.A_Character_Footstep_DefaultCue'
    
    
    JumpDashDurationTime=0.1
    JumpDashSpeed=1000.0
	HomingDashRadius=1200.0
    HomingDashSpeed=5000.0
    LandingDefaultSound=none
    LandingSounds.Empty
    MagneticRingsRadius=120.0
    MagneticSpeedBoost=800.0
    MaxJumpImpulseTime=0.15
    MinRollingSpeed=500.0
	MaxFallSpeed=100000.0
	StompSpeed = 4000.0
	MachStateStartThreshold = 2600
	MachStateMinThreshold = 2000
	
	JumpingSound=SoundCue'SonicGDKPackSounds.ModernJumpSoundCue'
	JumpDashSound=SoundCue'SonicGDKPackSounds.HomingDashSoundCue'
    HomingDashSound=SoundCue'SonicGDKPackSounds.HomingDashSoundCue'
    HomingLockOnSound=SoundCue'SonicGDKPackSounds.LockOnSoundCue'
    LightDashSound=none
    MachDashASound=SoundCue'SonicGDKPackSounds.SpeedDashSoundCue'
    MachDashBSound=SoundCue'SonicGDKPackSounds.MachDashSoundCue'
    QuickStepSound=SoundCue'SonicGDKPackSounds.QuickStepSoundCue'
    StompASound=SoundCue'SonicGDKPackSounds.StompSoundCue'
    StompBSound=SoundCue'SonicGDKPackSounds.StompLandCue'
	RollingSound=SoundCue'SonicGDKPackSounds.ModernRollSoundCue'
    SkiddingDefaultSound=SoundCue'SonicGDKPackSounds.ClassicSkiddingSoundCue'
	SpinDashChargeDefaultSound=SoundCue'SonicGDKPackSounds.ClassicSpinDashChargeSoundCue'
	SpinDashReleaseSound=SoundCue'SonicGDKPackSounds.ModernSpinDashReleaseSoundCue'
	
	bDropAllRings=true

	 bLimitRollingJump=true

	bSmoothRotation=true
    SmoothRotationRate=100.0
 
    SpinDashDecreaseTime=0.2
    
    SpinDashSpeedPct=0.5
	
	
	
}
event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

	`Log(CurrentSpeed);
	
if (!bIsMachState && CurrentSpeed >= MachStateStartThreshold && SpecialMoveId == 0 && IsTouchingGround())
{
  bIsMachState=true;
  
  
  ResetPhysicsValues();
  
   if (MachDashParticles != none)
                {
                    MachStateEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                    MachStateEmitter.SetTemplate(MachDashParticles,false);
                    MachStateEmitter.SetVectorParameter('ColorParameter',ColorVectorParameter);

                    AttachToRoot(MachStateEmitter);
                }

	PlayMachDashSound();
	
	PlaySound(MachDashASound);
	
	//Start Animation
	if(!bSuperForm)
		StartAnimation(MachStateAnimation,10.0,0.0,0.25,true,true);
	
	if (IsTimerActive(NameOf(PlayMachDashSound)))
		ClearTimer(NameOf(PlayMachDashSound));
	
				
}
if ((bIsMachState && CurrentSpeed < MachStateMinThreshold) ||(bIsMachState && SpecialMoveId > 0))
{
	 StopAnimation(MachStateAnimation);
	 
	 UndoSpecialMove();
	 
	 //Destroy MachState effects.
        if (MachStateEmitter != none)
        {
            DetachFromRoot(MachStateEmitter);
            MachStateEmitter.DelayedDestroy();
            MachStateEmitter = none;
        }
	 
	 bIsMachState=false;
	 ResetPhysicsValues();
	 
	  if (MachDashLoopingSound.SoundCue != none);
       MachDashLoopingSound.FadeOut(1.0,0.0);
}

//Cancel and start MachStateAnimation when appropriate
if ((bRolling && bIsMachState) || (Physics==PHYS_Falling && bIsMachState))
{
	StopAnimation(MachStateAnimation);
}
	
if(bIsMachState && !bRolling && Physics != PHYS_Falling && !bSuperForm)
{
	if (CustomAnimation == '')
		StartAnimation(MachStateAnimation,10.0,0.0,0.25,true,true);
}


if(IsHalfPipe())
	if(Physics == PHYS_Falling && !bIsInHalfPipeVolume)
	{
		SGDKPlayerController(Controller).GetPlayerCamera().FixedLookDown();
		SGDKPlayerController(Controller).GetPlayerCamera().FixedLookDown();
	
		bIsInHalfPipeVolume=true;
	
	}

if(!IsHalfPipe())
	if(bIsInHalfPipeVolume && Physics != PHYS_Falling)
	{
		SGDKPlayerController(Controller).GetPlayerCamera().FixedLookReset();
		
		bIsInHalfPipeVolume=false;
	}
/*	
if(IsHalfPipe())
	if(Physics != PHYS_Falling)
	{
		SGDKPlayerController(Controller).GetPlayerCamera().FixedLookReset();
		
		bIsInHalfPipeVolume=false;
	}
	*/
}



function bool IsMagnetized()
{
    return ((SpecialMoveId == 5 && bMachDashMagnetizes) || super.IsMagnetized() || bIsMachState);
}

function byte GetPhysicsDataIndex()
{
	
	if (bIsMachState)
	{
		if(!bSuperForm)
		{
			return 6;
		}
		else
		{
			return 7;
		}
	}
    if (!bSuperForm)
    {
        if (!PhysicsVolume.bWaterVolume)
            return 0;
        else 
            return 1;	
    }
    else
        if (!bHyperForm)
        {
            if (!PhysicsVolume.bWaterVolume)
                return 2;
            else
                return 3;
        }
        else
        {
            if (!PhysicsVolume.bWaterVolume)
                return 4;
            else
                return 5;
        }
}


/**
 * Player pawn is bounced.
 * @param Impulse    direction and magnitude of applied impulse
 * @param bHarsh     true if pawn velocity will be equal to impulse vector
 * @param bMulti     true if multi-jumps will be enabled
 * @param bZero      true if initial Z component of velocity will be set to zero
 * @param PushActor  the actor that pushes this pawn
 * @param Reason     the reason of the push
 * @return           true if this pawn will be bounced soon
 */
function bool Bounce(vector Impulse,optional bool bHarsh,optional bool bMulti,
                     optional bool bZero,optional Actor PushActor,optional name Reason)
{
    if (Health > 0 && !bIgnoreForces && !BounceData.bWillBounce)
    {
        if (SpecialMoveId > 0)
            UndoSpecialMove();

        if (WorldInfo.TimeSeconds - LastHomingDashTime < 1.0)
        {
            if (Reason == 'Destroyable' || Reason == 'Enemy' || Reason == 'Monitor')
            {
                bHarsh = true;
                Impulse.Z = FClamp(Impulse.Z,-JumpZ,JumpZ);
            }

            LastHomingDashTime = 0.0;
        }

        return super.Bounce(Impulse,bHarsh,bMulti,bZero,PushActor,Reason);
    }

    return false;
}


function class<DamageType> GetMeleeDamageType()
{
    if (SpecialMoveId == 4)
        return StompDamageType;
    else
        if (SpecialMoveId == 5 || bIsMachState)
            return MachDashDamageType;
        else
            return super.GetMeleeDamageType();
}

/**
 * Is player pawn using a melee attack?
 * @return  true if pawn is performing a melee attack
 */
function bool IsUsingMelee()
{
    return (SpecialMoveId == 4 || SpecialMoveId == 5 || bIsMachState || super.IsUsingMelee());
}
/* 
function bool GroundSpecialMove(byte ButtonId)
{
    local RingActor Ring;

    if (ButtonId == 4 && !bDodging && !bDucking && !bPushing && !bRolling && !bSkidding && SpecialMoveId == 0)
    {
        if (bCanLightDash)
        {
            foreach VisibleCollidingActors(class'RingActor',Ring,LightDashRadius,Location,true)
                if (Ring.bLightDash && FastTrace(Location,Ring.Location))
                    break;
                else
                    Ring = none;
        }

        if (bCanLightDash && Ring != none)
        {
            SpecialMoveId = 3;

            SGDKPlayerController(Controller).IgnoreDirInput(true);

            AerialBoost(vect(0,0,250) >> DesiredMeshRotation,false,self,'LightDash');

            Acceleration = vect(0,0,0);
            MultiJumpRemaining = 0;

            if (LightDashSound != none)
                PlaySound(LightDashSound,false,true);

            if (LightDashParticles != none)
            {
                SpecialMoveEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                SpecialMoveEmitter.SetTemplate(LightDashParticles,false);
                SpecialMoveEmitter.SetVectorParameter('ColorParameter',ColorVectorParameter);

                AttachToRoot(SpecialMoveEmitter);
            }

            return true;
        }
        else
            if (bCanMachDash && (!bCanSpeedDash || VSizeSq(GetVelocity()) > Square(ApexGroundSpeed * 0.2)) &&
                ((!AboveWalkingSpeed() && MachDashEnergy >= MachDashDischargeRate) ||
                (AboveWalkingSpeed() && MachDashEnergy >= MachDashDischargeRate * 0.1)))
            {
                SpecialMoveId = 5;

                if (!bSuperForm)
                    MachDashEnergy = 100;

                if (ConstrainedMovement == CM_None)
                    ForceRotation(GetRotation(),true);

                HighSpeedBoost(1.0,false);

                if (MachDashASound != none)
                    PlaySound(MachDashASound,false,true);

                if (MachDashParticles != none)
                {
                    SpecialMoveEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                    SpecialMoveEmitter.SetTemplate(MachDashParticles,false);
                    SpecialMoveEmitter.SetVectorParameter('ColorParameter',ColorVectorParameter);

                    AttachToRoot(SpecialMoveEmitter);
                }

                SetTimer(0.3,false,NameOf(PlayMachDashSound));

                return true;
            }
            else
                if (bCanSpeedDash && !AboveWalkingSpeed() &&
                    (bAntiGravityMode || Physics == PHYS_Walking || FloorDotAngle > WalkableFloorZ))
                {
                    HighSpeedBoost(0.65,ConstrainedMovement != CM_None);

                    return true;
                }
    }

    return false;
} */

function int ModifyTurningAbility(float DeltaTime,int DeltaRotation)
{
    //DeltaRotation = FClamp(DeltaRotation,-200000 * DeltaTime,200000 * DeltaTime);

    if (!bRolling && IsTouchingGround() && AboveWalkingSpeed())
        //Decrease turning sensibility while running fast.
        DeltaRotation *= FMax(DefaultGroundSpeed / VSize(GetVelocity()),0.5);
	
    return DeltaRotation;
}


/**
 * Is Sonic Physics mode allowed?
 * @param AnActor  optional floor actor to check
 * @return         true if pawn allowed to activate Sonic Physics mode
 */
function bool IsHalfPipe(optional Actor AnActor)
{
    local HalfPipeVolume V;

    if (!bDisableSonicPhysics)
    {
        if (AnActor == none)
        {
            foreach TouchingActors(class'HalfPipeVolume',V)
                if (V.ApplyToActorClass == none && V.ApplyToActorObject == none)
                    return true;
        }
        else
        {
            if (SGDKStaticMeshActor(AnActor) != none)
                return true;

            foreach TouchingActors(class'HalfPipeVolume',V)
                if ((V.ApplyToActorClass == none && V.ApplyToActorObject == none) ||
                    (V.ApplyToActorClass == AnActor.Class || V.ApplyToActorObject == AnActor))
                    return true;
        }
    }

    return false;
}

/**
 * Player wants to jump or released the jump button/key.
 * @param bJump  true if player wants to jump, false if player has released the jump button/key
 * @return       true if allowed to perform a jump
 */
function bool Jump(bool bJump)
{
    local vector Spot,V;
    local ReceivePawnEvents NotifyObject;

    if (bJump)
    {
        //Can the pawn really jump?
        if (bJumpCapable && !bDucking && !bWantsToDuck && (bHanging || IsTouchingGround() ||
            Physics == PHYS_Ladder || (Physics == PHYS_Falling && Velocity.Z == 0.0)))
        {
            if (bHanging)
                //Cancel hanging from handle.
                SetHanging(false);

            //Limits initial speed.
            if (MaxSpeedBeforeJump > 0.0)
                SetVelocity(ClampLength(GetVelocity(),MaxSpeedBeforeJump));

            //Get the true velocity vector.
            V = GetVelocity();

            //If pawn is rolling on ground...
            if (bRolling)
            {
                //Unset rolling on ground mode.
                Roll(false);

                if (bLimitRollingJump)
                    //Disable aerial control.
                    AirControl = 0.0;
            }

            //If pawn is in Sonic Physics mode...
            if (bSonicPhysicsMode)
            {
                Spot = Location;

                //Try to position a box to avoid overlapping world geometry.
                if (FindSpot(GetCollisionExtent(),Spot))
                    Move(Spot - Location);

                //Unset Sonic Physics mode.
                SetSonicPhysics(false);

                if (!bAntiGravityMode)
                    //Limit previous velocity according to floor normal.
                    V *= FMax(0.5,Abs(FloorNormal.Z));

                //Jump according to floor normal.
                V += FloorNormal * JumpZ;
            }
            else
                if (Physics == PHYS_Walking || Physics == PHYS_Spider)
                {
                    if (!bAntiGravityMode)
                        //Limit previous velocity according to floor normal.
                        V *= FMax(0.5,Abs(Floor.Z));

                    //Jump according to floor normal.
                    V += Floor * JumpZ;
                }
                else
                    if (Physics == PHYS_Ladder)
                        //About to leave the ladder.
                        V.Z = 0.0;
                    else
                    {
                        //A way to escape unwanted death traps, where pawn gets stuck due to wrong world geometry.

                        //Trigger landed event.
                        TriggerLanded();

                        //Jump according to gravity.
                        V += GetGravityDirection() * -JumpZ;
                    }

            //Add part of base vertical velocity to jump velocity if base exists and moves.
            if (Base != none && !Base.bWorldGeometry && Base.Velocity.Z != 0.0)
                V.Z += Base.Velocity.Z * 0.25;

            //Limits vertical speed.
            V.Z = FClamp(V.Z,-MaxJumpZ,MaxJumpZ);

            //Set some values.
            bDodging = false;
            bReadyToDoubleJump = true;

            //Set falling physics properly.
            AerialBoost(V,false,self,'Jump');

            //Store this value for short jumps.
            LastJumpTime = WorldInfo.TimeSeconds;

            //If visible...
            if (!IsInvisible())
                PlayJumpingSound();

            //Notify other objects.
            foreach NotifyEventsTo(NotifyObject)
                NotifyObject.PawnJumped(self);

            return true;
        }
        else
            return false;
    }
    else
    {
        //If pawn jumped recently...
        if (Physics == PHYS_Falling && HasJumped() && WorldInfo.TimeSeconds - LastJumpTime < MaxJumpImpulseTime &&
            ((!bReverseGravity && Velocity.Z > 0.0) || (bReverseGravity && Velocity.Z < 0.0)))
            //Perform a shorter jump according to the amount of time passed since the last jump command.
            Velocity.Z *= (WorldInfo.TimeSeconds - LastJumpTime) / MaxJumpImpulseTime;

        LastJumpTime = 0.0;

        if (!bClassicSpinDash && SpinDashCount > 0)
            //Unset timer so that SpinDash will no longer be charged automatically.
            ClearTimer(NameOf(SpinDashCharge));
        else
            NoActionPerformed(1);

        return false;
    }
}