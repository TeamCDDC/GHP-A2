//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Bumper Actor > SGDKActor > Actor
//
// The Bumper Actor is the round bumper found in some of the classic Sonic games.
// Players are bounced off harshly when touching this actor.
//================================================================================
class BumperActor extends SGDKActor
    placeable;


/**The bumper visual static mesh.*/ var() editconst StaticMeshComponent BumperMesh;

/**Multiplier to apply to air control of bounced pawns.*/ var() float AirControlMultiplier;
    /**Multiplier to apply to bounce impulse magnitude.*/ var() float BounceSpeedMultiplier;
    /**Counts the amount of bumps this bumper receives.*/ var int BumpCount;
                      /**The sound played when touched.*/ var() SoundCue BumpSound;
        /**The default scale of the visual static mesh.*/ var float OriginalMeshScale;
 /**Score bonus is granted when this bumper is touched.*/ var() int ScoreBonus;
        /**Score bonus is granted this number of times.*/ var() int ScoreTimes;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    OriginalMeshScale = BumperMesh.Scale;
}

/**
 * Called when another actor is attached to this actor.
 * @param Other  the other actor that is attached
 */
event Attach(Actor Other)
{
    local SGDKPlayerPawn P;

    P = SGDKPlayerPawn(Other);

    if (P != none)
        Bump(P,CollisionComponent,P.GetFloorNormal());
}

/**
 * Called only once when collision with another blocking actor happens.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitNormal       the surface normal of this actor where the bump occurred
 */
event Bump(Actor Other,PrimitiveComponent OtherComponent,vector HitNormal)
{
    local SGDKPlayerPawn P;

    P = SGDKPlayerPawn(Other);

    if (P != none && P.Bounce(HitNormal * (BounceSpeedMultiplier * 1000.0),true,false,false,self,'Bumper'))
    {
        BumpCount++;

        P.AirControl *= AirControlMultiplier;

        if (BumpSound != none)
            P.PlaySound(BumpSound);

        if (BumpCount <= ScoreTimes && P.Controller != none)
            SGDKPlayerController(P.Controller).AddScore(ScoreBonus);

        BumperMesh.SetScale(OriginalMeshScale * 0.5);

        TriggerEventClass(class'SeqEvent_TouchAccepted',P,0);

        Enable('Tick');
    }
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    if (BumperMesh.Scale < OriginalMeshScale)
        BumperMesh.SetScale(FMin(BumperMesh.Scale + OriginalMeshScale * DeltaTime,OriginalMeshScale));
    else
        Disable('Tick');
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    BumpCount = 0;

    if (BumperMesh.Scale < OriginalMeshScale)
    {
        BumperMesh.SetScale(OriginalMeshScale);

        Disable('Tick');
    }
}


defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=BumperActorMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.BumperStaticMesh'
        bAllowApproximateOcclusion=true
        bCastDynamicShadow=true
        bForceDirectLightMap=true
        bUsePrecomputedShadows=true
        BlockActors=true
        BlockRigidBody=true
        CastShadow=true
        CollideActors=true
        MaxDrawDistance=9000.0
        Scale=1.0
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    CollisionComponent=BumperActorMesh
    BumperMesh=BumperActorMesh
    Components.Add(BumperActorMesh)


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

    AirControlMultiplier=0.5
    BounceSpeedMultiplier=0.66
    BumpSound=SoundCue'SonicGDKPackSounds.BumperSoundCue'
    ScoreBonus=10
    ScoreTimes=10
}
