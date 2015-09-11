//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Player Start Factory > ActorFactoryPlayerStart > ActorFactory > Object
//
// This is a factory used by the editor which places the desired actor in the map.
//================================================================================
class SGDKPlayerStartFactory extends ActorFactoryPlayerStart;


defaultproperties
{
    bShowInEditorQuickMenu=false
    MenuName="Add SGDK PlayerStart"
    NewActorClass=class'SGDKPlayerStart'
}
