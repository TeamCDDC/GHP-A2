//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Board Sphere Actor > BetterTouchActor > SGDKActor > Actor
//
// This actor is a (usually spherical) pickup placed on the Board Special Stage.
//================================================================================
class BoardSphereActor extends BetterTouchActor
    abstract;


            /**The sphere visual static mesh.*/ var StaticMeshComponent SphereMesh;
/**The material instance to change its color.*/ var MaterialInstanceConstant MeshMaterialInstance;
        /**The associated collision cylinder.*/ var CylinderComponent CylinderComponent;

/**Sound played when touched.*/ var SoundCue TouchSound;

/**Dummy clones of this pickup.*/ var array<BoardSphereActor> SphereClones;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    local float Distance,MaxX,MaxY,MinX,MinY;
    local int i,j;
    local vector V;

    super.PostBeginPlay();

    if (BoardSpecialStage(Owner) != none)
    {
        Distance = BoardSpecialStage(Owner).SquareDistance;

        MaxX = Owner.Location.X + 24.5 * Distance;
        MinX = Owner.Location.X - 25.5 * Distance;
        MaxY = Owner.Location.Y + 24.5 * Distance;
        MinY = Owner.Location.Y - 25.5 * Distance;

        Distance *= 32.0;

        for (i = 0; i < 3; i++)
            for (j = 0; j < 3; j++)
                if (i != 1 || j != 1)
                {
                    V = Location + vect(1,1,0) * (-Distance) + vect(1,0,0) * (i * Distance) + vect(0,1,0) * (j * Distance);

                    if (V.X > MinX && V.X < MaxX && V.Y > MinY && V.Y < MaxY)
                        SphereClones[SphereClones.Length] = Spawn(Class,self,,V);
                }
    }
    else
        if (BoardSphereActor(Owner) != none)
            SetCollision(false,false);
}

/**
 * Called immediately before destroying this actor.
 */
event Destroyed()
{
    local int i;

    for (i = 0; i < SphereClones.Length; i++)
        if (SphereClones[i] != none)
            SphereClones[i].Destroy();

    super.Destroyed();
}

/**
 * Hides, deactivates and destroys this actor.
 */
function HideAndDestroy()
{
    local int i;

    SetCollision(false,false);
    SetHidden(true);

    LifeSpan = 1.0;

    for (i = 0; i < SphereClones.Length; i++)
        if (SphereClones[i] != none)
            SphereClones[i].SetHidden(true);
}

/**
 * Is a pawn in condition to touch this actor?
 * @param P  the pawn involved in the touch
 * @return   true if pawn is a valid actor for touch events
 */
function bool IsValidTouchedBy(SGDKPawn P)
{
    return (super.IsValidTouchedBy(P) && P.Physics == PHYS_Walking);
}

/**
 * Transforms this actor into a ring item.
 */
function TransformIntoRing()
{
    local BoardSphereActorRing Ring;
    local SGDKPawn P;

    HideAndDestroy();

    Ring = Spawn(class'BoardSphereActorRing',Owner,,Location,Rotation);

    foreach Ring.TouchingActors(class'SGDKPawn',P)
        Ring.Touch(P,P.CollisionComponent,vect(0,0,0),vect(0,0,0));
}


defaultproperties
{
    Begin Object Class=CylinderComponent Name=CollisionCylinder
        CollideActors=true
        CollisionHeight=1.0
        CollisionRadius=20.0
    End Object
    CollisionComponent=CollisionCylinder
    CylinderComponent=CollisionCylinder
    Components.Add(CollisionCylinder)


    Begin Object Class=StaticMeshComponent Name=SphereStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SphereStaticMesh'
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.SpecialBoardSphereMaterial'
        bAcceptsDynamicDecals=false
        bAcceptsDynamicLights=false
        bAcceptsLights=false
        bAcceptsStaticDecals=false
        bCastDynamicShadow=false
        bForceDirectLightMap=true
        bUseAsOccluder=true
        bUsePrecomputedShadows=false
        BlockActors=false
        BlockRigidBody=false
        BoundsScale=10.0
        CastShadow=false
        CollideActors=false
        Scale=0.75
        Scale3D=(X=1.0,Y=1.0,Z=1.0)
    End Object
    SphereMesh=SphereStaticMesh
    Components.Add(SphereStaticMesh)


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bIgnoreEncroachers=true    //Ignore collisions between movers and this actor.
    bMovable=true              //Actor can be moved.
    bNoDelete=false            //Can be deleted during play.
    bPushedByEncroachers=false //Encroachers can't push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.

    TouchSound=SoundCue'SonicGDKPackSounds.RingSoundCue'
}
