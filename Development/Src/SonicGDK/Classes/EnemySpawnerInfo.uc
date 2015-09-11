//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Enemy Spawner Info > Info > Actor
//
// Classes based on Info hold only information.
// This class holds information related to enemy creation and spawns the enemy
// when needed.
//================================================================================
class EnemySpawnerInfo extends Info
    ClassGroup(SGDK,Invisible)
    placeable
    showcategories(Movement);


                                 /**Class of the enemy to spawn.*/ var() class<SGDKEnemyPawn> EnemyClass;
/**Pawn template used to copy collision, visual mesh, effects...*/ var() SGDKEnemyPawn PawnTemplate;
  /**Skeletal mesh used just for object placement in the editor.*/ var() SkeletalMeshComponent PreviewMesh;

       /**If true, this spawner is disabled; toggle to enable it.*/ var() bool bDisabled;
/**Frequency to check for nearby player pawns to spawn the enemy.*/ var() float CheckTimerFrequency;
   /**An enemy is spawned if a player pawn is within this radius.*/ var() float MaxCheckPlayersRadius;
/**An enemy isn't spawned if a player pawn is within this radius.*/ var() float MinCheckPlayersRadius;
                   /**Time needed to vanish a not rendered enemy.*/ var() float VanishEnemyCheckTime;

                              /**If true, enemy will try to chase the player pawn.*/ var() bool bChasePlayers;
/**If true, enemy returns to the initial point instantly after finishing a patrol.*/ var() bool bHarshPatrolReturn;
                                     /**If true, enemy stops moving while turning.*/ var() bool bPatrolIdleTurning;
              /**Time needed to stop chasing/looking at a not visible player pawn.*/ var() float LoseEnemyCheckTime;
                                      /**Dynamic array of patrol points to follow.*/ var() array<NavigationPoint> PatrolPoints;

/**The normal of the plane that constrains enemy movement.*/ var() vector PlaneConstraintNormal;

/**If true, this spawner was disabled at startup.*/ var bool bOldDisabled;
          /**If true, the enemy has been spawned.*/ var bool bSpawnedEnemy;
             /**A reference to the spawned enemy.*/ var SGDKEnemyPawn EnemyPawn;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    bOldDisabled = bDisabled;

    DetachComponent(PreviewMesh);
    PreviewMesh = none;

    if (!bDisabled)
        SetTimer(CheckTimerFrequency,true,NameOf(CheckForPlayers));
}

/**
 * Checks for nearby players and spawns or destroys an enemy.
 */
function CheckForPlayers()
{
    local SGDKPlayerPawn P;

    if (!bSpawnedEnemy)
    {
        foreach WorldInfo.AllPawns(class'SGDKPlayerPawn',P,Location,MaxCheckPlayersRadius)
            if (!P.bAmbientCreature && VSizeSq(P.Location - Location) > Square(MinCheckPlayersRadius))
                break;
            else
                P = none;

        if (P != none)
        {
            EnemyPawn = Spawn(EnemyClass,self,,Location,Rotation,,true);

            if (EnemyPawn != none)
            {
                bSpawnedEnemy = true;

                TriggerEventClass(class'SeqEvent_EnemySpawn',none,0);
            }
        }
    }
    else
        if (EnemyPawn != none && EnemyPawn.Health > 0 && !EnemyPawn.bDeleteMe &&
            WorldInfo.TimeSeconds - EnemyPawn.LastRenderTime > VanishEnemyCheckTime)
        {
            foreach WorldInfo.AllPawns(class'SGDKPlayerPawn',P,EnemyPawn.Location,MaxCheckPlayersRadius)
                if (!P.bAmbientCreature)
                    break;
                else
                    P = none;

            if (P == none)
            {
                EnemyPawn.Destroy();

                EnemyPawn = none;
                bSpawnedEnemy = false;

                TriggerEventClass(class'SeqEvent_EnemySpawn',none,1);
            }
        }

    if (bSpawnedEnemy && (EnemyPawn == none || EnemyPawn.Health < 1 || EnemyPawn.bDeleteMe))
        ClearTimer(NameOf(CheckForPlayers));
}

/**
 * Handler for the SeqAct_Toggle action; allows level designers to toggle on/off this actor.
 * @param Action  related Kismet sequence action
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

    if (!bDisabled)
        SetTimer(CheckTimerFrequency,true,NameOf(CheckForPlayers));
    else
        ClearTimer(NameOf(CheckForPlayers));
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    if (bSpawnedEnemy)
    {
        if (EnemyPawn != none)
            EnemyPawn.Destroy();

        EnemyPawn = none;
        bSpawnedEnemy = false;
    }

    bDisabled = bOldDisabled;

    if (!bDisabled)
        SetTimer(CheckTimerFrequency,true,NameOf(CheckForPlayers));
    else
        ClearTimer(NameOf(CheckForPlayers));
}


defaultproperties
{
    Begin Object Name=Sprite
        Sprite=Texture2D'EditorResources.S_Pawn'
        SpriteCategoryName="Info"
    End Object


    Begin Object Class=ArrowComponent Name=Arrow
        bTreatAsASprite=true
        ArrowColor=(R=255,G=0,B=0,A=255)
        ArrowSize=2.0
        SpriteCategoryName="Info"
    End Object
    Components.Add(Arrow)


    Begin Object Class=SkeletalMeshComponent Name=PreviewMeshComponent
        CastShadow=false
    End Object
    PreviewMesh=PreviewMeshComponent
    Components.Add(PreviewMeshComponent)


    SupportedEvents.Empty
    SupportedEvents.Add(class'SeqEvent_EnemySpawn')


    bDisabled=false
    CheckTimerFrequency=1.0
    MaxCheckPlayersRadius=4096.0
    MinCheckPlayersRadius=0.0
    VanishEnemyCheckTime=5.0

    bChasePlayers=false
    bHarshPatrolReturn=false
    bPatrolIdleTurning=true
    LoseEnemyCheckTime=10.0
}
