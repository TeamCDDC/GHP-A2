//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Shield Actor > SGDKActor > Actor
//
// The Shield Actor is the classic shield found in all Sonic games.
// It protects pawn owner and has a state for each type of existing shield.
//================================================================================
class ShieldActor extends SGDKActor
    implements(ReceivePawnEvents);


           /**Link to pawn owner.*/ var SGDKPlayerPawn PawnOwner;
/**The shield visual static mesh.*/ var StaticMeshComponent ShieldMesh;

/**Holds flame particle visual effects.*/ var SGDKEmitter FlameEmitter;
        /**The particle visual effects.*/ var ParticleSystem FlameParticleSystem,MagneticParticleSystem;
    /**Attached dynamic point of light.*/ var SGDKSpawnablePointLight ShieldLight;

/**Sounds played for shield's special move.*/ var SoundCue BubbleActionSound,FlameActionSound,MagneticActionSound;
 /**Sounds played when shield is picked up.*/ var SoundCue BubblePickupSound,FlamePickupSound,MagneticPickupSound,StandardPickupSound;
        /**Delay time for the pickup sound.*/ var float PickupSoundDelay;

/**DamageType classes to use for special moves.*/ var class<SGDKDamagetype> BubbleDamageType,FlameDamageType;

/**If true, gravity affecting pawn owner has been modified.*/ var bool bModifiedGravity;
      /**If true, a shield special move has been performed.*/ var bool bSpecialMove;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    PawnOwner = SGDKPlayerPawn(Owner);

    //Add this actor to the array to get common owner notifications.
    PawnOwner.NotifyEventsTo.AddItem(self);
}

/**
 * Called immediately before destroying this actor.
 */
simulated event Destroyed()
{
    //Kill flame particle effects if not already deleted.
    if (FlameEmitter != none)
    {
        FlameEmitter.DelayedDestroy();
        FlameEmitter = none;
    }

    super.Destroyed();
}

/**
 * Cancels any performed special move.
 */
function CancelMoves()
{
}

/**
 * Denies pawn owner pick up an actor.
 * @param AnActor  actor to be picked up
 * @return         true if actor is denied
 */
function bool DenyActorPickup(Actor AnActor)
{
    return false;
}

/**
 * Searches for nearby rings within a radius.
 */
function FindRings()
{
    PawnOwner.MagnetizeNearbyActors(PawnOwner.MagneticRingsRadius);
}

/**
 * Gets the damage type to use for melee attacks; delegated to states.
 * @return  class of melee damage type
 */
function class<DamageType> GetAttackDamageType()
{
    return none;
}

/**
 * Is the shield able to inflict melee damage?; delegated to states.
 * @return  true if melee damage should be inflicted
 */
function bool IsAttacking()
{
    return false;
}

//Ignored function calls.
function PawnBounced(SGDKPlayerPawn ThePawn);
function PawnDoubleJumped(SGDKPlayerPawn ThePawn);
function PawnHeadLeftWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnHurtPawn(SGDKPlayerPawn ThePawn,Pawn TheOtherPawn);
function PawnJumpApex(SGDKPlayerPawn ThePawn);
function PawnJumped(SGDKPlayerPawn ThePawn);
function PawnLeftWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);
function PawnTookDamage(SGDKPlayerPawn ThePawn,Actor TheDamageCauser);

/**
 * Called when the pawn dies.
 * @param ThePawn  the pawn that generates the event
 */
function PawnDied(SGDKPlayerPawn ThePawn)
{
    //Pawn owner died.
    Destroy();
}

/**
 * Called when the pawn enters a water volume; delegated to states.
 * @param ThePawn         the pawn that generates the event
 * @param TheWaterVolume  the new physics volume in which the pawn has entered
 */
function PawnEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);

/**
 * Called when the pawn's head enters a water volume; delegated to states.
 * @param ThePawn         the pawn that generates the event
 * @param TheWaterVolume  the new physics volume in which the pawn's head has entered
 */
function PawnHeadEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume);

/**
 * Called when the pawn lands on level geometry while falling; delegated to states.
 * @param ThePawn           the pawn that generates the event
 * @param bWillLeaveGround  true if the pawn will leave the actor is standing on soon
 * @param TheHitNormal      the surface normal of the actor/level geometry landed on
 * @param TheFloorActor     the actor landed on
 */
function PawnLanded(SGDKPlayerPawn ThePawn,bool bWillLeaveGround,vector TheHitNormal,Actor TheFloorActor);

/**
 * Called when all physics data of the pawn is adapted to a new physics environment.
 * @param ThePawn  the pawn that generates the event
 */
function PawnPhysicsChanged(SGDKPlayerPawn ThePawn)
{
    SetHidden(IsInState('Disabled') || ThePawn.bIsInvulnerable);

    if (ShieldLight != none)
        ShieldLight.LightComponent.SetEnabled(!bHidden);
}

/**
 * A pawn has a new type of shield now.
 * @param P  the pawn
 */
function PickedUpBy(SGDKPlayerPawn P)
{
    local SGDKPlayerController PC;

    //Alerts nearby AI.
    P.MakeNoise(0.5);

    PC = SGDKPlayerController(P.Controller);

    //Updates the HUD.
    if (PC != none && SGDKHud(PC.MyHUD) != none)
        SGDKHud(PC.MyHUD).LastPickupTime = WorldInfo.TimeSeconds;

    //Make sure special move flag is false.
    bSpecialMove = false;

    if (!P.bIsInvulnerable)
    {
        //Shield is displayed.
        SetHidden(false);

        //Light is displayed.
        if (ShieldLight != none)
            ShieldLight.LightComponent.SetEnabled(true);
    }
}

/**
 * Call to see if a damage class is absorbed by the shield; delegated to states.
 * @param DamageClass  the type of damage
 * @return             true if damage is prevented
 */
function bool PreventDamage(class<DamageType> DamageClass)
{
    return false;
}

/**
 * Should the pawn owner pass through a solid actor?
 * @return  true if the pawn owner should pass through an actor
 */
function bool ShouldPassThrough(Actor AnActor)
{
    return false;
}

/**
 * Should the attached skeletal mesh component of pawn owner play the dashing animation?; delegated to states.
 * @return  true if the attached skeletal mesh component of pawn owner should play the dashing animation
 */
function bool ShouldPlayDash()
{
    return false;
}

/**
 * Pawn owner wants to perform a shield special move; delegated to states.
 * @return  true if special move is performed
 */
function bool SpecialMove()
{
    return false;
}

/**
 * The shield took damage.
 */
function TookDamage()
{
    //Hide/disable shield.
    GotoState('Disabled');
}


//Disabled shield state; default state.
auto state Disabled
{
    event BeginState(name PreviousStateName)
    {
        //Make sure special move flag is false.
        bSpecialMove = false;

        //Shield isn't displayed in this state.
        SetHidden(true);
    }
}


//Bubble shield state.
state Bubble
{
    event BeginState(name PreviousStateName)
    {
        //Change the material of the shield first.
        ShieldMesh.SetMaterial(0,PawnOwner.BubbleMaterial);

        PickedUpBy(PawnOwner);

        //Allow breath in water.
        if (PawnOwner.HeadVolume.bWaterVolume)
            PawnOwner.Breath(true);
    }

    event EndState(name NextStateName)
    {
        CancelMoves();

        //Deny breath in water.
        if (PawnOwner.HeadVolume.bWaterVolume)
            PawnOwner.Breath(false);
    }

    function CancelMoves()
    {
        if (bSpecialMove)
        {
            //Modify special move flag.
            bSpecialMove = false;

            //Restore scale of the shield mesh.
            ShieldMesh.SetScale3D(vect(1.0,1.0,1.0));

            //Restore default aerial control.
            PawnOwner.AirControl = PawnOwner.DefaultAirControl;
        }
    }

    function bool DenyActorPickup(Actor AnActor)
    {
        if (BubbleProjectile(AnActor) != none)
            return true;

        return false;
    }

    function class<DamageType> GetAttackDamageType()
    {
        if (bSpecialMove)
            return BubbleDamageType;

        return none;
    }

    function bool IsAttacking()
    {
        return bSpecialMove;
    }

    function PawnBounced(SGDKPlayerPawn ThePawn)
    {
        CancelMoves();
    }

    function PawnHeadEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume)
    {
        //Allow breath in water.
        PawnOwner.Breath(true);
    }

    function PawnLanded(SGDKPlayerPawn ThePawn,bool bWillLeaveGround,vector TheHitNormal,Actor TheFloorActor)
    {
        local vector V;

        if (bSpecialMove)
        {
            //Modify special move flag.
            bSpecialMove = false;

            //Restore scale of the shield mesh.
            ShieldMesh.SetScale3D(vect(1.0,1.0,1.0));

            //If pawn won't leave ground soon...
            if (!bWillLeaveGround)
            {
                //Apply boost according to floor normal direction.
                V = TheHitNormal * (PawnOwner.JumpZ * PawnOwner.BubbleBounceFactor);

                if (PawnOwner.Bounce(V,true,true,false,self,'Bubble'))
                    //Plays action sound.
                    PawnOwner.PlaySound(BubbleActionSound);
            }
        }
    }

    function bool PreventDamage(class<DamageType> DamageClass)
    {
        //Any type of drowning damage is ignored.
        if (ClassIsChildOf(DamageClass,class'SGDKDmgType_Drowned'))
            return true;

        return false;
    }

    function bool SpecialMove()
    {
        local vector V;

        if (!PawnOwner.bIsInvulnerable && PawnOwner.HasJumped() && PawnOwner.Physics == PHYS_Falling &&
            PawnOwner.MultiJumpRemaining > 0 && !IsZero(PawnOwner.GetVelocity()))
        {
            //Modify special move flag.
            bSpecialMove = true;

            V = PawnOwner.GetVelocity();

            //Slow down the pawn owner.
            V *= 0.05;

            //Apply boost according to gravity direction.
            if (!PawnOwner.bReverseGravity)
                V.Z = -PawnOwner.BubbleSpeedBoost;
            else
                V.Z = PawnOwner.BubbleSpeedBoost;

            //Set velocity for pawn owner.
            PawnOwner.SetVelocity(V);

            //Reduce amount of aerial control of pawn owner.
            PawnOwner.AirControl = 0.0;

            //Plays action sound.
            PawnOwner.PlaySound(BubbleActionSound);

            //Deform the shield mesh.
            ShieldMesh.SetScale3D(vect(1.5,1.5,0.75));

            return true;
        }

        return false;
    }

Begin:
    Sleep(PickupSoundDelay);

    //Plays pickup sound.
    PawnOwner.PlaySound(BubblePickupSound);
}


//Flame shield state.
state Flame
{
    event BeginState(name PreviousStateName)
    {
        //Change the material of the shield first.
        ShieldMesh.SetMaterial(0,PawnOwner.FlameMaterial);

        //Create and attach a light.
        ShieldLight = Spawn(class'PointLightShieldFlame',PawnOwner);
        PawnOwner.AttachToRoot(ShieldLight);

        PickedUpBy(PawnOwner);
    }

    event EndState(name NextStateName)
    {
        PawnLanded(PawnOwner,false,vect(0,0,0),none);

        //Delete the light.
        if (ShieldLight != none)
        {
            PawnOwner.DetachFromRoot(ShieldLight);
            ShieldLight.Destroy();

            ShieldLight = none;
        }
    }

    function CancelMoves()
    {
        if (bSpecialMove)
        {
            //Modify special move flag.
            bSpecialMove = false;

            if (bModifiedGravity)
            {
                bModifiedGravity = false;

                //Scale gravity magnitude which affects the pawn owner.
                PawnOwner.GravityScale /= PawnOwner.FlameGravityScale;
            }

            //Kill flame particle effects if not already deleted.
            if (FlameEmitter != none)
            {
                FlameEmitter.DelayedDestroy();
                FlameEmitter = none;
            }
        }
    }

    function class<DamageType> GetAttackDamageType()
    {
        if (bSpecialMove)
            return FlameDamageType;

        return none;
    }

    function bool IsAttacking()
    {
        return bSpecialMove;
    }

    function PawnBounced(SGDKPlayerPawn ThePawn)
    {
        CancelMoves();
    }

    function PawnEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume)
    {
        //Hide/disable shield.
        GotoState('Disabled');
    }

    function PawnLanded(SGDKPlayerPawn ThePawn,bool bWillLeaveGround,vector TheHitNormal,Actor TheFloorActor)
    {
        CancelMoves();
    }

    function bool PreventDamage(class<DamageType> DamageClass)
    {
        //Any type of burning damage is ignored.
        if (DamageClass == class'UTDmgType_Burning' || DamageClass == class'UTDmgType_Fire' ||
            DamageClass == class'UTDmgType_Lava')
            return true;

        return false;
    }

    function bool ShouldPassThrough(Actor AnActor)
    {
        return bSpecialMove;
    }

    function bool ShouldPlayDash()
    {
        return bSpecialMove;
    }

    function bool SpecialMove()
    {
        local vector Dir;
        local float Dist,ChosenDist;
        local SGDKEnemyPawn P,ChosenPawn;

        if (!PawnOwner.bIsInvulnerable && PawnOwner.HasJumped() && PawnOwner.Physics == PHYS_Falling &&
            PawnOwner.MultiJumpRemaining > 0 && !IsZero(PawnOwner.GetVelocity()))
        {
            //Modify special move flag.
            bSpecialMove = true;

            //Get a normalized vector which faces the proper direction.
            Dir = PawnOwner.GetDefaultDirection();

            //Used to get the nearest pawn.
            ChosenDist = Square(PawnOwner.FlameHomingRadius) + 10000.0;

            //For each pawn within a radius...
            foreach WorldInfo.AllPawns(class'SGDKEnemyPawn',P,PawnOwner.Location,PawnOwner.FlameHomingRadius)
            {
                //Ignore pawns behind obstacles and pawns behind the owner (angle greater than 90°).
                if (P.IsHomingTarget() && FastTrace(PawnOwner.Location,P.Location) &&
                    Normal(Dir) dot Normal(P.Location - PawnOwner.Location) >= 0.7)
                {
                    //Get distance to possible target.
                    Dist = VSizeSq(P.Location - PawnOwner.Location);

                    //If it's the nearest pawn until now...
                    if (Dist < ChosenDist)
                    {
                        //Pawn is chosen for now.
                        ChosenPawn = P;
                        ChosenDist = Dist;
                    }
                }
            }

            //If a pawn has been found...
            if (ChosenPawn != none)
            {
                //Direction and magnitude is calculated.
                Dir = Normal(ChosenPawn.GetHomingLocation(PawnOwner) - PawnOwner.Location) * PawnOwner.FlameSpeedBoost;

                //Set velocity for pawn owner.
                PawnOwner.SetVelocity(Dir);
            }
            else
            {
                //Scale gravity magnitude which affects the pawn owner.
                PawnOwner.GravityScale *= PawnOwner.FlameGravityScale;

                //Take note.
                bModifiedGravity = true;

                //Direction is taken from pressed direction keys/buttons.
                Dir = SGDKPlayerController(PawnOwner.Controller).GetPressedDirection(true,PawnOwner.bClassicMovement);

                //If no direction keys/buttons are pressed, use proper direction.
                if (Dir.X == 0.0 && Dir.Y == 0.0)
                    Dir = PawnOwner.GetDefaultDirection();

                Dir.Z = 0.0;

                //Set velocity for pawn owner.
                PawnOwner.SetVelocity(Normal(Dir) * PawnOwner.FlameSpeedBoost);
            }

            //Plays action sound.
            PawnOwner.PlaySound(FlameActionSound);

            //Display flame particle effects.
            FlameEmitter = Spawn(class'SGDKEmitter',self,,Location,Rotation);
            FlameEmitter.SetBase(self);
            FlameEmitter.SetTemplate(FlameParticleSystem,false);

            return true;
        }

        return false;
    }

Begin:
    Sleep(PickupSoundDelay);

    //Plays pickup sound.
    PawnOwner.PlaySound(FlamePickupSound);
}


//Magnetic shield state.
state Magnetic
{
    event BeginState(name PreviousStateName)
    {
        //Change the material of the shield first.
        ShieldMesh.SetMaterial(0,PawnOwner.MagneticMaterial);

        //Create and attach a light.
        ShieldLight = Spawn(class'PointLightShieldMagnetic',PawnOwner);
        PawnOwner.AttachToRoot(ShieldLight);

        PickedUpBy(PawnOwner);

        //Check for nearby rings with a timer.
        SetTimer(0.1,true,NameOf(FindRings));
    }

    event EndState(name NextStateName)
    {
        //Delete the timer.
        ClearTimer(NameOf(FindRings));

        //Delete the light.
        if (ShieldLight != none)
        {
            PawnOwner.DetachFromRoot(ShieldLight);
            ShieldLight.Destroy();

            ShieldLight = none;
        }
    }

    function PawnEnteredWater(SGDKPlayerPawn ThePawn,PhysicsVolume TheWaterVolume)
    {
        //Hide/disable shield.
        GotoState('Disabled');
    }

    function bool PreventDamage(class<DamageType> DamageClass)
    {
        //Any type of shock damage is ignored.
        if (DamageClass == class'UTDmgType_ShockBall')
            return true;

        return false;
    }

    function bool SpecialMove()
    {
        local vector V;
        local SGDKEmitter MagneticEmitter;

        if (!PawnOwner.bIsInvulnerable && PawnOwner.HasJumped() && PawnOwner.Physics == PHYS_Falling &&
            PawnOwner.MultiJumpRemaining > 0 && !IsZero(PawnOwner.GetVelocity()))
        {
            V = PawnOwner.GetVelocity();

            //Apply boost according to gravity direction.
            if (!PawnOwner.bReverseGravity)
                V.Z = PawnOwner.MagneticSpeedBoost;
            else
                V.Z = -PawnOwner.MagneticSpeedBoost;

            PawnOwner.SetVelocity(V);

            //Plays action sound.
            PawnOwner.PlaySound(MagneticActionSound);

            //Display magnetic particle effects.
            MagneticEmitter = Spawn(class'SGDKEmitter',self,,Location,rot(0,0,0));
            MagneticEmitter.SetTemplate(MagneticParticleSystem,true);

            return true;
        }

        return false;
    }

Begin:
    Sleep(PickupSoundDelay);

    //Plays pickup sound.
    PawnOwner.PlaySound(MagneticPickupSound);
}


//Standard shield state.
state Standard
{
    event BeginState(name PreviousStateName)
    {
        //Change the material of the shield first.
        ShieldMesh.SetMaterial(0,PawnOwner.StandardMaterial);

        PickedUpBy(PawnOwner);
    }

Begin:
    Sleep(PickupSoundDelay);

    //Plays pickup sound.
    PawnOwner.PlaySound(StandardPickupSound);
}


defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=TheShieldMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.ShieldStaticMesh'
        bAcceptsLights=false
        bAllowApproximateOcclusion=false
        bCastDynamicShadow=false
        bForceDirectLightMap=true
        BlockActors=false
        BlockRigidBody=false
        CastShadow=false
        CollideActors=false
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    ShieldMesh=TheShieldMesh
    Components.Add(TheShieldMesh)


    bBlockActors=false           //Doesn't block other nonplayer actors.
    bCollideActors=false         //Doesn't collide with other actors.
    bCollideWorld=false          //Doesn't collide with the world.
    bHidden=true                 //Actor isn't displayed from start.
    bIgnoreBaseRotation=true     //Ignores the effects of changes in its base's rotation.
    bMovable=true                //Actor can be moved.
    bNoDelete=false              //Can be deleted during play.
    bStatic=false                //It moves or changes over time.
    Physics=PHYS_None            //Actor's physics mode; no physics.
    TickGroup=TG_DuringAsyncWork //Tick run in parallel of the async work.

    FlameParticleSystem=ParticleSystem'SonicGDKPackParticles.Particles.FlameParticleSystem'
    MagneticParticleSystem=ParticleSystem'SonicGDKPackParticles.Particles.MagneticParticleSystem'

    BubbleActionSound=SoundCue'SonicGDKPackSounds.BubbleActionSoundCue'
    FlameActionSound=SoundCue'SonicGDKPackSounds.FlameActionSoundCue'
    MagneticActionSound=SoundCue'SonicGDKPackSounds.MagneticActionSoundCue'

    BubblePickupSound=SoundCue'SonicGDKPackSounds.BubblePickupSoundCue'
    FlamePickupSound=SoundCue'SonicGDKPackSounds.FlamePickupSoundCue'
    MagneticPickupSound=SoundCue'SonicGDKPackSounds.MagneticPickupSoundCue'
    StandardPickupSound=SoundCue'SonicGDKPackSounds.StandardPickupSoundCue'
    PickupSoundDelay=1.0

    BubbleDamageType=class'SGDKDmgType_Bubble'
    FlameDamageType=class'SGDKDmgType_Flame'

    bSpecialMove=false
}
