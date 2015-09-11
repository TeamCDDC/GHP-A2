//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Chaos Emerald Actor > RingActor > SGDKActor > Actor
//
// This actor is the typical Chaos Emerald found in all Sonic games which can be
// collected.
//================================================================================
class ChaosEmeraldActor extends RingActor
    ClassGroup(SGDK,Visible)
    hidecategories(RingActor);


/**The material instance to change its color.*/ var MaterialInstanceConstant MeshMaterialInstance;

/**The index number to indicate a color; goes from 0 to 6.*/ var() byte ColorIndex;
            /**Maximum value allowed for granted emeralds.*/ var() byte MaxEmeralds;

/**The Chaos Emerald pickup music track.*/ var SoundCue EmeraldSoundCue;
      /**A reference to a music manager.*/ var SGDKMusicManager MusicManager;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    local LinearColor NewLinearColor;

    super.PostBeginPlay();

    MeshMaterialInstance = RingMesh.CreateAndSetMaterialInstanceConstant(0);
    RingMesh.SetMaterial(0,MeshMaterialInstance);

    switch (ColorIndex)
    {
        case 0:
            NewLinearColor = MakeLinearColor(1.0,0.0,0.0,1.0);

            break;
        case 1:
            NewLinearColor = MakeLinearColor(1.0,1.0,0.0,1.0);

            break;
        case 2:
            NewLinearColor = MakeLinearColor(0.0,1.0,0.0,1.0);

            break;
        case 3:
            NewLinearColor = MakeLinearColor(0.0,1.0,1.0,1.0);

            break;
        case 4:
            NewLinearColor = MakeLinearColor(0.0,0.0,1.0,1.0);

            break;
        case 5:
            NewLinearColor = MakeLinearColor(1.0,0.0,1.0,1.0);

            break;
        case 6:
            NewLinearColor = MakeLinearColor(0.5,0.5,0.5,1.0);
    }

    MeshMaterialInstance.SetVectorParameterValue('ColorParameter',NewLinearColor);
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    //Disabled.
}

/**
 * Stops the Chaos Emerald music track.
 */
function StopMusicTrack()
{
    MusicManager.StopMusicTrack(EmeraldSoundCue,1.0);
}


//The Chaos Emerald is visible and standing still.
state Pickup
{
    event BeginState(name PreviousStateName)
    {
        //Triggers an event.
        TriggerEventClass(class'SeqEvent_PickupStatusChange',none,0);
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
        local SGDKPlayerPawn P;

        P = SGDKPlayerPawn(Other);

        //If valid touched by a player pawn, let him pick this up.
        if (P != none && P.Controller != none && ValidTouch(P) &&
            SGDKPlayerController(P.Controller).ChaosEmeralds < MaxEmeralds)
        {
            SGDKPlayerController(P.Controller).ChaosEmeralds++;

            MusicManager = SGDKPlayerController(P.Controller).GetMusicManager();
            EmeraldSoundCue = MusicManager.EmeraldMusicTrack;
            MusicManager.StartMusicTrack(EmeraldSoundCue,0.0);

            SetTimer(EmeraldSoundCue.Duration - 1.0,false,NameOf(StopMusicTrack));

            //Triggers an event.
            TriggerEventClass(class'SeqEvent_PickupStatusChange',P,1);

            GotoState('Sleeping');
        }
    }

    /**
     * Validates touch.
     * @param P  the player pawn that tries to pick up this object
     * @return   true if this object can be picked up
     */
    function bool ValidTouch(SGDKPlayerPawn P)
    {
        if (!P.CanPickupActor(self) || P.HasAllEmeralds())
            return false;
        else
            if (P.Controller == none)
            {
                //Re-check later in case the pawn would have a controller shortly.
                SetTimer(0.2,false,NameOf(CheckTouching));

                return false;
            }

        return true;
    }
}


defaultproperties
{
    Begin Object Name=RingStaticMesh
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.ChaosEmeraldStaticMesh'
        Scale=0.5
    End Object
    RingMesh=RingStaticMesh


    bIgnoreEncroachers=false  //Don't ignore collisions between movers and this actor.
    bMagnetic=false
    bNoDelete=false           //Can be deleted during play.
    bPushedByEncroachers=true //Encroachers can push this actor.
    PickupSound=none
    RotationRate=(Yaw=8192)   //Change in rotation per second.

    ColorIndex=0
    MaxEmeralds=14
}
