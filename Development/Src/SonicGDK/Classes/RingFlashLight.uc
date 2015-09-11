//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Ring Flash Light > UDKExplosionLight > PointLightComponent > LightComponent >
//     > ActorComponent > Component
//
// A point of light that changes its radius, brightness and color over its
// lifespan, based on user specified points.
// This class is used for rings.
//================================================================================
class RingFlashLight extends UDKExplosionLight;


defaultproperties
{
    bAffectCompositeShadowDirection=false
    Brightness=8.0
    HighDetailFrameTime=0.02
    LightColor=(R=255,G=255,B=0,A=255)
    Radius=64.0
    TimeShift=((StartTime=0.0,Brightness=8.0,LightColor=(R=255,G=255,B=0,A=255),Radius=64.0),(StartTime=0.5,Brightness=4.0,LightColor=(R=192,G=192,B=0,A=255),Radius=32.0),(StartTime=1.0,Brightness=2.0,LightColor=(R=128,G=128,B=0,A=255),Radius=16.0))
}
