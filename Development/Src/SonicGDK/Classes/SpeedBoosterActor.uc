//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Speed Booster Actor > BetterTouchActor > SGDKActor > Actor
//
// The Speed Booster Actor is the dash panel found in all modern Sonic games.
// Players should trot over the surface for an instant speed boost.
//================================================================================
class SpeedBoosterActor extends BetterTouchActor
    placeable;


                        /**The speed booster visible mesh.*/ var() editconst StaticMeshComponent BoosterMesh;
/**The invisible sensor mesh that detects touching actors.*/ var() editconst SensorMeshComponent SensorMesh;

                  /**If true, the impulse is applied to falling pawns too.*/ var() bool bPushFallingPawns;
                     /**If true, the impulse also rotates the camera view.*/ var() bool bRotateView;
                   /**The sound played when this speed booster is touched.*/ var() SoundCue BoosterSound;
/**How much time the player is forced to run forward (turning is enabled).*/ var() float DisabledInputTime;
                                    /**The speed magnitude of the impulse.*/ var() float ImpulseSpeed;


/**
 * Is a pawn in condition to touch this actor?
 * @param P  the pawn involved in the touch
 * @return   true if pawn is a valid actor for touch events
 */
function bool IsValidTouchedBy(SGDKPawn P)
{
    return (super.IsValidTouchedBy(P) && !SGDKPlayerPawn(P).WillBeBounced() &&
            (SGDKPlayerPawn(P).IsTouchingGround() || (bPushFallingPawns && P.Physics == PHYS_Falling)));
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    local SGDKPlayerPawn APawn;
    local vector HitLocation,HitNormal;
    local Actor HitActor;

    APawn = SGDKPlayerPawn(P);

    if (!APawn.IsTouchingGround())
    {
        HitActor = APawn.Trace(HitLocation,HitNormal,
                               APawn.Location + (vect(0,0,-1) >> Rotation) * (APawn.GetCollisionHeight() * 2.0),
                               APawn.Location,true,,,TRACEFLAG_Blocking);

        if (HitActor != none && APawn.IsSonicPhysicsAllowed(HitActor))
        {
            APawn.TriggerLanded(HitNormal,HitActor);

            APawn.ForceRotation(Rotation,bRotateView,true);

            APawn.FloorNormal = HitNormal;
            APawn.SetSonicPhysics(true);
            APawn.SetBase(HitActor);
        }
        else
            return;
    }
    else
        APawn.ForceRotation(Rotation,bRotateView,true);

    APawn.HighSpeedBoost(ImpulseSpeed,true,DisabledInputTime);

    if (BoosterSound != none)
        APawn.PlaySound(BoosterSound);
}


defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=BoosterActorMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SpeedBoosterStaticMesh'
        bAllowApproximateOcclusion=true
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=true
        BlockActors=false
        BlockRigidBody=false
        CastShadow=true
        CollideActors=false
        MaxDrawDistance=9000.0
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=-8.0)
    End Object
    BoosterMesh=BoosterActorMesh
    Components.Add(BoosterActorMesh)


    Begin Object Class=SensorMeshComponent Name=SensorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.SpeedBoosterMaterialC'
        Scale=1.0
        Scale3D=(X=4.0,Y=2.0,Z=0.8)
        Translation=(X=0.0,Y=0.0,Z=1.0)
    End Object
    SensorMesh=SensorStaticMesh
    Components.Add(SensorStaticMesh)


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bMovable=false             //Actor can't be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPushedByEncroachers=false //Encroachers can't push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    TouchedByInterval=0.33

    bPushFallingPawns=false
    bRotateView=true
    BoosterSound=SoundCue'SonicGDKPackSounds.SpeedBoosterSoundCue'
    DisabledInputTime=0.7
    ImpulseSpeed=1.0
}
