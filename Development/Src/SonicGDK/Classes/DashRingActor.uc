//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Dash Ring Actor > BetterTouchActor > SGDKActor > Actor
//
// The Dash Ring Actor is the dash ring object found in modern Sonic games.
// Players should pass through the ring to get catapulted into the air.
//================================================================================
class DashRingActor extends BetterTouchActor
    implements(DestroyableEntity)
    placeable;


/**The dash ring visual static mesh.*/ var() editconst StaticMeshComponent DashRingMesh;

                        /**If true, can be a possible target for Homing Dash move.*/ var() bool bHomingDash;
/**The Homing Dash target location will offset from this spring using this vector.*/ var() vector HomingLocationOffset;
  /**How much air control the player should have while in the air off this spring.*/ var() float JumpAirControl;
                                  /**The sound played when this spring is touched.*/ var() SoundCue JumpSound;
                                            /**The speed magnitude of the impulse.*/ var() float JumpSpeed;
                 /**The name of the animation that the catapulted pawns will play.*/ var() name PawnAnimName;


/**
 * Gets the location to where a Homing Dash special move must go.
 * @param APawn  the pawn that tries to destroy this object
 * @return       location of a vulnerable point
 */
function vector GetHomingLocation(SGDKPlayerPawn APawn)
{
    return (Location + (HomingLocationOffset >> Rotation));
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
    return bHomingDash;
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    local SGDKPlayerPawn APawn;

    APawn = SGDKPlayerPawn(P);

    APawn.AerialBoost((vect(0,0,1) >> Rotation) * (JumpSpeed * 1000.0),
                      APawn.Physics == PHYS_Falling,self,'DashRing');

    P.MoveSmooth((Location - APawn.Location) * 0.25);

    APawn.AirControl *= JumpAirControl;
    APawn.Acceleration = vect(0,0,0);

    if (JumpSound != none)
        APawn.PlaySound(JumpSound);

    if (PawnAnimName != '')
        APawn.StartAnimation(PawnAnimName,1.0,0.0,0.1,false,true);
}


defaultproperties
{
    Begin Object Class=ArrowComponent Name=Arrow
        bTreatAsASprite=true
        ArrowSize=1.5
        Rotation=(Pitch=16384,Yaw=0,Roll=0)
    End Object
    Components.Add(Arrow)


    Begin Object Class=StaticMeshComponent Name=DashRingStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.DashRingStaticMesh'
        bAllowApproximateOcclusion=true
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=true
        BlockActors=true
        BlockRigidBody=true
        CanBlockCamera=false
        CastShadow=true
        CollideActors=true
        MaxDrawDistance=9000.0
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
    DashRingMesh=DashRingStaticMesh
    Components.Add(DashRingStaticMesh)


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bEdShouldSnap=true         //It snaps to the grid in the editor.
    bMovable=false             //Actor can't be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPushedByEncroachers=false //Encroachers can't push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    bHomingDash=false
    HomingLocationOffset=(X=0.0,Y=0.0,Z=0.0)
    JumpAirControl=0.5
    JumpSound=SoundCue'SonicGDKPackSounds.DashRingSoundCue'
    JumpSpeed=1.0
    PawnAnimName=Spring
}
