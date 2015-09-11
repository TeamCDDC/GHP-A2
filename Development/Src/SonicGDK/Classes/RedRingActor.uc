//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Red Ring Actor > RingActor > SGDKActor > Actor
//
// The Red Ring Actor is the unique ring item found in some Sonic games; it's
// often used to grant special bonuses.
//================================================================================
class RedRingActor extends RingActor
    implements(DrawableEntity)
    placeable;


/**Material used if the mesh becomes translucent.*/ var() MaterialInterface TranslucentMaterial;

                  /**Coordinates for mapping the current icon texture.*/ var TextureCoordinates CurrentHudCoords;
                         /**Coordinates for mapping the icon textures.*/ var TextureCoordinates HudCoords[3];
/**The index number to indicate HUD display order; goes from 0 to 255.*/ var() byte HudOrderIndex;
                          /**Screen position of the list of red rings.*/ var vector2d HudPosition;
               /**Amount of red rings that are contained in the level.*/ var byte NumRedRings;
            /**Name of the pickup state used when the ring is visible.*/ var name PickupState;
                  /**Score bonus granted when this actor is picked up.*/ var() int ScoreBonus;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    local RedRingActor RedRing;
    local SGDKGameInfo Game;
    local JsonObject Data;
    local string MapName;

    super.PostBeginPlay();

    CurrentHudCoords = HudCoords[2];

    foreach DynamicActors(class'RedRingActor',RedRing)
        NumRedRings++;

    Game = SGDKGameInfo(WorldInfo.Game);
    Data = Game.PersistentData.GetData();
    MapName = Game.GetMapFileName();

    if (!Data.HasKey(MapName $ ".RedRing" $ HudOrderIndex))
    {
        Data.SetBoolValue(MapName $ ".RedRing" $ HudOrderIndex,false);
        Data.SetIntValue(MapName $ ".RedRings",NumRedRings);

        Game.PersistentData.InsertData(Data);
    }
    else
        if (Data.GetBoolValue(MapName $ ".RedRing" $ HudOrderIndex))
            PickupState = 'GhostPickup';
}

/**
 * Called after PostBeginPlay to set the initial state.
 */
simulated event SetInitialState()
{
    if (!bHidden)
        InitialState = PickupState;
    else
        InitialState = 'Sleeping';

    super(SGDKActor).SetInitialState();
}

/**
 * Pawn picks up this ring actor.
 * @param P  the pawn
 */
function GrantRings(SGDKPlayerPawn P)
{
    local SGDKGameInfo Game;
    local JsonObject Data;
    local SGDKPlayerController PC;

    CurrentHudCoords = HudCoords[0];

    Game = SGDKGameInfo(WorldInfo.Game);
    Data = Game.PersistentData.GetData();

    //Change persistent data.
    Data.SetBoolValue(Game.GetMapFileName() $ ".RedRing" $ HudOrderIndex,true);
    Game.PersistentData.InsertData(Data);

    //Give energy.
    P.ReceiveEnergy(EnergyAmount);

    //Alerts nearby AI.
    P.MakeNoise(1.0);

    if (PickupSound != none)
        //Plays ring sound.
        P.PlaySound(PickupSound);

    //Updates the HUD.
    PC = SGDKPlayerController(P.Controller);
    if (PC != none)
    {
        SGDKHud(PC.MyHUD).LastPickupTime = WorldInfo.TimeSeconds;

        PC.AddScore(ScoreBonus);
    }

    //Triggers an event.
    TriggerEventClass(class'SeqEvent_PickupStatusChange',P,1);
}

/**
 * Draws 2D graphics on the HUD.
 * @param TheHud  the HUD
 */
function HudGraphicsDraw(SGDKHud TheHud)
{
    local vector2d Position;

    if (HudPosition.Y < 0.0)
    {
        if (!TheHud.bIsSplitScreen)
            Position.Y = HudPosition.Y + 768.0;
        else
            Position.Y = HudPosition.Y + 384.0;
    }

    Position.X = HudPosition.X * TheHud.ResolutionScaleX;
    Position.Y *= TheHud.ResolutionScale;

    TheHud.ResolutionScale *= TheHud.HudScale;

    TheHud.Canvas.DrawColor = TheHud.GetDrawColor();

    //Draw the icon.
    TheHud.Canvas.SetPos(Position.X - CurrentHudCoords.UL * (NumRedRings - HudOrderIndex) *
                         TheHud.ResolutionScale,Position.Y);
    TheHud.Canvas.DrawTile(TheHud.HudTexture,CurrentHudCoords.UL * TheHud.ResolutionScale,
                           CurrentHudCoords.VL * TheHud.ResolutionScale,CurrentHudCoords.U,
                           CurrentHudCoords.V,CurrentHudCoords.UL,CurrentHudCoords.VL);

    TheHud.ResolutionScale /= TheHud.HudScale;
}

/**
 * Updates all graphics' values safely.
 * @param DeltaTime  time since last render of the HUD
 * @param TheHud     the HUD
 */
function HudGraphicsUpdate(float DeltaTime,SGDKHud TheHud)
{
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super(SGDKActor).Reset();

    if (bHidden != bOldHidden)
    {
        if (!bOldHidden)
            GotoState(PickupState);
        else
            GotoState('Sleeping');
    }
}


//The ring is visible and standing still.
state Pickup
{
    event BeginState(name PreviousStateName)
    {
        SetRotation(default.InitialRotation);

        //Triggers an event.
        TriggerEventClass(class'SeqEvent_PickupStatusChange',none,0);
    }
}


//The ring is visible, translucent and standing still.
state GhostPickup extends Pickup
{
    event BeginState(name PreviousStateName)
    {
        CurrentHudCoords = HudCoords[1];
        RingMesh.SetMaterial(0,TranslucentMaterial);

        RotationRate.Yaw /= 3;

        super.BeginState(PreviousStateName);
    }

    event EndState(name NextStateName)
    {
        RotationRate.Yaw *= 3;
    }
}


//Ring is invisible and standing still.
state Sleeping
{
    /**
     * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
     * @param Action  the related Kismet sequence action
     */
    function OnToggle(SeqAct_Toggle Action)
    {
        if (Action.InputLinks[0].bHasImpulse || Action.InputLinks[2].bHasImpulse)
            //Show ring actor.
            GotoState(PickupState);
    }

    /**
     * Resets this actor to its initial state; used when restarting level without reloading.
     */
    function Reset()
    {
        //Disabled.
    }
}


defaultproperties
{
    Begin Object Name=RingStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.RedRingStaticMesh'
        MaxDrawDistance=9000.0
        Scale=1.0
    End Object
    RingMesh=RingStaticMesh


    bLightDash=false
    bMagnetic=false
    EnergyAmount=0.0
    InitialRotation=(Pitch=0,Yaw=0,Roll=0)
    MagneticRingClass=none
    PickupSound=SoundCue'SonicGDKPackSounds.RedRingSoundCue'
    RingParticleSystem=none
    RingsAmount=0
    RotationRate=(Yaw=49152)

    HudCoords[0]=(U=784,V=568,UL=70,VL=70)
    HudCoords[1]=(U=864,V=568,UL=70,VL=70)
    HudCoords[2]=(U=944,V=568,UL=70,VL=70)
    HudOrderIndex=0
    HudPosition=(X=1008,Y=-68)
    PickupState=Pickup
    TranslucentMaterial=Material'SonicGDKPackStaticMeshes.Materials.RedRingMaterialB'
    ScoreBonus=1000
}
