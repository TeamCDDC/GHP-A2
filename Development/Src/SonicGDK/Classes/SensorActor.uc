//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sensor Actor > BetterTouchActor > SGDKActor > Actor
//
// This actor is a sensor that detects player pawn touch and notifies one of three
// different types of events.
//================================================================================
class SensorActor extends BetterTouchActor
    ClassGroup(SGDK,Invisible)
    placeable;


/**The invisible sensor mesh that detects touching actors.*/ var() editconst SensorMeshComponent SensorMesh;


/**
 * Called when a pawn touches this actor.
 * @param P  the pawn involved in the touch
 */
function TouchedBy(SGDKPawn P)
{
    TriggerEventClass(class'SeqEvent_SensorTouch',P,0);
}

/**
 * Called when a pawn stops touching this actor.
 * @param P  the pawn involved in the untouch
 */
function UnTouchedBy(SGDKPawn P)
{
    local vector X,Y,Z;

    GetAxes(Rotation,X,Y,Z);

    if (X dot Normal(P.Location - PointProjectToPlane(P.Location,Location,Location + Y,Location + Z)) >= 0.0)
        TriggerEventClass(class'SeqEvent_SensorTouch',P,1);
    else
        TriggerEventClass(class'SeqEvent_SensorTouch',P,2);
}


defaultproperties
{
    Begin Object Class=ArrowComponent Name=ArrowA
        bTreatAsASprite=true
        ArrowColor=(R=255,G=0,B=0,A=255)
        ArrowSize=3.0
        SpriteCategoryName="Triggers"
    End Object
    Components.Add(ArrowA)


    Begin Object Class=ArrowComponent Name=ArrowB
        bTreatAsASprite=true
        ArrowColor=(R=0,G=0,B=255,A=255)
        ArrowSize=3.0
        Rotation=(Pitch=0,Yaw=32768,Roll=0)
        SpriteCategoryName="Triggers"
    End Object
    Components.Add(ArrowB)


    Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorResources.S_Route'
        HiddenGame=true
        Scale=1.0
        SpriteCategoryName="Triggers"
    End Object
    Components.Add(Sprite)


    Begin Object Class=SensorMeshComponent Name=SensorStaticMesh
        Scale=1.0
        Scale3D=(X=0.5,Y=4.0,Z=12.0)
    End Object
    SensorMesh=SensorStaticMesh
    Components.Add(SensorStaticMesh)


    SupportedEvents.Empty
    SupportedEvents.Add(class'SeqEvent_SensorTouch')


    bCollideActors=true //Collides with other actors.
    bCollideWorld=false //Doesn't collide with the world.
    bNoDelete=true      //Cannot be deleted during play.
    bStatic=false       //It moves or changes over time.
}
