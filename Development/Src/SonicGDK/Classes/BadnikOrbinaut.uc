//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Badnik Orbinaut > EnemyPawnFlying > SGDKEnemyPawn > SGDKPawn > UTPawn >
//     > UDKPawn > GamePawn > Pawn > Actor
//
// The Pawn is the base class of all actors that can be controlled by players or
// artificial intelligence (AI).
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision and physics. Pawns can take damage, make sounds,
// and hold weapons and other inventory. In short, they are responsible for all
// physical interaction between the player or AI and the world.
// This type belongs to the Orbinaut, a hovering spherical enemy surrounded by
// spiked balls.
//================================================================================
class BadnikOrbinaut extends EnemyPawnFlying
    placeable;


/**If true, default physics mode for this pawn is PHYS_Interpolating.*/ var(Template,Orbinaut) bool bPhysInterpolating;

             /**If true, the XY plane is used for orbiting
                     spiked balls, instead of the XZ plane.*/ var(Template,Orbinaut) bool bHorizontalOrbit;
/**If true, spiked balls are thrown when noticing a player.*/ var(Template,Orbinaut) bool bThrowBalls;
                     /**Orbital radius of the spiked balls.*/ var(Template,Orbinaut) float OrbitRadius;
                      /**Orbital speed of the spiked balls.*/ var(Template,Orbinaut) float OrbitSpeed;
                         /**Mesh used for the spiked balls.*/ var(Template,Orbinaut) StaticMesh SpikedBallMesh;
                       /**Amount of spiked balls to create.*/ var(Template,Orbinaut) byte SpikedBalls;
                       /**Throws speed of the spiked balls.*/ var(Template,Orbinaut) float ThrowSpeed;

/**Class used for the spiked balls.*/ var class<SpikedBallProjectile> SpikedBallClass;


/**
 * Called immediately before gameplay begins.
 */
simulated event PreBeginPlay()
{
    local BadnikOrbinaut PawnTemplate;

    super.PreBeginPlay();

    if (!IsTemplate() && EnemySpawner.PawnTemplate != none)
    {
        PawnTemplate = BadnikOrbinaut(EnemySpawner.PawnTemplate);

        if (PawnTemplate != none)
        {
            bPhysInterpolating = PawnTemplate.bPhysInterpolating;

            bHorizontalOrbit = PawnTemplate.bHorizontalOrbit;
            bThrowBalls = PawnTemplate.bThrowBalls;
            OrbitRadius = PawnTemplate.OrbitRadius;
            OrbitSpeed = PawnTemplate.OrbitSpeed;
            SpikedBallMesh = PawnTemplate.SpikedBallMesh;
            SpikedBalls = PawnTemplate.SpikedBalls;
            ThrowSpeed = PawnTemplate.ThrowSpeed;
        }

        if (bPhysInterpolating)
            DefaultPhysics = PHYS_Interpolating;
    }
}

/**
 * Called immediately after gameplay begins.
 */
simulated event PostBeginPlay()
{
    local int i;
    local float Angle;
    local vector V;

    super.PostBeginPlay();

    if (!IsTemplate())
    {
        Mesh.bCastDynamicShadow = true;
        ReattachComponent(Mesh);

        if (SpikedBalls > 0)
        {
            i = 0;

            while (i < SpikedBalls)
            {
                Angle = Pi * 2.0 * i / SpikedBalls;
                V = Location;

                V.X += Cos(Angle) * OrbitRadius;

                if (!bHorizontalOrbit)
                    V.Z += Sin(Angle) * OrbitRadius;
                else
                    V.Y += Sin(Angle) * OrbitRadius;

                Spawn(SpikedBallClass,self,,V,Rotation);

                i++;
            }
        }
    }
}


defaultproperties
{
    Begin Object Name=WPawnSkeletalMeshComponent
        AnimSets[0]=AnimSet'SonicGDKPackSkeletalMeshes.Animation.OrbinautAnimSet'
        AnimTreeTemplate=AnimTree'SonicGDKPackSkeletalMeshes.Animation.OrbinautAnimTree'
        PhysicsAsset=PhysicsAsset'SonicGDKPackSkeletalMeshes.PhysicsAssets.OrbinautPhysicsAsset'
        SkeletalMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.OrbinautSkeletalMesh'
        bCastDynamicShadow=false
        BoundsScale=2.5
        Scale=1.0
    End Object
    Mesh=WPawnSkeletalMeshComponent
    VisibleMesh=WPawnSkeletalMeshComponent


    Begin Object Name=CollisionCylinder
        CollisionHeight=20.0
        CollisionRadius=20.0
    End Object
    CollisionMesh=CollisionCylinder
    CylinderComponent=CollisionCylinder


    WeakSpots.Empty
    WeakSpots.Add((Offset=(X=0,Y=0,Z=30),Socket=Main))

    bHorizontalOrbit=false
    bThrowBalls=false
    OrbitRadius=50.0
    OrbitSpeed=2.5
    SpikedBallClass=class'SpikedBallProjectile'
    SpikedBallMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.SpikedBallStaticMesh'
    SpikedBalls=4
    ThrowSpeed=250.0
}
