//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Bot Controller > UDKBot > AIController > Controller > Actor
//
// Controllers are non-physical actors that can be attached to a pawn to control
// its actions.
// Controllers take control of a pawn using their Possess() method, and relinquish
// control of the pawn by calling UnPossess().
// Controllers receive notifications for many of the events occuring for the Pawn
// they are controlling. This gives the controller the opportunity to implement
// the behavior in response to this event, intercepting the event and superceding
// the Pawn's default behavior.
// AIControllers implement the artificial intelligence for the pawns they control.
//================================================================================
class SGDKBotController extends UDKBot;


                              /**If true, enemy will try to chase the player pawn.*/ var bool bChasePlayers;
/**If true, enemy returns to the initial point instantly after finishing a patrol.*/ var bool bHarshPatrolReturn;
                                           /**If true, stops moving while turning.*/ var bool bPatrolIdleTurning;
              /**Time needed to stop chasing/looking at a not visible player pawn.*/ var float LoseEnemyCheckTime;

  /**If true, possessed pawn stops moving while turning.*/ var bool bIdleTurning;
               /**Name of the corresponding chase state.*/ var name ChaseState;
/**Reference to the controller of the enemy player pawn.*/ var Controller EnemyController;
             /**Index of the next patrol point to reach.*/ var int PatrolIndex;
                          /**Next patrol point to reach.*/ var NavigationPoint PatrolPoint;
               /**Stores the name of the previous state.*/ var name PreviousState;

struct TGoingSomewhereData
{
           /**Destination to move to.*/ var vector Destination;
/**Maximum allowed time for the move.*/ var float MaxTime;
    /**Actor to look at while moving.*/ var Actor ViewFocus;
};
/**Stores data related to GoingSomewhere state.*/ var TGoingSomewhereData GoingSomewhereData;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    Skill = default.Skill;
}

/**
 * Called whenever the enemy player pawn is no longer within our line of sight.
 */
event EnemyNotVisible()
{
    bEnemyIsVisible = false;

    if (!IsTimerActive(NameOf(CheckEnemyVisibility)))
        SetTimer(LoseEnemyCheckTime,false,NameOf(CheckEnemyVisibility));

    NotSeeingPlayer(Enemy,false);
}

/**
 * Called when the pawn enters a new physics volume.
 * @param NewVolume  the physics volume in which the pawn is standing in
 */
event NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if (NewVolume.bWaterVolume)
    {
        if (!Pawn.bCanSwim)
            MoveTimer = -1.0;
        else
            if (Pawn.Physics != PHYS_Swimming && Pawn.Physics != PHYS_RigidBody)
                Pawn.SetPhysics(PHYS_Swimming);
    }
    else
        if (Pawn.Physics == PHYS_Swimming)
        {
            if (Pawn.bCanFly)
                Pawn.SetPhysics(PHYS_Flying);
            else
                Pawn.SetPhysics(PHYS_Falling);
        }
}

/**
 * Called whenever a player is seen within our line of sight.
 * @param P  the seen player pawn
 */
event SeePlayer(Pawn P)
{
    local bool bFirstSeen;

    if (P.Health > 0 && !P.bDeleteMe)
    {
        if (Enemy == none)
            bFirstSeen = true;

        Enemy = P;
        EnemyController = P.Controller;

        if (CanSeeByPoints(Pawn.Location,Enemy.Location,Pawn.Rotation))
        {
            bEnemyIsVisible = true;
            ClearTimer(NameOf(CheckEnemyVisibility));

            SeeingPlayer(Enemy,bFirstSeen);
        }
        else
            bEnemyIsVisible = false;

        if (bChasePlayers)
            GotoState(ChaseState);
    }
    else
        if (Enemy != none)
            EnemyNotVisible();
}

/**
 * Re-checks enemy player pawn visibility after a while.
 */
function CheckEnemyVisibility()
{
    if (!bEnemyIsVisible)
    {
        ClearTimer(NameOf(CheckEnemyVisibility));

        NotSeeingPlayer(Enemy,true);

        Enemy = none;
        EnemyController = none;
    }
}

/**
 * Searches for visible enemy player pawns.
 */
function CheckSight()
{
    local SGDKPlayerController PC;

    SightCounter = SightCounterInterval;

    foreach WorldInfo.AllControllers(class'SGDKPlayerController',PC)
        if (PC.Pawn != none && CanSee(PC.Pawn))
            SeePlayer(PC.Pawn);
}

/**
 * Gradually moves the possessed pawn to the desired reachable location.
 * @param Destination  the destination to move to
 * @param ViewFocus    the actor to look at while moving
 * @param MaxTime      the maximum allowed time that the move should take
 */
function GoToLocation(vector Destination,Actor ViewFocus,float MaxTime)
{
    GoingSomewhereData.Destination = Destination;
    GoingSomewhereData.MaxTime = MaxTime;
    GoingSomewhereData.ViewFocus = ViewFocus;

    PushState('GoingSomewhere');
}

/**
 * Should the possessed pawn go to another reachable location?
 * @return  true if the possessed pawn should go to a location
 */
function bool GoToSomewhereElse()
{
    return false;
}

/**
 * Is the possessed pawn going to a reachable location?
 * @return  true if the possessed pawn is moving to a fixed destination
 */
function bool IsGoingSomewhere()
{
    return false;
}

/**
 * Notification from the game that a pawn has been killed.
 * @param Killer       the controller responsible for the damage
 * @param Killed       the controller which owned the killed pawn
 * @param KilledPawn   the killed pawn
 * @param DamageClass  class describing the damage that was done
 */
function NotifyKilled(Controller Killer,Controller Killed,Pawn KilledPawn,class<DamageType> DamageClass)
{
    if (EnemyController == Killed)
    {
        bEnemyIsVisible = false;

        CheckEnemyVisibility();
    }
}

/**
 * Currently not seeing the enemy player pawn.
 * @param P      the enemy pawn
 * @param bLast  true if it's last call
 */
function NotSeeingPlayer(Pawn P,bool bLast)
{
    if (!bLast)
        SGDKEnemyPawn(Pawn).SeeingEnemy(P,false);
    else
        SGDKEnemyPawn(Pawn).LostEnemy(P);
}

/**
 * Handler for the UTSeqAct_AIFreeze action; allows level designers to freeze AI.
 * @param Action  related Kismet sequence action
 */
function OnAIFreeze(UTSeqAct_AIFreeze Action)
{
    if (Action.InputLinks[0].bHasImpulse)
        PushState('Frozen');
}

/**
 * Handles attaching this controller to the given pawn.
 * @param P                   the pawn to possess
 * @param bVehicleTransition  true if transitioning from a vehicle
 */
function Possess(Pawn P,bool bVehicleTransition)
{
    super.Possess(P,bVehicleTransition);

    Pawn.SetMovementPhysics();
}

/**
 * Currently seeing the enemy player pawn.
 * @param P       the enemy pawn
 * @param bFirst  true if it's first call
 */
function SeeingPlayer(Pawn P,bool bFirst)
{
    if (!bFirst)
        SGDKEnemyPawn(Pawn).SeeingEnemy(P,true);
    else
        SGDKEnemyPawn(Pawn).NoticedEnemy(P);
}


auto state Idle
{
Begin:
    Sleep(0.01);

    switch (SGDKEnemyPawn(Pawn).DefaultPhysics)
    {
        case PHYS_Flying:
            ChaseState = 'FlyingChasePlayer';

            if (SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints.Length == 0)
                GotoState('FlyingIdle');
            else
                GotoState('FlyingPatrol');

            break;

        case PHYS_Swimming:
            ChaseState = 'SwimmingChasePlayer';

            if (SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints.Length == 0)
                GotoState('SwimmingIdle');
            else
                GotoState('SwimmingPatrol');

            break;

        case PHYS_Walking:
            ChaseState = 'WalkingChasePlayer';

            if (SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints.Length == 0)
                GotoState('WalkingIdle');
            else
                GotoState('WalkingPatrol');

            break;

        case PHYS_Interpolating:
            bChasePlayers = false;

            GotoState('InterpolatingIdle');
    }
}


state Patrol
{
    event BeginState(name PreviousStateName)
    {
        local float Dist;

        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
        {
            Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn,Pawn.Location,true,true,Dist));

            PatrolIndex = 0;
            PatrolPoint = SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints[PatrolIndex];
        }
    }

    event EndState(name NextStateName)
    {
        if (bIdleTurning && Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe && Pawn.MovementSpeedModifier == 0.0)
            Pawn.MovementSpeedModifier = 1.0;

        bIdleTurning = false;
    }
}


state ChasePlayer
{
    event BeginState(name PreviousStateName)
    {
        PreviousState = PreviousStateName;
    }

    /**
     * Re-checks enemy player pawn visibility after a while.
     */
    function CheckEnemyVisibility()
    {
        global.CheckEnemyVisibility();

        if (!bEnemyIsVisible)
            GotoState(PreviousState);
    }
}


state FlyingIdle
{
    event BeginState(name PreviousStateName)
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetPhysics(PHYS_None);
    }

    event EndState(name NextStateName)
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetMovementPhysics();
    }

    event ContinuedState()
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetPhysics(PHYS_None);
    }

    event PausedState()
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetMovementPhysics();
    }
}


state FlyingPatrol extends Patrol
{
Begin:
    Sleep(0.01);

GoToFirstPoint:
    if (!ActorReachable(PatrolPoint))
    {
        ScriptedMoveTarget = FindPathToward(PatrolPoint);

        if (ScriptedMoveTarget != none)
        {
            MoveTo(ScriptedMoveTarget.Location);

            Goto('GoToFirstPoint');
        }
    }

GoToOtherPoints:
    MoveTo(PatrolPoint.Location);

    if (Pawn.ReachedDestination(PatrolPoint))
    {
        SGDKEnemyPawn(Pawn).ReachedPatrolPoint(PatrolPoint);

        Sleep(0.01);

        PatrolIndex++;

        if (PatrolIndex == SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints.Length)
        {
            if (!bHarshPatrolReturn)
                PatrolIndex = 0;
            else
            {
                PatrolIndex = 1;

                Pawn.SetLocation(SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints[0].Location);
            }
        }

        PatrolPoint = SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints[PatrolIndex];

        if (bPatrolIdleTurning)
        {
            bIdleTurning = true;

            Pawn.ZeroMovementVariables();
            Pawn.MovementSpeedModifier = 0.0;

            SGDKEnemyPawn(Pawn).MaxYawAim = 0;
            Focus = PatrolPoint;

            Sleep(0.01);

            while (Pawn.Rotation.Yaw != Pawn.DesiredRotation.Yaw)
                Sleep(0.05);

            Focus = none;
            SGDKEnemyPawn(Pawn).MaxYawAim = SGDKEnemyPawn(Pawn).default.MaxYawAim;

            Pawn.MovementSpeedModifier = 1.0;

            bIdleTurning = false;
        }
    }

    Goto('GoToOtherPoints');
}


state FlyingChasePlayer extends ChasePlayer
{
Begin:
    if (Enemy != none)
        MoveToward(Enemy);
    else
        GotoState(PreviousState);

    Goto('Begin');
}


state SwimmingIdle
{
    event BeginState(name PreviousStateName)
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetPhysics(PHYS_None);
    }

    event EndState(name NextStateName)
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetMovementPhysics();
    }

    event ContinuedState()
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetPhysics(PHYS_None);
    }

    event PausedState()
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetMovementPhysics();
    }
}


state SwimmingPatrol extends Patrol
{
Begin:
    Sleep(0.01);

GoToFirstPoint:
    if (!ActorReachable(PatrolPoint))
    {
        ScriptedMoveTarget = FindPathToward(PatrolPoint);

        if (ScriptedMoveTarget != none)
        {
            MoveTo(ScriptedMoveTarget.Location);

            Goto('GoToFirstPoint');
        }
    }

GoToOtherPoints:
    MoveTo(PatrolPoint.Location);

    if (Pawn.ReachedDestination(PatrolPoint))
    {
        SGDKEnemyPawn(Pawn).ReachedPatrolPoint(PatrolPoint);

        Sleep(0.01);

        PatrolIndex++;

        if (PatrolIndex == SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints.Length)
        {
            if (!bHarshPatrolReturn)
                PatrolIndex = 0;
            else
            {
                PatrolIndex = 1;

                Pawn.SetLocation(SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints[0].Location);
            }
        }

        PatrolPoint = SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints[PatrolIndex];

        if (bPatrolIdleTurning)
        {
            bIdleTurning = true;

            Pawn.ZeroMovementVariables();
            Pawn.MovementSpeedModifier = 0.0;

            SGDKEnemyPawn(Pawn).MaxYawAim = 0;
            Focus = PatrolPoint;

            Sleep(0.01);

            while (Pawn.Rotation.Yaw != Pawn.DesiredRotation.Yaw)
                Sleep(0.05);

            Focus = none;
            SGDKEnemyPawn(Pawn).MaxYawAim = SGDKEnemyPawn(Pawn).default.MaxYawAim;

            Pawn.MovementSpeedModifier = 1.0;

            bIdleTurning = false;
        }
    }

    Goto('GoToOtherPoints');
}


state SwimmingChasePlayer extends ChasePlayer
{
Begin:
    if (Enemy != none)
        MoveToward(Enemy);
    else
        GotoState(PreviousState);

    Goto('Begin');
}


state WalkingIdle
{
}


state WalkingPatrol extends Patrol
{
Begin:
    Sleep(0.01);

GoToFirstPoint:
    if (!ActorReachable(PatrolPoint))
    {
        ScriptedMoveTarget = FindPathToward(PatrolPoint);

        if (ScriptedMoveTarget != none)
        {
            MoveTo(ScriptedMoveTarget.Location);

            Goto('GoToFirstPoint');
        }
    }

GoToOtherPoints:
    MoveTo(PatrolPoint.Location);

    if (Pawn.ReachedDestination(PatrolPoint))
    {
        SGDKEnemyPawn(Pawn).ReachedPatrolPoint(PatrolPoint);

        Sleep(0.01);

        PatrolIndex++;

        if (PatrolIndex == SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints.Length)
        {
            if (!bHarshPatrolReturn)
                PatrolIndex = 0;
            else
            {
                PatrolIndex = 1;

                Pawn.SetLocation(SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints[0].Location);
            }
        }

        PatrolPoint = SGDKEnemyPawn(Pawn).EnemySpawner.PatrolPoints[PatrolIndex];

        if (bPatrolIdleTurning)
        {
            bIdleTurning = true;

            Pawn.ZeroMovementVariables();

            SGDKEnemyPawn(Pawn).MaxYawAim = 0;
            Focus = PatrolPoint;

            Sleep(0.01);

            while (Pawn.Rotation.Yaw != Pawn.DesiredRotation.Yaw)
                Sleep(0.05);

            Focus = none;
            SGDKEnemyPawn(Pawn).MaxYawAim = SGDKEnemyPawn(Pawn).default.MaxYawAim;

            bIdleTurning = false;
        }
    }

    Goto('GoToOtherPoints');
}


state WalkingChasePlayer extends ChasePlayer
{
    event EndState(name NextStateName)
    {
        super.EndState(NextStateName);

        ClearTimer(NameOf(ChangeMoveTimer));
    }

    /**
     * Changes MoveTimer.
     */
    function ChangeMoveTimer()
    {
        MoveTimer = 0.5;
    }

Begin:
    if (Enemy != none)
    {
        if (!ActorReachable(Enemy))
        {
            ScriptedMoveTarget = FindPathToward(Enemy);

            if (ScriptedMoveTarget != none)
                MoveToward(ScriptedMoveTarget,Enemy,Pawn.GetCollisionRadius());
            else
                Sleep(0.25);
        }
        else
        {
            SetTimer(0.01,false,NameOf(ChangeMoveTimer));

            MoveTo(Enemy.Location,Enemy);

            MoveTimer = -1.0;
        }
    }
    else
        GotoState(PreviousState);

    Goto('Begin');
}


state InterpolatingIdle
{
    event BeginState(name PreviousStateName)
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetMovementPhysics();
    }

    event ContinuedState()
    {
        if (Pawn != none && Pawn.Health > 0 && !Pawn.bDeleteMe)
            Pawn.SetMovementPhysics();
    }
}


state Frozen
{
    ignores SeePlayer;

    event PushedState()
    {
        Pawn.ZeroMovementVariables();

        if (Pawn.Physics == PHYS_Flying || Pawn.Physics == PHYS_Swimming)
            Pawn.MovementSpeedModifier = 0.0;
    }

    event PoppedState()
    {
        if (Pawn.Physics == PHYS_Flying || Pawn.Physics == PHYS_Swimming)
            Pawn.MovementSpeedModifier = 1.0;
    }

    /**
     * Handler for the UTSeqAct_AIFreeze action; allows level designers to freeze AI.
     * @param Action  related Kismet sequence action
     */
    function OnAIFreeze(UTSeqAct_AIFreeze Action)
    {
        if (Action.InputLinks[1].bHasImpulse)
            PopState();
    }
}


state GoingSomewhere
{
    event PoppedState()
    {
        ClearTimer(NameOf(ChangeMoveTimer));

        MoveTimer = -1.0;
    }

    /**
     * Changes MoveTimer.
     */
    function ChangeMoveTimer()
    {
        MoveTimer = GoingSomewhereData.MaxTime;
    }

    /**
     * Gradually moves the possessed pawn to the desired reachable location.
     * @param Destination  the destination to move to
     * @param ViewFocus    the actor to look at while moving
     * @param MaxTime      the maximum allowed time that the move should take
     */
    function GoToLocation(vector Destination,Actor ViewFocus,float MaxTime)
    {
    }

    /**
     * Is the possessed pawn going to a reachable location?
     * @return  true if the possessed pawn is moving to a fixed destination
     */
    function bool IsGoingSomewhere()
    {
        return (MoveTimer > 0.0 && !IsZero(GoingSomewhereData.Destination));
    }

Begin:
    if (GoingSomewhereData.MaxTime > 0.0)
    {
        SetTimer(0.01,false,NameOf(ChangeMoveTimer));

        MoveTo(GoingSomewhereData.Destination,GoingSomewhereData.ViewFocus);

        GoingSomewhereData.Destination = vect(0,0,0);
        MoveTimer = -1.0;
    }

    if (!GoToSomewhereElse())
        PopState();
    else
        Goto('Begin');
}


defaultproperties
{
    bSlowerZAcquire=false    //AI acquires targets above or below it at the same speed.
    SightCounterInterval=0.1 //How often player visibility is checked.
    Skill=10.0               //Skill of the AI.

    bChasePlayers=true
    bHarshPatrolReturn=false
    bPatrolIdleTurning=true
    LoseEnemyCheckTime=10.0
}
