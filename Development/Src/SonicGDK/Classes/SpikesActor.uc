//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Spikes Actor > BetterTouchActor > SGDKActor > Actor
//
// The Spikes Actor is the classic hazard found in all Sonic games.
// Players should avoid touching the pointy part of this group of spikes.
//================================================================================
class SpikesActor extends BetterTouchActor
    placeable;


/**The invisible sensor mesh that detects touching actors.*/ var() editconst SensorMeshComponent SensorMesh;
                 /**The sound to play when a pawn is hurt.*/ var() SoundCue SpikesSound;

                        /**If true, this actor is disabled.*/ var() bool bDisabled;
                  /**Stores the default value of bDisabled.*/ var bool bOldDisabled;
/**If true, walking pawns touching this actor are required.*/ var() bool bRequireWalkingPawn;
        /**Multiplier to apply to bounce impulse magnitude.*/ var() float BounceSpeedMultiplier;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    bOldDisabled = bDisabled;
}

/**
 * Is a pawn in condition to touch this actor?
 * @param P  the pawn involved in the touch
 * @return   true if pawn is a valid actor for touch events
 */
function bool IsValidTouchedBy(SGDKPawn P)
{
    local vector V;

    if (!bDisabled && super.IsValidTouchedBy(P))
    {
        if (!bRequireWalkingPawn)
            return true;
        else
            if (SGDKPlayerPawn(P).IsTouchingGround())
            {
                V = vect(0,0,1) >> Rotation;

                if (V.Z >= 0.0)
                    return (P.Location.Z > Location.Z);
                else
                    return (P.Location.Z < Location.Z);
            }
    }

    return false;
}

/**
 * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
 * @param Action  the related Kismet sequence action
 */
function OnToggle(SeqAct_Toggle Action)
{
    if (Action.InputLinks[0].bHasImpulse)
        bDisabled = false;
    else
        if (Action.InputLinks[1].bHasImpulse)
            bDisabled = true;
        else
            bDisabled = !bDisabled;
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    bDisabled = bOldDisabled;
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    P.TakeDamage(1,none,Location,(vect(0,0,1) >> Rotation) * (BounceSpeedMultiplier * 500.0),
                 class'SGDKDmgType_Spikes',,self);

    if (SpikesSound != none && SGDKPlayerPawn(P).LastDamageTime == WorldInfo.TimeSeconds)
        P.PlaySound(SpikesSound);
}


defaultproperties
{
    Begin Object Class=SensorMeshComponent Name=SensorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.SpikesMaterialB'
        Scale=1.0
        Scale3D=(X=1.75,Y=1.75,Z=1.0)
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
    SensorMesh=SensorStaticMesh
    Components.Add(SensorStaticMesh)


    Begin Object Class=StaticMeshComponent Name=SpikeStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SpikeStaticMesh'
        bAcceptsDecals=false
        bAcceptsDynamicLights=false
        bAcceptsLights=false
        bAcceptsStaticDecals=false
        bCastDynamicShadow=false
        bNeverBecomeDynamic=true
        BlockActors=false
        BlockRigidBody=false
        CastShadow=false
        CollideActors=false
        HiddenGame=true
        Scale=1.0
    End Object
    Components.Add(SpikeStaticMesh)


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bMovable=true              //Actor can be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPathColliding=false       //Doesn't block paths during AI path building in the editor. 
    bPushedByEncroachers=false //Whether encroachers can push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    TouchedByInterval=0.15

    SpikesSound=SoundCue'SonicGDKPackSounds.SpikesDamageSoundCue'

    bDisabled=false
    bRequireWalkingPawn=false
    BounceSpeedMultiplier=1.0
}
