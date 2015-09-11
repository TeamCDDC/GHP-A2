//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Visibility Box Component > DrawBoxComponent > PrimitiveComponent >
//     > ActorComponent > Component
//
// A component available to all hidden objects that need to check if they would be
// rendered if not hidden.
// It's commonly used for objects that disappear and reappear. 
//================================================================================
class VisibilityBoxComponent extends DrawBoxComponent
    hidecategories(Collision,Lighting,Lightmass,MobileSettings,Physics,Rendering);


defaultProperties
{
    bDrawLitBox=true
    bDrawWireBox=false
    bIgnoreOwnerHidden=true
    BoxColor=(R=128,G=128,B=128,A=255)
    BoxExtent=(X=128.0,Y=128.0,Z=128.0)
    HiddenEditor=true
    HiddenGame=false
}
