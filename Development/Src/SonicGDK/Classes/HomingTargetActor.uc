//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Homing Target Actor > SGDKActor > Actor
//
// The Homing Target Actor is an invisible target for Homing Dash.
//================================================================================
class HomingTargetActor extends SGDKActor
    ClassGroup(SGDK,Invisible)
    implements(DestroyableEntity)
    placeable;


      /**If true, this actor is disabled.*/ var() bool bDisabled;
/**Stores the default value of bDisabled.*/ var bool bOldDisabled;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    bOldDisabled = bDisabled;
}

/**
 * Gets the location to where a Homing Dash special move must go.
 * @param APawn  the pawn that tries to destroy this object
 * @return       location of a vulnerable point
 */
function vector GetHomingLocation(SGDKPlayerPawn APawn)
{
    return Location;
}

/**
 * Can this object be destroyed by a certain pawn?
 * @param APawn  the pawn that tries to destroy this object
 * @return       true if this object is vulnerable to the pawn
 */
function bool IsDestroyableBy(SGDKPlayerPawn APawn)
{
    return false;
}

/**
 * Can this object be a target for Homing Dash special move?
 * @return  true if this object is a valid target for Homing Dash
 */
function bool IsHomingTarget()
{
    return !bDisabled;
}

/**
 * Function handler for SeqAct_Toggle Kismet sequence action; allows level designers to toggle on/off this actor.
 * @param Action  the related Kismet sequence action
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
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    super.Reset();

    bDisabled = bOldDisabled;
}


defaultproperties
{
    Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorMaterials.TargetIcon'
        SpriteCategoryName="Misc"
        HiddenGame=true
        Scale=0.1
    End Object
    Components.Add(Sprite)


    Begin Object Class=CylinderComponent Name=CollisionCylinder
        bAlwaysRenderIfSelected=false
        bDrawBoundingBox=false
        BlockActors=false
        BlockRigidBody=false
        CollideActors=true
        CollisionHeight=10.0
        CollisionRadius=10.0
    End Object
    CollisionComponent=CollisionCylinder
    Components.Add(CollisionCylinder)


    Begin Object Class=VisibilityBoxComponent Name=VisibilityComponent
        BoxExtent=(X=10.0,Y=10.0,Z=10.0)
    End Object
    Components.Add(VisibilityComponent)


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=true        //Collides with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bEdShouldSnap=true         //It snaps to the grid in the editor.
    bMovable=false             //Actor can't be moved.
    bNoDelete=true             //Cannot be deleted during play.
    bPushedByEncroachers=false //Encroachers can't push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.
}
