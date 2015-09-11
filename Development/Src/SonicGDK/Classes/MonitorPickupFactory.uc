//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Monitor Pickup Factory > UTPickupFactory > UDKPickupFactory > PickupFactory >
//     > NavigationPoint > Actor
//
// Produces pickups when active and grants an item when touched.
// This class is the classic monitor found in most classic Sonic games, represents
// the visual object which can be broken.
//================================================================================
class MonitorPickupFactory extends UTPickupFactory
    abstract
    ClassGroup(SGDK,Visible,Monitors)
    implements(DestroyableEntity)
    showcategories(Collision,Display);


/**The intact monitor visual static mesh.*/ var() editconst StaticMeshComponent MonitorMesh;
      /**The monitor's light environment.*/ var() editconst DynamicLightEnvironmentComponent MonitorLightEnvironment;

            /**The destroyed monitor visual static mesh.*/ var() StaticMeshComponent DestroyedMesh;
/**The particle system shown with the destroyed monitor.*/ var() ParticleSystem DestroyedParticleSystem;
           /**The sound played by the destroyed monitor.*/ var() SoundCue DestroyedSound;

/**If true, this monitor doesn't block movement.*/ var() bool bGhostCollision;
  /**Minimum speed used to bounce the destroyer.*/ var() float MinBounceSpeed;
                     /**Respawn after this time.*/ var() float RespawnTime;


/**
 * Called only once when collision with another blocking actor happens.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitNormal       the surface normal of this actor where the bump occurred
 */
event Bump(Actor Other,PrimitiveComponent OtherComponent,vector HitNormal)
{
    Touch(Other,OtherComponent,Location,HitNormal);
}

/**
 * A player pawn just destroyed this monitor.
 * @param P  the player pawn involved in the destruction
 */
function DestroyedBy(SGDKPlayerPawn P)
{
    local vector V;
    local float PawnSpeed;
    local SGDKEmitter MonitorEmitter;

    if (!bGhostCollision)
    {
        if (!P.ShouldPassThrough(self))
        {
            V = vect(0,0,1) >> Rotation;
            PawnSpeed = P.GetVelocity() dot V;

            if (PawnSpeed > 0.0)
                V *= MinBounceSpeed;
            else
                V *= FMax(MinBounceSpeed,PawnSpeed * -0.7);

            P.Bounce(V,false,true,true,self,'Monitor');
        }
        else
            P.OverrideVelocity();
    }

    if (DestroyedParticleSystem != none)
    {
        MonitorEmitter = Spawn(class'SGDKEmitter',self,,Location,Rotation);
        MonitorEmitter.SetTemplate(DestroyedParticleSystem,true);
    }
}

/**
 * Gets the location to where a Homing Dash special move must go.
 * @param APawn  the pawn that tries to destroy this object
 * @return       location of a vulnerable point
 */
function vector GetHomingLocation(SGDKPlayerPawn APawn)
{
    return (Location + (vect(0,0,50) >> Rotation));
}

/**
 * Initializes the pickup data.
 */
simulated function InitializePickup()
{
    bPredictRespawns = InventoryType.default.bPredictRespawns;
    MaxDesireability = InventoryType.default.MaxDesireability;
    bIsSuperItem = InventoryType.default.bDelayedSpawn;
}

/**
 * Can this object be destroyed by a certain pawn?
 * @param APawn  the pawn that tries to destroy this object
 * @return       true if this object is vulnerable to the pawn
 */
function bool IsDestroyableBy(SGDKPlayerPawn APawn)
{
    return false;
}

/**
 * Can this object be a target for Homing Dash special move?
 * @return  true if this object is a valid target for Homing Dash
 */
function bool IsHomingTarget()
{
    return false;
}

/**
 * Shows respawn effects.
 */
simulated function RespawnEffect()
{
}

/**
 * Hides pickup mesh and associated effects.
 */
simulated function SetPickupHidden()
{
    bCanBeDamaged = false;

    CollisionComponent.SetActorCollision(true,false);
    PickupMesh.SetActorCollision(true,false);
    PickupMesh.SetBlockRigidBody(false);

    if (DestroyedMesh != none)
        DestroyedMesh.SetHidden(false);

    super.SetPickupHidden();
}

/**
 * Shows pickup mesh and associated effects.
 */
simulated function SetPickupVisible()
{
    super.SetPickupVisible();

    CollisionComponent.SetActorCollision(true,!bGhostCollision);
    PickupMesh.SetActorCollision(true,!bGhostCollision);
    PickupMesh.SetBlockRigidBody(!bGhostCollision);

    if (DestroyedMesh != none)
        DestroyedMesh.SetHidden(true);

    bCanBeDamaged = true;
}

/**
 * Spawns an inventory item for a pawn.
 * @param P  the pawn which receives the inventory item
 */
function SpawnCopyFor(Pawn P)
{
    local Inventory Inv;

    if (DestroyedSound != none)
        P.PlaySound(DestroyedSound);

    P.MakeNoise(0.2);

    Inv = Spawn(InventoryType,self);
    if (Inv != none)
        MonitorInventory(Inv).NewOwner(P);
}

/**
 * Returns true if projectiles should call ProcessTouch() when they touch this actor.
 * @param P  the projectile involved in the touch
 * @return   true if the projectile should call ProcessTouch()
 */
simulated function bool StopsProjectile(Projectile P)
{
    return bCanBeDamaged;
}


//Intact pickup state; default state.
auto state Pickup
{
    event BeginState(name PreviousStateName)
    {
        SetPickupVisible();

        super.BeginState(PreviousStateName);
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
        local Pawn P;

        P = Pawn(Other);

        if (P != none && ValidTouch(P))
        {
            DestroyedBy(SGDKPlayerPawn(P));

            GiveTo(P);
        }
    }

    /**
     * Can this object be destroyed by a certain pawn?
     * @param APawn  the pawn that tries to destroy this object
     * @return       true if this object is vulnerable to the pawn
     */
    function bool IsDestroyableBy(SGDKPlayerPawn APawn)
    {
        return APawn.IsUsingMelee();
    }

    /**
     * Can this object be a target for Homing Dash special move?
     * @return  true if this object is a valid target for Homing Dash
     */
    function bool IsHomingTarget()
    {
        return true;
    }

    /**
     * Validates touch.
     * @param Other  the pawn that tries to pick up this object
     * @return       true if this object can be picked up
     */
    function bool ValidTouch(Pawn Other)
    {
        local SGDKPlayerPawn P;

        P = SGDKPlayerPawn(Other);

        if (Other == none || P == none)
            return false;
        else
            if (Other.Controller == none)
            {
                SetTimer(0.2,false,NameOf(RecheckValidTouch));

                return false;
            }
            else
                return (P.CanPickupActor(self) && (bGhostCollision ||
                       (P.IsUsingMelee() && !ClassIsChildOf(P.GetMeleeDamageType(),P.InvincibleDamageType))));
    }
}


//Destroyed state.
state Sleeping
{
Begin:
    if (RespawnTime > 0.0)
    {
        Sleep(RespawnTime);

Respawn:
        if (WorldInfo.TimeSeconds - LastRenderTime > 0.25)
        {
            RespawnEffect();

            GotoState('Pickup');
        }
        else
        {
            Sleep(1.0);

            Goto('Respawn');
        }
    }
}


defaultproperties
{
    Begin Object Name=CollisionCylinder
        CollideActors=false
        CollisionHeight=30.0
        CollisionRadius=1.0
    End Object


    Begin Object Name=PickupLightEnvironment
        bCastShadows=true
        bDynamic=false
        MinTimeBetweenFullUpdates=1.5
        ModShadowFadeoutTime=5.0
    End Object
    LightEnvironment=PickupLightEnvironment
    MonitorLightEnvironment=PickupLightEnvironment


    Begin Object Class=StaticMeshComponent Name=MonitorStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.MonitorIntactStaticMesh'
        LightEnvironment=PickupLightEnvironment
        bAllowApproximateOcclusion=true
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=false
        CastShadow=true
        BlockActors=true
        BlockNonZeroExtent=true
        BlockRigidBody=true
        BlockZeroExtent=true
        CanBlockCamera=true
        CollideActors=true
        MaxDrawDistance=9000.0
        Scale=1.1
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=-1.0)
    End Object
    MonitorMesh=MonitorStaticMesh
    PickupMesh=MonitorStaticMesh
    Components.Add(MonitorStaticMesh)


    Begin Object Class=StaticMeshComponent Name=MonitorStaticMeshB
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.MonitorDestroyedStaticMesh'
        LightEnvironment=PickupLightEnvironment
        bAllowApproximateOcclusion=true
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=false
        CastShadow=true
        CollideActors=false
        BlockActors=false
        BlockRigidBody=false
        HiddenEditor=true
        HiddenGame=true
        MaxDrawDistance=9000.0
        Scale=1.1
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=-1.0)
    End Object
    DestroyedMesh=MonitorStaticMeshB
    Components.Add(MonitorStaticMeshB)


    bBlockActors=true  //Blocks other nonplayer actors.
    bCanBeDamaged=true //It can take damage.

    bGhostCollision=false
    DestroyedParticleSystem=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_GeneralExplosion'
    DestroyedSound=SoundCue'SonicGDKPackSounds.MonitorBreakSoundCue'
    MinBounceSpeed=500.0
    RespawnTime=0.0
}
