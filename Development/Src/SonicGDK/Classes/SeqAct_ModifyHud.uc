//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Modify HUD > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action modifies properties of the HUD.
//================================================================================
class SeqAct_ModifyHud extends SequenceAction;


/**Value that determines the opacity of the HUD; 0 means transparent, 255 means opaque.*/ var() byte Opacity;
                                         /**The texture which has all the HUD graphics.*/ var() Texture2D Texture;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Controller C;
    local SGDKHud TheHUD;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        C = GetController(Actor(ObjectVar.GetObjectValue()));

        if (C != none && SGDKPlayerController(C) != none)
        {
            TheHUD = SGDKPlayerController(C).GetHud();

            TheHUD.HudAlpha = Opacity;

            if (Texture != none)
                TheHUD.HudTexture = Texture;
        }
    }
}


defaultproperties
{
    bCallHandler=false   //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"   //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Modify HUD" //Text label that describes this object.

    Opacity=255
}
