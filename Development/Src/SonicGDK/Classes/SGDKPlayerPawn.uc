//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Player Pawn > SGDKPawn > UTPawn > UDKPawn > GamePawn > Pawn > Actor
//
// The Pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
// This type belongs to playable characters and is controlled by human players.
//================================================================================
class SGDKPlayerPawn extends SGDKPawn;


/**Simplified way of storing player input commands.*/ var enum EInputState
{
/**No command or decelerate command.*/ IS_None,
  /**Accelerate if possible command.*/ IS_Accel,
                   /**Brake command.*/ IS_Brake,
                        /**Not used.*/ IS_Custom,
} InputState;

struct TAttachmentData
{
/**If true, rotation pivot faces velocity direction of this pawn.*/ var bool bUseVelocity;
                                  /**Actor attached to this pawn.*/ var Actor AttachedActor;
                               /**Location relative to this pawn.*/ var vector RelativeLocation;
                               /**Rotation relative to this pawn.*/ var rotator RelativeRotation;
};
/**Array of actors that follow this pawn and rotate with it.*/ var protected array<TAttachmentData> RootAttachments;

struct TBounceData
{
                        /**If true, multi-jumps will be enabled.*/ var bool bAddMultiJump;
      /**If true, pawn velocity will be equal to impulse vector.*/ var bool bHarshBounce;
                           /**If true, player jumped previously.*/ var bool bHadJumped;
                     /**If true, this pawn will be bounced soon.*/ var bool bWillBounce;
/**If true, initial Z component of velocity will be set to zero.*/ var bool bZeroZSpeed;
                             /**The actor that pushes this pawn.*/ var Actor BounceActor;
        /**Direction and magnitude of the to-be-applied impulse.*/ var vector BounceImpulse;
                                      /**The reason of the push.*/ var name BounceReason;
};
/**Stores bounce data.*/ var protected TBounceData BounceData;

struct TDecelData
{
                          /**If true, deceleration is active.*/ var bool bEnabled;
/**Deceleration interpolates from this on ground speed value.*/ var float FromValue;
                    /**Current scale applied to deceleration.*/ var float Scale;

    structdefaultproperties
    {
        Scale=1.0
    }
};
                                       /**Stores deceleration data.*/ var protected TDecelData DecelData;
/**Deceleration rate; only used while running or rolling on ground.*/ var float DecelRate;

/**Data that links a type of material with a sound.*/ struct TMaterialSoundData
{
              /**Name of material type.*/ var() name MaterialType;
/**Sound associated to a material type.*/ var() SoundCue Sound;
};

struct TPhysicsData
{
            /**Speed is increased by this amount each second when running.*/ var() float RunningAcceleration;
/**Speed is decreased by this amount each second when running and braking.*/ var() float RunningBrakingStrength;
                    /**Speed is decreased by this amount each second when
                             running and decelerating gradually to a stop.*/ var() float RunningGroundFriction;
  /**Speed tends towards this reference value when running on flat plains.*/ var() float RunningReferenceSpeed;
                           /**Speed is increased/decreased by this amount
                                  each second when running down/up slopes.*/ var() float RunningSlopeBonus;
                            /**Maximum speed value reachable when running
                                    down slopes or due to external forces.*/ var() float RunningTopSpeed;

/**Speed is decreased by this amount each second when rolling and braking.*/ var() float RollingBrakingStrength;
                    /**Speed is decreased by this amount each second when
                             rolling and decelerating gradually to a stop.*/ var() float RollingGroundFriction;
/**Speed is increased by this amount each second when rolling down slopes.*/ var() float RollingSlopeDownBonus;
  /**Speed is decreased by this amount each second when rolling up slopes.*/ var() float RollingSlopeUpBonus;
                            /**Maximum speed value reachable when rolling
                                    down slopes or due to external forces.*/ var() float RollingTopSpeed;

 /**Horizontal speed is increased by this amount each second when falling.*/ var() float FallingAirAcceleration;
                /**Magnitude of gravity acceleration applied when falling.*/ var() float FallingGravityAccel;
      /**Horizontal speed tends towards this reference value when falling.*/ var() float FallingReferenceSpeed;

                         /**Speed value used for jumping from flat plains.*/ var() float JumpingNormalStrength;
       /**Maximum vertical speed value reachable when jumping from slopes.*/ var() float JumpingTopStrength;
	          
};
/**Data associated to different physics setups; 0 is standard, 1 is underwater,
                          2 is standard super form, 3 is underwater super form,
                          4 is standard hyper form, 5 is underwater hyper form.*/ var(Template,Physics) protected
                                                                                      array<TPhysicsData> PhysicsData;

/**Data associated to a trace.*/ struct TTraceData
{
                   /**Actor hit.*/ var Actor HitActor;
   /**Additional trace hit info.*/ var TraceHitInfo HitInfo;
/**World location of hit impact.*/ var vector HitLocation;
        /**Hit normal of impact.*/ var vector HitNormal;
       /**End location of trace.*/ var vector TraceEnd;
};

struct TVelocityData
{
            /**Cached data of floor.*/ var vector Floor;
/**Cached result: the real velocity.*/ var vector RealVelocity;
/**Cached data of Unreal's velocity.*/ var vector UnrealVelocity;
};
/**Stores last result of GetVelocity().*/ var protected TVelocityData CachedVelocityData;

              /**If true, this object's class is the
                   default pawn class for this level.*/ var(Template,Misc) bool bDefaultPawnClass;
    /**Information regarding specific character data.*/ var class<SGDKFamilyInfo> FamilyInfoClass;
/**Mesh translation offset along Z axis when ducking.*/ var(Template,Mesh) float MeshDuckingOffset;
     /**Default mesh translation offset along Z axis.*/ var float MeshStandingOffset;
                      /**Template used for this pawn.*/ var SGDKPlayerPawn PawnTemplate;
                       /**The character visible mesh.*/ var(Template,Mesh) editconst SkeletalMeshComponent VisibleMesh;

/**Objects that will get event notifications related to this pawn.*/ var array<ReceivePawnEvents> NotifyEventsTo;

/**Standard standing straight half of height for collision cylinder.*/ var float DefaultHeight;
        /**Standard standing straight radius for collision cylinder.*/ var float DefaultRadius;

                                /**Anti-gravity boots mode flag.*/ var bool bAntiGravityMode;
           /**If true, classic speed bonuses are used on slopes.*/ var(Template,Physics) bool bClassicSlopes;
           /**If true, forces next check for Sonic Physics mode.*/ var bool bForcePhysicsCheck;
                                /**Sonic Physics on ground flag.*/ var bool bOnGround;
                /**If true, world gravity direction is reversed.*/ var bool bReverseGravity;
                                     /**Sonic Physics mode flag.*/ var bool bSonicPhysicsMode;
									 
									 /**Sonic is in Mach State*/ var bool bIsMachState;
									 
									 /**Sonic is in a Half Pipe Volume*/ var bool bIsInHalfPipeVolume;
									 
                                     /**Water running mode flag.*/ var bool bWaterRunningMode;
     /**Percent of walking speed to stick to walls and ceilings.*/ var(Template,Physics) float AdhesionPct;
              /**Angle between floor normal and reverse gravity.*/ var float FloorDotAngle;
                   /**Sonic Physics current floor normal vector.*/ var vector FloorNormal;
                            /**Length of trace to ground checks.*/ var float GroundTraceLength;
  /**Maximum acceleration bonus applied while going down slopes.*/ var float MaxSlopeDownBonus;
    /**Maximum deceleration bonus applied while climbing slopes.*/ var float MaxSlopeUpBonus;
       /**Minimum speed required to stick to walls and ceilings.*/ var float MinAdhesionSpeed;
   /**Saved velocity to apply turning penalty for Sonic Physics.*/ var protected vector OldVelocity;
   /**Direction of slope when sliding down according to gravity.*/ var vector SlopeDirection;
     /**Initial time running on a slope not considered as floor.*/ var float SlopeRunningTime;
   /**Current bonus applied on slopes to adjust character speed.*/ var float SlopeSpeedBonus;
/**All blend nodes in the animation tree for Sonic Physics mode.*/ var array<SGDKAnimBlendBySonicPhysics> SonicPhysicsBlendNodes;
                    /**This pawn is stuck in Sonic Physics mode.*/ var byte StuckCount;
      /**Maximum z value allowed for walkable normals of plains.*/ var float WalkablePlainZ;
           /**Minimum z value allowed for walkable wall normals.*/ var float WalkableWallZ;
             /**Percent of walking speed needed to run on water.*/ var(Template,Physics) float WaterRunAdhesionPct;

                                           /**Spider physics mode flag.*/ var bool bSpiderPhysicsMode;
/**Half of height and radius for collision cylinder for spider physics.*/ var float SpiderRadius;
            /**The maximum value of on ground speed for spider physics.*/ var float SpiderSpeed;
			
			/**Character's current speed*/ var() float CurrentSpeed;

enum EConstrainedMovement
{
/**No constrained movement, default 3D movement.*/ CM_None,
        /**Classic movement constrained to 2.5D.*/ CM_Classic2dot5d,
      /**Runway movement constrained to 3D path.*/ CM_Runway3d,
                                    /**Not used.*/ CM_Custom1,
                                    /**Not used.*/ CM_Custom2,
                                    /**Not used.*/ CM_Custom3,
                                    /**Not used.*/ CM_Custom4,
                                    /**Not used.*/ CM_Custom5,
};
                 /**Classic movement constrained to 2.5D flag.*/ var bool bClassicMovement;
                          /**If true, movement is constrained.*/ var bool bConstrainMovement;
    /**Indicates how movement should be constrained to a path.*/ var EConstrainedMovement ConstrainedMovement;
    /**Spline actor that is currently being used as reference.*/ var SGDKSplineActor CurrentSplineActor;
/**Spline component that is currently being used as reference.*/ var SplineComponent CurrentSplineComp;
       /**Stores the last calculated 2D tangent of the spline.*/ var vector LastTangent2D;
       /**Saved location to find out linear movement for 2.5D.*/ var vector OldLocation;
    /**Distance traveled from current spline component origin.*/ var float SplineDistance;
         /**Lateral distance offset from constrained location.*/ var float SplineOffset;
  /**Encoding of rotation at the current point of spline path.*/ var vector SplineX,SplineY,SplineZ;

/**If true, air control is removed if this pawn jumps while rolling.*/ var(Template,Physics) bool bLimitRollingJump;
       /**If true, an event will be triggered when at apex of jumps.*/ var bool bNotifyJumpApex;
                                    /**Jumping sound effect to play.*/ var(Template,Sounds) SoundCue JumpingSound;
                     /**Last time a regular jump has been performed.*/ var float LastJumpTime;
  /**Time required to hold jump button and perform the highest jump.*/ var(Template,Physics) float MaxJumpImpulseTime;
                         /**Maximum vertical acceleration for jumps.*/ var float MaxJumpZ;
                   /**Speed is lowered to this value before jumping.*/ var float MaxSpeedBeforeJump;

                       /**Standard sound for dodging.*/ var(Template,Sounds) SoundCue DodgeSound;
/**Default footstep sound used when a given material
       type is not found in the footstep sounds list.*/ var(Template,Sounds) SoundCue FootstepDefaultSound;
  /**Footstep sound effect to play per material type.*/ var(Template,Sounds) array<TMaterialSoundData> FootstepSounds;
 /**Default landing sound used when a given material
        type is not found in the landing sounds list.*/ var(Template,Sounds) SoundCue LandingDefaultSound;
   /**Landing sound effect to play per material type.*/ var(Template,Sounds) array<TMaterialSoundData> LandingSounds;

             /**If true, player can unroll while rolling on ground.*/ var(Template,Skills) bool bCanUnRoll;
/**If true, scripted rolling of attached skeletal mesh is disabled.*/ var(Template,Misc) bool bDisableScriptedRoll;
                        /**If true, this pawn is ducking/crouching.*/ var bool bDucking;
                        /**If true, this pawn is rolling on ground.*/ var bool bRolling;
                       /**If true, this pawn is skidding on ground.*/ var bool bSkidding;
                /**If true, player is holding down the duck button.*/ var bool bWantsToDuck;
                       /**Minimum required speed to roll on ground.*/ var float MinRollingSpeed;
             /**All blend nodes in the animation tree for postures.*/ var array<SGDKAnimBlendByPosture> PostureBlendNodes;
                            /**Sound played when rolling on ground.*/ var(Template,Sounds) SoundCue RollingSound;
              /**Default skidding sound used when a given material
                     type is not found in the skidding sounds list.*/ var(Template,Sounds) SoundCue SkiddingDefaultSound;
                /**Skidding sound effect to play per material type.*/ var(Template,Sounds) array<TMaterialSoundData> SkiddingSounds;

                /**If true, this pawn can perform SpinDash movement.*/ var(Template,Skills) bool bCanSpinDash;
/**If true, SpinDash is only charged with consecutive jump commands.*/ var(Template,Skills) bool bClassicSpinDash;
                       /**Last time a SpinDash charge was performed.*/ var float LastSpinDashTime;
  /**Default sound played when a SpinDash movement is charged and a
       given material type is not found in the SpinDash sounds list.*/ var(Template,Sounds) SoundCue SpinDashChargeDefaultSound;
                 /**SpinDash sound effect to play per material type.*/ var(Template,Sounds) array<TMaterialSoundData> SpinDashChargeSounds;
                 /**SpinDash counter; 0 means SpinDash isn't active.*/ var int SpinDashCount;
                /**SpinDash charge decreases after this time passes.*/ var(Template,Skills) float SpinDashDecreaseTime;
                                   /**Holds SpinDash visual effects.*/ var SGDKEmitter SpinDashEmitter;
                                /**Effect to play while SpinDashing.*/ var(Template,Particles) ParticleSystem SpinDashParticleSystem;
               /**Sound played when a SpinDash movement is released.*/ var(Template,Sounds) SoundCue SpinDashReleaseSound;
   /**Percent of maximum on ground speed value for SpinDash impulse.*/ var(Template,Skills) float SpinDashSpeedPct;

                             /**If true, Sonic Physics mode is banned.*/ var bool bDisableSonicPhysics;
          /**If true, doubles gravity when falling towards the ground.*/ var bool bDoubleGravity;
                                           /**Just entered water flag.*/ var bool bEnteredWater;
                     /**If true, standard on ground speed must be low.*/ var bool bMustWalk;
               /**Factor used for a special formula that is performed
                           on horizontal speed while ascending in air.*/ var(Template,Physics) float AirDragFactor;
                              /**The maximum value of on ground speed.*/ var float ApexGroundSpeed;
                        /**Percent of deceleration rate while braking.*/ var float BrakeDecelPct;
                                     /**The default acceleration rate.*/ var float DefaultAccelRate;
                          /**The default value of the air drag factor.*/ var float DefaultAirDragFactor;
                                     /**The default deceleration rate.*/ var float DefaultDecelRate;
                /**The default scaling factor for this pawn's gravity.*/ var float DefaultGravityPct;
                                 /**The default on ground speed value.*/ var float DefaultGroundSpeed;
/**Stores default percent of deceleration rate while running on water.*/ var float DefaultWaterRunDecelPct;
                 /**Available multiplier to scale this pawn's gravity.*/ var float GravityScale;
                             /**The current value for on ground speed.*/ var float RealGroundSpeed;
             /**The reference value for on ground speed while falling.*/ var float RefAerialSpeed;
                   /**The reference value for running on ground speed.*/ var float RefGroundSpeed;
                   /**The reference value for rolling on ground speed.*/ var float RollingRefSpeed;
/**Percent of deceleration rate while running at high speed on plains.*/ var float RunningOnPlainsPct;
            /**All blend nodes related to speed in the animation tree.*/ var array<SGDKAnimBlendBySpeed> SpeedBlendNodes;
                  /**Percent of reference speed that walking speed is.*/ var float WalkSpeedPct;
       /**Percent of deceleration rate applied while running on water.*/ var(Template,Physics) float WaterRunDecelPct;

/**If true, use all rotation components set by the native physics engine.*/ var bool bFullNativeRotation;
       /**If true, alignment of the attached skeletal mesh to the ground
               takes into account the direction of gravity while walking.*/ var(Template,Misc) bool bMeshAlignToGravity;
          /**If true, rotations of the attached skeletal mesh are smooth.*/ var bool bSmoothRotation;
      /**If true, forces a rotation update of the attached skeletal mesh.*/ var bool bUpdateMeshRotation;
 /**Current non-modified rotation for attached skeletal mesh; do not use.*/ var protected rotator CurrentMeshRotation;
                          /**Desired rotation for attached skeletal mesh.*/ var rotator DesiredMeshRotation;
 /**Desired rotation for this pawn according to controller view rotation.*/ var rotator DesiredViewRotation;
       /**Desired pitch rotation for attached skeletal mesh (in radians).*/ var float MeshPitchRotation;
                  /**Rotation increment set by the native physics engine.*/ var rotator NativePhysicsRotation;
  /**Attached skeletal mesh smooth rotation rate; 0 means no smooth rate.*/ var(Template,Misc) float SmoothRotationRate;
   /**Additional mesh translation offset along Z axis used while walking.*/ var float WalkingZTranslation;

  /**Overrides velocity calculated by the native physics engine.*/ var protected vector VelocityOverride;
/**Overrides Z velocity calculated by the native physics engine.*/ var protected float VelocityZOverride;

          /**If true, this pawn died because of lack of air.*/ var bool bDrowned;
/**Stores last water volume found by GetMaterialBelowFeet().*/ var SGDKWaterVolume CachedWaterVolume;
                         /**Dying sound played when drowned.*/ var(Template,Sounds) SoundCue DrownSound;
  /**How much time this pawn can stand in water without air.*/ var(Template,Misc) float UnderwaterTimer;

enum ESpecialAction
{
     /**Special move of shields.*/ SA_ShieldMove,
/**Transform into a super state.*/ SA_SuperTransform,
   /**Special move of character.*/ SA_CharacterMove,
                    /**Not used.*/ SA_Custom1,
                    /**Not used.*/ SA_Custom2,
                    /**Not used.*/ SA_Custom3,
                    /**Not used.*/ SA_Custom4,
                    /**Not used.*/ SA_Custom5,
};
               /**If true, special moves of shields are banned.*/ var bool bDisableShieldMoves;
                          /**If true, special moves are banned.*/ var bool bDisableSpecialMoves;
/**If true, this pawn will leave the actor is standing on soon.*/ var bool bQuickLand;
                     /**Last time a special move was performed.*/ var float LastSpecialMoveTime;
/**Minimum required time between two consecutive special moves.*/ var float MinTimeSpecialMoves;
                   /**List of actions that can be performed on
                           air by pressing the Jump key/button.*/ var(Template,Skills) array<ESpecialAction> AerialActionsJump;
                   /**List of actions that can be performed on
                         air by unpressing the Jump key/button.*/ var(Template,Skills) array<ESpecialAction> AerialActionsUnJump;
                   /**List of actions that can be performed on
                           air by pressing the Duck key/button.*/ var(Template,Skills) array<ESpecialAction> AerialActionsDuck;
                   /**List of actions that can be performed on
                         air by unpressing the Duck key/button.*/ var(Template,Skills) array<ESpecialAction> AerialActionsUnDuck;
               /**List of actions that can be performed on air
                        by pressing the SpecialMove key/button.*/ var(Template,Skills) array<ESpecialAction> AerialActionsSpecialMove;
               /**List of actions that can be performed on air
                      by unpressing the SpecialMove key/button.*/ var(Template,Skills) array<ESpecialAction> AerialActionsUnSpecialMove;

                 /**If true, this pawn is pushing an object.*/ var bool bPushing;
                         /**The object that is being pushed.*/ var PushableKActor PushableActor;
                          /**Constant direction of the push.*/ var vector PushDirection;
/**Counter that enables or disables bPushesRigidBodies flag.*/ var int PushRigidBodies;

              /**Hanging from an actor mode flag.*/ var bool bHanging;
        /**Actor from which this pawn is hanging.*/ var HandleActor HangingActor;
                /**The default hanging animation.*/ var name HangingAnimation;
				/**The default Mach State animation.*/ var name MachStateAnimation;
/**Last time this pawn was hanging from an actor.*/ var float LastHangingTime;

  /**DamageType class to use for invulnerability.*/ var class<SGDKDamagetype> InvincibleDamageType;
            /**DamageType class to use for jumps.*/ var class<SGDKDamagetype> JumpedDamageType;
/**DamageType class to use for rolling on ground.*/ var class<SGDKDamagetype> RollingDamageType;

     /**If true, disables the circular blob shadows.*/ var(Template,Misc) bool bDisableBlobShadows;
/**BlobShadowActor class to use for the blob shadow.*/ var class<BlobShadowActor> BlobShadowClass;
  /**The circular blob shadow attached to this pawn.*/ var BlobShadowActor Shadow;

       /**Bounce factor applied to owner JumpZ for bubble shield.*/ var(Template,Shields) float BubbleBounceFactor;
                          /**The material used for bubble shield.*/ var(Template,Shields) MaterialInterface BubbleMaterial;
               /**The applied speed boost for bubble shield move.*/ var(Template,Shields) float BubbleSpeedBoost;
    /**Scale to apply to gravity while doing special flame boost.*/ var(Template,Shields) float FlameGravityScale;
   /**Targets within this radius are considered for flame shield.*/ var(Template,Shields) float FlameHomingRadius;
                           /**The material used for flame shield.*/ var(Template,Shields) MaterialInterface FlameMaterial;
                /**The applied speed boost for flame shield move.*/ var(Template,Shields) float FlameSpeedBoost;
                        /**The material used for magnetic shield.*/ var(Template,Shields) MaterialInterface MagneticMaterial;
/**Targets within this radius are considered for magnetic shield.*/ var(Template,Shields) float MagneticRingsRadius;
             /**The applied speed boost for magnetic shield move.*/ var(Template,Shields) float MagneticSpeedBoost;
                       /**The shield actor attached to this pawn.*/ var ShieldActor Shield;
                      /**ShieldActor class to use for the shield.*/ var class<ShieldActor> ShieldClass;
                        /**The material used for standard shield.*/ var(Template,Shields) MaterialInterface StandardMaterial;

/**If true, this pawn doesn't blink after taking damage.*/ var(Template,Misc) bool bDisableDamageBlink;
        /**If true, this pawn drops all rings when hurt.*/ var(Template,Misc) bool bDropAllRings;
           /**If true, this pawn is disabled/turned off.*/ var bool bTurnedOff;
                              /**Class of dropped rings.*/ var class<RingProjectile> DroppedRingsClass;
                /**Sound played when player drops rings.*/ var(Template,Sounds) SoundCue DroppedRingsSound;
                                /**Standard dying sound.*/ var(Template,Sounds) SoundCue DyingSound;
              /**Animation played when player gets hurt.*/ var name HurtAnimation;
                  /**Sound played when player gets hurt.*/ var(Template,Sounds) SoundCue HurtSound;
                             /**Initial amount of rings.*/ var(Template,Misc) byte InitialRings <ClampMax=50>;
                           /**Last time player got hurt.*/ var float LastDamageTime;
     /**Time period during which damage will be ignored.*/ var(Template,Misc) float MinTimeDamage;
       /**Factor applied to initial velocity of ragdoll.*/ var(Template,Misc) float RagdollImpulseFactor;
  /**How old the ragdoll lives before trying to respawn.*/ var(Template,Misc) float RagdollTimeSpan;

                                  /**If true, mini-size mode is enabled.*/ var bool bMiniSize;
   /**Mini-size standing straight half of height for collision cylinder.*/ var float MiniHeight;
           /**Mini-size standing straight radius for collision cylinder.*/ var float MiniRadius;
/**All blend nodes related to animation play rate in the animation tree.*/ var array<AnimNodeScaleRateBySpeed> PlayRateBlendNodes;

       /**Coordinates for mapping the character name for the HUD.*/ var(Template,Misc) TextureCoordinates HudCharNameCoords;
      /**Coordinates for mapping the decoration icon for the HUD.*/ var(Template,Misc) TextureCoordinates HudDecorationCoords;
/**Coordinates for mapping the decoration icon for standard form.*/ var TextureCoordinates NormalHudDecoCoords;

           /**If true, this pawn can acquire hyper form status.*/ var(Template,Super) bool bHasHyperForm;
/**If true, this pawn has super form status and its advantages.*/ var bool bSuperForm;
               /**If true, this pawn has hyper form status too.*/ var bool bHyperForm;
     /**While in super form, one ring per this time is removed.*/ var(Template,Super) float RingCountdownTime;
 /**Animation set used on top of all anim sets for super forms.*/ var(Template,Super) AnimSet SuperAnimSet;
                    /**DamageType class to use for super forms.*/ var class<SGDKDamagetype> SuperDamageType;
      /**All blend nodes in the animation tree for super forms.*/ var array<SGDKAnimBlendBySuperForm> SuperFormBlendNodes;
  /**Coordinates for mapping the decoration icon of super form.*/ var(Template,Super) TextureCoordinates SuperHudDecoCoords;
  /**Coordinates for mapping the decoration icon of hyper form.*/ var(Template,Super) TextureCoordinates HyperHudDecoCoords;
                         /**Dynamic point light of super forms.*/ var SGDKSpawnablePointLight SuperLight;
              /**Brightness to use for the light of super form.*/ var(Template,Super) float SuperLightBrightness;
              /**Brightness to use for the light of hyper form.*/ var(Template,Super) float HyperLightBrightness;
                /**Class of dynamic point light of super forms.*/ var(Template,Super) class<SGDKSpawnablePointLight> SuperLightClass;
                   /**Color to use for the light of super form.*/ var(Template,Super) Color SuperLightColor;
                   /**Color to use for the light of hyper form.*/ var(Template,Super) Color HyperLightColor;
                  /**The particle visual effects of super form.*/ var(Template,Super) ParticleSystem SuperParticleSystem;
                  /**The particle visual effects of hyper form.*/ var(Template,Super) ParticleSystem HyperParticleSystem;
          /**Trailing skeletal mesh ghosts used for hyper form.*/ var SkeletalMeshComponent HyperSkeletalGhosts[2];
            /**Mesh reference for super form of this character.*/ var(Template,Super) SkeletalMesh SuperSkeletalMesh;
            /**Mesh reference for hyper form of this character.*/ var(Template,Super) SkeletalMesh HyperSkeletalMesh;
               /**Holds particle visual effects of super forms.*/ var SGDKEmitter SuperEmitter;

/**A life is granted after surpassing this limit of health.*/ var int HealthLimit;
       /**MonitorInventory class that grants an extra life.*/ var class<MonitorInventory> LifeInventoryClass;
    /**Multiplier applied to scoring for enemy destruction.*/ var float ScoreMultiplier;

/**The default victory animation.*/ var name VictoryAnimation;

  /**Effect to play while using "drill" orb.*/ var(Template,Particles) ParticleSystem OrbDrillParticles;
/**Holds the visual effects related to orbs.*/ var SGDKEmitter OrbEmitter;
  /**Effect to play while using "hover" orb.*/ var(Template,Particles) ParticleSystem OrbHoverParticles;
  /**Effect to play while using "laser" orb.*/ var(Template,Particles) ParticleSystem OrbLaserParticles;
 /**Effect to play while using "rocket" orb.*/ var(Template,Particles) ParticleSystem OrbRocketParticles;
 /**Effect to play while using "spikes" orb.*/ var(Template,Particles) ParticleSystem OrbSpikesParticles;
   /**Sound played when a SpinDash movement
        is charged while using "spikes" orb.*/ var(Template,Sounds) SoundCue OrbSpikesSound;


/**
 * Called immediately before gameplay begins.
 */
simulated event PreBeginPlay()
{
    local SGDKPlayerPawn P;

    if (!IsTemplate())
    {
        super.PreBeginPlay();

        //Hide all arms and overlay meshes because this pawn doesn't hold any first person weapons.
        if (ArmsMesh[0] != none)
            ArmsMesh[0].SetHidden(true);

        if (ArmsMesh[1] != none)
            ArmsMesh[1].SetHidden(true);

        //Store default values for collision height and radius.
        DefaultHeight = CylinderComponent.CollisionHeight;
        DefaultRadius = CylinderComponent.CollisionRadius;

        //Search for a pawn template in the map.
        foreach WorldInfo.AllPawns(class'SGDKPlayerPawn',P)
            if (P.IsTemplate() && P.Class == Class)
            {
                PawnTemplate = P;

                break;
            }

        //Use data from pawn template if it exists.
        if (PawnTemplate != none)
        {
            Tag = PawnTemplate.Tag;

            //Copy misc data.
            bDisableBlobShadows = PawnTemplate.bDisableBlobShadows;
            bDisableDamageBlink = PawnTemplate.bDisableDamageBlink;
            bDisableScriptedRoll = PawnTemplate.bDisableScriptedRoll;
            bDropAllRings = PawnTemplate.bDropAllRings;
            bMeshAlignToGravity = PawnTemplate.bMeshAlignToGravity;
            HudCharNameCoords = PawnTemplate.HudCharNameCoords;
            HudDecorationCoords = PawnTemplate.HudDecorationCoords;
            InitialRings = PawnTemplate.InitialRings;
            MinTimeDamage = PawnTemplate.MinTimeDamage;
            RagdollImpulseFactor = PawnTemplate.RagdollImpulseFactor;
            RagdollTimeSpan = PawnTemplate.RagdollTimeSpan;
            SmoothRotationRate = PawnTemplate.SmoothRotationRate;
            UnderwaterTimer = PawnTemplate.UnderwaterTimer;

            //Copy physics.
            bClassicSlopes = PawnTemplate.bClassicSlopes;
            bLimitRollingJump = PawnTemplate.bLimitRollingJump;
            AdhesionPct = PawnTemplate.AdhesionPct;
            AirDragFactor = PawnTemplate.AirDragFactor;
            MaxJumpImpulseTime = PawnTemplate.MaxJumpImpulseTime;
            PhysicsData = PawnTemplate.PhysicsData;
            WaterRunAdhesionPct = PawnTemplate.WaterRunAdhesionPct;
            WaterRunDecelPct = PawnTemplate.WaterRunDecelPct;

            //Copy sounds.
            DodgeSound = PawnTemplate.DodgeSound;
            DroppedRingsSound = PawnTemplate.DroppedRingsSound;
            DrownSound = PawnTemplate.DrownSound;
            DyingSound = PawnTemplate.DyingSound;
            FootstepDefaultSound = PawnTemplate.FootstepDefaultSound;
            FootstepSounds = PawnTemplate.FootstepSounds;
            HurtSound = PawnTemplate.HurtSound;
            JumpingSound = PawnTemplate.JumpingSound;
            LandingDefaultSound = PawnTemplate.LandingDefaultSound;
            LandingSounds = PawnTemplate.LandingSounds;
            OrbSpikesSound = PawnTemplate.OrbSpikesSound;
            RollingSound = PawnTemplate.RollingSound;
            SkiddingDefaultSound = PawnTemplate.SkiddingDefaultSound;
            SkiddingSounds = PawnTemplate.SkiddingSounds;
            SpinDashChargeDefaultSound = PawnTemplate.SpinDashChargeDefaultSound;
            SpinDashChargeSounds = PawnTemplate.SpinDashChargeSounds;
            SpinDashReleaseSound = PawnTemplate.SpinDashReleaseSound;

            //Copy skills.
            bCanSpinDash = PawnTemplate.bCanSpinDash;
            bCanUnRoll = PawnTemplate.bCanUnRoll;
            bClassicSpinDash = PawnTemplate.bClassicSpinDash;
            AerialActionsJump = PawnTemplate.AerialActionsJump;
            AerialActionsUnJump = PawnTemplate.AerialActionsUnJump;
            AerialActionsDuck = PawnTemplate.AerialActionsDuck;
            AerialActionsUnDuck = PawnTemplate.AerialActionsUnDuck;
            AerialActionsSpecialMove = PawnTemplate.AerialActionsSpecialMove;
            AerialActionsUnSpecialMove = PawnTemplate.AerialActionsUnSpecialMove;
            SpinDashDecreaseTime = PawnTemplate.SpinDashDecreaseTime;
            SpinDashSpeedPct = PawnTemplate.SpinDashSpeedPct;

            //Copy super params.
            bHasHyperForm = PawnTemplate.bHasHyperForm;
            RingCountdownTime = PawnTemplate.RingCountdownTime;
            SuperHudDecoCoords = PawnTemplate.SuperHudDecoCoords;
            HyperHudDecoCoords = PawnTemplate.HyperHudDecoCoords;
            SuperLightBrightness = PawnTemplate.SuperLightBrightness;
            HyperLightBrightness = PawnTemplate.HyperLightBrightness;
            SuperLightClass = PawnTemplate.SuperLightClass;
            SuperLightColor = PawnTemplate.SuperLightColor;
            HyperLightColor = PawnTemplate.HyperLightColor;
            SuperParticleSystem = PawnTemplate.SuperParticleSystem;
            HyperParticleSystem = PawnTemplate.HyperParticleSystem;

            //Copy shield data.
            BubbleBounceFactor = PawnTemplate.BubbleBounceFactor;
            BubbleMaterial = PawnTemplate.BubbleMaterial;
            BubbleSpeedBoost = PawnTemplate.BubbleSpeedBoost;
            FlameGravityScale = PawnTemplate.FlameGravityScale;
            FlameHomingRadius = PawnTemplate.FlameHomingRadius;
            FlameMaterial = PawnTemplate.FlameMaterial;
            FlameSpeedBoost = PawnTemplate.FlameSpeedBoost;
            MagneticMaterial = PawnTemplate.MagneticMaterial;
            MagneticRingsRadius = PawnTemplate.MagneticRingsRadius;
            MagneticSpeedBoost = PawnTemplate.MagneticSpeedBoost;
            StandardMaterial = PawnTemplate.StandardMaterial;

            //Copy particles.
            OrbDrillParticles = PawnTemplate.OrbDrillParticles;
            OrbHoverParticles = PawnTemplate.OrbHoverParticles;
            OrbLaserParticles = PawnTemplate.OrbLaserParticles;
            OrbRocketParticles = PawnTemplate.OrbRocketParticles;
            OrbSpikesParticles = PawnTemplate.OrbSpikesParticles;
            SpinDashParticleSystem = PawnTemplate.SpinDashParticleSystem;
        }
    }
    else
        InitialState = 'Template';
}

/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    if (!IsTemplate())
    {
        super.PostBeginPlay();

        //Set falling physics for startup.
        SetPhysics(PHYS_Falling);

        //Initialize values.
        CurrentMeshRotation = Rotation;
        DefaultAirDragFactor = AirDragFactor;
        DefaultWaterRunDecelPct = WaterRunDecelPct;
        DesiredMeshRotation = Rotation;
        DesiredViewRotation = Rotation;
        Health = InitialRings + 1;
        NormalHudDecoCoords = HudDecorationCoords;
        OldLocation = Location;
        ResetPhysicsValues();
        SetGroundSpeed(DefaultGroundSpeed);
        GroundTraceLength = DefaultHeight * 1.75;
        RefGroundSpeed = DefaultGroundSpeed;
        UnderWaterTime = UnderwaterTimer;

        //Create a blob shadow and attach it.
        Shadow = Spawn(BlobShadowClass,self,,Location,rotator(GetGravityDirection()));
        Shadow.SetBase(self);

        //Create a shield and attach it.
        Shield = Spawn(ShieldClass,self);
        AttachToRoot(Shield);
    }
}

/**
 * Called immediately before destroying this actor.
 */
simulated event Destroyed()
{
    local int i;

    //Destroy all attached actors.
    for (i = 0; i < RootAttachments.Length; i++)
        if (RootAttachments[i].AttachedActor != none && !RootAttachments[i].AttachedActor.bDeleteMe)
        {
            RootAttachments[i].AttachedActor.SetBase(none);
            RootAttachments[i].AttachedActor.Destroy();
        }

    //Empty the array.
    RootAttachments.Length = 0;

    //Destroy the attached blob shadow.
    if (Shadow != none)
        Shadow.Destroy();

    super.Destroyed();
}

/**
 * Called after actor's base changes.
 */
singular event BaseChange()
{
    if (Pawn(Base) != none && (DrivenVehicle == none || !DrivenVehicle.IsBasedOn(Base)))
    {
        if (!WillBeBounced() && !Pawn(Base).CanBeBaseForPawn(self))
            Bounce(GetGravityDirection() * -500.0,true,false,true,Base,'Enemy');
    }
    else
        if (DynamicSMActor(Base) != none && !DynamicSMActor(Base).CanBasePawn(self))
            Bounce(GetGravityDirection() * -500.0,true,false,true,Base,'InvalidBase');
}

/**
 * Called by the camera when this actor becomes its ViewTarget.
 * @param PC  the controller that owns the camera
 */
simulated event BecomeViewTarget(PlayerController PC)
{
    super.BecomeViewTarget(PC);

    bUpdateEyeheight = default.bUpdateEyeheight;
}

/**
 * Called when the breath timer runs out.
 */
event BreathTimer()
{
    TakeDamage(1,none,Location,vect(0,0,0),class'SGDKDmgType_Drowned');
}

/**
 * Called when this actor gets pushed somewhere and there isn't enough space at that location.
 * @param Other  the other actor that pushed this actor
 */
event EncroachedBy(Actor Other)
{
    if (Pawn(Other) != none)
    {
        if (!Other.bDeleteMe && Pawn(Other).Health > 0 && Vehicle(Other) == none &&
            Other.Physics != PHYS_Interpolating && Other.Physics != PHYS_RigidBody)
            GibbedBy(Other);
    }
    else
        if (Other != none && !Other.bDeleteMe && !Other.bIgnoreEncroachers && DynamicSMActor(Other) == none)
            GibbedBy(Other);
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

        //No multi-jumps until landing.
        MultiJumpRemaining = 0;
    }

    LeftGround();

    bUpdateMeshRotation = true;
}

/**
 * Called when the pawn's head enters a new physics volume.
 * @param NewHeadVolume  the new physics volume in which the pawn's head is standing in
 */
event HeadVolumeChange(PhysicsVolume NewHeadVolume)
{
    local ReceivePawnEvents NotifyObject;

    //If the new volume isn't a water volume and the old volume was a water volume...
    if (!NewHeadVolume.bWaterVolume && HeadVolume != none && HeadVolume.bWaterVolume)
    {
        Breath(true);

        //Notify other objects.
        foreach NotifyEventsTo(NotifyObject)
            NotifyObject.PawnHeadLeftWater(self,HeadVolume);
    }
    else
        //If the new volume is a water volume and the old volume wasn't a water volume...
        if (NewHeadVolume.bWaterVolume && (HeadVolume == none || !HeadVolume.bWaterVolume))
        {
            if (!bHyperForm)
                Breath(false);

            //Notify other objects.
            foreach NotifyEventsTo(NotifyObject)
                NotifyObject.PawnHeadEnteredWater(self,NewHeadVolume);
        }
}

/**
 * Called when the pawn collides with a blocking piece of world geometry.
 * @param HitNormal      the surface normal of the hit actor/level geometry
 * @param WallActor      the hit actor
 * @param WallComponent  the associated primitive component of the wall actor
 */
event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
{
    local vector Y,Z;
    local float DotAngle;
    local int i;

    //Inflicts melee damage to fractured actors.
    if (!WallActor.bStatic && IsUsingMelee() && FracturedStaticMeshActor(WallActor) != none)
        MeleeDamage(WallActor,HitNormal);

    if (Physics == PHYS_Falling)
    {
        //If Sonic Physics mode is allowed...
        if (!bDisableSonicPhysics)
        {
            //If world gravity direction is reversed and the wall actor is walkable...
            if (bReverseGravity && HitNormal dot vect(0,0,-1) > WalkableFloorZ)
            {
                //Trigger landed event.
                TriggerLanded(HitNormal,WallActor);

                Velocity.Z = 0.0;

                //Set Sonic Physics mode.
                FloorNormal = HitNormal;
                SetSonicPhysics(true);
                SetBase(WallActor);
            }
            else
                //If anti-gravity boots mode is enabled or speed is enough to stick to wall, and
                //a proper raycast check gets the same wall object...
                if ((bAntiGravityMode || Abs(Velocity.Z) > MinAdhesionSpeed) &&
                    IsSonicPhysicsAllowed(WallActor) &&
                    Trace(Y,HitNormal,Location + HitNormal * -GroundTraceLength,
                          Location,true,GetCollisionExtent(),,TRACEFLAG_Blocking) == WallActor)
                {
                    DotAngle = -(HitNormal dot GetGravityDirection());

                    //If angle between surface normal and reverse gravity is less than 75° or
                    //greater than 105° and less than 135°, and velocity direction is acceptable...
                    if ((DotAngle > WalkableWallZ || (DotAngle < -WalkableWallZ && DotAngle > -WalkableFloorZ)) &&
                        (bAntiGravityMode || Abs(Normal(Velocity) dot HitNormal) < WalkableFloorZ))
                    {
                        //Trigger landed event.
                        TriggerLanded(HitNormal,WallActor);

                        //Set rotation along the ramp.
                        Z = HitNormal;
                        Y = Z cross Normal(Velocity);
                        ForceRotation(OrthoRotation(Y cross Z,Y,Z),ShouldRotateView());

                        //Set Sonic Physics mode.
                        FloorNormal = HitNormal;
                        SetSonicPhysics(true);
                        SetBase(WallActor);
                    }
                }
        }

        //If collided against a ceiling...
        if (!bSonicPhysicsMode && Velocity.Z > 0.0 && HitNormal.Z < 0.0 && VelocityOverride == default.VelocityOverride)
        {
            //Override Z velocity so that this pawn isn't bounced harshly by the native physics engine.
            Velocity.Z *= HitNormal.Z + 1.0;
            VelocityZOverride = Velocity.Z;
        }
    }
    else
        //If not already pushing, wall actor is pushable and really valid to push...
        if (!bPushing && PushableKActor(WallActor) != none && WallActor != Base &&
            IsTouchingGround() && CanPush() && IsValidPush(WallComponent))
        {
            //Set some values.
            bPushing = true;
            PushableActor = PushableKActor(WallActor);
            PushDirection = PushableActor.GetPushDirection(HitNormal);

            //Notify blend nodes the change of posture.
            for (i = 0; i < PostureBlendNodes.Length; i++)
                PostureBlendNodes[i].PostureChanged(5);
        }
}

/**
 * Called when the pawn lands on level geometry while falling.
 * @param HitNormal   the surface normal of the actor/level geometry landed on
 * @param FloorActor  the actor landed on
 */
event Landed(vector HitNormal,Actor FloorActor)
{
    local ReceivePawnEvents NotifyObject;
    local vector X,Y,Z;

    if (FloorActor != none)
    {
        if (UTVehicle(FloorActor) != none)
            //Applies an impulse to vehicles.
            UTVehicle(FloorActor).Mesh.AddImpulse(Velocity * vect(0,0,4),Location);
        else
            if (DynamicSMActor(FloorActor) != none)
                //Applies am impulse to dynamic static mesh actors.
                DynamicSMActor(FloorActor).StaticMeshComponent.AddImpulse(Velocity * vect(0,0,4),Location);
            else
                if (FracturedStaticMeshActor(FloorActor) != none && IsUsingMelee())
                    //Inflicts melee damage to fractured actors.
                    MeleeDamage(FloorActor,HitNormal);
    }

    //Notify other objects.
    foreach NotifyEventsTo(NotifyObject)
        NotifyObject.PawnLanded(self,WillLeaveGround(),HitNormal,FloorActor);

    //Restore original values.
    bDodging = false;
    bDoubleGravity = default.bDoubleGravity;
    bReadyToDoubleJump = false;
    AirControl = DefaultAirControl;
    LastJumpTime = 0.0;
    MeshPitchRotation = 0.0;
    MultiJumpRemaining = MaxMultiJump;

    //Set this native on ground speed value so that player doesn't lose speed.
    GroundSpeed = VSize2D(Velocity);

    if (!WillLeaveGround())
    {
        ScoreMultiplier = default.ScoreMultiplier;

        //Updates player eye height position.
        if (Abs(Velocity.Z) > 200.0)
        {
            OldZ = Location.Z;
            bJustLanded = (bUpdateEyeHeight && Controller != none && Controller.LandingShake());
        }

        //If visible...
        if (!IsInvisible())
        {
            //Alerts nearby AI.
            if (Abs(Velocity.Z) > 1.4 * JumpZ)
                MakeNoise(0.5);
            else
                if (Abs(Velocity.Z) > 0.8 * JumpZ)
                    MakeNoise(0.2);

            //Plays landing sound.
            PlayLandingSound();
        }

        //Adjusts base eye height.
        SetBaseEyeheight();

        //Hide the blob shadow.
        Shadow.SetHidden(true);

        //If player wants to duck and enough speed...
        if (!bRolling && bWantsToDuck && !bMiniSize && VSizeSq(Velocity) > Square(MinRollingSpeed))
            //Roll on ground.
            Roll(true);

        //If Sonic Physics mode is allowed...
        if (!bDisableSonicPhysics && IsSonicPhysicsAllowed(FloorActor))
        {
            FloorNormal = HitNormal;

            //Adjust velocity according to floor.
            GetAxes(rotator(FloorNormal),X,Y,Z);
            Velocity = PointProjectToPlane(Velocity,vect(0,0,0),Y,Z);

            //Set this native on ground speed value so that player doesn't lose speed.
            GroundSpeed = VSize(Velocity);

            Y = Normal(FloorNormal cross vector(DesiredMeshRotation));
            DesiredMeshRotation = OrthoRotation(Y cross FloorNormal,Y,FloorNormal);

            //Set Sonic Physics mode.
            SetSonicPhysics(true);
            SetBase(FloorActor);
        }

        //Force check for Sonic Physics mode in the next tick.
        bForcePhysicsCheck = true;
    }
}

/**
 * Called when the pawn enters a new physics volume.
 * @param NewVolume  the new physics volume in which the pawn is standing in
 */
event PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    local ReceivePawnEvents NotifyObject;

    //If the new volume isn't a water volume and the old volume was a water volume...
    if (!NewVolume.bWaterVolume && PhysicsVolume.bWaterVolume)
    {
        //Notify other objects.
        foreach NotifyEventsTo(NotifyObject)
            NotifyObject.PawnLeftWater(self,PhysicsVolume);
    }
    else
        //If the new volume is a water volume and the old volume wasn't a water volume...
        if (NewVolume.bWaterVolume && !PhysicsVolume.bWaterVolume)
        {
            //Notify other objects.
            foreach NotifyEventsTo(NotifyObject)
                NotifyObject.PawnEnteredWater(self,NewVolume);
        }

    //Change physics data according to new physics environment.
    //It's delayed so that it doesn't get called many times in a row.
    SetTimer(0.1,false,NameOf(PhysicsVolumeChangeDelayed));
}

/**
 * Called after initializing the AnimTree for the given SkeletalMeshComponent that has this pawn as its owner.
 * This is a good place to cache references to skeletal controllers and animation blend nodes.
 * @param SkelComponent  the affected skeletal mesh component
 */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComponent)
{
    local SGDKAnimBlendByFalling FallingBlendNode;
    local AnimNodeScaleRateBySpeed PlayRateBlendNode;
    local SGDKAnimBlendByPosture PostureBlendNode;
    local SGDKAnimBlendBySonicPhysics SonicPhysicsBlendNode;
    local SGDKAnimBlendBySpeed SpeedBlendNode;
    local SGDKAnimBlendBySuperForm SuperFormBlendNode;

    super.PostInitAnimTree(SkelComponent);

    //If the affected skeletal mesh component is the one the pawn has...
    if (SkelComponent == Mesh)
    {
        //Search for all blend nodes related to falling in the animation tree.
        foreach Mesh.AllAnimNodes(class'SGDKAnimBlendByFalling',FallingBlendNode)
            FallingBlendNode.PawnOwner = self;

        PlayRateBlendNodes.Length = 0;
        PostureBlendNodes.Length = 0;
        SonicPhysicsBlendNodes.Length = 0;
        SpeedBlendNodes.Length = 0;
        SuperFormBlendNodes.Length = 0;

        //Search for all blend nodes related to postures in the animation tree.
        foreach Mesh.AllAnimNodes(class'AnimNodeScaleRateBySpeed',PlayRateBlendNode)
            PlayRateBlendNodes.AddItem(PlayRateBlendNode);

        //Search for all blend nodes related to postures in the animation tree.
        foreach Mesh.AllAnimNodes(class'SGDKAnimBlendByPosture',PostureBlendNode)
            PostureBlendNodes.AddItem(PostureBlendNode);

        //Search for all blend nodes related to Sonic Physics mode in the animation tree.
        foreach Mesh.AllAnimNodes(class'SGDKAnimBlendBySonicPhysics',SonicPhysicsBlendNode)
            SonicPhysicsBlendNodes.AddItem(SonicPhysicsBlendNode);

        //Search for all blend nodes related to speed in the animation tree.
        foreach Mesh.AllAnimNodes(class'SGDKAnimBlendBySpeed',SpeedBlendNode)
            SpeedBlendNodes.AddItem(SpeedBlendNode);

        //Search for all blend nodes related to super form in the animation tree.
        foreach Mesh.AllAnimNodes(class'SGDKAnimBlendBySuperForm',SuperFormBlendNode)
            SuperFormBlendNodes.AddItem(SuperFormBlendNode);
    }
}

/**
 * Called when the physics mode changes from falling and its related notification is enabled.
 */
event StoppedFalling()
{
    bNotifyStopFalling = false;
}

/**
 * Applies some amount of damage to this actor.
 * @param DamageAmount     the base damage to apply
 * @param EventInstigator  the controller responsible for the damage
 * @param HitLocation      world location where the hit occurred
 * @param Momentum         force/impulse caused by this hit
 * @param DamageClass      class describing the damage that was done
 * @param HitInfo          additional info about where the hit occurred
 * @param DamageCauser     the actor that directly caused the damage
 */
event TakeDamage(int DamageAmount,Controller EventInstigator,vector HitLocation,vector Momentum,
                 class<DamageType> DamageClass,optional TraceHitInfo HitInfo,optional Actor DamageCauser)
{
    local int ActualDamage,i;
    local Controller Killer;
    local SeqEvent_TakeDamage DamageEvent;
    local ReceivePawnEvents NotifyObject;

    if (Health > 0)
    {
        //Accumulate damage taken in a single tick.
        if (AccumulationTime != WorldInfo.TimeSeconds)
        {
            AccumulateDamage = 0.0;
            AccumulationTime = WorldInfo.TimeSeconds;

            if (DamageCauser != none && ClassIsChildOf(DamageClass,class'SGDKDmgType_Crushed'))
                return;
        }

        DamageAmount = Max(0,DamageAmount);

        if (DamageClass == none)
            DamageClass = class'DamageType';

        if (HitLocation == vect(0,0,0))
            HitLocation = Location;

        if (IsTouchingGround() && DamageClass.default.bExtraMomentumZ)
        {
            if (!bReverseGravity)
                Momentum.Z = FMax(Momentum.Z,VSize(Momentum) * 0.5);
            else
                Momentum.Z = FMin(Momentum.Z,VSize(Momentum) * 0.5);
        }

        if (DrivenVehicle != none)
            DrivenVehicle.AdjustDriverDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageClass);

        ActualDamage = DamageAmount;

        WorldInfo.Game.ReduceDamage(ActualDamage,self,EventInstigator,HitLocation,Momentum,DamageClass,DamageCauser);
        AdjustDamage(ActualDamage,Momentum,EventInstigator,HitLocation,DamageClass,HitInfo,DamageCauser);

        if (ActualDamage > -1)
        {
            ActualDamage = Max(0,ActualDamage);

            //Search for any damage events.
            for (i = 0; i < GeneratedEvents.Length; i++)
            {
                DamageEvent = SeqEvent_TakeDamage(GeneratedEvents[i]);

                if (DamageEvent != none)
                    //Notify the event of the damage received.
                    DamageEvent.HandleDamage(self,EventInstigator,DamageClass,ActualDamage);
            }

            CancelMoves();

            Health -= ActualDamage;
            LastDamageTime = WorldInfo.TimeSeconds;

            if (Health > 0)
            {
                if (!IsZero(Momentum))
                    Bounce(Momentum,true,false,false,DamageCauser,'Damage');

                if (DrivenVehicle != none)
                    DrivenVehicle.NotifyDriverTakeHit(EventInstigator,HitLocation,ActualDamage,DamageClass,Momentum);

                if (EventInstigator != none && EventInstigator != Controller)
                    LastHitBy = EventInstigator;

                if (ActualDamage > 0)
                    DropRings(ActualDamage);

                if (WorldInfo.TimeSeconds - LastPainSound > MinTimeBetweenPainSounds)
                {
                    LastPainSound = WorldInfo.TimeSeconds;

                    if (ActualDamage > 0)
                        PlayHurtSound();
                }

                if (HurtAnimation != '')
                    StartAnimation(HurtAnimation,1.0,0.1,0.2,false);

                foreach NotifyEventsTo(NotifyObject)
                    NotifyObject.PawnTookDamage(self,DamageCauser);
            }
            else
            {
                Killer = SetKillInstigator(EventInstigator,DamageClass);

                if (PhysicsVolume.bDestructive && PhysicsVolume.bWaterVolume &&
                    WaterVolume(PhysicsVolume).ExitActor != none)
                    Spawn(WaterVolume(PhysicsVolume).ExitActor);

                if (ClassIsChildOf(DamageClass,class'SGDKDmgType_Drowned'))
                    bDrowned = true;

                foreach NotifyEventsTo(NotifyObject)
                    NotifyObject.PawnTookDamage(self,DamageCauser);

                Died(Killer,DamageClass,HitLocation);

                Mesh.SetRBLinearVelocity((Velocity * vect(1,1,0) + Momentum) * RagdollImpulseFactor,false);
            }

            LastPainTime = WorldInfo.TimeSeconds;

            MakeNoise(1.0);

            AccumulateDamage += ActualDamage;
        }
    }
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    local float AccelBonus,SpeedZ;
    local byte i;
    local vector MeshTranslation,OldVel,RealVelocity,V1,V2,V3;
    local ReceivePawnEvents NotifyObject;

    super.Tick(DeltaTime);

    //If pawn is alive...
    if (Health > 0)
    {
        OldVel = OldVelocity;

        if (Physics == PHYS_Walking)
            //Walking physics only works with flat XY velocity vectors.
            Velocity.Z = 0.0;

        if (!bDisableSonicPhysics && (bForcePhysicsCheck || Physics != PHYS_Walking || !IsZero(Velocity)))
            CheckSonicPhysics();

        bCanCrouch = false;
        bEnteredWater = bEnteredWater && PhysicsVolume.bWaterVolume;
        bForcePhysicsCheck = false;
        AccelRate = DefaultAccelRate;
        BaseTranslationOffset = 0.0;
        CustomGravityScaling = DefaultGravityPct * GravityScale;
        DecelData.bEnabled = false;
        DecelRate = DefaultDecelRate;
        MeshTranslation = vect(0,0,1) * MeshStandingOffset;
        SlopeDirection = vect(0,0,0);
        SlopeSpeedBonus = 0.0;

        if (IsTouchingGround())
        {
            if (bEnteredWater)
            {
                i = GetPhysicsDataIndex();

                SetVelocity(GetVelocity() * PhysicsData[i].RunningTopSpeed / PhysicsData[i - 1].RunningTopSpeed);
            }

            RealVelocity = GetVelocity();
            CurrentSpeed = VSize(RealVelocity);

            V1 = GetFloorNormal();
            V2 = -GetGravityDirection();
            FloorDotAngle = V1 dot V2;

            if (CurrentSpeed < MinRollingSpeed && Physics != PHYS_Spider)
            {
                if (bRolling)
                    Roll(false);

                if (!bMiniSize && (bAntiGravityMode || FloorDotAngle > 0.87))
                {
                    bCanCrouch = true;

                    if (bWantsToDuck && !bDucking)
                        Duck(true);
                }
            }

            if (bDucking)
            {
                if (!bCanCrouch)
                    Duck(false);
                else
                {
                    CurrentSpeed = 0.0;
                    RealVelocity = vect(0,0,0);

                    Velocity = vect(0,0,0);
                    Acceleration = vect(0,0,0);
                }
            }

            if (bSonicPhysicsMode)
                UpdateCollisionCylinder();

            if (!bRolling)
            {
                if (Physics != PHYS_Spider)
                {
                    RefGroundSpeed = DefaultGroundSpeed;

                    if (!bMustWalk && (SGDKPlayerController(Controller).AnalogAccelPct > 0.9 ||
                        CurrentSpeed > DefaultGroundSpeed + 5.0))
                        RefGroundSpeed /= WalkSpeedPct;
                }
                else
                {
                    RefGroundSpeed = SpiderSpeed;

                    if (SGDKPlayerController(Controller).AnalogAccelPct < 0.9 &&
                        CurrentSpeed < SpiderSpeed * 0.5 + 5.0)
                        RefGroundSpeed *= 0.5;
                }

                AccelRate *= SGDKPlayerController(Controller).AnalogAccelPct;

                if (bSonicPhysicsMode && !bAntiGravityMode && FloorDotAngle > 0.0 && FloorDotAngle < WalkableFloorZ)
                {
                    if (SlopeRunningTime == 0.0)
                        SlopeRunningTime = WorldInfo.TimeSeconds;
                }
                else
                    SlopeRunningTime = 0.0;
            }
            else
            {
                RefGroundSpeed = RollingRefSpeed;
                SlopeRunningTime = 0.0;
            }

            if (!bAntiGravityMode && Abs(FloorDotAngle) < 0.98)
            {
                if (CurrentSpeed > 0.0)
                {
                    SpeedZ = Normal(RealVelocity).Z * V2.Z;

                    //Penalty for horizontal wall running.
                    if (Abs(SpeedZ) < 0.25 && Abs(FloorDotAngle) < WalkableFloorZ)
                        SpeedZ = 0.5;

                    if (SpeedZ > WalkablePlainZ)
                    {
                        GetSlopeBonuses(CurrentSpeed,SpeedZ,AccelBonus,SlopeSpeedBonus);

                        if (FloorDotAngle < WalkableFloorZ || CurrentSpeed > RefGroundSpeed + SlopeSpeedBonus)
                        {
                            DecelData.bEnabled = true;
                            DecelData.FromValue = CurrentSpeed;

                            DecelRate = -AccelBonus;

                            switch (InputState)
                            {
                                case IS_None:
                                    DecelRate += DefaultDecelRate;

                                    break;

                                case IS_Brake:
                                    DecelRate += DefaultDecelRate * BrakeDecelPct;
                            }
                        }
                        else
                        {
                            switch (InputState)
                            {
                                case IS_None:
                                    DecelData.bEnabled = true;
                                    DecelData.FromValue = CurrentSpeed;

                                    DecelRate -= AccelBonus;

                                    break;

                                case IS_Brake:
                                    DecelData.bEnabled = true;
                                    DecelData.FromValue = CurrentSpeed;

                                    DecelRate = DecelRate * BrakeDecelPct - AccelBonus;
                            }
                        }
                    }
                    else
                        if (SpeedZ < -WalkablePlainZ)
                        {
                            GetSlopeBonuses(CurrentSpeed,SpeedZ,AccelBonus,SlopeSpeedBonus);

                            if (!bRolling)
                            {
                                switch (InputState)
                                {
                                    case IS_None:
                                        DecelData.bEnabled = true;
                                        DecelData.FromValue = CurrentSpeed;

                                        DecelRate = FMax(0.0,DecelRate - AccelBonus);

                                        break;

                                    case IS_Brake:
                                        DecelData.bEnabled = true;
                                        DecelData.FromValue = CurrentSpeed;

                                        DecelRate = FMax(0.0,DecelRate * BrakeDecelPct - AccelBonus);
                                }
                            }

                            AccelRate += AccelBonus;
                        }
                        else
                            if (!bRolling)
                            {
                                switch (InputState)
                                {
                                    case IS_None:
                                        DecelData.bEnabled = true;
                                        DecelData.FromValue = CurrentSpeed;

                                        break;

                                    case IS_Accel:
                                        if (CurrentSpeed > RefGroundSpeed + 1.0)
                                        {
                                            DecelData.bEnabled = true;
                                            DecelData.FromValue = CurrentSpeed;

                                            DecelRate *= RunningOnPlainsPct;
                                        }

                                        break;

                                    case IS_Brake:
                                        DecelData.bEnabled = true;
                                        DecelData.FromValue = CurrentSpeed;

                                        DecelRate *= BrakeDecelPct;
                                }
                            }
                            else
                            {
                                DecelData.bEnabled = true;
                                DecelData.FromValue = CurrentSpeed;

                                if (InputState == IS_Brake)
                                    DecelRate *= BrakeDecelPct;
                            }
                }

                if (bRolling || (SlopeRunningTime != 0.0 && (InputState != IS_Accel || 
                    CurrentSpeed < MinAdhesionSpeed || WorldInfo.TimeSeconds - SlopeRunningTime > 1.0)))
                {
                    SlopeDirection = V1 cross -V2;

                    if (!IsZero(SlopeDirection))
                        SlopeDirection = SlopeDirection cross V1;
                }

                if (!bRolling && bSonicPhysicsMode && !IsZero(SlopeDirection))
                {
                    if (CurrentSpeed > MinAdhesionSpeed && SpeedZ > 0.0)
                        SlopeDirection = vect(0,0,0);
                    else
                        DecelData.bEnabled = false;
                }
            }
            else
                if (CurrentSpeed > 0.0)
                {
                    if (!bRolling)
                    {
                        switch (InputState)
                        {
                            case IS_None:
                                DecelData.bEnabled = true;
                                DecelData.FromValue = CurrentSpeed;

                                if (bWaterRunningMode)
                                    DecelRate += DecelRate * WaterRunDecelPct;

                                break;

                            case IS_Accel:
                                if (bWaterRunningMode)
                                {
                                    DecelData.bEnabled = true;
                                    DecelData.FromValue = CurrentSpeed;

                                    DecelRate *= WaterRunDecelPct;
                                }
                                else
                                    if (CurrentSpeed > RefGroundSpeed + 1.0)
                                    {
                                        DecelData.bEnabled = true;
                                        DecelData.FromValue = CurrentSpeed;

                                        DecelRate *= RunningOnPlainsPct;
                                    }

                                break;

                            case IS_Brake:
                                DecelData.bEnabled = true;
                                DecelData.FromValue = CurrentSpeed;

                                DecelRate *= BrakeDecelPct;
                        }
                    }
                    else
                    {
                        DecelData.bEnabled = true;
                        DecelData.FromValue = CurrentSpeed;

                        if (InputState == IS_Brake)
                            DecelRate *= BrakeDecelPct;
                    }
                }

            DecelRate *= DecelData.Scale;

            if (!DecelData.bEnabled)
            {
                if (RealGroundSpeed < RefGroundSpeed + SlopeSpeedBonus || Physics == PHYS_Spider)
                    SetGroundSpeed(RefGroundSpeed + SlopeSpeedBonus);
            }
            else
            {
                if (CurrentSpeed >= DecelData.FromValue)
                    CurrentSpeed = DecelData.FromValue - DecelRate * DeltaTime;
                else
                    CurrentSpeed -= DecelRate * DeltaTime;

                if (CurrentSpeed < 10.0)
                {
                    DecelData.bEnabled = false;

                    CurrentSpeed = 0.0;
                    RealVelocity = vect(0,0,0);

                    Velocity = vect(0,0,0);
                    Acceleration = vect(0,0,0);

                    SetGroundSpeed(RefGroundSpeed);
                }
                else
                {
                    DecelData.FromValue = CurrentSpeed;

                    RealVelocity = ClampLength(RealVelocity,CurrentSpeed);
                    SetVelocity(RealVelocity);

                    SetGroundSpeed(CurrentSpeed);
                }
            }

            GroundSpeed = RealGroundSpeed;
            if (Physics == PHYS_Walking && Floor.Z < 1.0 && CurrentSpeed > 0.0)
                GroundSpeed *= Normal(Velocity) dot Normal(RealVelocity);

            if (bSonicPhysicsMode)
            {
                AirSpeed = GroundSpeed;

                if (CurrentSpeed > 0.0 && !IsZero(OldVel) && (bAntiGravityMode || FloorDotAngle > WalkableFloorZ))
                {
                    GetAxes(rotator(-FloorNormal),V1,V2,V3);

                    CurrentSpeed *= (Normal(PointProjectToPlane(Velocity,vect(0,0,0),V2,V3)) dot
                                    Normal(PointProjectToPlane(OldVel,vect(0,0,0),V2,V3))) ** 5.0;

                    Velocity = ClampLength(Velocity,CurrentSpeed);
                }
            }

            if (ShouldPlayRoll())
            {
                if (bRolling || bSpiderPhysicsMode)
                    MeshPitchRotation += CurrentSpeed * DeltaTime * 0.02;
                else
                    if (SpinDashCount > 0)
                        MeshPitchRotation += (SpinDashCount + 5) * DeltaTime * 3.0;
            }

            if (SpinDashCount > 0)
            {
                if (SpinDashCount > 1 && WorldInfo.TimeSeconds - LastSpinDashTime > SpinDashDecreaseTime)
                {
                    LastSpinDashTime = WorldInfo.TimeSeconds;

                    SpinDashCount--;
                }

                if (SpinDashEmitter != none)
                    SpinDashEmitter.ParticleSystemComponent.SetFloatParameter('ParticleRate',SpinDashCount * 0.4);
            }
            else
                if (bDucking)
                    //Modify skeletal mesh translation offset.
                    MeshTranslation.Z += MeshDuckingOffset;

            MeshTranslation = MeshTranslation >> DesiredMeshRotation;

            if (Physics == PHYS_Walking)
            {
                if (FloorDotAngle < 0.999)
                    WalkingZTranslation = Lerp(WalkingZTranslation,FMin((1.05 - FloorDotAngle) * 50.0,10.0),
                                               FMin(DeltaTime * 2.0,1.0));
                else
                    WalkingZTranslation = Lerp(WalkingZTranslation,0.0,FMin(DeltaTime * 2.0,1.0));

                MeshTranslation.Z -= WalkingZTranslation;
            }
            else
                WalkingZTranslation = 0.0;
        }
        else
        {
            if (Physics == PHYS_Falling)
            {
                if (bEnteredWater)
                    Velocity *= vect(0.5,0.5,0.25);

                //If pawn is ascending in air with a determined speed...
                if (AirDragFactor > 0.0 &&
                    ((!bReverseGravity && Velocity.Z > 5.0 && Velocity.Z < JumpZ * 0.8) ||
                    bReverseGravity && Velocity.Z < -5.0 && Velocity.Z > JumpZ * -0.8))
                    Velocity *= vect(1,1,0) * (AirDragFactor ** (DeltaTime * 100.0)) + vect(0,0,1);

                //If pawn is falling towards the ground...
                if ((!bReverseGravity && Velocity.Z < -5.0) || (bReverseGravity && Velocity.Z > 5.0))
                {
                    if (bNotifyJumpApex)
                    {
                        bNotifyJumpApex = false;

                        //Notify other objects.
                        foreach NotifyEventsTo(NotifyObject)
                            NotifyObject.PawnJumpApex(self);
                    }

                    if (bDoubleGravity)
                        //Increase force of gravity to remove floaty jump sensation.
                        CustomGravityScaling *= 2.0;
                }
                else
                    if (bReverseGravity && bDoubleGravity && Velocity.Z < -5.0)
                        //Increase force of gravity to remove floaty jump sensation.
                        CustomGravityScaling *= 2.0;

                CurrentSpeed = VSize2D(Velocity);
                SetGroundSpeed(FMax(RefAerialSpeed,CurrentSpeed));

                if (ShouldFaceVelocity())
                {
                    if (!bReverseGravity)
                        MeshPitchRotation = Pi * 0.5 * -Normal(Velocity).Z;
                    else
                        MeshPitchRotation = Pi * 0.5 * Normal(Velocity).Z;
                }
                else
                    if (ShouldPlayRoll())
                        MeshPitchRotation += DeltaTime * (CurrentSpeed * 0.01 + 15.0);
                    else
                        if (ShouldTilt())
                            MeshPitchRotation = FMin(CurrentSpeed * 0.0005,0.5);
                        else
                            MeshPitchRotation = 0.0;
            }
            else
            {
                CurrentSpeed = VSize2D(Velocity);
                SetGroundSpeed(FMax(RefAerialSpeed,CurrentSpeed));
            }

            MeshTranslation = MeshTranslation >> DesiredMeshRotation;

            WalkingZTranslation = 0.0;
        }

        Mesh.SetTranslation(MeshTranslation);

        //Unset this flag.
        bEnteredWater = false;

        //Check if movement must be constrained to spline paths.
        if (CurrentSplineActor != none && Location != OldLocation)
            CheckSplineMovement(DeltaTime);

        if (!bDisableDamageBlink)
        {
            if (WorldInfo.TimeSeconds - LastDamageTime < MinTimeDamage)
                Mesh.SetHidden(WorldInfo.TimeSeconds % 0.1 < 0.025);
            else
                Mesh.SetHidden(false);
        }

        OldLocation = Location;
        OldVelocity = GetVelocity();

        if (bHyperForm)
        {
            if (!HyperSkeletalGhosts[0].HiddenGame || IsZero(OldVelocity))
            {
                HyperSkeletalGhosts[0].SetHidden(true);
                HyperSkeletalGhosts[1].SetHidden(true);
            }
            else
            {
                HyperSkeletalGhosts[0].SetRotation(Mesh.Rotation);
                HyperSkeletalGhosts[0].SetScale(Mesh.Scale);
                HyperSkeletalGhosts[0].SetTranslation(Mesh.Translation - OldVelocity * 0.025);

                HyperSkeletalGhosts[1].SetRotation(Mesh.Rotation);
                HyperSkeletalGhosts[1].SetScale(Mesh.Scale);
                HyperSkeletalGhosts[1].SetTranslation(Mesh.Translation - OldVelocity * 0.05);

                HyperSkeletalGhosts[0].SetHidden(false);
                HyperSkeletalGhosts[1].SetHidden(false);
            }
        }
    }
}

/**
 * Called whenever time passes and after physics movement has completed.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last TickSpecial call
 */
event TickSpecial(float DeltaTime)
{
    if (Health > 0)
    {
        if (Physics == PHYS_Spider)
            SetVelocity(ClampLength(GetVelocity(),
                                    FMin(VSize(OldVelocity) + AccelRate * DeltaTime,GroundSpeed)));

        if (VelocityOverride != default.VelocityOverride)
        {
            SetVelocity(VelocityOverride);

            VelocityOverride = default.VelocityOverride;
        }

        if (VelocityZOverride != default.VelocityZOverride)
        {
            SetVelocity(GetVelocity() * vect(1,1,0) + vect(0,0,1) * VelocityZOverride);

            VelocityZOverride = default.VelocityZOverride;
        }

        if (bSonicPhysicsMode && !IsZero(Velocity))
        {
            if (Location == OldLocation)
            {
                StuckCount++;

                if (StuckCount > 2)
                {
                    StuckCount = 0;

                    //Avoids players getting stuck at the edges of level geometry.
                    SetVelocity(FloorNormal * 250.0);
                    SetSonicPhysics(false);
                }
            }
            else
                StuckCount = 0;
        }
        else
            StuckCount = 0;

        if (bSonicPhysicsMode && bReverseGravity && Base != none && Base.bStatic && FloorNormal.Z < -0.99 &&
            OldLocation.Z > Location.Z + 12.5 && !IsSonicPhysicsAllowed(Base))
            //Fixes a bug of the native physics that occurs when running upside-down against a wall.
            Move(vect(0,0,1) * (OldLocation.Z - Location.Z));

        OldVelocity = GetVelocity();
    }
}

/**
 * Called every tick to update player eye height position, based on smoothing view while moving up and down
 * stairs and adding view bobs for landing.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last tick
 */
event UpdateEyeHeight(float DeltaTime)
{
    local float OldEyeHeight,Smooth;

    if (bTearOff || Health < 1)
    {
        //If dead, no eye height updates is performed.
        EyeHeight = default.BaseEyeHeight;
        bUpdateEyeHeight = false;
    }
    else
    {
        if (Abs(Location.Z - OldZ) > 15.0)
        {
            //If position difference is too great, don't do smooth land recovery.
            bJustLanded = false;
            bLandRecovery = false;
        }

        if (!bJustLanded)
        {
            //Normal walking around; smooth eye height changes while going up/down stairs/ramps.
            Smooth = FMin(DeltaTime * 10.0,0.9);
            LandBob *= (1.0 - Smooth);

            if (Physics == PHYS_Walking && FloorDotAngle < 0.98)
                EyeHeight = FMax(0.0,(EyeHeight - 0.5 * (Location.Z - OldZ)) *
                                (1.0 - Smooth) + BaseEyeHeight * Smooth);
            else
                if (Physics == PHYS_Walking || Physics == PHYS_Swimming)
                    EyeHeight = (EyeHeight - Location.Z + OldZ) * (1.0 - Smooth) + BaseEyeHeight * Smooth;
                else
                    if (Physics == PHYS_Falling)
                        //Special case while falling; drop eye height.
                        EyeHeight = EyeHeight * (1.0 - Square(Smooth));
                    else
                        EyeHeight = EyeHeight * (1.0 - Smooth) + BaseEyeHeight * Smooth;
        }
        else
            if (bLandRecovery)
            {
                //Return eye height back up to full height.
                Smooth = FMin(DeltaTime * 9.0,0.9);
                LandBob *= (1.0 - Smooth);

                //Linear interpolation at end.
                if (EyeHeight > 0.9 * BaseEyeHeight)
                    EyeHeight = EyeHeight + 0.15 * BaseEyeHeight * Smooth;
                else
                    EyeHeight = EyeHeight * (1.0 - Smooth * 0.6) + BaseEyeHeight * Smooth * 0.6;

                if (EyeHeight >= BaseEyeHeight)
                {
                    bJustLanded = false;
                    bLandRecovery = false;
                    EyeHeight = BaseEyeHeight;
                }
            }
            else
            {
                //Drop eye height a bit on landing.
                Smooth = FMin(DeltaTime * 8.0,0.65);
                OldEyeHeight = EyeHeight;
                EyeHeight = EyeHeight * (1.0 - Smooth * 1.5);
                LandBob += 0.08 * (OldEyeHeight - EyeHeight);

                if (EyeHeight < 0.25 * BaseEyeHeight + 1.0 || LandBob > 2.4)
                {
                    bLandRecovery = true;
                    EyeHeight = 0.25 * BaseEyeHeight + 1.0;
                }
            }
    }
}

/**
 * Is player pawn running at high speed?
 * @return  true if pawn isn't walking at low speed
 */
function bool AboveWalkingSpeed()
{
    return (VSizeSq(GetVelocity()) > Square(DefaultGroundSpeed + 5.0));
}

/**
 * Plays a footstep sound according to the type of floor.
 * @param FootId  specifies which foot hit; 0 is left footstep, 1 is right footstep,
 *                                          2 is skidding, 3 is landing
 */
simulated function ActuallyPlayFootstepSound(int FootId)
{
    local name GroundMaterialName;
    local SoundCue FootSound;

    GroundMaterialName = GetMaterialBelowFeet();

    switch (FootId)
    {
        case 0:
        case 1:
            FootSound = GetFootstepSound(GroundMaterialName);

            if (CachedWaterVolume != none && GroundMaterialName == 'ShallowWater')
            {
                if (FootId == 0)
                    CachedWaterVolume.PlayFootstepSplash(Location + ((vect(0.0,0.75,0.0) *
                        GetCollisionRadius()) >> GetRotation()) - vect(0,0,1) * GetCollisionHeight());
                else
                    CachedWaterVolume.PlayFootstepSplash(Location - ((vect(0.0,0.75,0.0) *
                        GetCollisionRadius()) >> GetRotation()) - vect(0,0,1) * GetCollisionHeight());
            }

            break;

        case 2:
            if (VSizeSq(Velocity) > Square(DefaultGroundSpeed * 0.5))
                FootSound = GetSkiddingSound(GroundMaterialName);

            break;

        case 3:
            FootSound = GetLandingSound(GroundMaterialName);
    }

    if (FootSound != none)
        PlaySound(FootSound,false,true);
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
    //If this pawn has rings...
    if (Health > 1)
    {
        if (!bDropAllRings)
            DamageAmount = Min(Max((Health - 1) / 2,25),Health - 1);
        else
            DamageAmount = Health - 1;
    }

    if (IsInvulnerable(DamageClass))
        DamageAmount = -1;
    else
        if (DamageClass.default.bArmorStops)
        {
            if (HasShield())
            {
                //Shield protects the player from harm but vanishes.
                DamageAmount = 0;
                Shield.TookDamage();
            }
        }
        else
            if (class<UTDamageType>(DamageClass).default.bAlwaysGibs)
                DamageAmount = 100000;
            else
                DamageAmount = Health;
}

/**
 * Player pawn is about to be be driven into the air from the floor; correct way of applying an impulse and
 * setting falling physics.
 * @param BoostVelocity  the direction and magnitude of the impulse
 * @param bLand          true to call Landed event first
 * @param PushActor      the actor that pushes this pawn
 * @param Reason         the reason of the push
 */
function AerialBoost(vector BoostVelocity,optional bool bLand,optional Actor PushActor,optional name Reason)
{
    local bool bRollOnAir;

    bRollOnAir = (bRolling && Reason == 'SpeedJumpPad');

    if (bLand)
    {
        bQuickLand = true;

        TriggerLanded(,PushActor);

        bQuickLand = false;
    }

    if (bRollOnAir)
    {
        //Roll on air.
        bReadyToDoubleJump = true;

        //No multi-jumps until landing.
        MultiJumpRemaining = 0;
    }

    LeftGround();

    Velocity = BoostVelocity;

    SetPhysics(PHYS_Falling);

    bUpdateMeshRotation = true;
}

/**
 * Player pawn wants to perform an aerial special move.
 * @param ButtonId  identification of the (un)pressed button; 0 is Jump, 1 is UnJump, 2 is Duck, 3 is UnDuck,
 *                                                            4 is SpecialMove, 5 is UnSpecialMove
 * @return          true if pawn performed the special move
 */
function bool AerialSpecialMove(byte ButtonId)
{
    return false;
}

/**
 * Attaches an actor to this pawn; the actor will follow this pawn and rotate with it.
 * The attached actor will ignore any rotation caused by rolling on ground or on air.
 * @param AnActor        actor to be attached
 * @param RelLocation    location relative to this pawn
 * @param RelRotation    rotation relative to this pawn
 * @param bFaceVelocity  true if attached actor should face velocity direction
 */
function AttachToRoot(Actor AnActor,optional vector RelLocation,
                      optional rotator RelRotation,optional bool bFaceVelocity)
{
    AnActor.SetBase(none);
    AnActor.SetCollision(false,false);
    AnActor.SetHardAttach(true);

    AnActor.SetLocation(Location + (RelLocation >> CurrentMeshRotation));
    AnActor.SetRotation(CurrentMeshRotation + RelRotation);

    AnActor.bIgnoreBaseRotation = true;
    AnActor.SetBase(self);

    RootAttachments.Add(1);

    RootAttachments[RootAttachments.Length - 1].bUseVelocity = bFaceVelocity;
    RootAttachments[RootAttachments.Length - 1].AttachedActor = AnActor;
    RootAttachments[RootAttachments.Length - 1].RelativeLocation = RelLocation;
    RootAttachments[RootAttachments.Length - 1].RelativeRotation = RelRotation;
}

/**
 * Allows or denies breath to player pawn.
 * @param bBreath  allows/denies breath
 */
function Breath(bool bBreath)
{
    if (!bBreath)
    {
        if (BreathTime == 0.0)
        {
            //Enable breath timer.
            BreathTime = UnderWaterTime;

            if (Controller != none)
                SetTimer(UnderWaterTime - SGDKPlayerController(Controller).GetMusicManager().DrowningMusicTrack.Duration,
                         false,NameOf(PlayDrowningMusic));
        }
    }
    else
    {
        //Disable breath timer.
        BreathTime = 0.0;

        if (IsTimerActive(NameOf(PlayDrowningMusic)))
            ClearTimer(NameOf(PlayDrowningMusic));
        else
            if (Controller != none)
                SGDKPlayerController(Controller).GetMusicManager().StopMusicTrack(
                    SGDKPlayerController(Controller).GetMusicManager().DrowningMusicTrack,1.0);
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
        if (PushActor == none)
            PushActor = self;

        if (Reason == '')
            Reason = 'Bounce';

        if (Controller != none)
            SGDKPlayerController(Controller).DisableMoveInput(0.1);

        BounceData.bAddMultiJump = bMulti;
        BounceData.bHadJumped = bReadyToDoubleJump;
        BounceData.bHarshBounce = bHarsh;
        BounceData.bZeroZSpeed = bZero;
        BounceData.BounceActor = PushActor;
        BounceData.BounceImpulse = Impulse;
        BounceData.BounceReason = Reason;

        BounceData.bWillBounce = true;

        SetTimer(0.01,false,NameOf(BounceDelayed));

        return true;
    }

    return false;
}

/**
 * Called after the player pawn is bounced.
 */
protected function BounceDelayed()
{
    local vector Impulse;
    local ReceivePawnEvents NotifyObject;

    BounceData.bWillBounce = false;

    if (Health > 0 && !bIgnoreForces)
    {
        if (IsTouchingGround())
        {
            if (bRolling)
                //Unset rolling on ground mode.
                Roll(false);

            if (bSonicPhysicsMode)
                //Unset Sonic Physics mode.
                SetSonicPhysics(false);

            if (!BounceData.bHarshBounce)
                Impulse = GetVelocity() + BounceData.BounceImpulse;
            else
            {
                Impulse = BounceData.BounceImpulse;

                //Rotate the attached skeletal mesh harshly.
                bSmoothRotation = false;
            }

            //Set some values.
            bDodging = false;
            bReadyToDoubleJump = BounceData.bHadJumped;

            if (BounceData.bHadJumped && !BounceData.bAddMultiJump)
                MultiJumpRemaining = 0;

            //Set falling physics properly.
            AerialBoost(Impulse,false,BounceData.BounceActor,BounceData.BounceReason);

            //Notify other objects.
            foreach NotifyEventsTo(NotifyObject)
                NotifyObject.PawnBounced(self);
        }
        else
        {
            if (!BounceData.bHarshBounce)
            {
                Impulse = GetVelocity();

                if (BounceData.bZeroZSpeed)
                    Impulse.Z = 0.0;

                Impulse += BounceData.BounceImpulse;
            }
            else
                Impulse = BounceData.BounceImpulse;

            Velocity = Impulse;

            SetPhysics(PHYS_Falling);

            //Set some values.
            bDodging = false;
            bReadyToDoubleJump = BounceData.bHadJumped;

            if (BounceData.bAddMultiJump)
                MultiJumpRemaining = Min(MultiJumpRemaining + 1,MaxMultiJump);
            else
                MultiJumpRemaining = 0;

            //Notify other objects.
            foreach NotifyEventsTo(NotifyObject)
                NotifyObject.PawnBounced(self);
        }
    }
}

/**
 * Calculates camera view point when viewing this pawn.
 * @param DeltaTime       contains the amount of time in seconds that has passed since the last tick
 * @param OutCamLocation  camera location
 * @param OutCamRotation  camera rotation
 * @param OutFOV          field of view angle of camera
 * @return                true if this pawn should provide the camera point of view
 */
simulated function bool CalcCamera(float DeltaTime,out vector OutCamLocation,
                                   out rotator OutCamRotation,out float OutFOV)
{
    local vector HitLocation,HitNormal,OffsetVector;

    if (bFixedView)
    {
        OutCamLocation = FixedViewLoc;
        OutCamRotation = FixedViewRot;
    }
    else
        if (Health > 0 && !bFeigningDeath && Controller != none)
        {
            OutCamRotation = Normalize(QuatToRotator(QuatSlerp(QuatFromRotator(DesiredViewRotation),
                                                               QuatFromRotator(OutCamRotation),
                                                               0.5 ** (DeltaTime * 7.5),true)));

            OffsetVector = vect(0,0,1) * EyeHeight;

            OutCamLocation = Location + ((OffsetVector + vect(-200,0,40)) >> OutCamRotation);

            OffsetVector = Location + (OffsetVector >> DesiredMeshRotation);

            if (Trace(HitLocation,HitNormal,OffsetVector,Location,true,
                      vect(6,6,12),,TRACEFLAG_Blocking) != none)
                OutCamLocation = HitLocation;
            else
                if (Trace(HitLocation,HitNormal,OutCamLocation,OffsetVector,true,
                          vect(12,12,12),,TRACEFLAG_Blocking) != none)
                    OutCamLocation = HitLocation;
        }
        else
        {
            FindSpot(GetCollisionExtent(),OutCamLocation);

            OutCamRotation = Normalize(QuatToRotator(QuatSlerp(QuatFromRotator(rotator(Location -
                                 OutCamLocation)),QuatFromRotator(OutCamRotation),0.5 ** (DeltaTime * 7.5),true)));
        }

    return true;
}

/**
 * Cancels all performed special moves.
 */
function CancelMoves()
{
    local int i;

    Shield.CancelMoves();

    if (BounceData.bWillBounce)
    {
        //Cancel pending bounce.
        ClearTimer(NameOf(Bounce));
        BounceData.bWillBounce = false;
    }

    if (bHanging)
        //Cancel hanging from handle.
        SetHanging(false);

    if (bPushing)
    {
        //Unset pushing.
        bPushing = false;

        //Notify blend nodes the change of posture.
        for (i = 0; i < PostureBlendNodes.Length; i++)
            PostureBlendNodes[i].PostureChanged(0);
    }

    if (bRolling)
        //Unset rolling on ground mode.
        Roll(false);
    else
        if (SpinDashCount > 0)
            //Cancel SpinDash.
            SpinDashCancel();

    //Restore original values.
    bDodging = false;
    bReadyToDoubleJump = false;
    LastJumpTime = 0.0;
    MeshPitchRotation = 0.0;
}

/**
 * Cancels player's super form.
 */
function CancelSuperForms()
{
    if (bSuperForm)
    {
        if (!bHyperForm)
            SuperForm(false);
        else
            HyperForm(false);
    }
}

/**
 * Is the player pawn allowed to pick up an actor?
 * @param AnActor  actor to be picked up
 * @return         true if actor is allowed to be picked up
 */
function bool CanPickupActor(Actor AnActor)
{
    if (bCanPickupInventory && Health > 0)
    {
        if (bHyperForm && BubbleProjectile(AnActor) != none)
            return false;

        if (PickupFactory(AnActor) == none ||
            WorldInfo.Game.PickupQuery(self,PickupFactory(AnActor).InventoryType,AnActor))
            return !Shield.DenyActorPickup(AnActor);
    }

    return false;
}

/**
 * Is the player pawn allowed to push?
 * @return  true if allowed to push
 */
function bool CanPush()
{
    return (!bDodging && !bDucking && !bRolling && !bSkidding);
}

/**
 * Is the player pawn allowed to fly using a cheat command?
 * @return  true if allowed to fly
 */
function bool CheatFly()
{
    if (super.CheatFly())
    {
        if (IsTouchingGround())
            LeftGround();

        return true;
    }

    return false;
}

/**
 * Is the player pawn allowed to fly through walls using a cheat command?
 * @return  true if allowed to fly through walls
 */
function bool CheatGhost()
{
    if (super.CheatGhost())
    {
        if (IsTouchingGround())
            LeftGround();

        return true;
    }

    return false;
}

/**
 * Checks player pawn hanging from an actor mode and adjusts values for location and rotation.
 */
function CheckHanging()
{
    local vector V;

    SetBase(none);

    ForceRotation(HangingActor.Rotation,false);

    V = HangingActor.PawnLocationOffset;

    if (bMiniSize)
        V *= MiniHeight / DefaultHeight;

    SetLocation(HangingActor.Location + (V >> DesiredMeshRotation));

    SetBase(HangingActor);
}

/**
 * Checks player pawn Sonic Physics mode movement and adjusts values for velocity and location.
 */
function CheckSonicPhysics()
{
    local float Distance1,Distance2,DotAngle,HalfHeight;
    local TTraceData TraceInfos[3];
    local vector Y;

    bWaterRunningMode = false;

    if (IsInClassVolume('WaterRunVolume') && IsTouchingGround() && GetVelocity().Z <= 0.0 &&
        VSizeSq(GetVelocity()) > Square(DefaultGroundSpeed * WaterRunAdhesionPct))
    {
        bOnGround = false;
        TraceInfos[0].TraceEnd = vect(0,0,1) >> DesiredMeshRotation;

        if (TraceInfos[0].TraceEnd.Z > WalkableFloorZ)
        {
            TraceInfos[0].TraceEnd = Location + TraceInfos[0].TraceEnd * -GroundTraceLength;
            TraceInfos[0].HitActor = Trace(TraceInfos[0].HitLocation,TraceInfos[0].HitNormal,
                                           TraceInfos[0].TraceEnd,Location,true,,,TRACEFLAG_PhysicsVolumes);

            if (TraceInfos[0].HitActor != none && SGDKWaterVolume(TraceInfos[0].HitActor) != none &&
                Location.Z > TraceInfos[0].HitLocation.Z)
            {
                bOnGround = true;
                bWaterRunningMode = true;

                TraceInfos[2].HitActor = TraceInfos[0].HitActor;

                Distance1 = GetCollisionHeight() - 7.5;
                FloorNormal = vect(0,0,1);

                if (VSizeSq(Location - TraceInfos[0].HitLocation) != Square(Distance1))
                    MoveSmooth(TraceInfos[0].HitLocation + FloorNormal * Distance1 - Location);

                Velocity.Z = 0.0;
            }
        }
    }

    if (!bWaterRunningMode)
    {
        if (!bSonicPhysicsMode)
        {
            if (!IsTouchingGround() || !IsSonicPhysicsAllowed(Base))
                bOnGround = false;
            else
            {
                bOnGround = true;
                FloorNormal = Floor;

                FloorDotAngle = -(FloorNormal dot GetGravityDirection());

                Y = Normal(FloorNormal cross vector(DesiredMeshRotation));
                DesiredMeshRotation = OrthoRotation(Y cross FloorNormal,Y,FloorNormal);
            }
        }

        if (bOnGround)
        {
            bOnGround = false;

            if (bAntiGravityMode || FloorDotAngle > 0.0 || VSizeSq(GetVelocity()) > Square(MinAdhesionSpeed))
            {
                if (bReverseGravity && FloorDotAngle > WalkableFloorZ)
                {
                    HalfHeight = GetCollisionHeight();

                    TraceInfos[0].TraceEnd = Location + vect(0,0,1) * (HalfHeight + 5.0);
                    TraceInfos[0].HitActor = Trace(TraceInfos[0].HitLocation,TraceInfos[0].HitNormal,
                                                   TraceInfos[0].TraceEnd,Location,true,GetCollisionExtent(),,
                                                   TRACEFLAG_Blocking);

                    if (TraceInfos[0].HitActor != none && !IsSonicPhysicsAllowed(TraceInfos[0].HitActor) &&
                        TraceInfos[0].HitNormal dot vect(0,0,-1) > WalkableFloorZ)
                    {
                        bOnGround = true;

                        TraceInfos[1].HitActor = Trace(TraceInfos[1].HitLocation,TraceInfos[1].HitNormal,
                                                       TraceInfos[0].TraceEnd,Location,true,vect(1,1,1),,
                                                       TRACEFLAG_Blocking);

                        TraceInfos[2].HitActor = TraceInfos[0].HitActor;

                        if (TraceInfos[1].HitActor != none)
                        {
                            if (WorldInfo(TraceInfos[2].HitActor) != none)
                                Distance1 = HalfHeight + 2.0;
                            else
                                Distance1 = HalfHeight;

                            Distance2 = VSize(Location - TraceInfos[1].HitLocation);

                            if (Distance2 + 1.0 < Distance1 || Distance2 - 1.0 > Distance1)
                                Move((TraceInfos[1].HitLocation + TraceInfos[1].HitNormal * Distance1) - Location);
                        }
                        else
                            if (VSizeSq(Location - TraceInfos[0].HitLocation) > 1.0)
                                Move(TraceInfos[0].HitLocation - Location);

                        if (FloorNormal != TraceInfos[0].HitNormal)
                        {
                            if (!IsZero(Velocity))
                                Velocity = Normal((TraceInfos[0].HitNormal cross Normal(Velocity)) cross
                                               TraceInfos[0].HitNormal) * VSize(Velocity);

                            FloorNormal = TraceInfos[0].HitNormal;
                        }
                    }
                }

                if (!bOnGround)
                {
                    TraceInfos[0].TraceEnd = Location + ((vect(0.5,0.0,0.0) * GetCollisionRadius() +
                                             vect(0,0,-1) * GroundTraceLength) >> DesiredMeshRotation);
                    TraceInfos[0].HitActor = Trace(TraceInfos[0].HitLocation,TraceInfos[0].HitNormal,TraceInfos[0].TraceEnd,
                                                   Location,true,vect(1,1,1),,TRACEFLAG_Blocking);

                    TraceInfos[1].TraceEnd = Location + ((vect(-0.5,0.0,0.0) * GetCollisionRadius() +
                                             vect(0,0,-1) * GroundTraceLength) >> DesiredMeshRotation);
                    TraceInfos[1].HitActor = Trace(TraceInfos[1].HitLocation,TraceInfos[1].HitNormal,TraceInfos[1].TraceEnd,
                                                   Location,true,vect(1,1,1),,TRACEFLAG_Blocking);

                    if (TraceInfos[0].HitActor != none && TraceInfos[1].HitActor != none)
                    {
                        if (TraceInfos[0].HitNormal != TraceInfos[1].HitNormal)
                        {
                            TraceInfos[2].TraceEnd = Location + ((vect(0,0,-1) * GroundTraceLength) >> DesiredMeshRotation);
                            TraceInfos[2].HitActor = Trace(TraceInfos[2].HitLocation,TraceInfos[2].HitNormal,
                                                           TraceInfos[2].TraceEnd,Location,true,vect(1,1,1),,
                                                           TRACEFLAG_Blocking);

                            if (TraceInfos[2].HitActor != none)
                                TraceInfos[2].HitNormal = Normal(TraceInfos[0].HitNormal + TraceInfos[1].HitNormal +
                                                                 TraceInfos[2].HitNormal);
                            else
                            {
                                TraceInfos[2].HitActor = TraceInfos[0].HitActor;
                                TraceInfos[2].HitNormal = Normal(TraceInfos[0].HitNormal + TraceInfos[1].HitNormal);
                            }
                        }
                        else
                        {
                            TraceInfos[2].HitActor = TraceInfos[0].HitActor;
                            TraceInfos[2].HitNormal = TraceInfos[0].HitNormal;
                        }

                        DotAngle = TraceInfos[2].HitNormal dot FloorNormal;

                        if (DotAngle > WalkableFloorZ && (IsSonicPhysicsAllowed(TraceInfos[1].HitActor) ||
                            (bReverseGravity && TraceInfos[2].HitNormal dot vect(0,0,-1) > WalkableFloorZ)))
                        {
                            bOnGround = true;

                            TraceInfos[2].HitLocation = TraceInfos[0].HitLocation +
                                                        ((TraceInfos[1].HitLocation - TraceInfos[0].HitLocation) * 0.5);

                            if (WorldInfo(TraceInfos[2].HitActor) != none)
                                Distance1 = GetCollisionHeight() + 2.0;
                            else
                                Distance1 = GetCollisionHeight();

                            Distance2 = VSize(Location - TraceInfos[2].HitLocation);

                            if (Distance2 + 1.0 < Distance1 || Distance2 - 1.0 > Distance1)
                                Move((TraceInfos[2].HitLocation + FloorNormal * (DotAngle * Distance1)) - Location);

                            if (TraceInfos[2].HitNormal != FloorNormal)
                            {
                                if (!IsZero(Velocity))
                                    Velocity = Normal((TraceInfos[2].HitNormal cross Normal(Velocity)) cross
                                                      TraceInfos[2].HitNormal) * VSize(Velocity);

                                FloorNormal = TraceInfos[2].HitNormal;
                            }
                        }
                    }
                }
            }
        }
    }

    if (bOnGround)
    {
        if (!bSonicPhysicsMode)
            SetSonicPhysics(true);

        if (TraceInfos[2].HitActor != none && Base != TraceInfos[2].HitActor)
            SetBase(TraceInfos[2].HitActor);
    }
    else
    {
        if (bSonicPhysicsMode)
            SetSonicPhysics(false);

        FloorNormal = Floor;
    }
}

/**
 * Checks player pawn constrained movement to spline paths and adjusts values for velocity and location.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
function CheckSplineMovement(float DeltaTime)
{
    local bool bInverted;
    local SplineComponent NewSplineComp;
    local float Speed;
    local SGDKSplineActor SplineInfo;
    local vector Tangent,V,W,Y,Z;

    if (CurrentSplineActor.NextOrdered != none)
    {
        NewSplineComp = CurrentSplineActor.FindSplineComponentTo(CurrentSplineActor.NextOrdered);
        V = CurrentSplineActor.CalculateTangent(NewSplineComp,0.0);
    }
    else
        if (CurrentSplineActor.PrevOrdered != none)
        {
            NewSplineComp = CurrentSplineActor.PrevOrdered.FindSplineComponentTo(CurrentSplineActor);
            V = CurrentSplineActor.CalculateTangent(NewSplineComp,NewSplineComp.GetSplineLength());
        }

    if (NewSplineComp == none)
    {
        bClassicMovement = false;
        bConstrainMovement = false;
        ConstrainedMovement = CM_None;
        CurrentSplineActor = none;
        CurrentSplineComp = none;
        SplineDistance = 0.0;
        SplineOffset = default.SplineOffset;
    }
    else
    {
        NewSplineComp = none;

        if ((Location - CurrentSplineActor.Location) dot V >= 0.0)
        {
            if (CurrentSplineActor.NextOrdered != none)
            {
                SplineInfo = CurrentSplineActor;
                NewSplineComp = SplineInfo.FindSplineComponentTo(CurrentSplineActor.NextOrdered);
            }
        }
        else
            if (CurrentSplineActor.PrevOrdered != none)
            {
                bInverted = true;

                SplineInfo = SGDKSplineActor(CurrentSplineActor.PrevOrdered);
                NewSplineComp = SplineInfo.FindSplineComponentTo(CurrentSplineActor);
            }

        if (NewSplineComp != none && SplineInfo.ConstraintType != CM_None)
        {
            if (CurrentSplineComp == none || CurrentSplineComp != NewSplineComp)
            {
                CurrentSplineComp = NewSplineComp;

                SplineDistance = SplineInfo.CalculateSplineDistance(Location,CurrentSplineComp,bInverted);
            }
            else
                SplineDistance = FClamp(SplineDistance +
                    ((Location - OldLocation) dot SplineInfo.CalculateTangent(CurrentSplineComp,SplineDistance)),
                    0.0,CurrentSplineComp.GetSplineLength());

            Tangent = SplineInfo.CalculateTangent(CurrentSplineComp,SplineDistance);

            if (IsTouchingGround())
            {
                Z = GetFloorNormal();
                W = Z;

                if (Abs(Tangent.Z) < 0.99)
                {
                    LastTangent2D = Normal(Tangent * vect(1,1,0));

                    if (!bReverseGravity)
                    {
                        if (Z.Z < 0.0)
                            LastTangent2D *= -1;
                    }
                    else
                        if (Z.Z > 0.0)
                            LastTangent2D *= -1;
                }
            }
            else
            {
                if (!bInverted)
                    Z = Normal((vect(0,0,1) >> CurrentSplineActor.Rotation) +
                               (vect(0,0,1) >> CurrentSplineActor.NextOrdered.Rotation));
                else
                    Z = Normal((vect(0,0,1) >> CurrentSplineActor.PrevOrdered.Rotation) +
                               (vect(0,0,1) >> CurrentSplineActor.Rotation));

                if (Abs(Tangent.Z) < 0.99)
                {
                    LastTangent2D = Normal(Tangent * vect(1,1,0));

                    if (!bReverseGravity)
                    {
                        if (Z.Z < 0.0)
                            LastTangent2D *= -1;
                    }
                    else
                        if (Z.Z > 0.0)
                            LastTangent2D *= -1;
                }

                Z = Tangent cross Normal(Z cross Tangent);

                if (!bReverseGravity)
                    W = vect(0,0,1);
                else
                    W = vect(0,0,-1);
            }

            bClassicMovement = false;
            bConstrainMovement = (Physics != PHYS_None && !bDodging && (SplineInfo.MinSpeedConstraint <= 0.0 ||
                                 VSizeSq(GetVelocity()) > Square(SplineInfo.MinSpeedConstraint)));
            ConstrainedMovement = SplineInfo.ConstraintType;

            switch (ConstrainedMovement)
            {
                case CM_Classic2dot5d:
                    bClassicMovement = true;

                    if (bConstrainMovement && !IsZero(Velocity))
                    {
                        V = GetVelocity();
                        SetVelocity(Normal(PointProjectToPlane(V,vect(0,0,0),Z,Tangent)) * VSize(V));

                        if (IsTouchingGround())
                        {
                            if (W.Z >= 0.0)
                                Y = vect(0,0,1) cross Tangent;
                            else
                                Y = vect(0,0,-1) cross Tangent;

                            if (IsZero(Y))
                                Y = Z cross Tangent;

                            V = PointProjectToPlane(SplineInfo.CalculateLocation(CurrentSplineComp,SplineDistance) -
                                                    Location,vect(0,0,0),Tangent,Y);

                            if (!IsZero(V))
                                MoveSmooth(V * FMin(VSize(GetVelocity()) * SplineInfo.ConstraintMagnitude *
                                           DeltaTime * 0.001,1.0));
                        }
                    }

                    if (IsTouchingGround())
                    {
                        if (!bSonicPhysicsMode)
                        {
                            SplineZ = W;
                            SplineY = W cross Tangent;
                            SplineX = SplineY cross W;
                        }
                        else
                        {
                            if (!bInverted)
                                V = Normal(VLerp(vect(0,1,0) >> CurrentSplineActor.Rotation,
                                                 vect(0,1,0) >> CurrentSplineActor.NextOrdered.Rotation,
                                                 SplineDistance / CurrentSplineComp.GetSplineLength()));
                            else
                                V = Normal(VLerp(vect(0,1,0) >> CurrentSplineActor.PrevOrdered.Rotation,
                                                 vect(0,1,0) >> CurrentSplineActor.Rotation,
                                                 SplineDistance / CurrentSplineComp.GetSplineLength()));

                            V = Tangent cross Normal(Tangent cross V);

                            SplineX = W cross V;
                            SplineY = -V;
                            SplineZ = W;
                        }
                    }
                    else
                    {
                        SplineX = LastTangent2D;
                        SplineY = W cross LastTangent2D;
                        SplineZ = W;
                    }

                    break;

                case CM_Runway3d:
                    if (W.Z >= 0.0)
                        Y = vect(0,0,1) cross Tangent;
                    else
                        Y = vect(0,0,-1) cross Tangent;

                    if (IsZero(Y))
                        Y = Z cross Tangent;

                    V = SplineInfo.CalculateLocation(CurrentSplineComp,SplineDistance);

                    if (!IsTouchingGround())
                        bConstrainMovement = false;

                    if (bConstrainMovement && !IsZero(Velocity))
                    {
                        if (SplineOffset == default.SplineOffset)
                            SplineOffset = (Location - V) dot Normal(Y);

                        if (!bDodging)
                        {
                            if (SplineOffset != 0.0)
                            {
                                if (SplineInfo.NumRailsLeft > 0 || SplineInfo.NumRailsRight > 0)
                                {
                                    if (SplineOffset < 0.0)
                                    {
                                        if (SplineInfo.NumRailsLeft > 0 &&
                                            SplineOffset < SplineInfo.RailDistanceOffset * -0.5)
                                        {
                                            if (SplineInfo.NumRailsLeft == 2 &&
                                                SplineOffset < SplineInfo.RailDistanceOffset * -1.5)
                                                SplineOffset = SplineInfo.RailDistanceOffset * -2.0;
                                            else
                                                SplineOffset = -SplineInfo.RailDistanceOffset;

                                            V += Normal(Y) * SplineOffset;
                                        }
                                        else
                                            SplineOffset = 0.0;
                                    }
                                    else
                                        if (SplineInfo.NumRailsRight > 0 &&
                                            SplineOffset > SplineInfo.RailDistanceOffset * 0.5)
                                        {
                                            if (SplineInfo.NumRailsRight == 2 &&
                                                SplineOffset > SplineInfo.RailDistanceOffset * 1.5)
                                                SplineOffset = SplineInfo.RailDistanceOffset * 2.0;
                                            else
                                                SplineOffset = SplineInfo.RailDistanceOffset;

                                            V += Normal(Y) * SplineOffset;
                                        }
                                        else
                                            SplineOffset = 0.0;
                                }
                                else
                                    SplineOffset = 0.0;
                            }
                        }
                        else
                            V += Normal(Y) * SplineOffset;

                        V = PointProjectToPlane(V - Location,vect(0,0,0),Tangent,Y);

                        if (!IsZero(V))
                        {
                            Speed = VSize(GetVelocity());

                            SetVelocity(Normal(GetVelocity() + V *
                                               (Speed * SplineInfo.ConstraintMagnitude * DeltaTime * 0.01)) * Speed);

                            if (!bDodging)
                                MoveSmooth(V * FMin(Speed * SplineInfo.ConstraintMagnitude * DeltaTime * 0.001,1.0));
                        }
                    }
                    else
                        if (SplineInfo.NumRailsLeft > 0 || SplineInfo.NumRailsRight > 0)
                            SplineOffset = (Location - V) dot Normal(Y);
                        else
                            SplineOffset = 0.0;

                    if (IsTouchingGround())
                    {
                        if (!bSonicPhysicsMode)
                        {
                            SplineZ = W;
                            SplineY = W cross Tangent;
                            SplineX = SplineY cross W;
                        }
                        else
                        {
                            if (!bInverted)
                                V = Normal(VLerp(vect(0,1,0) >> CurrentSplineActor.Rotation,
                                                 vect(0,1,0) >> CurrentSplineActor.NextOrdered.Rotation,
                                                 SplineDistance / CurrentSplineComp.GetSplineLength()));
                            else
                                V = Normal(VLerp(vect(0,1,0) >> CurrentSplineActor.PrevOrdered.Rotation,
                                                 vect(0,1,0) >> CurrentSplineActor.Rotation,
                                                 SplineDistance / CurrentSplineComp.GetSplineLength()));

                            V = Normal(Tangent cross V) cross Tangent;

                            SplineX = V cross W;
                            SplineY = V;
                            SplineZ = W;
                        }
                    }
                    else
                    {
                        SplineX = LastTangent2D;
                        SplineY = W cross LastTangent2D;
                        SplineZ = W;
                    }
            }
        }
        else
        {
            if (ConstrainedMovement != CM_None && CurrentSplineActor.bRotateCameraOnExit)
            {
                if (CurrentSplineActor.NextOrdered != none)
                    V *= -1;

                if (IsTouchingGround())
                    Z = GetFloorNormal();
                else
                    if (!bReverseGravity)
                        Z = vect(0,0,1);
                    else
                        Z = vect(0,0,-1);

                DesiredViewRotation = OrthoRotation(V,Z cross V,Z);

                if (Controller != none)
                    SGDKPlayerController(Controller).ForceRotation(DesiredViewRotation);
            }

            bClassicMovement = false;
            bConstrainMovement = false;
            ConstrainedMovement = CM_None;
            CurrentSplineComp = none;
            SplineDistance = 0.0;
            SplineOffset = default.SplineOffset;

            if (!IsTouchingActor(CurrentSplineActor))
                CurrentSplineActor = none;
        }
    }
}

/**
 * Detaches a previously attached actor to this pawn; the actor will no longer follow this pawn and rotate with it.
 * @param AnActor  actor to be detached
 */
function DetachFromRoot(Actor AnActor)
{
    local int i;

    AnActor.SetBase(none);

    for (i = 0; i < RootAttachments.Length; i++)
        if (RootAttachments[i].AttachedActor == AnActor)
        {
            RootAttachments.Remove(i,1);

            break;
        }
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
    local ReceivePawnEvents NotifyObject;

    //If pawn is really dead...
    if (super.Died(Killer,DamageClass,HitLocation))
    {
        CancelSuperForms();

        //Notify other objects.
        foreach NotifyEventsTo(NotifyObject)
            NotifyObject.PawnDied(self);

        //Set some values of the attached skeletal mesh.
        Mesh.SetAbsolute(false,false);
        Mesh.SetHidden(false);

        //Destroy the attached blob shadow.
        if (Shadow != none)
            Shadow.Destroy();

        //Destroy SpinDash effects.
        if (SpinDashEmitter != none)
        {
            DetachFromRoot(SpinDashEmitter);
            SpinDashEmitter.DelayedDestroy();
            SpinDashEmitter = none;
        }

        return true;
    }

    return false;
}

/**
 * Destroys all expiring items.
 */
function DiscardExpiringItems()
{
    local MonitorInventory Monitor;

    if (InvManager != none)
    {
        foreach InvManager.InventoryActors(class'MonitorInventory',Monitor)
            if (Monitor.TimeRemaining != Monitor.default.TimeRemaining)
                Monitor.TimeExpired();
    }
}

/**
 * Lists important variables on canvas.
 * The HUD will call DisplayDebug() on the current ViewTarget when the ShowDebug command is used.
 * @param Hud   the affected HUD object
 * @param YL    the height of a word plus padding in pixels
 * @param YPos  the Y position on screen in pixels
 */
simulated function DisplayDebug(HUD Hud,out float YL,out float YPos)
{
    super.DisplayDebug(Hud,YL,YPos);

    if (Hud.ShouldDisplayDebug('physics'))
    {
        Hud.Canvas.SetDrawColor(255,0,0,255);

        Hud.Canvas.SetPos(4,YPos);
        Hud.Canvas.DrawText("Location:" @ Location @ "Rotation:" @ GetRotation());
        YPos += YL;

        Hud.Canvas.SetPos(4,YPos);
        Hud.Canvas.DrawText("SonicPhysicsMode:" @ bSonicPhysicsMode @ "RunningOnWater:" @
                            bWaterRunningMode @ "SpiderPhysicsMode:" @ bSpiderPhysicsMode);
        YPos += YL;

        Hud.Canvas.SetPos(4,YPos);
        Hud.Canvas.DrawText("Velocity:" @ GetVelocity() @ "Speed:" @ VSize(GetVelocity()) @
                            "Speed2D:" @ VSize2D(GetVelocity()));
        YPos += YL;

        Hud.Canvas.SetPos(4,YPos);
        Hud.Canvas.DrawText("AccelRate:" @ AccelRate @ "DecelRate:" @ DecelRate @
                            "GroundSpeed:" @ GetGroundSpeed());
        YPos += YL;

        Hud.Canvas.SetPos(4,YPos);
        Hud.Canvas.DrawText("Floor:" @ GetFloorNormal() @ "SlopeSpeedBonus:" @ SlopeSpeedBonus);
        YPos += YL;
    }
}

/**
 * Player wants to dodge.
 * @param DoubleClickMove  double click/press move direction
 * @return                 true if dodge is performed
 */
function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    //Disabled.
    return false;
}

/**
 * Player pressed the jump button/key.
 * @param bUpdating  updating position in controller; ignore it
 * @return           true if done something related to jumps
 */
function bool DoJump(bool bUpdating)
{
    //Try to perform a standard jump.
    if (Jump(true))
        return true;
    else
        //If pawn is ducking...
        if (bCanSpinDash && bDucking)
            //Perform SpinDash move.
            SpinDashCharge();
        else
            return !NoActionPerformed(0);

    return false;
}

/**
 * Performs actual attachment; attaches an actor to this pawn.
 * @param AnActor  actor to be attached
 * @param Action   related Kismet sequence action
 */
function DoKismetAttachment(Actor AnActor,SeqAct_AttachToActor Action)
{
    local vector RelativeOffset;
    local rotator RelativeOrientation;

    if (Action.BoneName == '')
    {
        if (!Action.bUseRelativeOffset)
            RelativeOffset = AnActor.Location - Location;
        else
            RelativeOffset = Action.RelativeOffset >> GetRotation();

        if (!Action.bUseRelativeRotation)
            RelativeOrientation = AnActor.Rotation - GetRotation();
        else
            RelativeOrientation = Action.RelativeRotation;

        AttachToRoot(AnActor,RelativeOffset,RelativeOrientation);
    }
    else
        super.DoKismetAttachment(AnActor,Action);
}

/**
 * Play an emote (taunt) given a category and an index within that category.
 * @param EmoteTag  name tag of the category
 * @param PlayerID  index within the category
 */
simulated function DoPlayEmote(name EmoteTag,int PlayerID)
{
    //Disabled.
}

/**
 * Call if an aerial special movement is performed.
 */
function DoubleJumped()
{
    local ReceivePawnEvents NotifyObject;

    LastSpecialMoveTime = WorldInfo.TimeSeconds;

    //Notify controller.
    SGDKPlayerController(Controller).bDoubleJump = true;

    //No more multi-jumps until landing.
    MultiJumpRemaining = 0;

    //Notify other objects.
    foreach NotifyEventsTo(NotifyObject)
        NotifyObject.PawnDoubleJumped(self);
}

/**
 * Drops rings.
 * @param Rings  amount of rings to drop
 */
function DropRings(int Rings)
{
    local RingProjectile Ring;
    local vector Tangent;

    Rings = Min(Rings,50);

    if (bClassicMovement)
    {
        Tangent = CurrentSplineActor.CalculateTangent(CurrentSplineComp,SplineDistance);

        if (Abs(Tangent.Z) > 0.99)
            Tangent = vect(0,0,1) >> GetRotation();
    }

    while (Rings > 0)
    {
        Rings--;

        Ring = Spawn(DroppedRingsClass,none,,Location);

        if (bClassicMovement && Ring != none && FRand() < 0.8)
            Ring.SetClassicMode(Tangent);
    }

    if (DroppedRingsSound != none)
        PlaySound(DroppedRingsSound,false,true);
}

/**
 * Player wants to duck/unduck.
 * @param bDuck  true if this pawn should duck or not
 * @return       true if ducking
 */
function bool Duck(bool bDuck)
{
    local float HeightAdjust;
    local int i;
    local vector V;

    if (Health > 0)
    {
        if (bDuck)
        {
            if (!bCanCrouch)
            {
                if (bHanging)
                    //Cancel hanging from handle.
                    SetHanging(false);
                else
                    if (!bRolling && !bWaterRunningMode && IsTouchingGround() && !bMiniSize &&
                        VSizeSq(GetVelocity()) > Square(MinRollingSpeed))
                        Roll(true);
                    else
                        if (bRolling && bCanUnRoll)
                            Roll(false);
                        else
                            NoActionPerformed(2);
            }
            else
                if (!bDucking)
                {
                    bDucking = true;

                    GroundTraceLength = CrouchHeight * 1.75;
                    HeightAdjust = CrouchHeight - DefaultHeight;

                    //Change size and translation of collision cylinder according to pawn state.
                    UpdateCollisionCylinder();

                    Move((vect(0,0,1) >> DesiredMeshRotation) * HeightAdjust);

                    //Adjust base eye height.
                    OldZ -= HeightAdjust;
                    SetBaseEyeheight();

                    //Notify blend nodes the change of posture.
                    for (i = 0; i < PostureBlendNodes.Length; i++)
                        PostureBlendNodes[i].PostureChanged(2);
                }
        }
        else
            if (bDucking)
            {
                if (SpinDashCount == 0)
                {
                    bDucking = false;
                    V = Location;

                    if (FindSpot(GetCollisionExtent(),V))
                    {
                        GroundTraceLength = DefaultHeight * 1.75;
                        HeightAdjust = DefaultHeight - CrouchHeight;

                        //Move up.
                        Move((vect(0,0,1) >> DesiredMeshRotation) * HeightAdjust);

                        //Change size and translation of collision cylinder according to pawn state.
                        UpdateCollisionCylinder();

                        //Adjust base eye height.
                        OldZ += HeightAdjust;
                        SetBaseEyeheight();

                        //Notify blend nodes the change of posture.
                        for (i = 0; i < PostureBlendNodes.Length; i++)
                            PostureBlendNodes[i].PostureChanged(0);
                    }
                    else
                        bDucking = true;
                }
                else
                    SpinDashRelease();
            }
            else
                NoActionPerformed(3);
    }

    return bDucking;
}

/**
 * Every tick, applies rotation constraints and updates rotation of this pawn.
 * @param NewRotation  passed by controller, desired rotation for this pawn
 * @param DeltaTime    contains the amount of time in seconds that has passed since the last tick;
 *                     zero if the function is called from the native physics to update the rotation
 */
simulated function FaceRotation(rotator NewRotation,float DeltaTime)
{
    local int i;
    local vector V,Y,Z;

    if (DeltaTime > 0.0)
    {
        //If pawn is on a ladder...
        if (Physics == PHYS_Ladder)
        {
            //Use rotation given by the ladder volume.
            NewRotation = OnLadder.Walldir;

            //Set view rotation from the same rotation.
            DesiredViewRotation = NewRotation;
        }
        else
        {
            //Set view rotation from controller rotation.
            DesiredViewRotation = NewRotation;

            if (IsTouchingGround())
            {
                //If walking physics...
                if (Physics == PHYS_Walking)
                {
                    //Remove any pitch or roll rotation.
                    NewRotation.Pitch = 0;
                    NewRotation.Roll = 0;

                    //Remove any pitch or roll rotation.
                    DesiredViewRotation.Pitch = 0;
                    DesiredViewRotation.Roll = 0;
                }
                else
                    //If speed is zero...
                    if (IsZero(Velocity))
                        //Don't rotate the attached skeletal mesh.
                        NewRotation = DesiredMeshRotation;
            }
            else
                //If falling physics, straighten rotation according to gravity.
                if (Physics == PHYS_Falling)
                {
                    //Remove any pitch rotation.
                    NewRotation.Pitch = 0;
                    DesiredViewRotation.Pitch = 0;

                    //Remove any roll rotation according to gravity.
                    if (!bReverseGravity)
                    {
                        NewRotation.Roll = 0;
                        DesiredViewRotation.Roll = 0;
                    }
                    else
                    {
                        NewRotation.Roll = 32768;
                        DesiredViewRotation.Roll = 32768;
                    }
                }
        }

        V = GetVelocity();

        if (!IsZero(V) && (bUpdateMeshRotation || (IsTouchingGround() && VSizeSq(V) > 100.0) ||
            (!IsTouchingGround() && VSizeSq2D(V) > 100.0)))
        {
            bUpdateMeshRotation = false;

            if (IsTouchingGround())
            {
                if (!bMeshAlignToGravity || Physics != PHYS_Walking)
                    Z = GetFloorNormal();
                else
                    Z = Normal(vect(0,0,1) + GetFloorNormal());

                Y = Normal(Z cross Normal(V));

                DesiredMeshRotation = OrthoRotation(Y cross Z,Y,Z);
            }
            else
            {
                Z = -GetGravityDirection();
                Y = Z cross Normal(V);

                if (IsZero(Y))
                    Y = vect(0,1,0) >> CurrentMeshRotation;

                DesiredMeshRotation = OrthoRotation(Y cross Z,Y,Z);
            }
        }
        else
            if (bSonicPhysicsMode && NativePhysicsRotation != rot(0,0,0))
            {
                //Applies normalized new rotation to the desired rotation for the attached skeletal mesh.
                DesiredMeshRotation = Normalize(NewRotation);

                Z = GetFloorNormal();
                Y = Normal(Z cross vector(DesiredMeshRotation));

                DesiredMeshRotation = OrthoRotation(Y cross Z,Y,Z);
            }

        if (NativePhysicsRotation != rot(0,0,0))
        {
            if (!bFullNativeRotation)
            {
                CurrentMeshRotation.Yaw += NativePhysicsRotation.Yaw;
                DesiredMeshRotation.Yaw += NativePhysicsRotation.Yaw;
            }
            else
            {
                CurrentMeshRotation += NativePhysicsRotation;
                DesiredMeshRotation += NativePhysicsRotation;
            }

            NativePhysicsRotation = rot(0,0,0);
        }

        if (bSmoothRotation && SmoothRotationRate > 0.0)
            CurrentMeshRotation = QuatToRotator(QuatSlerp(QuatFromRotator(CurrentMeshRotation),
                                                          QuatFromRotator(DesiredMeshRotation),
                                                          FMin(SmoothRotationRate * DeltaTime,1.0),true));
        else
        {
            CurrentMeshRotation = DesiredMeshRotation;
            bSmoothRotation = default.bSmoothRotation;
        }

        if (MeshPitchRotation == 0.0)
            Mesh.SetRotation(CurrentMeshRotation);
        else
            Mesh.SetRotation(QuatToRotator(QuatProduct(QuatFromAxisAndAngle(vect(0,1,0) >> CurrentMeshRotation,
                MeshPitchRotation),QuatFromRotator(CurrentMeshRotation))));

        for (i = 0; i < RootAttachments.Length; i++)
            if (RootAttachments[i].AttachedActor != none && !RootAttachments[i].AttachedActor.bDeleteMe)
            {
                RootAttachments[i].AttachedActor.SetBase(none);

                RootAttachments[i].AttachedActor.SetLocation(Location +
                    (RootAttachments[i].RelativeLocation >> CurrentMeshRotation));

                if (!RootAttachments[i].bUseVelocity || IsZero(V))
                    RootAttachments[i].AttachedActor.SetRotation(CurrentMeshRotation +
                        RootAttachments[i].RelativeRotation);
                else
                {
                    V = Normal(V);
                    Y = vect(0,1,0) >> DesiredMeshRotation;

                    RootAttachments[i].AttachedActor.SetRotation(OrthoRotation(V,Y,V cross Y) +
                        RootAttachments[i].RelativeRotation);
                }

                RootAttachments[i].AttachedActor.SetBase(self);
            }
            else
                RootAttachments.Remove(i--,1);
    }
    else
        NativePhysicsRotation += NewRotation;
}

/**
 * Causes this pawn to drop to the ground and pretend to be dead.
 */
exec simulated function FeignDeath()
{
    //Only cancel feigning death.
    if (bFeigningDeath)
        ServerFeignDeath();
}

/**
 * Applies properly a new rotation to this pawn and its skeletal mesh.
 * @param NewRotation  desired rotation for this pawn
 * @param bModifyView  true if controller view rotation is affected
 * @param bResetPitch  true to reset pitch rotation of the attached skeletal mesh
 */
function ForceRotation(rotator NewRotation,bool bModifyView = true,optional bool bResetPitch)
{
    SetRotation(rot(0,0,0));

    //Set new rotation for attached skeletal mesh.
    DesiredMeshRotation = NewRotation;

    if (bModifyView)
        //Set new rotation for controller view rotation.
        SetViewRotation(NewRotation);

    //Applies new rotation to pawn's skeletal mesh.
    CurrentMeshRotation = NewRotation;

    if (bResetPitch)
        MeshPitchRotation = 0.0;

    if (MeshPitchRotation == 0.0)
        Mesh.SetRotation(CurrentMeshRotation);
    else
        Mesh.SetRotation(QuatToRotator(QuatProduct(QuatFromAxisAndAngle(vect(0,1,0) >> CurrentMeshRotation,
            MeshPitchRotation),QuatFromRotator(CurrentMeshRotation))));
}

/**
 * Gets the desired acceleration for the movement of this pawn.
 * @param InputManager  object within controller that manages player input (pressed keys)
 * @param ControllerX   vector which points forward according to controller rotation
 * @param ControllerY   vector which points right according to controller rotation
 * @param ControllerZ   vector which points upward according to controller rotation
 * @return              acceleration to apply to this pawn
 */
function vector GetAccelerationInput(SGDKPlayerInput InputManager,vector ControllerX,
                                     vector ControllerY,vector ControllerZ)
{
    local vector V;

    if (!bClassicMovement)
        V = Normal(ControllerX * InputManager.aForward + ControllerY * InputManager.aStrafe);
    else
        if (InputManager.aStrafe != 0.0)
            V = Normal(ControllerY * InputManager.aStrafe);
        else
            if (InputManager.aForward > 0.0 && !IsZero(Velocity))
            {
                if (vector(DesiredMeshRotation) dot ControllerY > 0.0)
                    V = Normal(ControllerY * InputManager.aForward);
                else
                    V = Normal(ControllerY * -InputManager.aForward);
            }

    if (V.Z != 0.0 && (Physics == PHYS_Walking || Physics == PHYS_Falling))
        V = Normal(V * vect(1,1,0));

    return V * AccelRate;
}

/**
 * Gets the target location of the camera for this pawn.
 * @return  camera target location
 */
function vector GetCameraTarget()
{
    if (bDucking || bRolling)
        return Location + GetFloorNormal() * (DefaultHeight - CrouchHeight);

    return Location;
}

/**
 * Gets the desired half of total collision height for this pawn.
 * @return  half of collision height of this pawn
 */
simulated function float GetCollisionHeight()
{
    if (bDucking || bRolling)
        return CrouchHeight;

    if (bMiniSize)
        return MiniHeight;

    if (bSpiderPhysicsMode)
        return SpiderRadius;

    return DefaultHeight;
}

/**
 * Gets the desired total collision radius for this pawn.
 * @return  collision radius of this pawn
 */
simulated function float GetCollisionRadius()
{
    if (bDucking || bRolling)
        return CrouchRadius;

    if (bMiniSize)
        return MiniRadius;

    if (bSpiderPhysicsMode)
        return SpiderRadius;

    return DefaultRadius;
}

/**
 * Gets the default direction used by this pawn to move when there isn't a pressed direction.
 * @return  default direction
 */
function vector GetDefaultDirection()
{
    if (!bClassicMovement && ShouldRotateView())
        return vector(DesiredViewRotation);
    else
        return vector(DesiredMeshRotation);
}

/**
 * This will determine and then return the FamilyInfo of this pawn.
 * @return  class of FamilyInfo
 */
simulated function class<UTFamilyInfo> GetFamilyInfo()
{
    return FamilyInfoClass;
}

/**
 * Gets the current normal vector to the floor plane.
 * @return  normalized vector to the floor plane
 */
function vector GetFloorNormal()
{
    //Returns the correct floor normal if pawn is in Sonic Physics mode or not.
    return bSonicPhysicsMode ? FloorNormal : Floor;
}

/**
 * Gets the sound to play for a footstep.
 * @param MaterialType  the name of the material type under feet
 * @return              the sound to play, if found
 */
function SoundCue GetFootstepSound(name MaterialType)
{
    local int i;

    if (FootstepSounds.Length > 0 && MaterialType != '')
    {
        i = FootstepSounds.Find('MaterialType',MaterialType);

        if (i != INDEX_NONE)
            return FootstepSounds[i].Sound;
    }

    return FootstepDefaultSound;
}

/**
 * Gets the current direction of gravity.
 * @return  direction of gravity
 */
function vector GetGravityDirection()
{
    return bReverseGravity ? vect(0,0,1) : vect(0,0,-1);
}

/**
 * Gets the current on ground speed value.
 * @return  on ground speed value
 */
function float GetGroundSpeed()
{
    return RealGroundSpeed;
}

/**
 * Gets the sound to play for landing.
 * @param MaterialType  the name of the material type under feet
 * @return              the sound to play, if found
 */
function SoundCue GetLandingSound(name MaterialType)
{
    local int i;

    if (LandingSounds.Length > 0 && MaterialType != '')
    {
        i = LandingSounds.Find('MaterialType',MaterialType);

        if (i != INDEX_NONE)
            return LandingSounds[i].Sound;
    }

    return LandingDefaultSound;
}

/**
 * Gets the name of the material type below feet.
 * @return  name of material type
 */
simulated function name GetMaterialBelowFeet()
{
    local Actor HitActor;
    local vector HitLocation,HitNormal;
    local TraceHitInfo HitInfo;
    local name MaterialType;

    HitActor = Trace(HitLocation,HitNormal,Location + (vect(0,0,-1) >> DesiredMeshRotation) * GroundTraceLength,
                     Location,false,,HitInfo,TRACEFLAG_PhysicsVolumes);

    CachedWaterVolume = SGDKWaterVolume(HitActor);

    if (CachedWaterVolume != none)
        MaterialType = (Location.Z - HitLocation.Z < 0.5 * GetCollisionHeight()) ? 'Water' : 'ShallowWater';
    else
        MaterialType = GetMaterialType(HitInfo);

    return MaterialType;
}

/**
 * Gets the name of the material type of a TraceHitInfo structure.
 * @param HitInfo  structure which holds information about the hit
 * @return         name of material type
 */
function name GetMaterialType(TraceHitInfo HitInfo)
{
    local UTPhysicalMaterialProperty PhysicalProperty;

    if (HitInfo.PhysMaterial != none)
    {
        PhysicalProperty = UTPhysicalMaterialProperty(HitInfo.PhysMaterial.GetPhysicalMaterialProperty(
                               class'UTPhysicalMaterialProperty'));

        if (PhysicalProperty != none)
            return PhysicalProperty.MaterialType;
    }

    return '';
}

/**
 * Gets the damage type to use for melee attacks.
 * @return  class of melee damage type
 */
function class<DamageType> GetMeleeDamageType()
{
    local class<DamageType> DmgType;

    DmgType = Shield.GetAttackDamageType();

    if (DmgType != none)
        return DmgType;
    else
        if (HasJumped())
            return JumpedDamageType;
        else
            if (bRolling || bSpiderPhysicsMode || SpinDashCount > 0)
                return RollingDamageType;
            else
                if (bSuperForm)
                    return SuperDamageType;
                else
                    if (bIsInvulnerable)
                        return InvincibleDamageType;
                    else
                        return none;
}

/**
 * Gets the correct position in the PhysicsData array to use for a different physics setup.
 * @return  index for PhysicsData array
 */
function byte GetPhysicsDataIndex()
{
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
 * Gets the "true" rotation of the player pawn in world space.
 * @return  rotation of pawn
 */
function rotator GetRotation()
{
    return DesiredMeshRotation;
}

/**
 * Gets the sound to play for skidding.
 * @param MaterialType  the name of the material type under feet
 * @return              the sound to play, if found
 */
function SoundCue GetSkiddingSound(name MaterialType)
{
    local int i;

    if (SkiddingSounds.Length > 0 && MaterialType != '')
    {
        i = SkiddingSounds.Find('MaterialType',MaterialType);

        if (i != INDEX_NONE)
            return SkiddingSounds[i].Sound;
    }

    return SkiddingDefaultSound;
}

/**
 * Gets the speed bonus applied while running on slopes.
 * @param Speed       current velocity magnitude
 * @param DotSpeedZ   vertical speed value; range [-1,+1]
 * @param AccelBonus  on slope acceleration rate bonus
 * @param SpeedBonus  on slope maximum speed bonus
 */
function GetSlopeBonuses(float Speed,float DotSpeedZ,out float AccelBonus,out float SpeedBonus)
{
    if (!bClassicSlopes)
    {
        if (DotSpeedZ > 0.0)
        {
            AccelBonus = -DotSpeedZ * MaxSlopeUpBonus;
            SpeedBonus = -DotSpeedZ * (RefGroundSpeed - MinAdhesionSpeed + 10.0);
        }
        else
        {
            AccelBonus = -DotSpeedZ * MaxSlopeDownBonus;
            SpeedBonus = ApexGroundSpeed - RefGroundSpeed;
        }
    }
    else
    {
        if (DotSpeedZ > 0.0)
        {
            AccelBonus = -DotSpeedZ * MaxSlopeUpBonus;
            SpeedBonus = RefGroundSpeed * -0.875;

            if (FloorDotAngle < WalkableFloorZ)
                AccelBonus *= 0.65;
        }
        else
        {
            AccelBonus = -DotSpeedZ * MaxSlopeDownBonus;
            SpeedBonus = ApexGroundSpeed - RefGroundSpeed;

            if (Speed > RefGroundSpeed + 1.0)
                AccelRate = 0.0;
        }
    }
}

/**
 * Gets the "true" smooth rotation of the player pawn in world space; do not use if possible, use GetRotation().
 * @return  smooth rotation of pawn
 */
function rotator GetSmoothRotation()
{
    return CurrentMeshRotation;
}

/**
 * Gets the sound to play for SpinDash movement.
 * @param MaterialType  the name of the material type under body
 * @param SpinDashMode  specifies SpinDash mode; 0 is charge, 1 is release
 * @return              the sound to play, if found
 */
function SoundCue GetSpinDashSound(name MaterialType,int SpinDashMode)
{
    local int i;

    if (SpinDashMode == 0)
    {
        if (SpinDashChargeSounds.Length > 0 && MaterialType != '')
        {
            i = SpinDashChargeSounds.Find('MaterialType',MaterialType);

            if (i != INDEX_NONE)
                return SpinDashChargeSounds[i].Sound;
        }

        return SpinDashChargeDefaultSound;
    }
    else
        return SpinDashReleaseSound;
}

/**
 * Gets the true velocity of the player pawn in world space; usually used for walking physics.
 * @return  velocity of pawn
 */
function vector GetVelocity()
{
    local vector V1,V2;

    //If not walking physics or floor normal is vertical or speed magnitude is zero...
    if (Physics != PHYS_Walking)
        return Velocity;
    else
    {
        //Unreal walking physics only works with flat XY velocity vectors.
        Velocity.Z = 0.0;

        if (Floor.Z == 1.0 || Floor.Z == 0.0 || (Abs(Velocity.X) < 0.01 && Abs(Velocity.Y) < 0.01))
            return Velocity;
        else
            if (Velocity != CachedVelocityData.UnrealVelocity || Floor != CachedVelocityData.Floor)
            {
                //Get the real velocity vector because walking physics only works with flat XY velocity vectors.
                V1 = Normal(Velocity);
                V2 = Normal(Normal(vect(0,0,1) cross V1) cross Floor);
                V2 *= VSize(Velocity) / (V1 dot V2);

                //Cache the related data to get better performance.
                CachedVelocityData.UnrealVelocity = Velocity;
                CachedVelocityData.Floor = Floor;
                CachedVelocityData.RealVelocity = V2;

                return V2;
            }
            else
                //Return cached data.
                return CachedVelocityData.RealVelocity;
    }
}

/**
 * Gives health points to the player pawn.
 * @param HealAmount  amount of health points
 * @param HealMax     maximum resulting health allowed
 * @return            true if health points were given
 */
function bool GiveHealth(int HealAmount,int HealMax)
{
    local int OldHealth;
    local MonitorInventory Life;

    if (Health < HealMax)
    {
        OldHealth = Health;
        Health = Clamp(Health + HealAmount,1,HealMax);

        if (OldHealth < HealthLimit && Health >= HealthLimit)
        {
            Life = Spawn(LifeInventoryClass,self);

            if (Life != none)
                Life.NewOwner(self);

            HealthLimit += 100;
        }

        return true;
    }
    else
        return false;
}

/**
 * Player pawn wants to perform an on ground special move.
 * @param ButtonId  identification of the (un)pressed button; 4 is SpecialMove, 5 is UnSpecialMove
 * @return          true if pawn performed the special move
 */
function bool GroundSpecialMove(byte ButtonId)
{
    return false;
}

/**
 * Has the player pawn collected all the Chaos Emeralds?
 * @return  true if pawn has all the Chaos Emeralds
 */
function bool HasAllEmeralds()
{
    if (!bHasHyperForm)
        return (Controller != none && SGDKPlayerController(Controller).ChaosEmeralds > 6);
    else
        return (Controller != none && SGDKPlayerController(Controller).ChaosEmeralds > 13);
}

/**
 * Has the player pawn jump?
 * @return  true if pawn has jumped
 */
function bool HasJumped()
{
    return bReadyToDoubleJump;
}

/**
 * Has the player pawn a shield?
 * @return  true if shield object exists and is visible
 */
function bool HasShield()
{
    return (Shield != none && !Shield.IsInState('Disabled'));
}

/**
 * Applies an on ground high speed boost.
 * @param BoostPct           percent of ApexGroundSpeed that magnitude of applied boost is
 * @param bUseRotation       false if boost direction uses velocity vector as reference instead of current rotation
 * @param DisabledInputTime  how long the boost lasts
 */
function HighSpeedBoost(float BoostPct = 1.0,bool bUseRotation = false,optional float DisabledInputTime)
{
    local float Boost;

    //Apply boost only if pawn is touching ground.
    if (IsTouchingGround())
    {
        //Magnitude of applied boost.
        Boost = FMax(VSize(GetVelocity()),ApexGroundSpeed * BoostPct);

        if (!bUseRotation)
        {
            //If speed isn't zero...
            if (!IsZero(Velocity))
                //Use velocity as reference.
                SetVelocity(Normal(GetVelocity()) * Boost);
            else
                //Use view rotation as reference instead.
                SetVelocity(vector(DesiredViewRotation) * Boost);
        }
        else
            //Use pawn rotation as reference.
            SetVelocity(vector(DesiredMeshRotation) * Boost);

        //Adapt on ground speed to new speed.
        SetGroundSpeed(FMax(RealGroundSpeed,Boost));

        //Refresh values of important variables.
        GroundSpeed = RealGroundSpeed;
        if (bSonicPhysicsMode)
            AirSpeed = RealGroundSpeed;

        if (DisabledInputTime > 0.0)
        {
            //If a determined timer isn't set...
            if (!IsTimerActive(NameOf(HighSpeedBoostEnd)))
            {
                //Greatly decrease deceleration.
                ScaleDeceleration(0.01);

                //Ignore directional movement input.
                if (Controller != none)
                    SGDKPlayerController(Controller).IgnoreDirInput(true);
            }

            SetTimer(DisabledInputTime,false,NameOf(HighSpeedBoostEnd));
        }
        else
            //If a determined timer is set then cancel it properly.
            if (IsTimerActive(NameOf(HighSpeedBoostEnd)))
                HighSpeedBoostEnd();
    }
}

/**
 * Stops applying an on ground high speed boost.
 */
function HighSpeedBoostEnd()
{
    ClearTimer(NameOf(HighSpeedBoostEnd));

    //Restore deceleration scale value.
    ScaleDeceleration(100.0);

    //Stop ignoring directional movement input.
    if (Controller != none)
        SGDKPlayerController(Controller).IgnoreDirInput(false);
}

/**
 * Draws 2D graphics on the HUD.
 * @param TheHud  the HUD
 */
function HudGraphicsDraw(SGDKHud TheHud)
{
    local float YPos1,YPos2;
    local UTTimedPowerup Powerup;

    if (InvManager != none)
    {
        YPos1 = TheHud.Canvas.ClipY * TheHud.PowerupYPos;
        YPos2 = 0.0;

        foreach InvManager.InventoryActors(class'UTTimedPowerup',Powerup)
        {
            Powerup.DisplayPowerup(TheHud.Canvas,TheHud,TheHud.ResolutionScale,YPos1);

            if (MonitorInventory(Powerup) != none)
                MonitorInventory(Powerup).HudGraphicsDraw(TheHud,YPos2);
        }
    }
}

/**
 * Updates all 2D graphics' values safely.
 * @param DeltaTime  time since last render of the HUD
 * @param TheHud     the HUD
 */
function HudGraphicsUpdate(float DeltaTime,SGDKHud TheHud)
{
    local MonitorInventory Monitor;

    if (InvManager != none)
    {
        foreach InvManager.InventoryActors(class'MonitorInventory',Monitor)
            Monitor.HudGraphicsUpdate(DeltaTime,TheHud);
    }
}

/**
 * Hurts a pawn by using a melee attack.
 * @param APawn  the pawn that receives the damage
 */
function HurtPawn(SGDKPawn APawn)
{
    local ReceivePawnEvents NotifyObject;

    APawn.TakeDamage(1,Controller,Location,GetVelocity(),GetMeleeDamageType(),,self);

    if (APawn.Health < 1 && SGDKEnemyPawn(APawn) != none)
    {
        ReceiveEnergy(SGDKEnemyPawn(APawn).EnergyBonus);

        ReceiveScore(SGDKEnemyPawn(APawn).ScoreBonus,APawn);
    }

    //Notify other objects.
    foreach NotifyEventsTo(NotifyObject)
        NotifyObject.PawnHurtPawn(self,APawn);
}

/**
 * Sets or unsets player's hyper form.
 * @param bHyper  sets/unsets hyper form
 */
function HyperForm(bool bHyper)
{
    if (!bHyper)
    {
        if (bHyperForm)
        {
            SuperForm(false);

            bHyperForm = false;

            DetachComponent(HyperSkeletalGhosts[0]);
            DetachComponent(HyperSkeletalGhosts[1]);
        }
    }
    else
        if (!bSuperForm)
        {
            bHyperForm = true;

            SuperForm(true);

            HyperSkeletalGhosts[0].SetSkeletalMesh(Mesh.SkeletalMesh);
            HyperSkeletalGhosts[1].SetSkeletalMesh(Mesh.SkeletalMesh);

            AttachComponent(HyperSkeletalGhosts[0]);
            AttachComponent(HyperSkeletalGhosts[1]);
        }
}

/**
 * Player wants to transform into a hyper state.
 */
function HyperTransformation()
{
    HyperForm(true);
}

/**
 * Is player pawn in a type of volume?
 * @param VolumeName  name of volume class
 * @return            true if pawn is in the provided type of volume
 */
function bool IsInClassVolume(name VolumeName)
{
    local Volume V;

    //Iterate through touching volumes and check their type.
    foreach TouchingActors(class'Volume',V)
        if (V.IsA(VolumeName))
            return true;

    return false;
}

/**
 * Is player pawn invulnerable to a damage type?
 * @param DamageClass  class describing the damage that was done
 * @return             true if pawn is invulnerable
 */
function bool IsInvulnerable(optional class<DamageType> DamageClass)
{
    if (DamageClass != none)
    {
        if (!DamageClass.default.bArmorStops)
            return false;
        else
            if (Shield.PreventDamage(DamageClass))
                return true;
    }

    return (bIsInvulnerable || WorldInfo.TimeSeconds - LastDamageTime < MinTimeDamage);
}

/**
 * Is the player pawn magnetized?
 * @return  true if pawn can attract magnetized rings
 */
function bool IsMagnetized()
{
    return (Shield != none && Shield.IsInState('Magnetic'));
}

/**
 * Is the player pawn near the ground?
 * @param bUseLine  if true, a thin line trace is used instead of box trace
 * @return          true if pawn is near the ground
 */
function bool IsNearGround(bool bUseLine = false)
{
    local vector HitLocation,HitNormal,TraceEnd,TraceExtent;

    if (!bUseLine)
    {
        TraceExtent = vect(0.7,0.7,0.0) * GetCollisionRadius();
        TraceExtent.Z = 0.5;

        //Checked place is different according to gravity.
        if (!bReverseGravity)
        {
            TraceEnd = Location + vect(0,0,-1) * GroundTraceLength;

            //Perform a check for collision geometry.
            if (Trace(HitLocation,HitNormal,TraceEnd,Location,true,TraceExtent,,TRACEFLAG_Blocking) != none &&
                HitNormal.Z > WalkableFloorZ && HitLocation.Z - 0.5 < Location.Z - GetCollisionHeight() * 0.6)
                return true;
            else
                return false;
        }
        else
        {
            TraceEnd = Location + vect(0,0,1) * GroundTraceLength;

            //Perform a check for collision geometry.
            if (Trace(HitLocation,HitNormal,TraceEnd,Location,true,TraceExtent,,TRACEFLAG_Blocking) != none &&
                HitNormal.Z < -WalkableFloorZ && HitLocation.Z + 0.5 < Location.Z + GetCollisionHeight() * 0.6)
                return true;
            else
                return false;
        }
    }
    else
    {
        //Checked place is different according to gravity.
        if (!bReverseGravity)
            TraceEnd = Location + vect(0,0,-1) * GroundTraceLength;
        else
            TraceEnd = Location + vect(0,0,1) * GroundTraceLength;

        //Perform a check for collision geometry.
        return !FastTrace(TraceEnd,Location);
    }
}

/**
 * Is the player pawn rolling on ground?
 * @return  true if pawn's rolling on ground flag is set
 */
function bool IsRolling()
{
    return bRolling;
}

/**
 * Is Sonic Physics mode allowed?
 * @param AnActor  optional floor actor to check
 * @return         true if pawn allowed to activate Sonic Physics mode
 */
function bool IsSonicPhysicsAllowed(optional Actor AnActor)
{
    local SonicPhysicsVolume V;

    if (!bDisableSonicPhysics)
    {
        if (AnActor == none)
        {
            foreach TouchingActors(class'SonicPhysicsVolume',V)
                if (V.ApplyToActorClass == none && V.ApplyToActorObject == none)
                    return true;
        }
        else
        {
            if (SGDKStaticMeshActor(AnActor) != none)
                return true;

            foreach TouchingActors(class'SonicPhysicsVolume',V)
                if ((V.ApplyToActorClass == none && V.ApplyToActorObject == none) ||
                    (V.ApplyToActorClass == AnActor.Class || V.ApplyToActorObject == AnActor))
                    return true;
        }
    }

    return false;
}

/**
 * Is the player pawn touching a specific actor?
 * @param AnActor  actor to check
 * @return         true if pawn is touching the actor
 */
function bool IsTouchingActor(Actor AnActor)
{
    local Actor A;

    //Look for the actor in the Touching array.
    foreach TouchingActors(class'Actor',A)
        if (A == AnActor)
            return true;

    return false;
}

/**
 * Is the player pawn touching ground?
 * @return  true if pawn is standing/walking/running
 */
function bool IsTouchingGround()
{
    return (Physics == PHYS_Walking || (bSonicPhysicsMode && bOnGround) || Physics == PHYS_Spider);
}

/**
 * Is the player pawn using a melee attack?
 * Add other melee attack flags here.
 * @return  true if pawn is performing a melee attack
 */
function bool IsUsingMelee()
{
    return (bIsInvulnerable || bRolling || bSpiderPhysicsMode ||
            SpinDashCount > 0 || HasJumped() || Shield.IsAttacking());
}

/**
 * Is a primitive component pushable?
 * @param TestComponent  primitive component to test
 * @return               true if primitive component is pushable
 */
function bool IsValidPush(PrimitiveComponent TestComponent)
{
    local vector TraceEnd,HitLocation,HitNormal,HitNormalB;

    TraceEnd = Location + ((vect(2,-1,0) * GetCollisionRadius()) >> DesiredMeshRotation);

    if (TraceComponent(HitLocation,HitNormal,TestComponent,TraceEnd,Location))
    {
        TraceEnd = Location + ((vect(2,1,0) * GetCollisionRadius()) >> DesiredMeshRotation);

        if (TraceComponent(HitLocation,HitNormalB,TestComponent,TraceEnd,Location) &&
            HitNormal dot HitNormalB > 0.71)
            return true;
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

/**
 * Should be manually called before the pawn leaves the actor is standing on.
 */
function LeftGround()
{
    local vector Spot;

    //Set some values.
    bNotifyJumpApex = true;
    AirSpeed = default.AirSpeed;
    GroundSpeed = RefAerialSpeed;
    LastJumpTime = 0.0;

    if (bRolling)
        //Unset rolling on ground mode.
        Roll(false);
    else
        if (SpinDashCount > 0)
            //Cancel SpinDash.
            SpinDashCancel();

    if (bSonicPhysicsMode)
    {
        Spot = Location;

        //Try to position a box to avoid overlapping world geometry.
        if (FindSpot(GetCollisionExtent(),Spot))
            Move(Spot - Location);

        //Unset Sonic Physics mode.
        SetSonicPhysics(false);
    }

    if (!bDisableBlobShadows)
        //Show the blob shadow.
        Shadow.SetHidden(false);

    //Player is unforced to run forward.
    if (Controller != none && SGDKPlayerController(Controller).bKeepForward)
        SGDKPlayerController(Controller).KeepRunning(0.0);
}

/**
 * Tries to magnetize nearby objects.
 * @param Radius  the radius of the sphere used for the check
 */
function MagnetizeNearbyActors(float Radius)
{
    local Actor A;

    //For each magnetizable object...
    foreach VisibleCollidingActors(class'Actor',A,Radius,Location,false,,,class'MagnetizableEntity')
        MagnetizableEntity(A).Magnetize(self);
}

/**
 * Inflicts damage to an actor by using a melee attack.
 * @param HitActor   the hit actor
 * @param HitNormal  the surface normal of the hit actor
 */
function MeleeDamage(Actor HitActor,vector HitNormal)
{
    if (Physics == PHYS_Falling)
    {
        HitActor.TakeDamage(1,Controller,Location,GetVelocity() * 0.5,JumpedDamageType,,self);

        if (!BounceData.bWillBounce)
        {
            if (!bReverseGravity)
                Bounce(HitNormal * FMax(500.0,VSize(GetVelocity()) * 0.7),
                       HitNormal.Z < WalkableFloorZ,false,true,HitActor,'Melee');
            else
                Bounce(HitNormal * FMax(500.0,VSize(GetVelocity()) * 0.7),
                       HitNormal.Z < -WalkableFloorZ,false,true,HitActor,'Melee');
        }
    }
    else
        if (bRolling || SpinDashCount > 0)
            HitActor.TakeDamage(1,Controller,Location,GetVelocity() * 0.5,RollingDamageType,,self);
}

/**
 * Sets or unsets mini-size mode.
 * @param bMini  sets/unsets mini-size mode
 */
function MiniSize(bool bMini = false)
{
    local float HeightAdjust,SizeAdjust;
    local vector V;
    local int i;

    //Set new mode.
    bMiniSize = bMini;

    if (bMiniSize)
    {
        ClearTimer(NameOf(MiniSize));

        CancelMoves();

        bCanCrouch = false;

        if (bDucking)
            Duck(false);

        SizeAdjust = MiniHeight / DefaultHeight;

        Mesh.SetScale(Mesh.Scale * SizeAdjust);
        Shield.ShieldMesh.SetScale(Shield.ShieldMesh.Scale * SizeAdjust);

        GroundTraceLength = MiniHeight * 1.75;
        HeightAdjust = MiniHeight - DefaultHeight;

        //Change size and translation of collision cylinder according to pawn state.
        UpdateCollisionCylinder();

        Move((vect(0,0,1) >> DesiredMeshRotation) * HeightAdjust);

        //Adjust base eye height.
        OldZ -= HeightAdjust;
        SetBaseEyeheight();

        for (i = 0; i < PlayRateBlendNodes.Length; i++)
            PlayRateBlendNodes[i].BaseSpeed *= SizeAdjust;
    }
    else
    {
        V = Location;

        if (FindSpot(GetCollisionExtent(),V))
        {
            ClearTimer(NameOf(MiniSize));

            SizeAdjust = DefaultHeight / MiniHeight;

            Mesh.SetScale(Mesh.Scale * SizeAdjust);
            Shield.ShieldMesh.SetScale(Shield.ShieldMesh.Scale * SizeAdjust);

            GroundTraceLength = DefaultHeight * 1.75;
            HeightAdjust = DefaultHeight - MiniHeight;

            if (V != Location)
                Move(V - Location);
            else
                Move((vect(0,0,1) >> DesiredMeshRotation) * HeightAdjust);

            //Change size and translation of collision cylinder according to pawn state.
            UpdateCollisionCylinder();

            //Adjust base eye height.
            OldZ += HeightAdjust;
            SetBaseEyeheight();

            for (i = 0; i < PlayRateBlendNodes.Length; i++)
                PlayRateBlendNodes[i].BaseSpeed *= SizeAdjust;

            if (bHanging)
                CheckHanging();
        }
        else
            bMiniSize = true;
    }
}

/**
 * Modifies the ability to turn left-right.
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param DeltaRotation  contains the amount of yaw rotation caused since the last tick
 * @return               the allowed amount of turning for yaw rotation
 */
function int ModifyTurningAbility(float DeltaTime,int DeltaRotation)
{
    DeltaRotation = FClamp(DeltaRotation,-200000 * DeltaTime,200000 * DeltaTime);

    if (!bRolling && IsTouchingGround() && AboveWalkingSpeed())
        //Decrease turning sensibility while running fast.
        DeltaRotation *= FMax(DefaultGroundSpeed / VSize(GetVelocity()),0.5);

    return DeltaRotation;
}

/**
 * Player pressed or released the Jump/Duck/SpecialMove key/button and no action was performed.
 * @param ButtonId  identification of the (un)pressed button; 0 is Jump, 1 is UnJump, 2 is Duck, 3 is UnDuck,
 *                                                            4 is SpecialMove, 5 is UnSpecialMove
 * @return          false if pawn finally performed an action
 */
function bool NoActionPerformed(byte ButtonId = 0)
{
    local array<ESpecialAction> SpecialActions;
    local int i;

    //Avoid two consecutive special moves that are too close in time.
    if (!bDisableSpecialMoves && WorldInfo.TimeSeconds - LastSpecialMoveTime > MinTimeSpecialMoves)
    {
        if (Physics == PHYS_Falling)
        {
            switch (ButtonId)
            {
                case 0:
                    SpecialActions = AerialActionsJump;

                    break;

                case 1:
                    SpecialActions = AerialActionsUnJump;

                    break;

                case 2:
                    SpecialActions = AerialActionsDuck;

                    break;

                case 3:
                    SpecialActions = AerialActionsUnDuck;

                    break;

                case 4:
                    SpecialActions = AerialActionsSpecialMove;

                    break;

                case 5:
                    SpecialActions = AerialActionsUnSpecialMove;
            }

            for (i = 0; i < SpecialActions.Length; i++)
            {
                switch (SpecialActions[i])
                {
                    case SA_CharacterMove:
                        if (AerialSpecialMove(ButtonId))
                        {
                            DoubleJumped();

                            return false;
                        }

                        break;

                    case SA_ShieldMove:
                        if (!bDisableShieldMoves && Shield.SpecialMove())
                        {
                            DoubleJumped();

                            return false;
                        }

                        break;

                    case SA_SuperTransform:
                        if (HasJumped() && SuperTransformation())
                            return false;
                }
            }
        }
        else
            if (IsTouchingGround() && GroundSpecialMove(ButtonId))
            {
                LastSpecialMoveTime = WorldInfo.TimeSeconds;

                return false;
            }
    }

    return true;
}

/**
 * Attaches an actor to this pawn through a Kismet action.
 * @param Action  related Kismet sequence action
 */
function OnAttachToActor(SeqAct_AttachToActor Action)
{
    local array<Object> ObjectVars;
    local int i;
    local Actor A;
    local Controller C;

    super.OnAttachToActor(Action);

    if (Action.bDetach)
    {
        Action.GetObjectVars(ObjectVars,"Attachment");

        for (i = 0; i < ObjectVars.Length && A == none; i++)
        {
            A = Actor(ObjectVars[i]);
            C = Controller(A);

            if (C != none && C.Pawn != none)
                A = C.Pawn;

            if (A != none)
                DetachFromRoot(A);
        }
    }
}

/**
 * Tells player pawn to react to player input while on ground.
 * @param StateId  identification of a state; 0 is accelerating, 1 is decelerating, 2 is braking
 */
function OnGroundState(byte StateId)
{
    local int i;

    switch (StateId)
    {
        case 0:
            InputState = IS_Accel;

            break;
        case 1:
            InputState = IS_None;

            break;
        case 2:
            InputState = IS_Brake;
    }

    if (!bSkidding)
    {
        if (InputState == IS_Brake && !bDucking && !bPushing && !bRolling && !bSpiderPhysicsMode)
        {
            bSkidding = true;

            //Notify blend nodes the change of posture.
            for (i = 0; i < PostureBlendNodes.Length; i++)
                PostureBlendNodes[i].PostureChanged(1);
        }
    }
    else
        if (InputState != IS_Brake || bDucking || bPushing || bRolling || bSpiderPhysicsMode)
        {
            bSkidding = false;

            //Notify blend nodes the change of posture.
            for (i = 0; i < PostureBlendNodes.Length; i++)
                if (PostureBlendNodes[i].ActiveChildIndex == 1)
                    PostureBlendNodes[i].PostureChanged(0);
        }
}

/**
 * Handler for the SeqAct_SetVelocity action; allows level designers to impart a velocity on this pawn.
 * @param Action  related Kismet sequence action
 */
simulated function OnSetVelocity(SeqAct_SetVelocity Action)
{
    local float Speed;
    local vector V;

    Speed = Action.VelocityMag;

    if (Speed <= 0.0)
        Speed = VSize(Action.VelocityDir);

    V = Normal(Action.VelocityDir) * Speed;

    if (Action.bVelocityRelativeToActorRotation)
        V = V >> DesiredMeshRotation;

    Velocity = V;

    if (Physics == PHYS_RigidBody && CollisionComponent != none)
        CollisionComponent.SetRBLinearVelocity(Velocity);

    if (Speed == 0.0)
        Acceleration = vect(0,0,0);
    else
        Acceleration = Velocity * 5.0;
}

/**
 * Allows the pawn to ignore any velocity set by the native physics engine due to collisions.
 */
function OverrideVelocity()
{
    VelocityOverride = GetVelocity();
}

/**
 * Called once after the pawn enters a new physics volume.
 */
protected function PhysicsVolumeChangeDelayed()
{
    if (PhysicsVolume.bWaterVolume)
        bEnteredWater = true;

    ResetPhysicsValues();
}

/**
 * Plays a dodging sound.
 */
function PlayDodgeSound()
{
    if (DodgeSound != none)
        PlaySound(DodgeSound,false,true);
}

/**
 * Plays the drowning music track.
 */
function PlayDrowningMusic()
{
    if (Controller != none)
        SGDKPlayerController(Controller).GetMusicManager().StartMusicTrack(
            SGDKPlayerController(Controller).GetMusicManager().DrowningMusicTrack,0.0);
}

/**
 * Plays a dying sound.
 */
function PlayDyingSound()
{
    if (!bDrowned)
    {
        if (DyingSound != none)
            PlaySound(DyingSound,false,true);
    }
    else
        if (DrownSound != none)
            PlaySound(DrownSound,false,true);
}

/**
 * Called by AnimNotify_Footstep; plays a footstep sound.
 * @param FootId  specifies which foot hit; 0 is left footstep, 1 is right footstep,
 *                                          2 is skidding, 3 is landing
 */
simulated event PlayFootStepSound(int FootId)
{
    if (FootId == 3 || (IsTouchingGround() && !WillLeaveGround()))
        super.PlayFootStepSound(FootId);
}

/**
 * Plays a hurt sound.
 */
function PlayHurtSound()
{
    if (HurtSound != none)
        PlaySound(HurtSound,false,true);
}

/**
 * Plays a jumping sound.
 */
function PlayJumpingSound()
{
    if (JumpingSound != none)
        PlaySound(JumpingSound,false,true);
}

/**
 * Plays a landing sound.
 */
function PlayLandingSound()
{
    //Don't play landing sound while spawning.
    if (WorldInfo.TimeSeconds - LastStartTime > 1.0)
        PlayFootstepSound(3);
}

/**
 * Plays a rolling on ground sound.
 */
function PlayRollingSound()
{
    if (RollingSound != none)
        PlaySound(RollingSound,false,true);
}

/**
 * Shows teleport visual effect and plays a sound.
 * @param bOut    true if player pawn has just been teleported
 * @param bSound  true if a sound needs to be played
 */
function PlayTeleportEffect(bool bOut,bool bSound)
{
    //Don't show visual effect while spawning.
    if (WorldInfo.TimeSeconds - LastStartTime > 1.0)
        super.PlayTeleportEffect(bOut,bSound);
}

/**
 * Called when this pawn is possessed by a controller.
 * @param AController         the controller that possesses this pawn
 * @param bVehicleTransition  true if a vehicle transition is happening
 */
function PossessedBy(Controller AController,bool bVehicleTransition)
{
    super.PossessedBy(AController,bVehicleTransition);

    if (SGDKPlayerController(AController) != none)
        SGDKPlayerController(AController).MinRespawnDelay = RagdollTimeSpan;
}

/**
 * Called after this pawn is teleported.
 * @param OutTeleporter  the last teleporter object involved in teleportation
 */
simulated function PostTeleport(Teleporter OutTeleporter)
{
    super.PostTeleport(OutTeleporter);

    if (OutTeleporter.bChangesYaw)
        ForceRotation(OutTeleporter.Rotation,ConstrainedMovement == CM_None);

    OldVelocity = GetVelocity();
}

/**
 * Called from controller to process player view rotation.
 * Returns the final rotation to be used for player camera.
 * @param DeltaTime      contains the amount of time in seconds that has passed since the last tick
 * @param ViewRotation   current player view rotation
 * @param DeltaRotation  player input added to view rotation
 */
simulated function ProcessViewRotation(float DeltaTime,out rotator ViewRotation,out rotator DeltaRotation)
{
    //If player wants to turn left-right the camera...
    if (DeltaRotation.Yaw != 0)
    {
        DeltaRotation.Yaw = ModifyTurningAbility(DeltaTime,DeltaRotation.Yaw);

        //Apply turning with quaternions.
        ViewRotation = QuatToRotator(QuatProduct(QuatFromAxisAndAngle(vect(0,0,1) >> ViewRotation,
                                     DeltaRotation.Yaw * UnrRotToRad),QuatFromRotator(ViewRotation)));
    }
}

/**
 * Player wants to keep pushing.
 * @return  true if still pushing
 */
function bool Push()
{
    local int i;

    if (bPushing)
    {
        if (IsTouchingGround() && (!bMiniSize || !PushableActor.bDisallowMiniPawn))
        {
            if (InputState == IS_Accel && IsValidPush(PushableActor.CollisionComponent))
            {
                SetVelocity(PushDirection * PushableActor.GetPushSpeed());
                Acceleration = vect(0,0,0);
            }
            else
            {
                MoveSmooth(PushDirection * -2.5);

                Velocity = vect(0,0,0);
                Acceleration = vect(0,0,0);

                bPushing = false;
            }
        }
        else
            bPushing = false;

        if (!bPushing)
        {
            //Notify blend nodes the change of posture.
            for (i = 0; i < PostureBlendNodes.Length; i++)
                PostureBlendNodes[i].PostureChanged(0);
        }
    }

    return bPushing;
}

/**
 * Receives an amount of energy.
 * @param Amount  amount of energy points
 */
function ReceiveEnergy(float Amount)
{
}

/**
 * Receives score points.
 * @param Amount   amount of score points
 * @param AnActor  actor from which the pawn receives the score points
 */
function ReceiveScore(int Amount,optional Actor AnActor)
{
    if (Amount > 0 && Controller != none)
    {
        SGDKPlayerController(Controller).AddScore(Amount * ScoreMultiplier);

        if (Physics == PHYS_Falling)
            ScoreMultiplier = FMin(ScoreMultiplier * 2.0,10.0);
    }
}

/**
 * All physics data is adapted to a new physics environment.
 */
function ResetPhysicsValues()
{
    local byte i;
    local float OldApexGroundSpeed;
    local ReceivePawnEvents NotifyObject;

    i = GetPhysicsDataIndex();
    OldApexGroundSpeed = ApexGroundSpeed;

    if (!bRolling)
    {
        ApexGroundSpeed = PhysicsData[i].RunningTopSpeed;
        DecelRate = PhysicsData[i].RunningGroundFriction;
        BrakeDecelPct = PhysicsData[i].RunningBrakingStrength / DecelRate;
        MaxSlopeDownBonus = PhysicsData[i].RunningSlopeBonus;
        MaxSlopeUpBonus = PhysicsData[i].RunningSlopeBonus;
    }
    else
    {
        ApexGroundSpeed = PhysicsData[i].RollingTopSpeed;
        DecelRate = PhysicsData[i].RollingGroundFriction;
        BrakeDecelPct = PhysicsData[i].RollingBrakingStrength / DecelRate;
        MaxSlopeDownBonus = PhysicsData[i].RollingSlopeDownBonus;
        MaxSlopeUpBonus = PhysicsData[i].RollingSlopeUpBonus;
    }

    AirControl = PhysicsData[i].FallingAirAcceleration / PhysicsData[i].RunningAcceleration;
    JumpZ = PhysicsData[i].JumpingNormalStrength;
    MaxJumpZ = PhysicsData[i].JumpingTopStrength;
    RefAerialSpeed = PhysicsData[i].FallingReferenceSpeed;

    DefaultAccelRate = PhysicsData[i].RunningAcceleration;
    DefaultAirControl = AirControl;
    DefaultDecelRate = DecelRate;
    DefaultGravityPct = Abs(PhysicsData[i].FallingGravityAccel / WorldInfo.WorldGravityZ);
    DefaultGroundSpeed = PhysicsData[i].RunningReferenceSpeed * WalkSpeedPct;

    MinAdhesionSpeed = DefaultGroundSpeed * AdhesionPct;
    RollingRefSpeed = (PhysicsData[i].RollingTopSpeed + MinAdhesionSpeed + 10.0) * 0.5;

    if (default.SpiderSpeed == 0.0)
        SpiderSpeed = PhysicsData[i].RunningReferenceSpeed;

    if (OldApexGroundSpeed > 0.0)
        for (i = 0; i < SpeedBlendNodes.Length; i++)
            SpeedBlendNodes[i].ScaleSpeed(ApexGroundSpeed / OldApexGroundSpeed);

    //Notify other objects.
    foreach NotifyEventsTo(NotifyObject)
        NotifyObject.PawnPhysicsChanged(self);
}

/**
 * Notifies this pawn that world gravity direction has changed.
 * @param bReverse  sets/unsets reverse gravity flag
 */
function ReversedGravity(bool bReverse)
{
    if (bReverseGravity != bReverse)
    {
        bReverseGravity = bReverse;

        //Rotate the blob shadow.
        Shadow.SetRotation(rotator(GetGravityDirection()));

        AerialBoost(vect(0,0,1) * (WorldInfo.WorldGravityZ * 0.1),false,WorldInfo,'Gravity');
    }
}

/**
 * This pawn is drained of one ring due to super form.
 */
function RingCountdown()
{
    if (Health > 1)
        Health--;

    if (Health == 1)
        CancelSuperForms();
}

/**
 * Sets or unsets rolling on ground mode and adjusts on ground speed.
 * @param bRoll  sets/unsets rolling on ground mode
 */
function Roll(bool bRoll)
{
    local byte i;
    local float HeightAdjust;
    local vector V;
    local bool bForceDuck;

    bForceDuck = false;
    bRolling = bRoll;

    i = GetPhysicsDataIndex();

    if (!bRolling)
    {
        GroundTraceLength = DefaultHeight * 1.75;
        HeightAdjust = DefaultHeight - CrouchHeight;

        MeshPitchRotation = 0.0;
        CurrentMeshRotation = DesiredMeshRotation;
        Mesh.SetRotation(CurrentMeshRotation);

        V = Location;
        if (FindSpot(GetCollisionExtent(),V))
        {
            if (V != Location)
                Move(V - Location);
            else
                Move((vect(0,0,1) >> DesiredMeshRotation) * HeightAdjust);
        }
        else
        {
            bForceDuck = true;
            Move((vect(0,0,1) >> DesiredMeshRotation) * HeightAdjust);
        }

        //Change size and translation of collision cylinder according to pawn state.
        UpdateCollisionCylinder();

        //Adjust base eye height.
        OldZ += HeightAdjust;
        SetBaseEyeheight();

        //Notify blend nodes the change of posture.
        for (i = 0; i < PostureBlendNodes.Length; i++)
            PostureBlendNodes[i].PostureChanged(0);
    }
    else
    {
        if (!bDucking)
        {
            GroundTraceLength = CrouchHeight * 1.75;
            HeightAdjust = CrouchHeight - DefaultHeight;

            //Change size and translation of collision cylinder according to pawn state.
            UpdateCollisionCylinder();

            Move((vect(0,0,1) >> DesiredMeshRotation) * HeightAdjust);

            //Adjust base eye height.
            OldZ -= HeightAdjust;
            SetBaseEyeheight();
        }
        else
            bDucking = false;

        //If visible...
        if (!IsInvisible())
            PlayRollingSound();

        //Notify blend nodes the change of posture.
        for (i = 0; i < PostureBlendNodes.Length; i++)
            PostureBlendNodes[i].PostureChanged(3);
    }

    ResetPhysicsValues();

    if (bForceDuck)
    {
        bCanCrouch = true;
        Duck(true);
    }
}

/**
 * Scales on ground deceleration rate by a factor.
 * @param Scale  additional scale factor applied to deceleration rate
 */
function ScaleDeceleration(float Scale)
{
    DecelData.Scale *= Scale;
}

/**
 * Sets new base eye height according to pawn status.
 */
simulated function SetBaseEyeheight()
{
    //If pawn is ducking or rolling on ground...
    if (bDucking || bRolling)
        BaseEyeHeight = FMin(CrouchHeight * 0.8,CrouchHeight - 10.0);
    else
        BaseEyeHeight = default.BaseEyeHeight;
}

/**
 * Sets various basic properties for this pawn based on the character class metadata.
 * @param FamilyClass  structure which has information about a particular character
 */
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> FamilyClass)
{
    local MaterialInterface TeamMaterialHead,TeamMaterialBody,TeamMaterialArms;
    local int i;
    local UTPlayerReplicationInfo PRI;

    if (FamilyClass != CurrCharClassInfo)
    {
        //Set the current family info.
        CurrCharClassInfo = FamilyClass;

        if (PawnTemplate == none)
        {
            DefaultMeshScale = FamilyClass.default.DefaultMeshScale;
            MeshDuckingOffset = class<SGDKFamilyInfo>(FamilyClass).default.CrouchTranslationOffset;
            MeshStandingOffset = FamilyClass.default.BaseTranslationOffset;

            //Assign the animation sets and tree stored in the family info to the skeletal mesh.
            Mesh.AnimSets = FamilyClass.default.AnimSets;
            Mesh.SetAnimTreeTemplate(class<SGDKFamilyInfo>(FamilyClass).default.AnimTreeTemplate);

            //Apply the team skins if necessary.
            FamilyClass.static.GetTeamMaterials(255,TeamMaterialHead,TeamMaterialBody);

            //Set the skeletal mesh and its materials.
            SetCharacterMeshInfo(FamilyClass.default.CharacterMesh,TeamMaterialHead,TeamMaterialBody);

            //Set the skeletal mesh scale first before the physics asset is re-initialized.
            Mesh.SetScale(DefaultMeshScale);

            //Assign and re-initialize the physics asset stored in the family info to the skeletal mesh.
            Mesh.SetPhysicsAsset(FamilyClass.default.PhysAsset,true);

            //Additional animation set for super form.
            SuperAnimSet = class<SGDKFamilyInfo>(FamilyClass).default.SuperAnimSet;
        }
        else
        {
            DefaultMeshScale = PawnTemplate.Mesh.Scale * PawnTemplate.DrawScale;
            MeshDuckingOffset = PawnTemplate.MeshDuckingOffset;
            MeshStandingOffset = PawnTemplate.Mesh.Translation.Z - PawnTemplate.PrePivot.Z;

            //Assign the animation sets and tree stored in the pawn template to the skeletal mesh.
            Mesh.AnimSets = PawnTemplate.Mesh.AnimSets;
            Mesh.SetAnimTreeTemplate(PawnTemplate.Mesh.AnimTreeTemplate);

            //Apply the team skins if necessary.
            FamilyClass.static.GetTeamMaterials(255,TeamMaterialHead,TeamMaterialBody);

            //Set the skeletal mesh.
            SetCharacterMeshInfo(PawnTemplate.Mesh.SkeletalMesh,TeamMaterialHead,TeamMaterialBody);

            //Set the skeletal mesh scale first before the physics asset is re-initialized.
            Mesh.SetScale(DefaultMeshScale);

            //Assign and re-initialize the physics asset stored in the pawn template to the skeletal mesh.
            Mesh.SetPhysicsAsset(PawnTemplate.Mesh.PhysicsAsset,true);

            //Additional animation set for super form.
            SuperAnimSet = PawnTemplate.SuperAnimSet;
        }

        //Assign the object responsible of pawn's sound effects.
        SoundGroupClass = FamilyClass.default.SoundGroupClass;

        //Change the materials of the skeletal mesh.
        for (i = 0; i < BodyMaterialInstances.Length; i++)
            BodyMaterialInstances[i].SetParent(Mesh.SkeletalMesh.Materials[i]);
        for (i = 0; i < Mesh.SkeletalMesh.Materials.Length; i++)
            Mesh.SetMaterial(i,BodyMaterialInstances[i]);

        //Add first-person arms mesh and materials if necessary.
        if (IsHumanControlled() && IsLocallyControlled())
        {
            TeamMaterialArms = FamilyClass.static.GetFirstPersonArmsMaterial(255);
            SetFirstPersonArmsInfo(FamilyClass.static.GetFirstPersonArms(),TeamMaterialArms);
        }

        //Make sure bEnableFullAnimWeightBodies is only true if it needs to be.
        Mesh.bEnableFullAnimWeightBodies = false;
        for (i = 0; i < Mesh.PhysicsAsset.BodySetup.Length; i++)
            if (Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
                Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
            {
                Mesh.bEnableFullAnimWeightBodies = true;

                break;
            }

        //Set the overlay skeletal mesh for overlay effects.
        if (OverlayMesh != none)
            OverlayMesh.SetSkeletalMesh(Mesh.SkeletalMesh);

        PRI = GetUTPlayerReplicationInfo();

        //Set some properties of the PRI.
        if (PRI != none)
        {
            //Assign fallback portrait.
            PRI.CharPortrait = FamilyClass.static.GetCharPortrait(255);

            PRI.bIsFemale = FamilyClass.default.bIsFemale;
            PRI.VoiceClass = FamilyClass.static.GetVoiceClass();

            if (PRI.bIsFemale)
                PRI.TTSSpeaker = ETTSSpeaker(Rand(4));
            else
                PRI.TTSSpeaker = ETTSSpeaker(Rand(5) + 4);
        }

        //Assign bone names.
        LeftFootBone = FamilyClass.default.LeftFootBone;
        RightFootBone = FamilyClass.default.RightFootBone;
        TakeHitPhysicsFixedBones = FamilyClass.default.TakeHitPhysicsFixedBones;
    }
}

/**
 * Sets a new maximum on ground speed value.
 * @param NewGroundSpeed  new maximum on ground speed for pawn
 */
function SetGroundSpeed(float NewGroundSpeed)
{
    //Don't surpass apex value of on ground speed.
    RealGroundSpeed = FClamp(NewGroundSpeed,0.0,ApexGroundSpeed);
}

/**
 * Sets or unsets hanging from an actor mode.
 * @param bSet     sets/unsets hanging mode
 * @param AnActor  actor from which the pawn will hang/is hanging
 */
function SetHanging(bool bSet,optional HandleActor AnActor)
{
    local vector V;

    if (!bSet)
    {
        LastHangingTime = WorldInfo.TimeSeconds;

        ClearTimer(NameOf(CheckHanging));

        if (AnActor == none)
            AnActor = HangingActor;

        if (HangingActor != none)
            StopAnimation(HangingActor.PawnAnimName);
        else
            if (HangingAnimation != '')
                StopAnimation(HangingAnimation);

        bFullNativeRotation = default.bFullNativeRotation;
        bHanging = false;
        bIgnoreForces = false;
        HangingActor = none;

        SetBase(none);
        SetPhysics(PHYS_Falling);

        if (AnActor != none)
            AnActor.PawnDetached(self);
    }
    else
        if (WorldInfo.TimeSeconds - LastHangingTime > 0.25)
        {
            V = GetVelocity();

            CancelMoves();

            bFullNativeRotation = true;
            bHanging = true;
            bIgnoreForces = true;
            HangingActor = AnActor;

            SetPhysics(PHYS_None);

            if (HangingActor != none)
            {
                StartAnimation(HangingActor.PawnAnimName,1.0,0.0,0.25,true,false);

                if (!HangingActor.bForceOneOrientation && V dot vector(HangingActor.Rotation) < 0.0)
                    HangingActor.ReverseRotation();

                ForceRotation(HangingActor.Rotation,false);

                V = HangingActor.PawnLocationOffset;

                if (bMiniSize)
                    V *= MiniHeight / DefaultHeight;

                SetLocation(HangingActor.Location + (V >> DesiredMeshRotation));

                SetBase(HangingActor);

                SetTimer(1.0,true,NameOf(CheckHanging));

                HangingActor.PawnAttached(self);
            }
            else
                if (HangingAnimation != '')
                    StartAnimation(HangingAnimation,1.0,0.0,0.25,true,false);
        }
}

/**
 * Increases or decreases a counter that enables or disables bPushesRigidBodies flag.
 * @param bSet  true if +1, false if -1
 */
function SetPushRigidBodies(bool bSet)
{
    local float Height,Radius,Translation;

    if (!bSet)
        PushRigidBodies--;
    else
        PushRigidBodies++;

    if (!bSonicPhysicsMode || bPushesRigidBodies || PushRigidBodies < 1)
        SetPushesRigidBodies(PushRigidBodies > 0);
    else
    {
        Height = CylinderComponent.CollisionHeight;
        Radius = CylinderComponent.CollisionRadius;
        Translation = CylinderComponent.Translation.Z;

        SetCollision(false,false);
        SetCollisionSize(DefaultRadius,DefaultHeight);
        CylinderComponent.SetTranslation(vect(0,0,0));

        SetPushesRigidBodies(true);

        CylinderComponent.SetTranslation(vect(0,0,1) * Translation);
        SetCollisionSize(Radius,Height);
        SetCollision(true,true);
    }
}

/**
 * Sets or unsets Sonic Physics mode.
 * @param bSet  sets/unsets Sonic Physics mode
 */
function SetSonicPhysics(bool bSet)
{
    local int i;

    //Set new mode.
    bSonicPhysicsMode = bSet;

    //Notify blend nodes the upcoming change of status.
    for (i = 0; i < SonicPhysicsBlendNodes.Length; i++)
        SonicPhysicsBlendNodes[i].PhysicsChanged(bSonicPhysicsMode);

    //If pawn is in Sonic Physics mode...
    if (bSonicPhysicsMode)
    {
        //Set values.
        bOnGround = true;
        FloorDotAngle = -(FloorNormal dot GetGravityDirection());

        //Change state of controller.
        Controller.GotoState('PlayerSonicPhysics');

        //Change size and translation of collision cylinder according to pawn state.
        UpdateCollisionCylinder();
    }
    else
    {
        //Unset some values.
        bOnGround = false;
        bWaterRunningMode = false;

        //Store current floor.
        Floor = FloorNormal;

        //Move up if needed to prevent sinking in floor.
        if (FloorDotAngle < 0.999 && FloorDotAngle > WalkableFloorZ)
        {
            Move(vect(0,0,2));
            WalkingZTranslation += 2.0;
        }

        //Restore size and translation of collision cylinder according to pawn state.
        UpdateCollisionCylinder();

        //Change state of controller taking water into account.
        if (!PhysicsVolume.bWaterVolume)
            Controller.GotoState(LandMovementState);
        else
            Controller.GotoState(WaterMovementState);
    }
}

/**
 * Sets or unsets spider physics mode.
 * @param bSet  sets/unsets spider physics mode
 */
function SetSpiderPhysics(bool bSet)
{
    local int i;

    //Set new mode.
    bSpiderPhysicsMode = bSet;
    bAntiGravityMode = bSet;

    //Notify blend nodes the upcoming change of status.
    for (i = 0; i < SonicPhysicsBlendNodes.Length; i++)
        SonicPhysicsBlendNodes[i].PhysicsChanged(bSpiderPhysicsMode);

    //If pawn is in spider physics mode...
    if (bSpiderPhysicsMode)
    {
        //Notify blend nodes the change of posture.
        for (i = 0; i < PostureBlendNodes.Length; i++)
            PostureBlendNodes[i].PostureChanged(3);

        //Change state of controller.
        Controller.GotoState('PlayerSpidering');

        //Change size of collision cylinder according to pawn state.
        UpdateCollisionCylinder();
    }
    else
    {
        MeshPitchRotation = 0.0;
        CurrentMeshRotation = DesiredMeshRotation;
        Mesh.SetRotation(CurrentMeshRotation);

        //Notify blend nodes the change of posture.
        for (i = 0; i < PostureBlendNodes.Length; i++)
            PostureBlendNodes[i].PostureChanged(0);

        Move((vect(0,0,1) >> DesiredMeshRotation) * (DefaultHeight - SpiderRadius));
        bForcePhysicsCheck = true;

        //Restore size of collision cylinder according to pawn state.
        UpdateCollisionCylinder();

        //Change state of controller taking water into account.
        if (!PhysicsVolume.bWaterVolume)
            Controller.GotoState(LandMovementState);
        else
            Controller.GotoState(WaterMovementState);
    }
}

/**
 * Sets the true velocity of the player pawn in world space.
 * @param NewVelocity  new velocity for pawn
 */
function SetVelocity(vector NewVelocity)
{
    //If not walking physics or new velocity is horizontal or new speed magnitude is zero...
    if (Physics != PHYS_Walking || NewVelocity.Z == 0.0 || IsZero(NewVelocity))
        Velocity = NewVelocity;
    else
    {
        //Walking physics only works with flat XY velocity vectors.
        Velocity = NewVelocity;
        Velocity.Z = 0.0;

        //Cache the related data to get better performance for GetVelocity().
        CachedVelocityData.UnrealVelocity = Velocity;
        CachedVelocityData.Floor = Floor;
        CachedVelocityData.RealVelocity = NewVelocity;
    }

    OldVelocity = Velocity;
}

/**
 * Applies properly a new rotation to controller view rotation.
 * @param NewRotation  desired rotation for controller view rotation
 */
simulated function SetViewRotation(rotator NewRotation)
{
    if (Controller != none)
    {
        DesiredViewRotation = NewRotation;

        SGDKPlayerController(Controller).ForceRotation(NewRotation);
    }
}

/**
 * Player is requesting that pawn crouches/uncrouches.
 * @param bCrouch  true if this pawn should crouch or not
 */
function ShouldCrouch(bool bCrouch)
{
    bWantsToDuck = bCrouch;
}

/**
 * Should the attached skeletal mesh component face the velocity vector while falling?
 * Add other similar animations to dashing animation here.
 * @return  true if playing the dashing animation
 */
function bool ShouldFaceVelocity()
{
    return ShouldPlayDash();
}

/**
 * Whether or not this pawn should gib due to damage from the passed in damage type.
 * @param DamageClass  class describing the damage that was done
 * @return             true if should gib due to the type of damage
 */
simulated function bool ShouldGib(class<UTDamageType> DamageClass)
{
    //Disabled.
    return false;
}

/**
 * Should the player pawn pass through a solid actor?
 * Add other similar conditions here.
 * @return  true if this pawn should pass through an actor
 */
function bool ShouldPassThrough(Actor AnActor)
{
    return (IsTouchingGround() || Shield.ShouldPassThrough(AnActor));
}

/**
 * Should the attached skeletal mesh component play the dashing animation?
 * @return  true if the attached skeletal mesh component should play the dashing animation
 */
function bool ShouldPlayDash()
{
    return Shield.ShouldPlayDash();
}

/**
 * Should the attached skeletal mesh component play the rolling animation?
 * @return  true if no custom animation is being played and roll animation is needed
 */
function bool ShouldPlayRoll()
{
    return (CustomAnimation == '' && !bDisableScriptedRoll &&
            (bRolling || bSpiderPhysicsMode || SpinDashCount > 0 || HasJumped()));
}

/**
 * Should the player view rotation be modified?
 * @return  true if movement isn't constrained (controls can be rotated)
 */
function bool ShouldRotateView()
{
    if (Controller != none)
        return SGDKPlayerController(Controller).GetPlayerCamera().ShouldViewRotate(self);
    else
        return (ConstrainedMovement == CM_None);
}

/**
 * Should the attached skeletal mesh component tilt a little while falling?
 * @return  true if no custom animation is being played and velocity XY magnitude isn't zero
 */
function bool ShouldTilt()
{
    return (CustomAnimation == '' && (Velocity.X != 0.0 || Velocity.Y != 0.0));
}

/**
 * Player is requesting that pawn walks.
 * @param bWalk  true if this pawn should walk or not
 */
function ShouldWalk(bool bWalk)
{
    bMustWalk = bWalk;
}

/**
 * Called when the player presses or releases the SpecialMove key/button.
 * @param bSpecial  true if player wants to perform a special move, false if player has released the button/key
 */
function SpecialMove(bool bSpecial)
{
    if (!bDisableSpecialMoves)
    {
        if (bSpecial)
            NoActionPerformed(4);
        else
            NoActionPerformed(5);
    }
}

/**
 * Cancels SpinDash movement.
 */
function SpinDashCancel()
{
    local int i;

    //Unset spindash.
    SpinDashCount = 0;

    if (SpinDashEmitter != none)
    {
        //Destroy effects.
        DetachFromRoot(SpinDashEmitter);
        SpinDashEmitter.DelayedDestroy();
        SpinDashEmitter = none;
    }

    if (!bClassicSpinDash)
        ClearTimer(NameOf(SpinDashCharge));

    //Notify blend nodes the change of posture.
    for (i = 0; i < PostureBlendNodes.Length; i++)
        PostureBlendNodes[i].PostureChanged(0);
}

/**
 * Player pawn charges for SpinDash movement.
 */
function SpinDashCharge()
{
    local int i;
    local SoundCue SpinDashSound;

    LastSpinDashTime = WorldInfo.TimeSeconds;

    if (ShouldRotateView())
        ForceRotation(DesiredViewRotation,true);

    if (SpinDashCount == 0)
    {
        //Notify blend nodes the change of posture.
        for (i = 0; i < PostureBlendNodes.Length; i++)
            PostureBlendNodes[i].PostureChanged(4);
    }

    if (SpinDashCount < 5)
        SpinDashCount++;

    if (!bWantsToDuck)
        SpinDashRelease();
    else
    {
        SpinDashSound = GetSpinDashSound(GetMaterialBelowFeet(),0);

        if (SpinDashSound != none)
            PlaySound(SpinDashSound,false,true);

        if (SpinDashEmitter == none && SpinDashParticleSystem != none)
        {
            SpinDashEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
            SpinDashEmitter.SetTemplate(SpinDashParticleSystem,false);

            AttachToRoot(SpinDashEmitter,vect(0,0,-1) * GetCollisionHeight());
        }

        if (!bClassicSpinDash)
            SetTimer(SpinDashDecreaseTime * 0.66,false,NameOf(SpinDashCharge));
    }
}

/**
 * Player pawn releases a SpinDash movement.
 */
function SpinDashRelease()
{
    local SoundCue SpinDashSound;

    LastSpecialMoveTime = WorldInfo.TimeSeconds;
    LastSpinDashTime = WorldInfo.TimeSeconds;

    if (!bClassicSpinDash)
        ClearTimer(NameOf(SpinDashCharge));

    Roll(true);
    HighSpeedBoost((SpinDashCount + 5) * 0.1 * SpinDashSpeedPct,true);
    SpinDashCount = 0;

    SpinDashSound = GetSpinDashSound(GetMaterialBelowFeet(),1);

    if (SpinDashSound != none)
        PlaySound(SpinDashSound,false,true);

    if (SpinDashEmitter != none)
    {
        DetachFromRoot(SpinDashEmitter);
        SpinDashEmitter.DelayedDestroy();
        SpinDashEmitter = none;
    }
}

/**
 * Sets or unsets player's super form.
 * @param bSuper  sets/unsets super form
 */
function SuperForm(bool bSuper)
{
    local int i;

    bIsInvulnerable = bSuper;
    bSuperForm = bSuper;

    if (!bSuperForm)
    {
        if (bHyperForm && HeadVolume != none && HeadVolume.bWaterVolume)
            Breath(false);

        bHyperForm = false;

        ClearTimer(NameOf(RingCountdown));

        if (SuperAnimSet != none)
            Mesh.AnimSets.Remove(Mesh.AnimSets.Length - 1,1);

        if (PawnTemplate == none)
            Mesh.SetSkeletalMesh(class<SGDKFamilyInfo>(CurrCharClassInfo).default.CharacterMesh);
        else
            Mesh.SetSkeletalMesh(PawnTemplate.Mesh.SkeletalMesh);

        for (i = 0; i < BodyMaterialInstances.Length; i++)
            BodyMaterialInstances[i].SetParent(Mesh.SkeletalMesh.Materials[i]);

        for (i = 0; i < Mesh.SkeletalMesh.Materials.Length; i++)
            Mesh.SetMaterial(i,BodyMaterialInstances[i]);

        if (SuperLight != none)
        {
            DetachFromRoot(SuperLight);
            SuperLight.Destroy();
        }

        HudDecorationCoords = NormalHudDecoCoords;

        if (SuperEmitter != none)
        {
            DetachFromRoot(SuperEmitter);
            SuperEmitter.DelayedDestroy();
            SuperEmitter = none;
        }

        //Notify blend nodes the change of super form.
        for (i = 0; i < SuperFormBlendNodes.Length; i++)
            SuperFormBlendNodes[i].FormChanged(false);

        WaterRunDecelPct = DefaultWaterRunDecelPct;
    }
    else
    {
        if (SuperAnimSet != none)
            Mesh.AnimSets[Mesh.AnimSets.Length] = SuperAnimSet;

        if (!bHyperForm)
        {
            if (PawnTemplate == none || PawnTemplate.SuperSkeletalMesh == none)
                Mesh.SetSkeletalMesh(class<SGDKFamilyInfo>(CurrCharClassInfo).default.SuperCharacterMesh);
            else
                Mesh.SetSkeletalMesh(PawnTemplate.SuperSkeletalMesh);
        }
        else
        {
            if (PawnTemplate == none || PawnTemplate.HyperSkeletalMesh == none)
                Mesh.SetSkeletalMesh(class<SGDKFamilyInfo>(CurrCharClassInfo).default.HyperCharacterMesh);
            else
                Mesh.SetSkeletalMesh(PawnTemplate.HyperSkeletalMesh);
        }

        for (i = 0; i < BodyMaterialInstances.Length; i++)
            BodyMaterialInstances[i].SetParent(Mesh.SkeletalMesh.Materials[i]);

        for (i = 0; i < Mesh.SkeletalMesh.Materials.Length; i++)
            Mesh.SetMaterial(i,BodyMaterialInstances[i]);

        if (SuperLightClass != none)
        {
            SuperLight = Spawn(SuperLightClass,self);

            if (!bHyperForm)
            {
                SuperLight.LightComponent.SetLightProperties(SuperLightBrightness,SuperLightColor);
                SuperLight.LightComponent.BloomTint = SuperLightColor;
            }
            else
            {
                SuperLight.LightComponent.SetLightProperties(HyperLightBrightness,HyperLightColor);
                SuperLight.LightComponent.BloomTint = HyperLightColor;
            }

            AttachToRoot(SuperLight,vect(1,0,0) * DefaultRadius + vect(0.0,0.0,0.5) * DefaultHeight);
        }

        if (!bHyperForm)
        {
            HudDecorationCoords = SuperHudDecoCoords;

            if (SuperParticleSystem != none)
            {
                SuperEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                SuperEmitter.SetTemplate(SuperParticleSystem,false);

                AttachToRoot(SuperEmitter);
            }
        }
        else
        {
            HudDecorationCoords = HyperHudDecoCoords;

            if (HyperParticleSystem != none)
            {
                SuperEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                SuperEmitter.SetTemplate(HyperParticleSystem,false);

                AttachToRoot(SuperEmitter);
            }
        }

        //Notify blend nodes the change of super form.
        for (i = 0; i < SuperFormBlendNodes.Length; i++)
            SuperFormBlendNodes[i].FormChanged(true);

        WaterRunDecelPct = 0.0;

        if (bHyperForm && HeadVolume != none && HeadVolume.bWaterVolume)
            Breath(true);

        SetTimer(RingCountdownTime,true,NameOf(RingCountdown));
    }

    ResetPhysicsValues();
}

/**
 * Player wants to transform into a super state.
 * @return  true if pawn transforms
 */
function bool SuperTransformation()
{
    if (!bSuperForm && Health > 50 && Controller != none && SGDKPlayerController(Controller).ChaosEmeralds > 6)
    {
        if (!bHasHyperForm || SGDKPlayerController(Controller).ChaosEmeralds < 14)
            SuperForm(true);
        else
            HyperForm(true);

        return true;
    }

    return false;
}

/**
 * Player pawn just touched a spline actor.
 * @param NewSpline  spline actor that has been touched
 */
function TouchedSpline(SGDKSplineActor NewSpline)
{
    if (Health > 0 && NewSpline != CurrentSplineActor)
        CurrentSplineActor = NewSpline;
}

/**
 * Player is about to land; scripted way of calling Landed event properly.
 * @param HitNormal   the surface normal of the actor/level geometry landed on
 * @param FloorActor  the actor landed on
 */
function TriggerLanded(optional vector HitNormal,optional Actor FloorActor)
{
    //If surface normal isn't provided...
    if (IsZero(HitNormal))
        //Get a fixed surface normal according to gravity.
        HitNormal = -GetGravityDirection();

    //Call landed event manually.
    if (!Controller.NotifyLanded(HitNormal,FloorActor))
        Landed(HitNormal,FloorActor);

    //Call this event manually if needed.
    if (bNotifyStopFalling)
        StoppedFalling();
}

/**
 * Freezes this pawn; stops sounds, animations, physics...
 */
simulated function TurnOff()
{
    local TimerData Timer;

    bTurnedOff = true;

    foreach Timers(Timer)
        PauseTimer(true,Timer.FuncName);

    bCanPickupInventory = false;
    bIgnoreForces = true;

    if (Mesh != none)
    {
        Mesh.bPauseAnims = true;

        if (Physics == PHYS_RigidBody)
        {
            Mesh.PhysicsWeight = 1.0;
            Mesh.bUpdateKinematicBonesFromAnimation = false;
        }
    }

    SetCollision(true,false);
    SetPhysics(PHYS_None);
    Velocity = vect(0,0,0);

    GotoState('NoDuckJumpSpecial');
}

/**
 * Unfreezes this pawn.
 */
function TurnOn()
{
    local TimerData Timer;

    foreach Timers(Timer)
        PauseTimer(false,Timer.FuncName);

    GotoState('Auto');

    bCanPickupInventory = default.bCanPickupInventory;
    bIgnoreForces = false;

    if (Mesh != none)
        Mesh.bPauseAnims = false;

    SetCollision(true,true);
    SetPhysics(PHYS_Falling);

    bTurnedOff = false;
}

/**
 * Updates the size and offset of the attached collision cylinder.
 */
function UpdateCollisionCylinder()
{
    if (!bSonicPhysicsMode)
    {
        CylinderComponent.SetTranslation(vect(0,0,0));

        if (!bSpiderPhysicsMode)
        {
            if (!bMiniSize)
            {
                if (!bDucking && !bRolling)
                    SetCollisionSize(DefaultRadius,DefaultHeight);
                else
                    SetCollisionSize(CrouchRadius,CrouchHeight);
            }
            else
                SetCollisionSize(MiniRadius,MiniHeight);
        }
        else
            SetCollisionSize(SpiderRadius,SpiderRadius);
    }
    else
    {
        if (!bMiniSize)
        {
            if (!bDucking && !bRolling)
            {
                if (Abs(FloorDotAngle) < 0.995)
                {
                    SetCollisionSize(DefaultRadius * 0.95,DefaultRadius * 0.95);
                    CylinderComponent.SetTranslation(vect(0,0,0));
                }
                else
                {
                    SetCollisionSize(DefaultRadius,DefaultRadius + (DefaultHeight - DefaultRadius) * 0.5);
                    CylinderComponent.SetTranslation(Normal(GetFloorNormal() * vect(0,0,1)) *
                                                     ((DefaultHeight - DefaultRadius) * 0.5));
                }
            }
            else
            {
                if (Abs(FloorDotAngle) < 0.995)
                {
                    SetCollisionSize(CrouchRadius * 0.6,CrouchRadius * 0.6);
                    CylinderComponent.SetTranslation(vect(0,0,0));
                }
                else
                {
                    SetCollisionSize(CrouchRadius,CrouchRadius * 0.75);
                    CylinderComponent.SetTranslation(Normal(GetFloorNormal() * vect(0,0,1)) *
                                                     (CrouchRadius - CrouchRadius * 0.75));
                }
            }
        }
        else
        {
            if (Abs(FloorDotAngle) < 0.995)
            {
                SetCollisionSize(MiniRadius * 0.6,MiniRadius * 0.6);
                CylinderComponent.SetTranslation(vect(0,0,0));
            }
            else
            {
                SetCollisionSize(MiniRadius,MiniHeight * 0.75);
                CylinderComponent.SetTranslation(Normal(GetFloorNormal() * vect(0,0,1)) *
                                                 (MiniHeight - MiniHeight * 0.75));
            }
        }
    }
}

/**
 * Plays a victory animation.
 */
function VictoryPose()
{
    if (IsZero(Velocity))
        StartAnimation(VictoryAnimation,1.0,0.25,0.25,true);
    else
        SetTimer(0.33,false,NameOf(VictoryPose));
}

/**
 * Will the player pawn be bounced soon?
 * @return  true if pawn will be bounced soon
 */
function bool WillBeBounced()
{
    return BounceData.bWillBounce;
}

/**
 * Will the player pawn leave the actor is standing on soon?
 * @return  true if pawn will leave the actor is standing on soon
 */
function bool WillLeaveGround()
{
    return (bQuickLand || BounceData.bWillBounce);
}


//Pawn is dead.
state Dying
{
    simulated event Tick(float DeltaTime)
    {
        if (bKilledByBio)
        {
            bKilledByBio = false;
            BioBurnAway.DeactivateSystem();
        }
    }

    event Timer()
    {
        //Disabled.
    }

    simulated function bool CalcCamera(float DeltaTime,out vector OutCamLocation,
                                       out rotator OutCamRotation,out float OutFOV)
    {
        return global.CalcCamera(DeltaTime,OutCamLocation,OutCamRotation,OutFOV);
    }
}


//Pawn can't duck, jump or perform a special move.
state NoDuckJumpSpecial
{
    function bool Duck(bool bDuck)
    {
        return false;
    }

    function bool Jump(bool bJump)
    {
        return false;
    }

    function SpecialMove(bool bSpecial)
    {
    }
}


//Pawn has an orb.
state Orb extends NoDuckJumpSpecial
{
    event BeginState(name PreviousStateName)
    {
        global.CancelMoves();

        CancelSuperForms();
    }

    event EndState(name NextStateName)
    {
        if (OrbEmitter != none)
        {
            DetachFromRoot(OrbEmitter);
            OrbEmitter.DelayedDestroy();
            OrbEmitter = none;
        }
    }

    function AerialBoost(vector BoostVelocity,optional bool bLand,optional Actor PushActor,optional name Reason)
    {
        if (Reason != GetStateName())
            GotoState('Auto');

        global.AerialBoost(BoostVelocity,bLand,PushActor,Reason);
    }

    function CancelMoves()
    {
        GotoState('Auto');

        global.CancelMoves();
    }

    function class<DamageType> GetMeleeDamageType()
    {
        return JumpedDamageType;
    }

    function HurtPawn(SGDKPawn APawn)
    {
        global.HurtPawn(APawn);

        ScoreMultiplier = default.ScoreMultiplier;
    }

    function bool IsValidPush(PrimitiveComponent TestComponent)
    {
        return false;
    }

    function bool IsUsingMelee()
    {
        return true;
    }

    function SetHanging(bool bSet,optional HandleActor AnActor)
    {
        if (!bSet)
            global.SetHanging(bSet,AnActor);
    }
}


//Pawn has a "drill" orb.
state OrbDrill extends Orb
{
    event BeginState(name PreviousStateName)
    {
        if (PhysicsVolume.bWaterVolume)
        {
            super.BeginState(PreviousStateName);

            bDisableSonicPhysics = true;
            bDisableSpecialMoves = true;
            bIgnoreForces = true;

            if (IsTouchingGround())
                AerialBoost(vect(0,0,100) >> DesiredMeshRotation,false,self,GetStateName());

            AirDragFactor = 0.0;
            GravityScale = default.GravityScale * 0.01;
            WalkingPhysics = PHYS_Falling;

            LastSpecialMoveTime = 0.0;

            Breath(true);

            if (OrbDrillParticles != none)
            {
                OrbEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
                OrbEmitter.SetTemplate(OrbDrillParticles,false);

                AttachToRoot(OrbEmitter,,,true);
            }
        }
        else
            GotoState('Auto');
    }

    event EndState(name NextStateName)
    {
        bDisableSonicPhysics = false;
        bDisableSpecialMoves = false;
        bIgnoreForces = false;

        AirDragFactor = DefaultAirDragFactor;
        GravityScale = default.GravityScale;
        WalkingPhysics = default.WalkingPhysics;

        LastSpecialMoveTime = 0.0;

        if (HeadVolume.bWaterVolume && (!HasShield() || !Shield.IsInState('Bubble')))
            Breath(false);

        super.EndState(NextStateName);
    }

    event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
    {
        Velocity = MirrorVectorByNormal(Velocity,HitNormal);
        VelocityOverride = Velocity;
    }

    event Landed(vector HitNormal,Actor FloorActor)
    {
        if (SGDKPawn(FloorActor) == none)
            HitWall(HitNormal,FloorActor,FloorActor.CollisionComponent);
    }

    event PhysicsVolumeChange(PhysicsVolume NewVolume)
    {
        if (!NewVolume.bWaterVolume)
            GotoState('Auto');

        global.PhysicsVolumeChange(NewVolume);
    }

    event Tick(float DeltaTime)
    {
        if (!IsZero(Acceleration))
            Velocity = Normal(Normal(Velocity) * (50.0 / (DeltaTime * 100.0)) + Normal(Acceleration)) * 1000.0;
        else
            if (!bClassicMovement)
                Velocity = Normal(Normal(Velocity) * (50.0 / (DeltaTime * 100.0)) +
                                  vector(SGDKPlayerController(Controller).GetPlayerCamera().GetCameraRotation())) * 1000.0;
            else
                Velocity = Normal(Velocity) * 1000.0;

        if (LastSpecialMoveTime != 0.0)
            Velocity *= 1.5;

        global.Tick(DeltaTime);
    }

    function bool CanPickupActor(Actor AnActor)
    {
        if (BubbleProjectile(AnActor) != none)
            return false;

        return global.CanPickupActor(AnActor);
    }

    function vector GetAccelerationInput(SGDKPlayerInput InputManager,vector ControllerX,
                                         vector ControllerY,vector ControllerZ)
    {
        return Normal(ControllerZ * InputManager.aForward + ControllerY * InputManager.aStrafe) * AccelRate;
    }

    function class<DamageType> GetMeleeDamageType()
    {
        return class'SGDKDmgType_OrbDrill';
    }

    function bool Jump(bool bJump)
    {
        SpecialMove(bJump);

        return false;
    }

    function bool ShouldPassThrough(Actor AnActor)
    {
        return true;
    }

    function bool ShouldPlayDash()
    {
        return true;
    }

    function SpecialMove(bool bSpecial)
    {
        LastSpecialMoveTime = bSpecial ? WorldInfo.TimeSeconds : 0.0;
    }
}


//Pawn has a "hover" orb.
state OrbHover extends Orb
{
    event BeginState(name PreviousStateName)
    {
        super.BeginState(PreviousStateName);

        bDisableSonicPhysics = true;
        bDisableSpecialMoves = true;
        bIgnoreForces = true;

        Velocity = vect(0,0,0);
        Acceleration = vect(0,0,0);
        VelocityOverride = vect(0,0,0);

        AerialBoost(vect(0,0,100) >> DesiredMeshRotation,false,self,GetStateName());

        bDoubleGravity = false;
        AirControl = DefaultAirControl * 0.33;
        AirDragFactor = 0.0;
        GravityScale = default.GravityScale * 0.33;
        WalkingPhysics = PHYS_Falling;

        LastSpecialMoveTime = 0.0;

        if (OrbHoverParticles != none)
        {
            OrbEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
            OrbEmitter.SetTemplate(OrbHoverParticles,false);

            AttachToRoot(OrbEmitter);
        }
    }

    event EndState(name NextStateName)
    {
        bDisableSonicPhysics = false;
        bDisableSpecialMoves = false;
        bIgnoreForces = false;

        bDoubleGravity = default.bDoubleGravity;
        AirControl = DefaultAirControl;
        AirDragFactor = DefaultAirDragFactor;
        GravityScale = default.GravityScale;
        WalkingPhysics = default.WalkingPhysics;

        LastSpecialMoveTime = 0.0;

        super.EndState(NextStateName);
    }

    event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
    {
        Velocity = MirrorVectorByNormal(Velocity,HitNormal) * 0.75;
        VelocityOverride = Velocity;
    }

    event Landed(vector HitNormal,Actor FloorActor)
    {
        if (SGDKPawn(FloorActor) == none)
            HitWall(HitNormal,FloorActor,FloorActor.CollisionComponent);
    }

    event Tick(float DeltaTime)
    {
        local float Dist,ChosenDist;
        local RingActor Ring,ChosenRing;

        AirControl = DefaultAirControl * 0.33;
        Velocity.Z = FClamp(Velocity.Z,-500.0,500.0);

        global.Tick(DeltaTime);

        if (WorldInfo.TimeSeconds - LastSpecialMoveTime < 0.2)
        {
            ChosenDist = Square(200.0) + 10000.0;

            foreach VisibleCollidingActors(class'RingActor',Ring,200.0,Location,true)
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
        }

        if (ChosenRing != none)
        {
            LastSpecialMoveTime = WorldInfo.TimeSeconds;

            Velocity = Normal(ChosenRing.Location - Location) * 1000.0;
        }
        else
            LastSpecialMoveTime = 0.0;
    }

    function class<DamageType> GetMeleeDamageType()
    {
        return class'SGDKDmgType_OrbHover';
    }

    function bool Jump(bool bJump)
    {
        if (bJump)
        {
            GravityScale = -default.GravityScale;

            if (!bReverseGravity)
            {
                if (Velocity.Z < 0.0)
                    Velocity.Z *= 0.5;
            }
            else
                if (Velocity.Z > 0.0)
                    Velocity.Z *= 0.5;
        }
        else
            GravityScale = default.GravityScale * 0.33;

        return false;
    }

    function bool ShouldPassThrough(Actor AnActor)
    {
        return true;
    }

    function bool ShouldPlayDash()
    {
        return (LastSpecialMoveTime != 0.0);
    }

    function SpecialMove(bool bSpecial)
    {
        local RingActor Ring;

        if (bSpecial)
        {
            foreach VisibleCollidingActors(class'RingActor',Ring,200.0,Location,true)
                if (Ring.bLightDash && FastTrace(Location,Ring.Location))
                    break;
                else
                    Ring = none;

            if (Ring != none)
                LastSpecialMoveTime = WorldInfo.TimeSeconds;
        }
    }

Begin:
    Sleep(0.01);

    Velocity = vect(0,0,0);
    Acceleration = vect(0,0,0);
}


//Pawn has a "laser" orb.
state OrbLaser extends Orb
{
    event BeginState(name PreviousStateName)
    {
        super.BeginState(PreviousStateName);

        bDisableSonicPhysics = true;
        bDisableSpecialMoves = true;
        bIgnoreForces = true;

        Velocity = vect(0,0,0);
        Acceleration = vect(0,0,0);
        VelocityOverride = vect(0,0,0);

        if (IsTouchingGround())
            AerialBoost(vect(0,0,100) >> DesiredMeshRotation,false,self,GetStateName());

        AirDragFactor = 0.0;
        GravityScale = default.GravityScale * 0.01;
        WalkingPhysics = PHYS_Falling;

        LastSpecialMoveTime = 0.0;

        if (OrbLaserParticles != none)
        {
            OrbEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
            OrbEmitter.SetTemplate(OrbLaserParticles,false);

            AttachToRoot(OrbEmitter);
        }
    }

    event EndState(name NextStateName)
    {
        bDisableSonicPhysics = false;
        bDisableSpecialMoves = false;
        bIgnoreForces = false;

        AirDragFactor = DefaultAirDragFactor;
        GravityScale = default.GravityScale;
        WalkingPhysics = default.WalkingPhysics;

        LastSpecialMoveTime = 0.0;

        AerialBoost(vect(0,0,100) >> DesiredMeshRotation,false,self,GetStateName());

        super.EndState(NextStateName);
    }

    event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
    {
        local vector HitLocation;
        local Actor HitActor;

        HitActor = Trace(HitLocation,HitNormal,Location + Velocity,
                         Location,true,GetCollisionExtent(),,TRACEFLAG_Blocking);

        if (HitActor != none && HitActor == WallActor)
        {
            VelocityOverride = MirrorVectorByNormal(Velocity,HitNormal);
            Velocity = vect(0,0,0);
        }
    }

    event Landed(vector HitNormal,Actor FloorActor)
    {
        if (SGDKPawn(FloorActor) == none)
            HitWall(HitNormal,FloorActor,FloorActor.CollisionComponent);
    }

    event Tick(float DeltaTime)
    {
        local rotator R;
        local vector HitLocation,HitNormal,HitLocationB,TraceExtent,TraceTarget,X,Y,Z;

        if (LastSpecialMoveTime == 0.0)
        {
            Velocity = vect(0,0,0);

            if (!bClassicMovement)
                R = SGDKPlayerController(Controller).GetPlayerCamera().GetCameraRotation();
            else
            {
                GetAxes(DesiredMeshRotation,X,Y,Z);

                X = Normal(Normal(Acceleration) + X * (12.5 / (DeltaTime * 100.0)));
                Z = X cross Y;

                R = OrthoRotation(X,Y,Z);
            }

            ForceRotation(R,false);

            TraceExtent = GetCollisionExtent();
            TraceTarget = Location + (vector(R) * 8192.0);

            if (Trace(HitLocation,HitNormal,TraceTarget,Location,true,TraceExtent,,TRACEFLAG_Blocking) != none)
            {
                DrawDebugLine(Location,HitLocation,255,255,255,false);

                HitLocationB = HitLocation;
                TraceTarget = HitLocation + Normal(MirrorVectorByNormal(HitLocation - Location,HitNormal)) * 8192.0;

                if (Trace(HitLocation,HitNormal,TraceTarget,HitLocationB,true,TraceExtent,,TRACEFLAG_Blocking) != none)
                    DrawDebugLine(HitLocationB,HitLocation,0,128,255,false);
                else
                    DrawDebugLine(HitLocationB,TraceTarget,0,128,255,false);
            }
            else
                DrawDebugLine(Location,TraceTarget,255,255,255,false);
        }
        else
            Velocity = Normal(Velocity) * 4000.0;

        Acceleration = vect(0,0,0);

        global.Tick(DeltaTime);
    }

    event UpdateEyeHeight(float DeltaTime)
    {
        local float Smooth;

        Smooth = FMin(DeltaTime * 10.0,0.9);

        EyeHeight = EyeHeight * (1.0 - Smooth) + 80.0 * Smooth;
    }

    function vector GetAccelerationInput(SGDKPlayerInput InputManager,vector ControllerX,
                                         vector ControllerY,vector ControllerZ)
    {
        return Normal(ControllerZ * InputManager.aForward + ControllerY * InputManager.aStrafe) * AccelRate;
    }

    function class<DamageType> GetMeleeDamageType()
    {
        return class'SGDKDmgType_OrbLaser';
    }

    function bool IsUsingMelee()
    {
        return !IsZero(Velocity);
    }

    function bool Jump(bool bJump)
    {
        SpecialMove(bJump);

        return false;
    }

    function bool ShouldPassThrough(Actor AnActor)
    {
        return true;
    }

    function bool ShouldPlayDash()
    {
        return true;
    }

    function SpecialMove(bool bSpecial)
    {
        if (bSpecial && LastSpecialMoveTime == 0.0)
        {
            LastSpecialMoveTime = WorldInfo.TimeSeconds;

            Velocity = vector(DesiredMeshRotation) * 4000.0;
        }
    }
}


//Pawn has a "rocket" orb.
state OrbRocket extends Orb
{
    event BeginState(name PreviousStateName)
    {
        super.BeginState(PreviousStateName);

        bDisableSonicPhysics = true;
        bDisableSpecialMoves = true;
        bIgnoreForces = true;

        Velocity = vect(0,0,0);
        Acceleration = vect(0,0,0);
        VelocityOverride = vect(0,0,0);

        if (IsTouchingGround())
            AerialBoost(vect(0,0,100) >> DesiredMeshRotation,false,self,GetStateName());

        AirControl = 0.0;
        GravityScale = default.GravityScale * -0.01;

        SetTimer(3.25,false,NameOf(RocketImpulse));

        if (OrbRocketParticles != none)
        {
            OrbEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
            OrbEmitter.SetTemplate(OrbRocketParticles,false);

            AttachToRoot(OrbEmitter);
        }
    }

    event EndState(name NextStateName)
    {
        ClearTimer(NameOf(RocketImpulse));

        bDisableSonicPhysics = false;
        bDisableSpecialMoves = false;
        bIgnoreForces = false;

        bDoubleGravity = false;
        AirControl = DefaultAirControl;
        GravityScale = default.GravityScale;

        super.EndState(NextStateName);
    }

    function class<DamageType> GetMeleeDamageType()
    {
        return class'SGDKDmgType_OrbRocket';
    }

    function RocketImpulse()
    {
        GravityScale *= 8.0;
    }

    function bool ShouldPassThrough(Actor AnActor)
    {
        return true;
    }

Begin:
    Sleep(0.01);

    Acceleration = vect(0,0,0);
    AirControl = 0.0;
    Velocity.X = 0.0;
    Velocity.Y = 0.0;

    if (IsTouchingGround())
        AerialBoost(vect(0,0,100) >> DesiredMeshRotation,false,self,GetStateName());

Accelerate:
    Sleep(0.5);

    AirControl = 0.0;
    GravityScale *= 2.0;

    Goto('Accelerate');
}


//Pawn has a "spikes" orb.
state OrbSpikes extends Orb
{
    event BeginState(name PreviousStateName)
    {
        super.BeginState(PreviousStateName);

        bDisableSonicPhysics = true;
        bDisableSpecialMoves = true;
        bIgnoreForces = true;

        if (IsTouchingGround() && !WillLeaveGround() && !bSpiderPhysicsMode)
            SetSpiderPhysics(true);

        LastSpecialMoveTime = 0.0;

        if (OrbSpikesParticles != none)
        {
            OrbEmitter = Spawn(class'SGDKEmitter',self,,Location,GetRotation());
            OrbEmitter.SetTemplate(OrbSpikesParticles,false);

            AttachToRoot(OrbEmitter);
        }
    }

    event EndState(name NextStateName)
    {
        if (bSpiderPhysicsMode)
            SetSpiderPhysics(false);

        bDisableSonicPhysics = false;
        bDisableSpecialMoves = false;
        bIgnoreForces = false;

        LastSpecialMoveTime = 0.0;

        Velocity = vect(0,0,0);
        Acceleration = vect(0,0,0);

        super.EndState(NextStateName);
    }

    event HitWall(vector HitNormal,Actor WallActor,PrimitiveComponent WallComponent)
    {
        SetBase(WallActor,HitNormal);

        TriggerLanded(HitNormal,WallActor);
    }

    event Landed(vector HitNormal,Actor FloorActor)
    {
        global.Landed(HitNormal,FloorActor);

        if (!WillLeaveGround() && !bSpiderPhysicsMode)
            SetSpiderPhysics(true);
    }

    event Tick(float DeltaTime)
    {
        if (LastSpecialMoveTime != 0.0)
        {
            if (IsTouchingGround())
            {
                if (WorldInfo.TimeSeconds - LastSpecialMoveTime < 0.5)
                {
                    Velocity = vect(0,0,0);
                    Acceleration = vect(0,0,0);

                    MeshPitchRotation += DeltaTime * 30.0;
                }
                else
                {
                    HighSpeedBoost(1.0,true);

                    LastSpecialMoveTime = 0.0;

                    if (OrbSpikesSound != none)
                        PlaySound(OrbSpikesSound,false,true);
                }
            }
            else
                LastSpecialMoveTime = 0.0;
        }

        global.Tick(DeltaTime);
    }

    function AerialBoost(vector BoostVelocity,optional bool bLand,optional Actor PushActor,optional name Reason)
    {
        if (Reason != 'Jump')
            GotoState('Auto');

        global.AerialBoost(BoostVelocity,bLand,PushActor,Reason);
    }

    function bool Duck(bool bDuck)
    {
        SpecialMove(bDuck);

        return false;
    }

    function class<DamageType> GetMeleeDamageType()
    {
        return class'SGDKDmgType_OrbSpikes';
    }

    function bool IsInvulnerable(optional class<DamageType> DamageClass)
    {
        if (ClassIsChildOf(DamageClass,class'SGDKDmgType_Spikes'))
            return true;

        return global.IsInvulnerable(DamageClass);
    }

    function bool IsUsingMelee()
    {
        return (LastSpecialMoveTime != 0.0 || !IsZero(Velocity));
    }

    function bool Jump(bool bJump)
    {
        if (LastSpecialMoveTime == 0.0)
            return global.Jump(bJump);
        else
            return false;
    }

    function LeftGround()
    {
        if (bSpiderPhysicsMode)
            SetSpiderPhysics(false);

        global.LeftGround();
    }

    function SpecialMove(bool bSpecial)
    {
        if (bSpecial && LastSpecialMoveTime == 0.0 && IsTouchingGround())
        {
            Velocity = vect(0,0,0);
            Acceleration = vect(0,0,0);

            LastSpecialMoveTime = WorldInfo.TimeSeconds;

            if (OrbSpikesSound != none)
                PlaySound(OrbSpikesSound,false,true);
        }
    }
}


defaultproperties
{
    Begin Object Name=WPawnSkeletalMeshComponent
        AbsoluteRotation=true //Uses world units as opposed to relative to the pawn owner.
        ForcedLodModel=1      //Forces Level Of Detail (LOD) to 0 (ForcedLodModel-1); the highest one.
    End Object
    Mesh=WPawnSkeletalMeshComponent
    VisibleMesh=WPawnSkeletalMeshComponent


    Begin Object Name=CollisionCylinder
        CollisionHeight=32.0 //This value is half the total height for the cylinder.
        CollisionRadius=20.0 //This value is the radius for cylinder.
    End Object
    CylinderComponent=CollisionCylinder


    Begin Object Class=SkeletalMeshComponent Name=Ghost1SkeletalComponent
        bAcceptsDynamicDecals=false            //Doesn't accept dynamic decals created during gameplay.
        bAcceptsStaticDecals=false             //Doesn't accept static decals placed in the level with the editor.
        bCacheAnimSequenceNodes=false          //Animation sequence nodes won't cache values when not playing animations.
        bCastDynamicShadow=false               //Doesn't cast dynamic shadows.
        bHasPhysicsAssetInstance=false         //Doesn't use a physical representation in the physics engine.
        bIgnoreControllersWhenNotRendered=true //Skeletal controls are ignored if the mesh isn't visible.
        bOwnerNoSee=false                      //It's visible to the owner.
        bPerBoneMotionBlur=false               //Doesn't use per-bone motion blur.
        bTransformFromAnimParent=0             //Ignores transform of parent skeletal mesh.
        bUpdateSkelWhenNotRendered=false       //Skeleton isn't updated if it isn't visible.
        bUseBoundsFromParentAnimComponent=true //Takes calculated bounds from parent skeletal mesh.
        bUseOnePassLightingOnTranslucency=true //Uses nice lighting for hair.
        AbsoluteRotation=true                  //Uses world units as opposed to relative to the pawn owner.
        BlockRigidBody=false                   //Doesn't block rigid bodies managed by the physics engine.
        CastShadow=false                       //Can't cast shadows.
        HiddenGame=true                        //Hidden by default.
        ParentAnimComponent=WPawnSkeletalMeshComponent //Parent skeletal mesh.
        TickGroup=TG_PreAsyncWork              //Operates on last frame's physics simulation results.
    End Object
    HyperSkeletalGhosts[0]=Ghost1SkeletalComponent


    Begin Object Class=SkeletalMeshComponent Name=Ghost2SkeletalComponent
        bAcceptsDynamicDecals=false            //Doesn't accept dynamic decals created during gameplay.
        bAcceptsStaticDecals=false             //Doesn't accept static decals placed in the level with the editor.
        bCacheAnimSequenceNodes=false          //Animation sequence nodes won't cache values when not playing animations.
        bCastDynamicShadow=false               //Doesn't cast dynamic shadows.
        bHasPhysicsAssetInstance=false         //Doesn't use a physical representation in the physics engine.
        bIgnoreControllersWhenNotRendered=true //Skeletal controls are ignored if the mesh isn't visible.
        bOwnerNoSee=false                      //It's visible to the owner.
        bPerBoneMotionBlur=false               //Doesn't use per-bone motion blur.
        bTransformFromAnimParent=0             //Ignores transform of parent skeletal mesh.
        bUpdateSkelWhenNotRendered=false       //Skeleton isn't updated if it isn't visible.
        bUseBoundsFromParentAnimComponent=true //Takes calculated bounds from parent skeletal mesh.
        bUseOnePassLightingOnTranslucency=true //Uses nice lighting for hair.
        AbsoluteRotation=true                  //Uses world units as opposed to relative to the pawn owner.
        BlockRigidBody=false                   //Doesn't block rigid bodies managed by the physics engine.
        CastShadow=false                       //Can't cast shadows.
        HiddenGame=true                        //Hidden by default.
        ParentAnimComponent=WPawnSkeletalMeshComponent //Parent skeletal mesh.
        TickGroup=TG_PreAsyncWork              //Operates on last frame's physics simulation results.
    End Object
    HyperSkeletalGhosts[1]=Ghost2SkeletalComponent


    bCanWalkOffLedges=true     //Can fall off ledges, even while walking at low speed.
    bEnableFootPlacement=false //Disables crappy foot placement IK system.
    bPushesRigidBodies=true    //Will do a check to find nearby PHYS_RigidBody actors and will give them a soft push.
    bScriptTickSpecial=true    //Will call the script TickSpecial event.
    BaseEyeHeight=40.0         //Base eye height above collision cylinder center.
    EyeHeight=40.0             //Current eye height, adjusted for bobbing and stairs.
    MaxLeanRoll=0              //How much pawn should lean into turns; 0 means roll rotation isn't allowed.
    RagdollLifespan=0.0        //How old (in seconds) the ragdoll lives before vanishing; 0 means forever.
    WalkableFloorZ=0.71        //Minimum z value for floor normal; if less, not a walkable floor for this pawn;
                               //                                  0.71 equals to less than 45° angle for floor.

    Health=1            //Amount of health this pawn has; it's the ring counter plus one.
    HealthMax=1000      //Normal maximum health of pawn; max value for ring counter plus one.
    SuperHealthMax=1000 //Maximum allowable boosted health; max value for ring counter plus one.

    AccelRate=0.0       //Max acceleration rate.
    AirControl=0.0      //Amount of aerial control available.
    AirSpeed=1500.0     //The maximum flying speed.
    CrouchedPct=0.5     //Percent of running speed that crouched walking speed is.
    GroundSpeed=0.0     //The maximum on ground speed while running.
    JumpZ=0.0           //Vertical acceleration for jumps.
    LadderSpeed=300.0   //The maximum ladder climbing speed.
    MaxFallSpeed=5000.0 //The maximum speed pawn can land without taking damage.
    WalkingPct=1.0      //Percent of running speed that walking speed is.
    WaterSpeed=500.0    //The maximum swimming speed.

    LandMovementState=PlayerWalking  //Controller state to use when moving on land or air.
    WaterMovementState=PlayerWalking //Controller state to use when moving in water.

    CrouchHeight=20.0 //Half of height for collision cylinder when crouching.
    CrouchRadius=20.0 //Radius for collision cylinder when crouching.

    bDefaultPawnClass=false

    AdhesionPct=0.85
    FloorDotAngle=1.0
    FloorNormal=(X=0.0,Y=0.0,Z=1.0)
    WalkablePlainZ=0.025
    WalkableWallZ=0.25
    WaterRunAdhesionPct=1.25

    SpiderRadius=20.0

    SplineOffset=999999.0

    bLimitRollingJump=true
    JumpingSound=SoundCue'SonicGDKPackSounds.JumpSoundCue'
    MaxJumpImpulseTime=0.25
    MaxJumpZ=0.0
    MaxSpeedBeforeJump=0.0

    DodgeSound=SoundCue'SonicGDKPackSounds.JumpSoundCue'
    FootstepDefaultSound=SoundCue'A_Character_Footsteps.Footsteps.A_Character_Footstep_DefaultCue'
    FootstepSounds.Add((MaterialType=Stone,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue'))
    FootstepSounds.Add((MaterialType=Dirt,        Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue'))
    FootstepSounds.Add((MaterialType=Energy,      Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyCue'))
    FootstepSounds.Add((MaterialType=Foliage,     Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageCue'))
    FootstepSounds.Add((MaterialType=Glass,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateCue'))
    FootstepSounds.Add((MaterialType=Water,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue'))
    FootstepSounds.Add((MaterialType=ShallowWater,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowCue'))
    FootstepSounds.Add((MaterialType=Metal,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalCue'))
    FootstepSounds.Add((MaterialType=Snow,        Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowCue'))
    FootstepSounds.Add((MaterialType=Wood,        Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodCue'))
    LandingDefaultSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue'
    LandingSounds.Add((MaterialType=Stone,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneLandCue'))
    LandingSounds.Add((MaterialType=Dirt,        Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue'))
    LandingSounds.Add((MaterialType=Energy,      Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyLandCue'))
    LandingSounds.Add((MaterialType=Foliage,     Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageLandCue'))
    LandingSounds.Add((MaterialType=Glass,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateLandCue'))
    LandingSounds.Add((MaterialType=GlassBroken, Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassBrokenLandCue'))
    LandingSounds.Add((MaterialType=Grass,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GrassLandCue'))
    LandingSounds.Add((MaterialType=Metal,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalLandCue'))
    LandingSounds.Add((MaterialType=Mud,         Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MudLandCue'))
    LandingSounds.Add((MaterialType=Metal,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalLandCue'))
    LandingSounds.Add((MaterialType=Snow,        Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowLandCue'))
    LandingSounds.Add((MaterialType=Tile,        Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_TileLandCue'))
    LandingSounds.Add((MaterialType=Water,       Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepLandCue'))
    LandingSounds.Add((MaterialType=ShallowWater,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowLandCue'))
    LandingSounds.Add((MaterialType=Wood,        Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodLandCue'))

    bCanUnRoll=false
    bDisableScriptedRoll=false
    MinRollingSpeed=150.0
    RollingSound=none
    SkiddingDefaultSound=SoundCue'SonicGDKPackSounds.SkiddingSoundCue'

    bCanSpinDash=true
    bClassicSpinDash=false
    SpinDashChargeDefaultSound=SoundCue'SonicGDKPackSounds.SpinDashSoundCue'
    SpinDashCount=0
    SpinDashDecreaseTime=0.33
    SpinDashParticleSystem=ParticleSystem'SonicGDKPackParticles.Particles.SpinDashParticleSystem'
    SpinDashSpeedPct=0.8
    SpinDashReleaseSound=none

    bDisableSonicPhysics=false
    bDoubleGravity=true
    bMustWalk=false
    AirDragFactor=0.0
    GravityScale=1.0
    RunningOnPlainsPct=0.1
    WalkSpeedPct=0.5
    WaterRunDecelPct=0.25

    bFullNativeRotation=false
    bMeshAlignToGravity=false
    bSmoothRotation=true
    SmoothRotationRate=7.5

    VelocityOverride=(X=999999.0,Y=999999.0,Z=999999.0)
    VelocityZOverride=999999.0

    DrownSound=SoundCue'SonicGDKPackSounds.DrownedSoundCue'
    UnderwaterTimer=30.0

    bDisableShieldMoves=false
    bDisableSpecialMoves=false
    MinTimeSpecialMoves=0.1
    AerialActionsJump[0]=SA_ShieldMove
    AerialActionsJump[1]=SA_SuperTransform
    AerialActionsJump[2]=SA_CharacterMove
    AerialActionsSpecialMove[0]=SA_ShieldMove
    AerialActionsSpecialMove[1]=SA_SuperTransform
    AerialActionsSpecialMove[2]=SA_CharacterMove

    PushRigidBodies=1

    HangingAnimation=Hang
	MachStateAnimation = Mach_State

    InvincibleDamageType=class'SGDKDmgType_Invincible'
    JumpedDamageType=class'SGDKDmgType_Jump'
    RollingDamageType=class'SGDKDmgType_Roll'

    bDisableBlobShadows=false
    BlobShadowClass=class'BlobShadowActor'

    BubbleBounceFactor=1.33
    BubbleMaterial=Material'SonicGDKPackStaticMeshes.Materials.ShieldBubbleMaterial'
    BubbleSpeedBoost=2000.0
    FlameGravityScale=0.5
    FlameHomingRadius=500.0
    FlameMaterial=Material'SonicGDKPackStaticMeshes.Materials.ShieldFlameMaterial'
    FlameSpeedBoost=2000.0
    MagneticMaterial=Material'SonicGDKPackStaticMeshes.Materials.ShieldMagneticMaterial'
    MagneticRingsRadius=250.0
    MagneticSpeedBoost=550.0
    ShieldClass=class'ShieldActor'
    StandardMaterial=Material'SonicGDKPackStaticMeshes.Materials.ShieldStandardMaterial'

    bDisableDamageBlink=false
    bDropAllRings=true
    bTurnedOff=false
    DroppedRingsClass=class'RingProjectile'
    DroppedRingsSound=SoundCue'SonicGDKPackSounds.RingsDroppedSoundCue'
    DyingSound=SoundCue'SonicGDKPackSounds.DyingSoundCue'
    HurtAnimation=Hurt
    HurtSound=none
    InitialRings=0
    LastDamageTime=-999999.0
    MinTimeDamage=3.0
    RagdollImpulseFactor=0.5
    RagdollTimeSpan=5.0

    bMiniSize=false
    MiniHeight=20.0
    MiniRadius=12.5

    HudCharNameCoords=(U=10,V=849,UL=296,VL=81)
    HudDecorationCoords=(U=10,V=290,UL=72,VL=70)

    bHasHyperForm=true
    bSuperForm=false
    bHyperForm=false
    RingCountdownTime=1.0
    SuperDamageType=class'SGDKDmgType_Super'
    SuperHudDecoCoords=(U=92,V=290,UL=72,VL=70)
    HyperHudDecoCoords=(U=174,V=290,UL=72,VL=70)
    SuperLightClass=class'PointLightSuper'

    HealthLimit=101
    LifeInventoryClass=class'MonitorInventoryLife'
    ScoreMultiplier=1.0

    VictoryAnimation=Victory

    OrbDrillParticles=ParticleSystem'SonicGDKPackParticles.Particles.OrbDrillParticleSystem'
    OrbHoverParticles=ParticleSystem'SonicGDKPackParticles.Particles.OrbHoverParticleSystem'
    OrbLaserParticles=ParticleSystem'SonicGDKPackParticles.Particles.OrbLaserParticleSystem'
    OrbRocketParticles=ParticleSystem'SonicGDKPackParticles.Particles.OrbRocketParticleSystem'
    OrbSpikesParticles=ParticleSystem'SonicGDKPackParticles.Particles.OrbSpikesParticleSystem'
    OrbSpikesSound=SoundCue'SonicGDKPackSounds.SpinDashSoundCue'
}
