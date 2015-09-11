//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Spline Actor > SplineActor > Actor
//
// This actor holds a spline component which can be used to create complex paths
// through a level, where each route can branch and merge.
//================================================================================
class SGDKSplineActor extends SplineActor
    ClassGroup(SGDK,Invisible)
    placeable;


/**The invisible sensor mesh that detects touching actors.*/ var() editconst SensorMeshComponent SensorMesh;

/**If true, camera faces pawn rotation on exiting path.*/ var() bool bRotateCameraOnExit;
                  /**Magnitude of the constraint force.*/ var() float ConstraintMagnitude;
   /**Type of constrained movement allowed in the path.*/ var() EConstrainedMovement ConstraintType;
  /**Minimum speed required to constrain pawn movement.*/ var() float MinSpeedConstraint;
             /**Number of rails added to the left side.*/ var() byte NumRailsLeft <ClampMin=0 | ClampMax=2>;
            /**Number of rails added to the right side.*/ var() byte NumRailsRight <ClampMin=0 | ClampMax=2>;
                             /**Distance between rails.*/ var() float RailDistanceOffset;

/**Amount of actors to create on startup.*/ var() int ActorsAmount;
/**Actor archetype used to create actors.*/ var() Actor ActorsArchetype;
             /**Amount of spawned actors.*/ var int SpawnedActors;

/**Used to cache the Light Dashable rings archetype.*/ var Actor CachedArchetype;

/**If true, the created actors are logged in files of
     Logs folder and can be copy-pasted to the editor.*/ var() bool bLogSpawnedActors;

       /**Resolution to draw the spline components at; only valid in game mode.*/ var(Debug) float DebugDrawResolution;
/**Scale to apply to tangets of the spline components; only valid in game mode.*/ var(Debug) float DebugTangentsScale;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    local LinearColor PointColor;
    local SplineConnection Connection;
    local float Alpha;

    super.PostBeginPlay();

    if (bDebug)
    {
        PointColor = MakeLinearColor(1.0,0.0,0.0,1.0);

        foreach Connections(Connection)
        {
            DrawDebugPoint(Location,5.0,MakeLinearColor(1.0,1.0,1.0,1.0),true);

            for (Alpha = DebugDrawResolution; Alpha < 1.0; Alpha += DebugDrawResolution)
                DrawDebugPoint(GetBezierCurvePoint(Location,
                    Location + GetWorldSpaceTangent() * DebugTangentsScale,Connection.ConnectTo.Location -
                    Connection.ConnectTo.GetWorldSpaceTangent() * DebugTangentsScale,
                    Connection.ConnectTo.Location,Alpha),
                    4.0,PointColor,true);

            if (Connection.ConnectTo.Connections.Length == 0)
                DrawDebugPoint(GetBezierCurvePoint(Location,
                    Location + GetWorldSpaceTangent() * DebugTangentsScale,Connection.ConnectTo.Location -
                    Connection.ConnectTo.GetWorldSpaceTangent() * DebugTangentsScale,
                    Connection.ConnectTo.Location,1.0),
                    4.0,PointColor,true);

            DrawDebugLine(Location,Location + GetWorldSpaceTangent() * DebugTangentsScale,0,255,0,true);
            DrawDebugLine(Connection.ConnectTo.Location,
                          Connection.ConnectTo.Location - Connection.ConnectTo.GetWorldSpaceTangent() * DebugTangentsScale,
                          0,0,255,true);
        }
    }
}

/**
 * Called for PendingTouch actor after the native physics step completes.
 * @param Other  the other actor involved in the previous touch event
 */
event PostTouch(Actor Other)
{
    local vector V;

    if (SGDKPlayerPawn(Other) != none)
    {
        V = vector(Rotation);

        PrevOrdered = GetBestConnectionInDirection(V * -1,true);
        NextOrdered = GetBestConnectionInDirection(V,false);

        SGDKPlayerPawn(Other).TouchedSpline(self);
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
    if (ConstraintType != CM_None && SGDKPlayerPawn(Other) != none)
    {
        PendingTouch = Other.PendingTouch;
        Other.PendingTouch = self;
    }
}

/**
 * Calculates the point in space where this spline should put you.
 * @param Spline          the spline curve
 * @param SplineDistance  distance traveled from spline origin
 * @return                location where this spline should put you
 */
static function vector CalculateLocation(SplineComponent Spline,float SplineDistance)
{
    if (Spline.SplineCurviness > 0.999)
        return Spline.Owner.Location + Normal(Spline.GetLocationAtDistanceAlongSpline(Spline.GetSplineLength()) -
                                              Spline.Owner.Location) * SplineDistance;
    else
        return Spline.GetLocationAtDistanceAlongSpline(SplineDistance);
}

/**
 * Calculates the distance covered by using the projection of a point to a spline curve.
 * @param Point          point to project onto the spline curve
 * @param Spline         the spline curve
 * @param bFromEndPoint  true if search process should start from the end point of the spline curve
 * @return               distance covered along the spline curve
 */
static function float CalculateSplineDistance(vector Point,SplineComponent Spline,optional bool bFromEndPoint)
{
    local float Alpha,Bisector,BisectorStep,SegmentLength,SplineDistance,SplineDistanceA,SplineDistanceB,SplineLength;
    local vector EndPoint,StartPoint,V;
    local int Iterations;

    SplineLength = Spline.GetSplineLength();

    EndPoint = Spline.GetLocationAtDistanceAlongSpline(SplineLength);
    StartPoint = Spline.Owner.Location;

    if (Spline.SplineCurviness > 0.999)
    {
        V = EndPoint - StartPoint;

        SplineDistance = FClamp((((Point - StartPoint) dot V) / VSizeSq(V)) * SplineLength,0.0,SplineLength);
    }
    else
    {
        SegmentLength = FMax(50.0,SplineLength * 0.05);

        SplineDistanceA = 0.0;
        SplineDistanceB = SplineLength;

        if (bFromEndPoint)
        {
            SplineDistanceA = FMax(0.0,SplineLength - SegmentLength);
            StartPoint = Spline.GetLocationAtDistanceAlongSpline(SplineDistanceA);
        }
        else
        {
            SplineDistanceB = FMin(SegmentLength,SplineLength);
            EndPoint = Spline.GetLocationAtDistanceAlongSpline(SplineDistanceB);
        }

        V = EndPoint - StartPoint;
        Alpha = ((Point - StartPoint) dot V) / VSizeSq(V);

        if (!bFromEndPoint && Alpha <= 0.0)
            SplineDistance = 0.0;
        else
            if (bFromEndPoint && Alpha >= 1.0)
                SplineDistance = SplineLength;
            else
                if (Alpha > 0.0 && Alpha < 1.0)
                    SplineDistance = SplineDistanceA + Alpha * (SplineDistanceB - SplineDistanceA);
                else
                {
                    Alpha = -1.0;
                    Bisector = 0.5;
                    BisectorStep = 0.25;

                    while (Alpha < 0.0 || Alpha > 1.0)
                    {
                        Iterations++;

                        SplineDistance = Bisector * SplineLength;

                        SplineDistanceA = FMax(0.0,SplineDistance - SegmentLength * 0.5);
                        SplineDistanceB = FMin(SplineDistance + SegmentLength * 0.5,SplineLength);

                        StartPoint = Spline.GetLocationAtDistanceAlongSpline(SplineDistanceA);
                        EndPoint = Spline.GetLocationAtDistanceAlongSpline(SplineDistanceB);

                        V = EndPoint - StartPoint;
                        Alpha = ((Point - StartPoint) dot V) / VSizeSq(V);

                        if (Iterations < 7)
                        {
                            if (Alpha < 0.0)
                            {
                                Bisector -= BisectorStep;
                                BisectorStep *= 0.5;
                            }
                            else
                                if (Alpha > 1.0)
                                {
                                    Bisector += BisectorStep;
                                    BisectorStep *= 0.5;
                                }
                                else
                                    SplineDistance = SplineDistanceA + Alpha * (SplineDistanceB - SplineDistanceA);
                        }
                        else
                        {
                            SplineDistance = FClamp(SplineDistanceA + Alpha * (SplineDistanceB - SplineDistanceA),
                                                    0.0,SplineLength);

                            break;
                        }
                    }
                }
    }

    return SplineDistance;
}

/**
 * Calculates the direction of the spline at a point.
 * @param Spline          the spline curve
 * @param SplineDistance  distance traveled from spline origin
 * @return                direction of the spline
 */
static function vector CalculateTangent(SplineComponent Spline,float SplineDistance)
{
    if (Spline.SplineCurviness > 0.999)
        return Normal(Spline.GetLocationAtDistanceAlongSpline(Spline.GetSplineLength()) - Spline.Owner.Location);
    else
        return Normal(Spline.GetTangentAtDistanceAlongSpline(SplineDistance));
}

/**
 * Gets a point that belongs to a cubic Bezier curved path.
 * @param Point0  first end point
 * @param Point1  forms the tangent at the first end point
 * @param Point2  forms the tangent at the second end point
 * @param Point3  second end point
 * @param Alpha   interpolant value
 * @return        evaluated point value
 */
static function vector GetBezierCurvePoint(vector Point0,vector Point1,vector Point2,vector Point3,float Alpha)
{
    local float Alpha2,Calc,Calc2;

    Alpha2 = Square(Alpha);
    Calc = 1.0 - Alpha;
    Calc2 = Square(Calc);

    return Point0 * (Calc * Calc2) + Point1 * (3.0 * Alpha * Calc2) +
           Point2 * (3.0 * Calc * Alpha2) + Point3 * (Alpha * Alpha2);
}


auto state Spawning
{
    event BeginState(name PreviousStateName)
    {
        if (ActorsAmount > 0 && ActorsArchetype != none)
            NextOrdered = GetBestConnectionInDirection(vector(Rotation),false);
        else
            GotoState('Idle');
    }

    /**
     * Called whenever time passes.
     * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
     */
    event Tick(float DeltaTime)
    {
        local SplineComponent SplineComp;
        local vector ActorLocation;

        if (SpawnedActors < ActorsAmount && NextOrdered != none)
        {
            SplineComp = FindSplineComponentTo(NextOrdered);
            ActorLocation = SplineComp.GetLocationAtDistanceAlongSpline((1.0 * SpawnedActors / ActorsAmount) *
                                                                        SplineComp.GetSplineLength());

            Spawn(ActorsArchetype.Class,none,,ActorLocation,rot(0,0,0),ActorsArchetype);
            SpawnedActors++;
        }
        else
            GotoState('Idle');
    }
}


state Idle
{
    event BeginState(name PreviousStateName)
    {
        local FileWriter LogFile;
        local SplineComponent SplineComp;
        local vector ActorLocation;

        if (bLogSpawnedActors && SpawnedActors > 0)
        {
            LogFile = Spawn(class'FileWriter');
            LogFile.OpenFile("" $ self,FWFT_Log,".txt",false,false);

            SpawnedActors = 0;

            LogFile.Logf("");
            LogFile.Logf("Begin Map");
            LogFile.Logf("Begin Level");

            while (SpawnedActors < ActorsAmount)
            {
                SplineComp = FindSplineComponentTo(NextOrdered);
                ActorLocation = SplineComp.GetLocationAtDistanceAlongSpline((1.0 * SpawnedActors / ActorsAmount) *
                                                                            SplineComp.GetSplineLength());

                LogFile.Logf("Begin Actor Class=" $ ActorsArchetype.Class);
                LogFile.Logf("Location=(X=" $ ActorLocation.X $ ",Y=" $ ActorLocation.Y $ ",Z=" $ ActorLocation.Z $ ")");
                LogFile.Logf("End Actor");

                SpawnedActors++;
            }

            LogFile.Logf("End Level");
            LogFile.Logf("End Map");

            LogFile.Destroy();
        }
    }
}


defaultproperties
{
    Begin Object Class=ArrowComponent Name=Arrow
        bTreatAsASprite=true
        ArrowColor=(R=192,G=0,B=255,A=255)
        ArrowSize=5.0
        Rotation=(Pitch=0,Yaw=-16384,Roll=0)
        SpriteCategoryName="Splines"
    End Object
    Components.Add(Arrow)


    Begin Object Name=Sprite
        Scale=0.25
    End Object


    Begin Object Class=SensorMeshComponent Name=SensorStaticMesh
        Materials[0]=Material'SonicGDKPackStaticMeshes.Materials.SplineMaterial'
        Scale=1.0
        Scale3D=(X=0.5,Y=4.0,Z=12.0)
        Translation=(X=0.0,Y=0.0,Z=160.0)
    End Object
    SensorMesh=SensorStaticMesh
    Components.Add(SensorStaticMesh)


    bCollideActors=true                 //Collides with other actors.
    bCollideWorld=false                 //Doesn't collide with the world.
    bNoDelete=true                      //Cannot be deleted during play.
    bStatic=false                       //It moves or changes over time.
    SplineColor=(R=255,G=0,B=128,A=255) //Color of the spline line.

    bRotateCameraOnExit=false
    ConstraintMagnitude=1.0
    ConstraintType=CM_Classic2dot5d
    MinSpeedConstraint=0.0
    NumRailsLeft=0
    NumRailsRight=0
    RailDistanceOffset=100.0

    ActorsAmount=0
    ActorsArchetype=RingActor_Dynamic'SonicGDKPackArchetypes.DynamicRingArchetype'
    CachedArchetype=RingActor_Dynamic'SonicGDKPackArchetypes.DynamicRingLightDashArchetype'

    bLogSpawnedActors=false

    DebugDrawResolution=0.05
    DebugTangentsScale=0.333
}
