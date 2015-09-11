//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Spiked Ball Actor > SGDKActor > Actor
//
// The Spiked Ball Actor is a hazard found in many Sonic games.
// Players should avoid touching the spikes around this ball.
//================================================================================
class SpikedBallActor extends SGDKActor
    placeable;


   /**The spiked ball visual static mesh.*/ var() editconst StaticMeshComponent SpikedBallMesh;
/**The sound to play when a pawn is hurt.*/ var() SoundCue SpikedBallSound;

/**Multiplier to apply to bounce impulse magnitude.*/ var() float BounceSpeedMultiplier;
                   /**Last time a sound was played.*/ var float LastSoundTime;


/**
 * Called only once when collision with another blocking actor happens.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitNormal       the surface normal of this actor where the bump occurred
 */
event Bump(Actor Other,PrimitiveComponent OtherComponent,vector HitNormal)
{
    local SGDKPlayerPawn P;
    local vector V;

    P = SGDKPlayerPawn(Other);

    if (P != none)
    {
        V = Normal(P.Location - Location) * (BounceSpeedMultiplier * 500.0);

        P.TakeDamage(1,none,Location,V,class'SGDKDmgType_Spikes',,self);

        if (P.LastDamageTime != WorldInfo.TimeSeconds)
            P.Bounce(V,true,false,false,self,'Damage');

        if (SpikedBallSound != none && WorldInfo.TimeSeconds - LastSoundTime > 0.1)
        {
            LastSoundTime = WorldInfo.TimeSeconds;

            P.PlaySound(SpikedBallSound);
        }

        TriggerEventClass(class'SeqEvent_TouchAccepted',P,0);
    }
}


defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=BallStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.GiantSpikedBallStaticMesh'
        bAllowApproximateOcclusion=true
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=true
        BlockActors=true
        BlockRigidBody=true
        CollideActors=true
        MaxDrawDistance=9000.0
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    CollisionComponent=BallStaticMesh
    SpikedBallMesh=BallStaticMesh
    Components.Add(BallStaticMesh)


    SupportedEvents.Add(class'SeqEvent_TouchAccepted')


    bBlockActors=true          //Blocks other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bIgnoreEncroachers=true    //Ignore collisions between movers and this actor.
    bMovable=false             //Actor can't be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPathColliding=true        //Blocks paths during AI path building in the editor. 
    bPushedByEncroachers=false //Whether encroachers can push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    SpikedBallSound=SoundCue'SonicGDKPackSounds.SpikesDamageSoundCue'

    BounceSpeedMultiplier=1.0
}
