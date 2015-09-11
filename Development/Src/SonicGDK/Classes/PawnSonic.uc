//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Pawn Sonic > SGDKPlayerPawn > SGDKPawn > UTPawn > UDKPawn > GamePawn > Pawn >
//     > Actor
//
// The Pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
// This class is for Sonic character.
//================================================================================
class PawnSonic extends SGDKPlayerPawn
    placeable;


/**If true, this pawn can perform Homing Dash movement.*/ var(Template,Skills) bool bCanHomingDash;
  /**If true, this pawn can perform Jump Dash movement.*/ var(Template,Skills) bool bCanJumpDash;
 /**If true, this pawn can perform Light Dash movement.*/ var(Template,Skills) bool bCanLightDash;
  /**If true, this pawn can perform Mach Dash movement.*/ var(Template,Skills) bool bCanMachDash;
 /**If true, this pawn can perform Quick Step movement.*/ var(Template,Skills) bool bCanQuickStep;
 /**If true, this pawn can perform Speed Dash movement.*/ var(Template,Skills) bool bCanSpeedDash;
      /**If true, this pawn can perform Stomp movement.*/ var(Template,Skills) bool bCanStomp;

           /**If true, player is holding the SpecialMove key/button.*/ var bool bHoldingSpecialMove;
               /**Holds the visual effects related to special moves.*/ var SGDKEmitter SpecialMoveEmitter;
			   /**Holds the visual effects related to MachState.*/ var SGDKEmitter MachStateEmitter;
/**Multi-value identification flag for special move; 1 is Jump Dash,
      2 is Homing Dash, 3 is Light Dash, 4 is Stomp, 5 is Mach Dash.*/ var byte SpecialMoveId;

    /**If true, Homing Dash requires a previous normal jump.*/ var(Template,Skills) bool bHomingDashNeedsJump;
         /**If true, Jump Dash halves speed after finishing.*/ var(Template,Skills) bool bJumpDashHalvesSpeed;
      /**If true, Jump Dash requires a previous normal jump.*/ var(Template,Skills) bool bJumpDashNeedsJump;
/**Scales this pawn's gravity for Jump Dash and Homing Dash.*/ var(Template,Skills) float DashGravityScale;
    /**Coordinates for mapping the Homing Dash icon texture.*/ var TextureCoordinates HomingDashHudCoords;
                             /**The Homing Dash area radius.*/ var(Template,Skills) float HomingDashRadius;
           /**The speed value used for Homing Dash movement.*/ var(Template,Skills) float HomingDashSpeed;
                     /**The target actor of the Homing Dash.*/ var Actor HomingTarget;
                             /**The Hyper Dash sound effect.*/ var(Template,Sounds) SoundCue HyperDashSound;
                       /**The Hyper Dash damage area radius.*/ var(Template,Skills) float HyperDashRadius;
            /**The speed value used for Hyper Dash movement.*/ var(Template,Skills) float HyperDashSpeed;
                    /**Duration time for Jump Dash movement.*/ var(Template,Skills) float JumpDashDurationTime;
             /**The speed value used for Jump Dash movement.*/ var(Template,Skills) float JumpDashSpeed;
     /**Last time a Homing Dash movement has been performed.*/ var float LastHomingDashTime;

                  /**The Light Dash area radius.*/ var(Template,Skills) float LightDashRadius;
/**The speed value used for Light Dash movement.*/ var(Template,Skills) float LightDashSpeed;

           /**If true, Mach Dash movement magnetizes nearby rings.*/ var(Template,Skills) bool bMachDashMagnetizes;
            /**DamageType class to use for Mach Dash special move.*/ var class<SGDKDamagetype> MachDashDamageType;
           /**Discharge rate of the energy for Mach Dash movement.*/ var float MachDashDischargeRate;
                  /**Amount of energy left for Mach Dash movement.*/ var(Template,Skills) float MachDashEnergy <ClampMax=100.0>;
            /**Coordinates for mapping the Mach Dash icon texture.*/ var TextureCoordinates MachDashHudCoords;
               /**Screen position of the Mach Dash energy counter.*/ var vector2d MachDashHudPosition;
                               /**Ambient Mach Dash running sound.*/ var AudioComponent MachDashLoopingSound;
     /**Rings within this radius are considered for magnetization.*/ var(Template,Skills) float MachDashMagneticRadius;
/**Maximum amount of energy auto-recharged for Mach Dash movement.*/ var(Template,Skills) float MachDashMaxRecharge <ClampMax=100.0>;
            /**Recharge rate of the energy for Mach Dash movement.*/ var float MachDashRechargeRate;
			
			 /**Required speed to enter Mach State.*/ var float MachStateStartThreshold;
			 /**Minimum speed required to maintain Mach State.*/ var float MachStateMinThreshold;

       /**Duration time for Quick Step movement.*/ var(Template,Skills) float QuickStepDurationTime;
/**The speed value used for Quick Step movement.*/ var(Template,Skills) float QuickStepSpeed;

/**If true, Stomp requires a previous normal jump.*/ var(Template,Skills) bool bStompNeedsJump;
/**DamageType class to use for Stomp special move.*/ var class<SGDKDamagetype> StompDamageType;
       /**The speed value used for Stomp movement.*/ var(Template,Skills) float StompSpeed;

             /**Sound to play for Jump Dash.*/ var(Template,Sounds) SoundCue JumpDashSound;
           /**Sound to play for Homing Dash.*/ var(Template,Sounds) SoundCue HomingDashSound;
/**Sound to play for lock-on of Homing Dash.*/ var(Template,Sounds) SoundCue HomingLockOnSound;
            /**Sound to play for Light Dash.*/ var(Template,Sounds) SoundCue LightDashSound;
             /**Sound to play for Mach Dash.*/ var(Template,Sounds) SoundCue MachDashASound;
          /**Sound to play during Mach Dash.*/ var(Template,Sounds) SoundCue MachDashBSound;
            /**Sound to play for Quick Step.*/ var(Template,Sounds) SoundCue QuickStepSound;
                 /**Sound to play for Stomp.*/ var(Template,Sounds) SoundCue StompASound;
       /**Sound to play at the end of Stomp.*/ var(Template,Sounds) SoundCue StompBSound;

       /**Effect to play for Jump Dash.*/ var(Template,Particles) ParticleSystem JumpDashParticles;
     /**Effect to play for Homing Dash.*/ var(Template,Particles) ParticleSystem HomingDashParticles;
      /**Effect to play for Light Dash.*/ var(Template,Particles) ParticleSystem LightDashParticles;
       /**Effect to play for Mach Dash.*/ var(Template,Particles) ParticleSystem MachDashParticles;
 /**Effect to play for left Quick Step.*/ var(Template,Particles) ParticleSystem QuickStepLParticles;
/**Effect to play for right Quick Step.*/ var(Template,Particles) ParticleSystem QuickStepRParticles;
        /**Effect to play during Stomp.*/ var(Template,Particles) ParticleSystem StompAParticles;
 /**Effect to play at the end of Stomp.*/ var(Template,Particles) ParticleSystem StompBParticles;
 

                 /**Current color used for effects.*/ var vector ColorVectorParameter;
/**Color of effects to play while in standard form.*/ var(Template,Particles) Color NormalColorParameter;
   /**Color of effects to play while in super form.*/ var(Template,Particles) Color SuperColorParameter;
   /**Color of effects to play while in hyper form.*/ var(Template,Particles) Color HyperColorParameter;

  /**Chaos emeralds used for super transformations.*/ var TransformationEmeraldActor TransformationEmeralds[7];
                 /**The super transformation sound.*/ var(Template,Sounds) SoundCue TransformationSound;
/**Stores the state of the transformation sequence.*/ var float TransformationState;


/**
 * Called immediately before gameplay begins.
 */
simulated event PreBeginPlay()
{
    local PawnSonic P;

    super.PreBeginPlay();

    if (!IsTemplate() && PawnTemplate != none)
    {
        P = PawnSonic(PawnTemplate);

        bCanHomingDash = P.bCanHomingDash;
        bCanJumpDash = P.bCanJumpDash;
        bCanLightDash = P.bCanLightDash;
        bCanMachDash = P.bCanMachDash;
        bCanQuickStep = P.bCanQuickStep;
        bCanSpeedDash = P.bCanSpeedDash;
        bCanStomp = P.bCanStomp;

        bJumpDashHalvesSpeed = P.bJumpDashHalvesSpeed;
        bJumpDashNeedsJump = P.bJumpDashNeedsJump;
        bHomingDashNeedsJump = P.bHomingDashNeedsJump;
        bMachDashMagnetizes = P.bMachDashMagnetizes;
        bStompNeedsJump = P.bStompNeedsJump;
        DashGravityScale = P.DashGravityScale;
        HomingDashRadius = P.HomingDashRadius;
        HomingDashSpeed = P.HomingDashSpeed;
        HyperDashRadius = P.HyperDashRadius;
        HyperDashSound = P.HyperDashSound;
        HyperDashSpeed = P.HyperDashSpeed;
        JumpDashDurationTime = P.JumpDashDurationTime;
        JumpDashSpeed = P.JumpDashSpeed;
        LightDashRadius = P.LightDashRadius;
        LightDashSpeed = P.LightDashSpeed;
        MachDashEnergy = P.MachDashEnergy;
        MachDashMagneticRadius = P.MachDashMagneticRadius;
        MachDashMaxRecharge = P.MachDashMaxRecharge;
        QuickStepDurationTime = P.QuickStepDurationTime;
        QuickStepSpeed = P.QuickStepSpeed;
        StompSpeed = P.StompSpeed;

        JumpDashSound = P.JumpDashSound;
        HomingDashSound = P.HomingDashSound;
        HomingLockOnSound = P.HomingLockOnSound;
        LightDashSound = P.LightDashSound;
        MachDashASound = P.MachDashASound;
        MachDashBSound = P.MachDashBSound;
        QuickStepSound = P.QuickStepSound;
        StompASound = P.StompASound;
        StompBSound = P.StompBSound;

        JumpDashParticles = P.JumpDashParticles;
        HomingDashParticles = P.HomingDashParticles;
        LightDashParticles = P.LightDashParticles;
        MachDashParticles = P.MachDashParticles;
        QuickStepLParticles = P.QuickStepLParticles;
        QuickStepRParticles = P.QuickStepRParticles;
        StompAParticles = P.StompAParticles;
        StompBParticles = P.StompBParticles;
		

        NormalColorParameter = P.NormalColorParameter;
        SuperColorParameter = P.SuperColorParameter;
        HyperColorParameter = P.HyperColorParameter;

        TransformationSound = P.TransformationSound;
    }

    if (MachDashBSound != none)
        MachDashLoopingSound.SoundCue = MachDashBSound;

    ColorVectorParameter.X = float(NormalColorParameter.R) / 255.0;
    ColorVectorParameter.Y = float(NormalColorParameter.G) / 255.0;
    ColorVectorParameter.Z = float(NormalColorParameter.B) / 255.0;
}

/**
 * Called immediately before the pawn leaves the actor is standing on and will start to fall.
 */
event Falling()
{
    if (bRolling)
    {
        //Unset rolling on ground mode.
        Roll(false);

        //Roll on air.
        bReadyToDoubleJump = true;

        if (bHomingDashNeedsJump && bJumpDashNeedsJump)
            //No multi-jumps until landing.
            MultiJumpRemaining = 0;
    }

    LeftGround();

    bUpdateMeshRotation = true;
}

/**
 * Called when the pawn lands on level geometry while falling.
 * @param HitNormal   the surface normal of the actor/level geometry landed on
 * @param FloorActor  the actor landed on
 */
event Landed(vector HitNormal,Actor FloorActor)
{
    if (SpecialMoveId == 1 || SpecialMoveId == 2 || SpecialMoveId == 4)
        UndoSpecialMove();

    super.Landed(HitNormal,FloorActor);

    SetTimer(0.01,false,NameOf(PostLanded));
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    local bool bMoved;
    local float Dist,ChosenDist;
    local RingActor Ring,ChosenRing;
    local Actor A;

    super.Tick(DeltaTime);

    if (Health > 0)
    {
        if (bDodging)
        {
            bMoved = false;

            if (!bRolling && IsTouchingGround() && AboveWalkingSpeed())
            {
                if (CurrentDir == DCLICK_Left)
                    bMoved = MoveSmooth((vect(0,-1,0) >> DesiredMeshRotation) * (QuickStepSpeed * DeltaTime));
                else
                    if (CurrentDir == DCLICK_Right)
                        bMoved = MoveSmooth((vect(0,1,0) >> DesiredMeshRotation) * (QuickStepSpeed * DeltaTime));
            }

            if (!bMoved)
                UnDodge();
        }
        else
        {
            if (SpecialMoveId != 5)
            {
                MachDashDischargeRate = default.MachDashDischargeRate;

                if (MachDashEnergy < MachDashMaxRecharge && !bTurnedOff)
                {
                    MachDashRechargeRate += DeltaTime * 0.25;

                    MachDashEnergy = FMin(MachDashEnergy + MachDashRechargeRate * DeltaTime,MachDashMaxRecharge);
                }
                else
                    MachDashRechargeRate = default.MachDashRechargeRate;
            }

            switch (SpecialMoveId)
            {
                case 2:
                    if (HomingTarget != none && DestroyableEntity(HomingTarget).IsHomingTarget() &&
                        WorldInfo.TimeSeconds - LastHomingDashTime < 1.0 &&
                        VSizeSq(HomingTarget.Location - Location) > 10000.0 &&
                        FastTrace(Location,HomingTarget.Location))
                    {
                        SetVelocity(Normal(DestroyableEntity(HomingTarget).GetHomingLocation(self) - Location) * HomingDashSpeed);

                        SetPhysics(PHYS_Falling);
                    }
                    else
                        UndoSpecialMove();

                    break;

                case 3:
                    ChosenDist = Square(LightDashRadius * 1.1) + 10000.0;

                    foreach VisibleCollidingActors(class'RingActor',Ring,LightDashRadius * 1.1,Location,true)
                    {
                        if (Ring.bLightDash && FastTrace(Location,Ring.Location))
                        {
                            Dist = VSizeSq(Ring.Location - Location);

                            if (Dist < ChosenDist)
                            {
                                ChosenRing = Ring;
                                ChosenDist = Dist;
                            }
                        }
                    }

                    if (ChosenRing != none)
                    {
                        SetVelocity(Normal(ChosenRing.Location - Location) * LightDashSpeed);

                        SetPhysics(PHYS_Falling);
                    }
                    else
                        UndoSpecialMove();

                    break;

                case 5:
                    MachDashDischargeRate = FMax(5.0,MachDashDischargeRate - DeltaTime * 2.0);
                    MachDashRechargeRate = default.MachDashRechargeRate;

                    if (!bSuperForm)
                        MachDashEnergy = FMax(0.0,MachDashEnergy - MachDashDischargeRate * DeltaTime);

                    if (bRolling || bSkidding || MachDashEnergy == 0.0 || !IsTouchingGround() ||
                        VSizeSq(GetVelocity()) < Square(ApexGroundSpeed * 0.2))
                        UndoSpecialMove();
                    else
                    {
                        SetGroundSpeed(ApexGroundSpeed);
                        HighSpeedBoost(1.0,false);

                        GroundSpeed = RealGroundSpeed;
                        if (Physics == PHYS_Walking && Floor.Z < 1.0 && !IsZero(Velocity))
                            GroundSpeed *= Normal(Velocity) dot Normal(GetVelocity());

                        if (bMachDashMagnetizes)
                            MagnetizeNearbyActors(MachDashMagneticRadius);
                    }
            }
        }

        if (bCanHomingDash)
        {
            if ((HomingTarget == none || SpecialMoveId != 2) &&
                (!bDisableSpecialMoves && Physics == PHYS_Falling && MultiJumpRemaining > 0 &&
                (!bHomingDashNeedsJump || HasJumped()) && !IsZero(Velocity)))
            {
                A = FindHomingTarget();

                if (HomingLockOnSound != none && A != none && A != HomingTarget)
                    PlaySound(HomingLockOnSound,false,true);

                HomingTarget = A;
            }
            else
                if (SpecialMoveId != 2)
                    HomingTarget = none;
        }
    }
    else
        HomingTarget = none;
}

/**
 * Player pawn wants to perform an aerial special move: Jump Dash, Homing Dash or Stomp.
 * @param ButtonId  identification of the (un)pressed button; 0 is Jump, 1 is UnJump, 2 is Duck, 3 is UnDuck,
 *                                                            4 is SpecialMove, 5 is UnSpecialMove
 * @return          true if pawn performed the special move
 */
function bool AerialSpecialMove(byte ButtonId)
{
    local Actor TargetActor;
    local vector Dir;
    local SGDKEnemyPawn Enemy;

    switch (ButtonId)
    {
        case 0:
        case 2:
        case 4:
            if (MultiJumpRemaining > 0 && !IsZero(Velocity))
            {
                if (bCanHomingDash && (!bHomingDashNeedsJump || HasJumped()))
                    TargetActor = FindHomingTarget();

                if (TargetActor != none)
                {
                    bReadyToDoubleJump = true;
                    GravityScale *= DashGravityScale;
                    HomingTarget = TargetActor;
                    LastHomingDashTime = WorldInfo.TimeSeconds;
                    SpecialMoveId = 2;

                    SetVelocity(Normal(DestroyableEntity(HomingTarget).GetHomingLocation(self) - Location) * HomingDashSpeed);

                    SGDKPlayerController(Controller).IgnoreDirInput(true);

                    if (HomingDashSound != none)
                        PlaySound(HomingDashSound,false,true);

                    if (HomingDashParticles != none)
                    {
                        SpecialMoveEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                        SpecialMoveEmitter.SetTemplate(HomingDashParticles,false);
                        SpecialMoveEmitter.SetVectorParameter('ColorParameter',ColorVectorParameter);

                        AttachToRoot(SpecialMoveEmitter);
                    }

                    return true;
                }
                else
                    if (bHyperForm && HasJumped())
                    {
                        if (!bClassicMovement)
                        {
                            Dir = SGDKPlayerController(Controller).GetPressedDirection(true,false);

                            if (Dir.X == 0.0 && Dir.Y == 0.0)
                                Dir = vector(SGDKPlayerController(Controller).GetPlayerCamera().GetCameraRotation());
                        }
                        else
                        {
                            Dir = SGDKPlayerController(Controller).GetPressedDirection(false,true);

                            if (IsZero(Dir))
                                Dir = GetDefaultDirection();
                        }

                        SetVelocity(Normal(Dir) * HyperDashSpeed);

                        foreach WorldInfo.AllPawns(class'SGDKEnemyPawn',Enemy,Location,HyperDashRadius)
                            if (Enemy.Hits == 1 && FastTrace(Enemy.Location,Location))
                                Enemy.TakeDamage(1,Controller,Enemy.Location,vect(0,0,0),none,,self);

                        if (HyperDashSound != none)
                            PlaySound(HyperDashSound,false,true);

                        SGDKPlayerController(Controller).ScreenFadeToColor(MakeLinearColor(1.0,1.0,1.0,1.0),0.0);
                        SGDKPlayerController(Controller).ScreenFadeToColor(MakeLinearColor(0.0,0.0,0.0,0.0),0.5);

                        return true;
                    }
                    else
                        if (bCanJumpDash && (!bJumpDashNeedsJump || HasJumped()))
                        {
                            bReadyToDoubleJump = true;
                            GravityScale *= DashGravityScale;
                            SpecialMoveId = 1;

                            Dir = SGDKPlayerController(Controller).GetPressedDirection(true,bClassicMovement);

                            if (Dir.X == 0.0 && Dir.Y == 0.0)
                                Dir = GetDefaultDirection();
                            Dir.Z = 0.0;

                            SetVelocity(Normal(Dir) * JumpDashSpeed);

                            SGDKPlayerController(Controller).IgnoreDirInput(true);

                            SetTimer(JumpDashDurationTime,false,NameOf(UndoSpecialMove));

                            if (JumpDashSound != none)
                                PlaySound(JumpDashSound,false,true);

                            if (JumpDashParticles != none)
                            {
                                SpecialMoveEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                                SpecialMoveEmitter.SetTemplate(JumpDashParticles,false);
                                SpecialMoveEmitter.SetVectorParameter('ColorParameter',ColorVectorParameter);

                                AttachToRoot(SpecialMoveEmitter);
                            }

                            return true;
                        }
            }

            break;

        case 3:
            if (bCanStomp && (!bStompNeedsJump || HasJumped()) && MultiJumpRemaining > 0 && !IsZero(Velocity))
            {
                SpecialMoveId = 4;

                bReadyToDoubleJump = false;
                Dir = GetVelocity() * 0.05;

                if (!bReverseGravity)
                    Dir.Z = -StompSpeed;
                else
                    Dir.Z = StompSpeed;

                SetVelocity(Dir);

                AirControl = 0.0;

                if (StompASound != none)
                    PlaySound(StompASound,false,true);

                if (StompAParticles != none)
                {
                    SpecialMoveEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                    SpecialMoveEmitter.SetTemplate(StompAParticles,false);
                    SpecialMoveEmitter.SetVectorParameter('ColorParameter',ColorVectorParameter);

                    AttachToRoot(SpecialMoveEmitter);
                }

                return true;
            }
    }

    return false;
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

/**
 * Cancels all performed special moves.
 */
function CancelMoves()
{
    bHoldingSpecialMove = false;
    UndoSpecialMove();

    super.CancelMoves();
}

/**
 * This pawn is about to die.
 * @param Killer       who killed this pawn
 * @param DamageClass  what killed it
 * @param HitLocation  where did the hit occur
 * @return             true if allowed to die
 */
function bool Died(Controller Killer,class<DamageType> DamageClass,vector HitLocation)
{
    if (super.Died(Killer,DamageClass,HitLocation))
    {
        if (SpecialMoveEmitter != none)
        {
            DetachFromRoot(SpecialMoveEmitter);
            SpecialMoveEmitter.DelayedDestroy();
            SpecialMoveEmitter = none;
        }

        return true;
    }

    return false;
}

/**
 * Player wants to dodge: Quick Step.
 * @param DoubleClickMove  double click/press move direction
 * @return                 true if dodge is performed
 */
function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    local float DotAngle;
    local EDoubleClickDir MoveDirection;
    local SGDKEmitter QuickStepEmitter;
    local SGDKSplineActor SplineInfo;

    if (bDisableSpecialMoves || !bCanQuickStep || DoubleClickMove == DCLICK_Forward ||
        DoubleClickMove == DCLICK_Back || bClassicMovement || bDodging ||
        bRolling || !IsTouchingGround() || !AboveWalkingSpeed())
        return false;
    else
    {
        DotAngle = vector(DesiredViewRotation) dot Normal(GetVelocity());

        if (Abs(DotAngle) < 0.7)
            return false;
        else
        {
            if (ConstrainedMovement == CM_Runway3d)
            {
                if (SplineX dot vector(DesiredViewRotation) > 0.0)
                    MoveDirection = DoubleClickMove;
                else
                {
                    if (DoubleClickMove == DCLICK_Left)
                        MoveDirection = DCLICK_Right;
                    else
                        MoveDirection = DCLICK_Left;
                }

                if (CurrentSplineActor.NextOrdered != none &&
                    CurrentSplineActor.FindSplineComponentTo(CurrentSplineActor.NextOrdered) == CurrentSplineComp)
                    SplineInfo = CurrentSplineActor;
                else
                    if (CurrentSplineActor.PrevOrdered != none &&
                        CurrentSplineActor.PrevOrdered.FindSplineComponentTo(CurrentSplineActor) == CurrentSplineComp)
                        SplineInfo = SGDKSplineActor(CurrentSplineActor.PrevOrdered);

                if (SplineInfo == none)
                    return false;
                else
                {
                    if (SplineInfo.NumRailsLeft > 0 || SplineInfo.NumRailsRight > 0)
                    {
                        if (MoveDirection == DCLICK_Left)
                        {
                            if ((SplineInfo.NumRailsLeft == 0 && SplineOffset < SplineInfo.RailDistanceOffset * 0.5) ||
                                (SplineInfo.NumRailsLeft == 1 && SplineOffset < SplineInfo.RailDistanceOffset * -0.5) ||
                                (SplineInfo.NumRailsLeft == 2 && SplineOffset < SplineInfo.RailDistanceOffset * -1.5))
                                return false;
                            else
                                SplineOffset -= SplineInfo.RailDistanceOffset;
                        }
                        else
                            if (MoveDirection == DCLICK_Right)
                            {
                                if ((SplineInfo.NumRailsRight == 0 && SplineOffset > SplineInfo.RailDistanceOffset * -0.5) ||
                                    (SplineInfo.NumRailsRight == 1 && SplineOffset > SplineInfo.RailDistanceOffset * 0.5) ||
                                    (SplineInfo.NumRailsRight == 2 && SplineOffset > SplineInfo.RailDistanceOffset * 1.5))
                                    return false;
                                else
                                    SplineOffset += SplineInfo.RailDistanceOffset;
                            }
                            else
                                return false;
                    }
                    else
                        return false;
                }

                QuickStepDurationTime = (SplineInfo.RailDistanceOffset / QuickStepSpeed) * 0.9;
            }
            else
            {
                if (DotAngle < 0.0)
                {
                    if (DoubleClickMove == DCLICK_Left)
                        DoubleClickMove = DCLICK_Right;
                    else
                        DoubleClickMove = DCLICK_Left;
                }

                if (PawnTemplate != none)
                    QuickStepDurationTime = PawnSonic(PawnTemplate).QuickStepDurationTime;
                else
                    QuickStepDurationTime = default.QuickStepDurationTime;
            }

            bDodging = true;
            CurrentDir = DoubleClickMove;

            if (QuickStepSound != none)
                PlaySound(QuickStepSound,false,true);

            if (CurrentDir == DCLICK_Left && QuickStepLParticles != none)
            {
                QuickStepEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                QuickStepEmitter.SetTemplate(QuickStepLParticles,true);
                QuickStepEmitter.SetVectorParameter('ColorParameter',ColorVectorParameter);
            }
            else
                if (CurrentDir == DCLICK_Right && QuickStepRParticles != none)
                {
                    QuickStepEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                    QuickStepEmitter.SetTemplate(QuickStepRParticles,true);
                    QuickStepEmitter.SetVectorParameter('ColorParameter',ColorVectorParameter);
                }

            SetTimer(QuickStepDurationTime,false,NameOf(UnDodge));

            return true;
        }
    }
}

/**
 * Finds a valid target for Homing Dash special move.
 * @return  valid target actor
 */
function Actor FindHomingTarget()
{
    local float Dist,ChosenDist;
    local Actor A,ChosenActor;
    local vector Dir,V;

    ChosenDist = Square(HomingDashRadius) + 10000.0;
    Dir = GetDefaultDirection();
    V = Location - Dir * (GetCollisionRadius() * 2.5);

    foreach CollidingActors(class'Actor',A,HomingDashRadius,Location,true,class'DestroyableEntity')
    {
        if (DestroyableEntity(A).IsHomingTarget() && WorldInfo.TimeSeconds - A.LastRenderTime < 0.1 &&
            FastTrace(Location,A.Location) && Dir dot Normal(A.Location - V) >= 0.0)
        {
            Dist = VSizeSq(A.Location - Location);

            if (Dist < ChosenDist)
            {
                ChosenActor = A;
                ChosenDist = Dist;
            }
        }
    }

    return ChosenActor;
}

/**
 * Gets the damage type to use for deaths caused by melee attacks.
 * @return  class of melee damage type
 */
function class<DamageType> GetMeleeDamageType()
{
    if (SpecialMoveId == 4)
        return StompDamageType;
    else
        if (SpecialMoveId == 5)
            return MachDashDamageType;
        else
            return super.GetMeleeDamageType();
}

/**
 * Player pawn wants to perform an on ground special move: Mach Dash, Speed Dash or Light Dash.
 * @param ButtonId  identification of the (un)pressed button; 4 is SpecialMove, 5 is UnSpecialMove
 * @return          true if pawn performed the special move
 */
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
                    MachDashEnergy = FMax(0.0,MachDashEnergy - MachDashDischargeRate * 0.5);

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
}

/**
 * Draws 2D graphics on the HUD.
 * @param TheHud  the HUD
 */
function HudGraphicsDraw(SGDKHud TheHud)
{
    local vector V;

    if (bCanMachDash)
    {
        TheHud.DrawInfoElement(MachDashHudPosition,false,TheHud.BackgroundSCoords,
                               MachDashHudCoords,vect2d(12,-16),MachDashEnergy);

        TheHud.LivesPosition = TheHud.default.LivesPosition;
    }
    else
        TheHud.LivesPosition = MachDashHudPosition;

    if (HomingTarget != none)
    {
        V = TheHud.Canvas.Project(DestroyableEntity(HomingTarget).GetHomingLocation(self));

        if (!TheHud.bIsSplitScreen || (V.X > 0.0 && V.X < TheHud.ViewX && V.Y > 0.0 && V.Y < TheHud.ViewY))
        {
            TheHud.Canvas.DrawColor = TheHud.GetDrawColor();

            //Draw the marker.
            TheHud.Canvas.SetPos(V.X - HomingDashHudCoords.UL * TheHud.ResolutionScale * 0.5,
                                 V.Y - HomingDashHudCoords.VL * TheHud.ResolutionScale * 0.5);
            TheHud.Canvas.DrawTile(TheHud.HudTexture,HomingDashHudCoords.UL * TheHud.ResolutionScale,
                                   HomingDashHudCoords.VL * TheHud.ResolutionScale,HomingDashHudCoords.U,
                                   HomingDashHudCoords.V,HomingDashHudCoords.UL,HomingDashHudCoords.VL);
        }
    }

    super.HudGraphicsDraw(TheHud);
}

/**
 * Is the player pawn magnetized?
 * @return  true if pawn can attract magnetized rings
 */
function bool IsMagnetized()
{
    return ((SpecialMoveId == 5 && bMachDashMagnetizes) || super.IsMagnetized());
}

/**
 * Is player pawn using a melee attack?
 * @return  true if pawn is performing a melee attack
 */
function bool IsUsingMelee()
{
    return (SpecialMoveId == 4 || SpecialMoveId == 5 || super.IsUsingMelee());
}

/**
 * Is a primitive component pushable?
 * @param TestComponent  primitive component to test
 * @return               true if primitive component is pushable
 */
function bool IsValidPush(PrimitiveComponent TestComponent)
{
    //Can't push while performing a special move.
    return (SpecialMoveId == 0 && super.IsValidPush(TestComponent));
}

/**
 * Player pressed or released the Jump/Duck/SpecialMove key/button and no action was performed.
 * @param ButtonId  identification of the (un)pressed button; 0 is Jump, 1 is UnJump, 2 is Duck, 3 is UnDuck,
 *                                                            4 is SpecialMove, 5 is UnSpecialMove
 * @return          false if pawn finally performed an action
 */
function bool NoActionPerformed(byte ButtonId = 0)
{
    local bool bResult;

    bResult = super.NoActionPerformed(ButtonId);

    if (bResult && !bHoldingSpecialMove && SpecialMoveId == 5)
    {
        //Cancel Mach Dash.
        UndoSpecialMove();

        return false;
    }

    return bResult;
}

/**
 * Plays the Mach Dash looped sound.
 */
function PlayMachDashSound()
{
    if (MachDashLoopingSound.SoundCue != none)
        MachDashLoopingSound.Play();
}

/**
 * Called after the pawn landed.
 */
function PostLanded()
{
    if (bHoldingSpecialMove && IsTouchingGround() && !WillLeaveGround() && !bDodging &&
        !bDucking && !bPushing && !bRolling && !bSkidding && GroundSpecialMove(4))
        LastSpecialMoveTime = WorldInfo.TimeSeconds;
}

/**
 * Receives an amount of energy.
 * @param Amount  amount of energy points
 */
function ReceiveEnergy(float Amount)
{
    MachDashEnergy = FClamp(MachDashEnergy + Amount,0.0,100.0);
}

/**
 * Should the player pawn pass through a solid actor?
 * @return  true if this pawn should pass through an actor
 */
function bool ShouldPassThrough(Actor AnActor)
{
    return (SpecialMoveId == 4 || super.ShouldPassThrough(AnActor));
}

/**
 * Should the attached skeletal mesh component play the dashing animation?
 * @return  true if the attached skeletal mesh component should play the dashing animation
 */
function bool ShouldPlayDash()
{
    return (SpecialMoveId == 3 || super.ShouldPlayDash());
}

/**
 * Called when the player presses or releases the SpecialMove key/button.
 * @param bSpecial  true if player wants to perform a special move, false if player has released the button/key
 */
function SpecialMove(bool bSpecial)
{
    if (!bDisableSpecialMoves)
    {
        bHoldingSpecialMove = bSpecial;

        super.SpecialMove(bSpecial);
    }
    else
        bHoldingSpecialMove = false;
}

/**
 * Sets or unsets player's super form.
 * @param bSuper  sets/unsets super form
 */
function SuperForm(bool bSuper)
{
    super.SuperForm(bSuper);

    if (!bSuperForm)
    {
        MachDashEnergy = 0.0;

        ColorVectorParameter.X = float(NormalColorParameter.R) / 255.0;
        ColorVectorParameter.Y = float(NormalColorParameter.G) / 255.0;
        ColorVectorParameter.Z = float(NormalColorParameter.B) / 255.0;
    }
    else
    {
        MachDashEnergy = 100.0;

        if (!bHyperForm)
        {
            ColorVectorParameter.X = float(SuperColorParameter.R) / 255.0;
            ColorVectorParameter.Y = float(SuperColorParameter.G) / 255.0;
            ColorVectorParameter.Z = float(SuperColorParameter.B) / 255.0;
        }
        else
        {
            ColorVectorParameter.X = float(HyperColorParameter.R) / 255.0;
            ColorVectorParameter.Y = float(HyperColorParameter.G) / 255.0;
            ColorVectorParameter.Z = float(HyperColorParameter.B) / 255.0;
        }
    }
}

/**
 * Player wants to transform into a super state.
 * @return  true if pawn transforms
 */
function bool SuperTransformation()
{
    if (!bSuperForm && Health > 50 && Controller != none && SGDKPlayerController(Controller).ChaosEmeralds > 6)
    {
        GotoState('Transforming');

        return true;
    }

    return false;
}

/**
 * Cancels Quick Step move.
 */
function UnDodge()
{
    ClearTimer(NameOf(UnDodge));

    bDodging = false;
}

/**
 * Cancels special moves.
 */
function UndoSpecialMove()
{
    local SGDKEmitter StompEmitter;

    switch (SpecialMoveId)
    {
        case 1:
            ClearTimer(NameOf(UndoSpecialMove));

            GravityScale /= DashGravityScale;

            if (Physics == PHYS_Falling)
                bReadyToDoubleJump = false;

            if (bJumpDashHalvesSpeed)
                SetVelocity(GetVelocity() * 0.5);

            SGDKPlayerController(Controller).IgnoreDirInput(false);

            break;

        case 2:
            GravityScale /= DashGravityScale;
            HomingTarget = none;
            LastHomingDashTime = WorldInfo.TimeSeconds;

            SGDKPlayerController(Controller).IgnoreDirInput(false);

            break;

        case 3:
            SGDKPlayerController(Controller).IgnoreDirInput(false);

            break;

        case 4:
            if (StompBSound != none)
                PlaySound(StompBSound,false,true);

            if (StompBParticles != none)
            {
                StompEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                StompEmitter.SetTemplate(StompBParticles,true);
            }

            break;

        case 5:
            if (IsTimerActive(NameOf(PlayMachDashSound)))
                ClearTimer(NameOf(PlayMachDashSound));
            else
                if (MachDashLoopingSound.SoundCue != none)
                    MachDashLoopingSound.FadeOut(1.0,0.0);
    }

    if (SpecialMoveEmitter != none)
    {
        SpecialMoveEmitter.DelayedDestroy(false,0.02);
        SpecialMoveEmitter = none;
    }

    SpecialMoveId = 0;
}


//Transforming into a super state.
state Transforming
{
    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        local int i;

        global.Tick(DeltaTime);

        if (TransformationState < 2.0)
        {
            if (TransformationEmeralds[0] != none)
                for (i = 0; i < 7; i++)
                    TransformationEmeralds[i].StaticMeshComponent.SetTranslation(
                        TransformationEmeralds[i].StaticMeshComponent.Translation + vect(50,0,0) * DeltaTime);
        }
        else
            if (TransformationState < 3.0)
            {
                TransformationState += DeltaTime;

                BodyMaterialInstances[0].SetScalarParameterValue('SuperParameter',TransformationState - 2.0);
            }
    }

    /**
     * Adjusts damage based on inventory and other attributes.
     * @param DamageAmount     the base damage to apply; return -1 if this pawn is invulnerable
     * @param Momentum         force/impulse caused by this hit
     * @param EventInstigator  the controller responsible for the damage
     * @param HitLocation      world location where the hit occurred
     * @param DamageClass      class describing the damage that was done
     * @param HitInfo          additional info about where the hit occurred
     * @param DamageCauser     the actor that directly caused the damage
     */
    function AdjustDamage(out int DamageAmount,out vector Momentum,Controller EventInstigator,vector HitLocation,
                          class<DamageType> DamageClass,TraceHitInfo HitInfo,Actor DamageCauser)
    {
        if (!IsInvulnerable(DamageClass) && !DamageClass.default.bArmorStops)
        {
            bIgnoreForces = false;
            SetPhysics(PHYS_Falling);

            DestroyEmeralds();

            global.AdjustDamage(DamageAmount,Momentum,EventInstigator,HitLocation,DamageClass,HitInfo,DamageCauser);

            GotoState('Auto');
        }
        else
            DamageAmount = -1;
    }

    /**
     * Creates the Chaos Emeralds used for the transformation sequence.
     */
    function CreateEmeralds()
    {
        local int i,SuperEmeralds;
        local rotator R;

        R = GetRotation();
        R.Pitch = -5000;

        for (i = 0; i < 7; i++)
        {
            TransformationEmeralds[i] = Spawn(class'TransformationEmeraldActor',self,,Location,R);
            TransformationEmeralds[i].ChangeColor(i);

            R.Yaw += 9362;
        }

        if (bHasHyperForm && SGDKPlayerController(Controller).ChaosEmeralds > 7)
        {
            SuperEmeralds = SGDKPlayerController(Controller).ChaosEmeralds - 7;

            for (i = 0; i < SuperEmeralds; i++)
                TransformationEmeralds[i].SetDrawScale(TransformationEmeralds[i].DrawScale * 1.5);
        }
    }

    /**
     * Destroys the Chaos Emeralds used for the transformation sequence.
     */
    function DestroyEmeralds()
    {
        local int i;

        for (i = 0; i < 7; i++)
            if (TransformationEmeralds[i] != none)
                TransformationEmeralds[i].Destroy();
    }

Begin:
    TransformationState = 1.0;

    CreateEmeralds();
    CancelMoves();

    bIgnoreForces = true;
    SetPhysics(PHYS_None);
    StartAnimation('Transformation',1.0,1.5,0.25,false);

    Sleep(1.0);

    TransformationState = 2.0;

    Sleep(1.0);

    TransformationState = 3.0;

    if (TransformationSound != none)
        PlaySound(TransformationSound,false,true);

    SGDKPlayerController(Controller).ScreenFadeToColor(MakeLinearColor(1.0,1.0,1.0,1.0));
    SGDKPlayerController(Controller).ScreenFadeToColor(MakeLinearColor(1.0,1.0,1.0,0.0),2.0);

    BodyMaterialInstances[0].SetScalarParameterValue('SuperParameter',0.0);

    DestroyEmeralds();

    if (!bHasHyperForm || SGDKPlayerController(Controller).ChaosEmeralds < 14)
        SuperForm(true);
    else
        HyperForm(true);

    ClearTimer(NameOf(RingCountdown));

    Sleep(1.0);

    TransformationState = 0.0;

    bIgnoreForces = false;
    SetTimer(RingCountdownTime,true,NameOf(RingCountdown));
    SetPhysics(PHYS_Falling);

    GotoState('Auto');
}


defaultproperties
{
    Begin Object Name=WPawnSkeletalMeshComponent
        AnimSets[0]=AnimSet'SonicGDKPackSkeletalMeshes.Animation.SonicAnimSet'
        AnimTreeTemplate=AnimTree'SonicGDKPackSkeletalMeshes.Animation.SonicAnimTree'
        PhysicsAsset=PhysicsAsset'SonicGDKPackSkeletalMeshes.PhysicsAssets.SonicPhysicsAsset'
        SkeletalMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.SonicSkeletalMesh'
        Scale=3.25 //Scale to triple size.
		bClothAwakeOnStartup = True
		bEnableClothSimulation = True
    End Object
    Mesh=WPawnSkeletalMeshComponent
    VisibleMesh=WPawnSkeletalMeshComponent
	
	


    Begin Object Class=AudioComponent Name=MachDashAudioComponent
        bAllowSpatialization=false
    End Object
    MachDashLoopingSound=MachDashAudioComponent
    Components.Add(MachDashAudioComponent)

/*
    //Data associated to standard physics.
    PhysicsData[0].RunningAcceleration = 500.0;     // 40% of RunningReferenceSpeed; takes 2.5 seconds to reach 1300.
    PhysicsData[0].RunningBrakingStrength = 3250.0; //250% of RunningReferenceSpeed.
    PhysicsData[0].RunningGroundFriction = 500.0;   // 40% of RunningReferenceSpeed.
    PhysicsData[0].RunningReferenceSpeed = 1300.0;
    PhysicsData[0].RunningSlopeBonus = 325.0;       // 65% of RunningGroundFriction.
    PhysicsData[0].RunningTopSpeed = 2000.0;
    PhysicsData[0].RollingBrakingStrength = 1800.0; //100% of RollingReferenceSpeed.
    PhysicsData[0].RollingGroundFriction = 300.0;   // 16% of RollingReferenceSpeed.
    PhysicsData[0].RollingSlopeDownBonus = 900.0;   //300% of RollingGroundFriction.
    PhysicsData[0].RollingSlopeUpBonus = 225.0;     // 25% of RollingSlopeDownBonus.
    PhysicsData[0].RollingTopSpeed = 2500.0;
    PhysicsData[0].FallingAirAcceleration = 500.0;
    PhysicsData[0].FallingGravityAccel = 520.0;
    PhysicsData[0].FallingReferenceSpeed = 650.0;
    PhysicsData[0].JumpingNormalStrength = 650.0;
    PhysicsData[0].JumpingTopStrength = 1100.0;     //170% of JumpingNormalStrength.

    //Data associated to underwater physics.
    PhysicsData[1].RunningAcceleration = PhysicsData[0].RunningAcceleration * 0.75;
    PhysicsData[1].RunningBrakingStrength = PhysicsData[0].RunningBrakingStrength * 0.75;
    PhysicsData[1].RunningGroundFriction = PhysicsData[0].RunningGroundFriction * 0.75;
    PhysicsData[1].RunningReferenceSpeed = PhysicsData[0].RunningReferenceSpeed * 0.75;
    PhysicsData[1].RunningSlopeBonus = PhysicsData[0].RunningSlopeBonus * 0.75;
    PhysicsData[1].RunningTopSpeed = PhysicsData[0].RunningTopSpeed * 0.75;
    PhysicsData[1].RollingBrakingStrength = PhysicsData[0].RollingBrakingStrength * 0.75;
    PhysicsData[1].RollingGroundFriction = PhysicsData[0].RollingGroundFriction;
    PhysicsData[1].RollingSlopeDownBonus = PhysicsData[0].RollingSlopeDownBonus * 0.75;
    PhysicsData[1].RollingSlopeUpBonus = PhysicsData[0].RollingSlopeUpBonus * 0.75;
    PhysicsData[1].RollingTopSpeed = PhysicsData[0].RollingTopSpeed * 0.75;
    PhysicsData[1].FallingAirAcceleration = PhysicsData[0].FallingAirAcceleration * 0.75;
    PhysicsData[1].FallingGravityAccel = PhysicsData[0].FallingGravityAccel * 0.5;
    PhysicsData[1].FallingReferenceSpeed = PhysicsData[0].FallingReferenceSpeed * 0.75;
    PhysicsData[1].JumpingNormalStrength = PhysicsData[0].JumpingNormalStrength * 0.85;
    PhysicsData[1].JumpingTopStrength = PhysicsData[0].JumpingTopStrength * 0.85;

    //Data associated to super form.
    PhysicsData[2].RunningAcceleration = 1000.0;    //200% of standard RunningAcceleration.
    PhysicsData[2].RunningBrakingStrength = 6500.0; //200% of standard RunningBrakingStrength.
    PhysicsData[2].RunningGroundFriction = 750.0;   //150% of standard RunningGroundFriction.
    PhysicsData[2].RunningReferenceSpeed = 1700.0;  //130% of standard RunningReferenceSpeed.
    PhysicsData[2].RunningSlopeBonus = 325.0;       //100% of standard RunningSlopeBonus.
    PhysicsData[2].RunningTopSpeed = 2300.0;        //115% of standard RunningTopSpeed.
    PhysicsData[2].RollingBrakingStrength = 1800.0; //100% of standard RollingReferenceSpeed.
    PhysicsData[2].RollingGroundFriction = 300.0;   //100% of standard RollingGroundFriction.
    PhysicsData[2].RollingSlopeDownBonus = 900.0;   //100% of standard RollingSlopeDownBonus.
    PhysicsData[2].RollingSlopeUpBonus = 225.0;     //100% of standard RollingSlopeUpBonus.
    PhysicsData[2].RollingTopSpeed = 2500.0;        //100% of standard RollingTopSpeed.
    PhysicsData[2].FallingAirAcceleration = 1000.0; //200% of standard FallingAirAcceleration.
    PhysicsData[2].FallingGravityAccel = 520.0;     //100% of standard FallingGravityAccel.
    PhysicsData[2].FallingReferenceSpeed = 650.0;   //100% of standard FallingReferenceSpeed.
    PhysicsData[2].JumpingNormalStrength = 800.0;   //123% of standard JumpingNormalStrength.
    PhysicsData[2].JumpingTopStrength = 1100.0;     //100% of standard JumpingTopStrength.

    //Data associated to underwater super form.
    PhysicsData[3].RunningAcceleration = PhysicsData[2].RunningAcceleration * 0.75;
    PhysicsData[3].RunningBrakingStrength = PhysicsData[2].RunningBrakingStrength * 0.75;
    PhysicsData[3].RunningGroundFriction = PhysicsData[2].RunningGroundFriction * 0.75;
    PhysicsData[3].RunningReferenceSpeed = PhysicsData[2].RunningReferenceSpeed * 0.75;
    PhysicsData[3].RunningSlopeBonus = PhysicsData[2].RunningSlopeBonus * 0.75;
    PhysicsData[3].RunningTopSpeed = PhysicsData[2].RunningTopSpeed * 0.75;
    PhysicsData[3].RollingBrakingStrength = PhysicsData[2].RollingBrakingStrength * 0.75;
    PhysicsData[3].RollingGroundFriction = PhysicsData[2].RollingGroundFriction * 0.75;
    PhysicsData[3].RollingSlopeDownBonus = PhysicsData[2].RollingSlopeDownBonus * 0.75;
    PhysicsData[3].RollingSlopeUpBonus = PhysicsData[2].RollingSlopeUpBonus * 0.75;
    PhysicsData[3].RollingTopSpeed = PhysicsData[2].RollingTopSpeed * 0.75;
    PhysicsData[3].FallingAirAcceleration = PhysicsData[2].FallingAirAcceleration * 0.75;
    PhysicsData[3].FallingGravityAccel = PhysicsData[2].FallingGravityAccel * 0.5;
    PhysicsData[3].FallingReferenceSpeed = PhysicsData[2].FallingReferenceSpeed * 0.75;
    PhysicsData[3].JumpingNormalStrength = PhysicsData[2].JumpingNormalStrength * 0.85;
    PhysicsData[3].JumpingTopStrength = PhysicsData[2].JumpingTopStrength * 0.85;

    //Data associated to hyper form.
    PhysicsData[4] = PhysicsData[2];

    //Data associated to underwater hyper form.
    PhysicsData[5] = PhysicsData[3];
*/
    PhysicsData[0]=(RunningAcceleration=500.0, RunningBrakingStrength=3250.0,RunningGroundFriction=500.0,RunningReferenceSpeed=1300.0,RunningSlopeBonus=325.0, RunningTopSpeed=2000.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=2500.0,FallingAirAcceleration=500.0, FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=650.0,JumpingTopStrength=1100.0)
    PhysicsData[1]=(RunningAcceleration=375.0, RunningBrakingStrength=2437.5,RunningGroundFriction=375.0,RunningReferenceSpeed=975.0, RunningSlopeBonus=243.75,RunningTopSpeed=1500.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=1875.0,FallingAirAcceleration=375.0, FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=552.5,JumpingTopStrength=935.0)
    PhysicsData[2]=(RunningAcceleration=1000.0,RunningBrakingStrength=6500.0,RunningGroundFriction=750.0,RunningReferenceSpeed=1700.0,RunningSlopeBonus=325.0, RunningTopSpeed=2300.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=2500.0,FallingAirAcceleration=1000.0,FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=800.0,JumpingTopStrength=1100.0)
    PhysicsData[3]=(RunningAcceleration=750.0, RunningBrakingStrength=4875.0,RunningGroundFriction=562.5,RunningReferenceSpeed=1275.0,RunningSlopeBonus=243.75,RunningTopSpeed=1725.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=1875.0,FallingAirAcceleration=750.0, FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=680.0,JumpingTopStrength=935.0)
    PhysicsData[4]=(RunningAcceleration=1000.0,RunningBrakingStrength=6500.0,RunningGroundFriction=750.0,RunningReferenceSpeed=1700.0,RunningSlopeBonus=325.0, RunningTopSpeed=2300.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=2500.0,FallingAirAcceleration=1000.0,FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=800.0,JumpingTopStrength=1100.0)
    PhysicsData[5]=(RunningAcceleration=750.0, RunningBrakingStrength=4875.0,RunningGroundFriction=562.5,RunningReferenceSpeed=1275.0,RunningSlopeBonus=243.75,RunningTopSpeed=1725.0,RollingBrakingStrength=1350.0,RollingGroundFriction=225.0,RollingSlopeDownBonus=675.0,RollingSlopeUpBonus=168.75,RollingTopSpeed=1875.0,FallingAirAcceleration=750.0, FallingGravityAccel=260.0,FallingReferenceSpeed=487.5,JumpingNormalStrength=680.0,JumpingTopStrength=935.0)
	PhysicsData[6]=(RunningAcceleration=500.0, RunningBrakingStrength=3250.0,RunningGroundFriction=500.0,RunningReferenceSpeed=1300.0,RunningSlopeBonus=325.0, RunningTopSpeed=2000.0,RollingBrakingStrength=1800.0,RollingGroundFriction=300.0,RollingSlopeDownBonus=900.0,RollingSlopeUpBonus=225.0, RollingTopSpeed=2500.0,FallingAirAcceleration=500.0, FallingGravityAccel=520.0,FallingReferenceSpeed=650.0,JumpingNormalStrength=650.0,JumpingTopStrength=1100.0)
	
    FamilyInfoClass=class'FamilyInfoSonic'
    MeshDuckingOffset=3.0
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
    AerialActionsUnDuck.Empty
    AerialActionsUnDuck[0]=SA_CharacterMove
    AerialActionsSpecialMove.Empty
    AerialActionsSpecialMove[0]=SA_ShieldMove
    AerialActionsSpecialMove[1]=SA_SuperTransform
    AerialActionsSpecialMove[2]=SA_CharacterMove

    bCanHomingDash=true
    bCanJumpDash=true
    bCanLightDash=true
    bCanMachDash=true
    bCanQuickStep=true
    bCanSpeedDash=true
    bCanStomp=true

    bHoldingSpecialMove=false

    bHomingDashNeedsJump=true
    bJumpDashHalvesSpeed=true
    bJumpDashNeedsJump=true
    DashGravityScale=0.01
    HomingDashHudCoords=(U=10,V=222,UL=100,VL=50)
    HomingDashRadius=450.0
    HomingDashSpeed=1500.0
    HyperDashRadius=1500.0
    HyperDashSound=SoundCue'SonicGDKPackSounds.HyperDashSoundCue'
    HyperDashSpeed=1500.0
    JumpDashDurationTime=0.25
    JumpDashSpeed=2000.0

    LightDashRadius=200.0
    LightDashSpeed=2000.0

    bMachDashMagnetizes=false
    MachDashEnergy=100.0
    MachDashDamageType=class'SGDKDmgType_MachDash'
    MachDashDischargeRate=10.0
    MachDashHudCoords=(U=544,V=408,UL=70,VL=70)
    MachDashHudPosition=(X=16,Y=-54)
    MachDashMagneticRadius=100.0
    MachDashMaxRecharge=20.0
    MachDashRechargeRate=0.0

	MachStateStartThreshold = 2600
	MachStateMinThreshold = 2000
	
    QuickStepDurationTime=0.065
    QuickStepSpeed=2000.0

    bStompNeedsJump=true
    StompDamageType=class'SGDKDmgType_Stomp'
    StompSpeed=2000.0

    JumpDashSound=SoundCue'SonicGDKPackSounds.HomingDashSoundCue'
    HomingDashSound=SoundCue'SonicGDKPackSounds.HomingDashSoundCue'
    HomingLockOnSound=SoundCue'SonicGDKPackSounds.LockOnSoundCue'
    LightDashSound=none
    MachDashASound=SoundCue'SonicGDKPackSounds.SpeedDashSoundCue'
    MachDashBSound=SoundCue'SonicGDKPackSounds.MachDashSoundCue'
    QuickStepSound=SoundCue'SonicGDKPackSounds.QuickStepSoundCue'
    StompASound=SoundCue'SonicGDKPackSounds.HomingDashSoundCue'
    StompBSound=none

    JumpDashParticles=ParticleSystem'SonicGDKPackParticles.Particles.DashRibbonParticleSystem'
    HomingDashParticles=ParticleSystem'SonicGDKPackParticles.Particles.DashRibbonParticleSystem'
    LightDashParticles=ParticleSystem'SonicGDKPackParticles.Particles.DashRibbonParticleSystem'
    MachDashParticles=ParticleSystem'SonicGDKPackParticles.Particles.MachDashParticleSystem'
	
    QuickStepLParticles=none
    QuickStepRParticles=none
    StompAParticles=ParticleSystem'SonicGDKPackParticles.Particles.DashRibbonParticleSystem'
    StompBParticles=none

    NormalColorParameter=(R=10,G=25,B=255)
    SuperColorParameter=(R=255,G=210,B=100)
    HyperColorParameter=(R=255,G=255,B=255)

    TransformationSound=SoundCue'SonicGDKPackSounds.TransformationSoundCue'
}
