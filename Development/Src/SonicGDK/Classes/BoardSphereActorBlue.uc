//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Board Sphere Actor Blue > BoardSphereActor > SGDKActor > Actor
//
// The parent class is a pickup placed on the Board Special Stage.
// This subclass is a blue sphere.
//================================================================================
class BoardSphereActorBlue extends BoardSphereActor;


/**If true, this sphere thinks that it's surrounded by blue/red spheres.*/ var bool bDumb;
                                                    /**Adjacent spheres.*/ var BoardSphereActor Friends[8];
                             /**Last time adjacent spheres were counted.*/ var float LastCountTime;
                                          /**Number of adjacent spheres.*/ var byte NumFriends;


/**
 * Checks for adjacent spheres to form a group.
 * @param bPivot        true if this sphere is the pivot
 * @param SphereActors  array of spheres that form a group
 * @return              true if a group is formed and is transformed into rings
 */
function bool CheckFriends(bool bPivot,out array<BoardSphereActor> SphereActors)
{
    local int i,j;
    local bool bContinue;

    if (!bDumb)
        CountFriends();

    if (NumFriends < 8 && !bDumb)
        return false;
    else
    {
        SphereActors[SphereActors.Length] = self;

        for (i = 0; i < 8; i++)
            if (Friends[i] != none)
            {
                bContinue = false;

                for (j = 0; j < SphereActors.Length; j++)
                    if (SphereActors[j] == Friends[i])
                    {
                        bContinue = true;

                        break;
                    }

                if (!bContinue)
                {
                    if (BoardSphereActorBlue(Friends[i]) != none)
                    {
                        if (!BoardSphereActorBlue(Friends[i]).CheckFriends(false,SphereActors))
                            return false;
                    }
                    else
                        if (BoardSphereActorRed(Friends[i]) != none)
                            SphereActors[SphereActors.Length] = Friends[i];
                }
            }

        if (bPivot)
        {
            for (i = 0; i < SphereActors.Length; i++)
                 SphereActors[i].TransformIntoRing();

            PlaySound(SoundCue'SonicGDKPackSounds.RingsDroppedSoundCue');
        }

        return true;
    }
}

/**
 * Counts the adjacent spheres.
 */
function CountFriends()
{
    local int i;

    if (WorldInfo.TimeSeconds != LastCountTime)
    {
        LastCountTime = WorldInfo.TimeSeconds;
        NumFriends = 0;

        for (i = 0; i < 8; i++)
            if (Friends[i] != none && !Friends[i].bHidden)
                NumFriends++;
    }
}

/**
 * Finds the accepted type of adjacent spheres.
 */
function FindFriends()
{
    local BoardSphereActor SphereActor;

    if (Owner != none && BoardSpecialStage(Owner) != none)
    {
        NumFriends = 0;

        foreach VisibleActors(class'BoardSphereActor',SphereActor,
                              BoardSpecialStage(Owner).SquareDistance * 1.42)
        {
            if (SphereActor != self && (BoardSphereActorBlue(SphereActor) != none ||
                BoardSphereActorRed(SphereActor) != none))
            {
                if (SphereActor.Owner != none && SphereActor.Owner != Owner)
                    SphereActor = BoardSphereActor(SphereActor.Owner);

                Friends[NumFriends] = SphereActor;
                NumFriends++;
            }
        }
    }
}

/**
 * Hides, deactivates and destroys this actor.
 */
function HideAndDestroy()
{
    super.HideAndDestroy();

    BoardSpecialStage(SGDKGameInfo(WorldInfo.Game).SpecialStage).SphereTouched(self);
}

/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    local int i,j;
    local BoardSphereActorRed RedSphere;
    local array<BoardSphereActorBlue> BlueSpheres;
    local array<BoardSphereActor> SphereActors;

    HideAndDestroy();

    RedSphere = Spawn(class'BoardSphereActorRed',Owner,,Location,Rotation);
    RedSphere.bIgnoreTouch = true;
    RedSphere.Touch(P,P.CollisionComponent,vect(0,0,0),vect(0,0,0));

    for (i = 0; i < 8; i++)
        if (Friends[i] != none && BoardSphereActorBlue(Friends[i]) != none)
        {
            BlueSpheres[BlueSpheres.Length] = BoardSphereActorBlue(Friends[i]);

            for (j = 0; j < 8; j++)
                if (BlueSpheres[BlueSpheres.Length - 1].Friends[j] == self)
                {
                    BlueSpheres[BlueSpheres.Length - 1].Friends[j] = RedSphere;

                    break;
                }
        }

    for (i = 0; i < BlueSpheres.Length; i++)
    {
        if (!BlueSpheres[i].CheckFriends(true,SphereActors))
            SphereActors.Length = 0;
        else
            break;
    }

    P.PlaySound(TouchSound);
}


defaultproperties
{
    Begin Object Name=SphereStaticMesh
        Materials[0]=MaterialInstanceConstant'SonicGDKPackStaticMeshes.Materials.SpecialBoardSphereBlueMIC'
    End Object
    SphereMesh=SphereStaticMesh


    TouchSound=SoundCue'SonicGDKPackSounds.SphereBlueSoundCue'

    bDumb=false
}
