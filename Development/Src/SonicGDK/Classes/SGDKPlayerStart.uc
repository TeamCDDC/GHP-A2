//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Player Start > PlayerStart > NavigationPoint > Actor
//
// The player start location, which is organized into a network of navigation
// points to provide AI the capability of determining paths to arbitrary
// destinations in a level.
//================================================================================
class SGDKPlayerStart extends PlayerStart
    ClassGroup(SGDK,Invisible);


/**The associated collision cylinder.*/ var() editconst CylinderComponent CollisionMesh;


/**
 * A pawn has been spawned.
 * @param P  a pawn
 */
function PlayerSpawned(Pawn P)
{
    TriggerEventClass(class'SeqEvent_PlayerSpawn',P,0);
}


defaultproperties
{
    Begin Object Name=CollisionCylinder
        bAlwaysRenderIfSelected=true
        bDrawBoundingBox=false
        CollisionHeight=32.0
        CollisionRadius=20.0
        CylinderColor=(R=0,G=255,B=0,A=255)
    End Object
    CollisionMesh=CollisionCylinder


    SupportedEvents.Empty
    SupportedEvents.Add(class'SeqEvent_PlayerSpawn')
}
