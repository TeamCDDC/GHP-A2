//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Pushable Karma Actor > SGDKKActor > UTKActor > UDKKActorBreakable > KActor >
//     > DynamicSMActor > Actor
//
// A KActor is a static mesh that uses rigid body calculations for physics
// simulation: position, rotation, linear and angular velocities...
// This subclass is pushable.
//================================================================================
class PushableKActor extends SGDKKActor
    ClassGroup(SGDK,Visible)
    placeable;


/**The invisible sensor mesh that detects touching actors.*/ var() editconst SensorMeshComponent SensorMesh;

/**Stores the pawns that are touching this actor.*/ var array<SGDKPlayerPawn> TouchedByPawns;

/**Stores default value of bLimitMaxPhysicsVelocity.*/ var bool bDefaultLimitVelocity;
     /**Stores default value of CustomGravityFactor.*/ var float DefaultGravityFactor;
      /**Stores default value of MaxPhysicsVelocity.*/ var float DefaultMaxVelocity;

    /**If true, this actor keeps its initial rotation while being pushed.*/ var() bool bConstrainRotation;
                           /**If true, pushing mini-pawns aren't allowed.*/ var() bool bDisallowMiniPawn;
/**If true, the pushing pawn is used as the shadow parent for this actor.*/ var() bool bShadowParent;
  /**If true, removes motion inertia after the pushing pawn stops moving.*/ var() bool bStopAfterPush;
                 /**This actor can keep this rotation while being pushed.*/ var rotator ConstantRotation;
                         /**If true, this actor has been pushed recently.*/ var bool bPushed;
                                      /**The pushing speed of this actor.*/ var() float PushSpeed;
   /**Spherical radius used to determine if a pawn isn't nearby any more.*/ var float UnTouchRadius;


/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    bDefaultLimitVelocity = bLimitMaxPhysicsVelocity;
    DefaultGravityFactor = CollisionComponent.GetRootBodyInstance().CustomGravityFactor * 2.0;
    DefaultMaxVelocity = MaxPhysicsVelocity;

    CollisionComponent.GetRootBodyInstance().CustomGravityFactor = DefaultGravityFactor;
}

/**
 * Called when the actor falls out of the world 'safely' (below KillZ and such).
 * @param DamageClass  the type of damage
 */
simulated event FellOutOfWorld(class<DamageType> DamageClass)
{
    SetPhysics(PHYS_None);
    SetHidden(true);
    SetCollision(false,false);

    if (CollisionComponent != none)
        CollisionComponent.SetBlockRigidBody(false);
}

/**
 * Called when the actor enters a new physics volume; delegated to states.
 * @param NewVolume  the new physics volume in which the actor is standing in
 */
event PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if (!NewVolume.bWaterVolume)
    {
        CollisionComponent.GetRootBodyInstance().CustomGravityFactor = DefaultGravityFactor;

        CollisionComponent.RetardRBLinearVelocity(vect(0,0,1),0.0);
        CollisionComponent.RetardRBLinearVelocity(vect(0,0,-1),0.0);
    }
    else
    {
        CollisionComponent.GetRootBodyInstance().CustomGravityFactor = DefaultGravityFactor * NewVolume.FluidFriction;

        CollisionComponent.RetardRBLinearVelocity(vect(0,0,1),1.0 - NewVolume.FluidFriction);
        CollisionComponent.RetardRBLinearVelocity(vect(0,0,-1),1.0 - NewVolume.FluidFriction);

        CollisionComponent.SetRBLinearVelocity(Velocity * (NewVolume.FluidFriction * NewVolume.FluidFriction),false);
    }
}

/**
 * Called for PendingTouch actor after the native physics step completes.
 * @param Other  the other actor involved in the previous touch event
 */
event PostTouch(Actor Other)
{
    local int i;
    local SGDKPlayerPawn P;

    P = SGDKPlayerPawn(Other);

    if (P != none && P.Health > 0 && P.Physics != PHYS_None && P.DrivenVehicle == none)
    {
        if (TouchedByPawns.Length > 0)
            for (i = 0; i < TouchedByPawns.Length; i++)
                if (TouchedByPawns[i] != none && TouchedByPawns[i] == P)
                {
                    P = none;
                    break;
                }

        if (P != none)
        {
            TouchedByPawns.AddItem(P);
            UnTouchRadius = FMax(UnTouchRadius,VSize(Location - P.Location) * 1.414);

            P.SetPushRigidBodies(false);

            ConstantRotation = CollisionComponent.GetRotation();

            if (bShadowParent)
                CollisionComponent.SetShadowParent(P.Mesh);

            Enable('Tick');
        }
    }
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    local bool bMoved,bTouchingPawns;
    local int i;
    local vector TraceEnd,HitLocation,HitNormal;
    local rotator R;

    if (TouchedByPawns.Length > 0)
    {
        for (i = 0; i < TouchedByPawns.Length; i++)
            if (TouchedByPawns[i] != none)
            {
                if (VSizeSq(Location - TouchedByPawns[i].Location) < Square(UnTouchRadius))
                {
                    if (TouchedByPawns[i].PushableActor == self && TouchedByPawns[i].Push())
                    {
                        if (!TouchedByPawns[i].bReverseGravity)
                            TraceEnd = Location + vect(0,0,-1) * UnTouchRadius;
                        else
                            TraceEnd = Location + vect(0,0,1) * UnTouchRadius;

                        if (Trace(HitLocation,HitNormal,TraceEnd,Location,true,
                                  vect(1,1,1) * TouchedByPawns[i].GetCollisionRadius(),,TRACEFLAG_Blocking) != none)
                        {
                            bMoved = true;

                            if (!bPushed)
                                TriggerEventClass(class'SeqEvent_TouchAccepted',TouchedByPawns[i],0);

                            bLimitMaxPhysicsVelocity = true;
                            bPushed = true;
                            MaxPhysicsVelocity = GetPushSpeed();

                            if (bConstrainRotation)
                            {
                                R = ConstantRotation;
                                ConstantRotation = CollisionComponent.GetRotation();
                                ConstantRotation.Yaw = R.Yaw;

                                CollisionComponent.SetRBRotation(ConstantRotation);
                            }

                            CollisionComponent.SetRBLinearVelocity(TouchedByPawns[i].GetVelocity(),false);
                        }
                    }

                    if (!bMoved)
                    {
                        bLimitMaxPhysicsVelocity = bDefaultLimitVelocity;
                        MaxPhysicsVelocity = DefaultMaxVelocity;

                        if (bPushed && bStopAfterPush)
                        {
                            bPushed = false;

                            if (bConstrainRotation)
                            {
                                R = ConstantRotation;
                                ConstantRotation = CollisionComponent.GetRotation();
                                ConstantRotation.Yaw = R.Yaw;

                                CollisionComponent.SetRBRotation(ConstantRotation);
                            }

                            CollisionComponent.SetRBLinearVelocity(vect(0,0,0));
                            CollisionComponent.SetRBAngularVelocity(vect(0,0,0));
                        }
                    }

                    bTouchingPawns = true;
                }
                else
                {
                    TouchedByPawns[i].SetPushRigidBodies(true);

                    TouchedByPawns[i] = none;
                }
            }

        if (!bTouchingPawns)
            TouchedByPawns.Length = 0;
    }
    else
    {
        bLimitMaxPhysicsVelocity = bDefaultLimitVelocity;
        bPushed = false;
        MaxPhysicsVelocity = DefaultMaxVelocity;

        if (bShadowParent)
            CollisionComponent.SetShadowParent(none);

        Disable('Tick');
    }
}

/**
 * Called when collision with another actor happens; also called every tick that the collision still occurs.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitLocation     the world location where the touch occurred
 * @param HitNormal       the surface normal of this actor where the touch occurred
 */
event Touch(Actor Other,PrimitiveComponent OtherComponent,vector HitLocation,vector HitNormal)
{
    if (SGDKPlayerPawn(Other) != none)
    {
        PendingTouch = Other.PendingTouch;
        Other.PendingTouch = self;
    }
}

/**
 * Is this actor allowed to show effects when entering a water volume?
 * @return  true if effects are allowed
 */
simulated function bool CanSplash()
{
    return true;
}

/**
 * Gets the pushing direction of this object.
 * @param HitNormal  the surface normal of this actor where the touch occurred
 * @return           pushing direction of this actor
 */
function vector GetPushDirection(vector HitNormal)
{
    local float Angle;

    HitNormal = Normal(HitNormal * vect(-1,-1,0));

    if (bConstrainRotation)
    {
        Angle = Atan2(HitNormal.Y,HitNormal.X);

        if (Abs(Angle) < 0.393)
            HitNormal = vect(1,0,0);
        else
            if (Abs(Angle) > 2.749)
                HitNormal = vect(-1,0,0);
            else
                if (Angle > 0.0)
                {
                    if (Angle < 1.178)
                        HitNormal = vect(0.707107,0.707107,0.0);
                    else
                        if (Angle > 1.964)
                            HitNormal = vect(-0.707107,0.707107,0.0);
                        else
                            HitNormal = vect(0,1,0);
                }
                else
                {
                    if (Angle > -1.178)
                        HitNormal = vect(0.707107,-0.707107,0.0);
                    else
                        if (Angle < -1.964)
                            HitNormal = vect(-0.707107,-0.707107,0.0);
                        else
                            HitNormal = vect(0,-1,0);
                }
    }

    return HitNormal;
}

/**
 * Gets the pushing speed of this object.
 * @return  pushing speed of this actor
 */
function float GetPushSpeed()
{
    return PushSpeed;
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
simulated function Reset()
{
    if (bHidden)
    {
        SetLocation(InitialLocation);
        SetRotation(InitialRotation);

        SetHidden(false);

        SetPhysics(PHYS_RigidBody);

        SetCollision(true,true);

        if (CollisionComponent != none)
            CollisionComponent.SetBlockRigidBody(true);
    }

    super.Reset();

    if (TouchedByPawns.Length > 0)
    {
        TouchedByPawns.Length = 0;

        bLimitMaxPhysicsVelocity = bDefaultLimitVelocity;
        bPushed = false;
        MaxPhysicsVelocity = DefaultMaxVelocity;

        if (bShadowParent)
            CollisionComponent.SetShadowParent(none);

        Disable('Tick');
    }
}


defaultproperties
{
    Begin Object Name=MyLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object


    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.PushableStaticMesh'
    End Object
    CollisionComponent=StaticMeshComponent0
    StaticMeshComponent=StaticMeshComponent0


    Begin Object Class=SensorMeshComponent Name=SensorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.PushableMaterial'
        Scale=4.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    SensorMesh=SensorStaticMesh
    Components.Add(SensorStaticMesh)


    SupportedEvents.Add(class'SeqEvent_TouchAccepted')


    bCanStepUpOn=false
    bNoEncroachCheck=false
    bPawnCanBaseOn=true

    bConstrainRotation=true
    bDisallowMiniPawn=false
    bPushed=false
    bShadowParent=true
    bStopAfterPush=true
    PushSpeed=75.0
}
