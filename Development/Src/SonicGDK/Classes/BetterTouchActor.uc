//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Better Touch Actor > SGDKActor > Actor
//
// An abstract class to provide better handling of Touch and UnTouch events.
//================================================================================
class BetterTouchActor extends SGDKActor
    abstract;


struct TouchedByPawnsHistory
{
                      /**A pawn touching this actor.*/ var SGDKPawn Pawn;
/**Last time this actor triggered the touched event.*/ var float TouchTime;
  /**Last time the pawn natively touched this actor.*/ var float UnTouchTime;
};
/**Stores the pawns that are touching this actor.*/ var protected array<TouchedByPawnsHistory> TouchedByPawns;

                                    /**If true, Tick calls are disabled when not necessary.*/ var bool bDisableTick;
                                              /**TouchedBy is called again after this time.*/ var float TouchedByInterval;
/**UnTouchedBy is called if a pawn isn't no longer touching this actor and after this time.*/ var float UnTouchedByInterval;


/**
 * Called for PendingTouch actor after the native physics step completes.
 * @param Other  the other actor involved in the previous touch event
 */
event PostTouch(Actor Other)
{
    local int i;
    local SGDKPawn P;

    P = SGDKPawn(Other);

    if (P != none && P.Health > 0)
    {
        if (TouchedByPawns.Length > 0)
            for (i = 0; i < TouchedByPawns.Length; i++)
                if (TouchedByPawns[i].Pawn != none && TouchedByPawns[i].Pawn == P)
                {
                    P = none;

                    break;
                }

        if (P != none)
        {
            TouchedByPawns.Add(1);
            TouchedByPawns[TouchedByPawns.Length - 1].Pawn = P;
            TouchedByPawns[TouchedByPawns.Length - 1].TouchTime = -default.TouchedByInterval;
            TouchedByPawns[TouchedByPawns.Length - 1].UnTouchTime = WorldInfo.TimeSeconds;

            Enable('Tick');

            if (IsValidTouchedBy(P))
            {
                TouchedBy(P);

                TouchedByPawns[TouchedByPawns.Length - 1].TouchTime = WorldInfo.TimeSeconds;
                TouchedByPawns[TouchedByPawns.Length - 1].UnTouchTime = WorldInfo.TimeSeconds;

                TriggerEventClass(class'SeqEvent_TouchAccepted',P,0);
            }
        }
    }
}

/**
 * Called whenever time passes.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last Tick
 */
event Tick(float DeltaTime)
{
    local bool bFound,bTouchingPawns;
    local int i;
    local SGDKPawn P;

    if (TouchedByPawns.Length > 0)
    {
        bTouchingPawns = false;

        for (i = 0; i < TouchedByPawns.Length; i++)
            if (TouchedByPawns[i].Pawn != none)
            {
                bFound = false;
                bTouchingPawns = true;

                foreach TouchingActors(class'SGDKPawn',P)
                    if (TouchedByPawns[i].Pawn == P)
                    {
                        bFound = true;

                        break;
                    }

                if (bFound)
                {
                    TouchedByPawns[i].UnTouchTime = WorldInfo.TimeSeconds;

                    if (WorldInfo.TimeSeconds - TouchedByPawns[i].TouchTime > TouchedByInterval &&
                        IsValidTouchedBy(TouchedByPawns[i].Pawn))
                    {
                        TouchedByPawns[i].TouchTime = WorldInfo.TimeSeconds;

                        TouchedBy(TouchedByPawns[i].Pawn);

                        TriggerEventClass(class'SeqEvent_TouchAccepted',TouchedByPawns[i].Pawn,0);
                    }
                }
                else
                    if (WorldInfo.TimeSeconds - TouchedByPawns[i].UnTouchTime > UnTouchedByInterval)
                    {
                        if (IsValidUnTouchedBy(TouchedByPawns[i].Pawn))
                            UnTouchedBy(TouchedByPawns[i].Pawn);

                        TouchedByPawns[i].Pawn = none;
                    }
            }

        if (!bTouchingPawns)
            TouchedByPawns.Length = 0;
    }
    else
        if (bDisableTick)
            Disable('Tick');
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
    if (SGDKPawn(Other) != none)
    {
        PendingTouch = Other.PendingTouch;
        Other.PendingTouch = self;
    }
}

/**
 * Is a pawn in condition to touch this actor?
 * @param P  the pawn involved in the touch
 * @return   true if pawn is a valid actor for touch events
 */
function bool IsValidTouchedBy(SGDKPawn P)
{
    return (SGDKPlayerPawn(P) != none && P.Health > 0 && P.Physics != PHYS_None && P.DrivenVehicle == none);
}

/**
 * Is a pawn in condition to trigger the untouch event of this actor?
 * @param P  the pawn involved in the untouch
 * @return   true if pawn is a valid actor for untouch events
 */
function bool IsValidUnTouchedBy(SGDKPawn P)
{
    return (SGDKPlayerPawn(P) != none && P.Health > 0 && P.Physics != PHYS_None && P.DrivenVehicle == none);
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    TouchedByPawns.Length = 0;

    if (bDisableTick)
        Disable('Tick');
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
}

/**
 * Called when a pawn stops touching this actor.
 * @param P  the pawn involved in the untouch
 */
function UnTouchedBy(SGDKPawn P)
{
}


defaultproperties
{
    SupportedEvents.Add(class'SeqEvent_TouchAccepted')


    bDisableTick=true
    TouchedByInterval=999999.0
    UnTouchedByInterval=0.07
}
