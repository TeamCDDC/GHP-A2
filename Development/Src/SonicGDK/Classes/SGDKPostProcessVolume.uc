//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Post Process Volume > PostProcessVolume > Volume > Brush > Actor
//
// Used to affect post process settings in the game and editor.
//================================================================================
class SGDKPostProcessVolume extends PostProcessVolume
    ClassGroup(SGDK);


struct WavyDistortionSettings
{
/**If true, screen wavy distortion is enabled.*/ var() bool bEnableWavyDistortion;
        /**Amount of vertical wavy distortion.*/ var() float Wavy_Amount;
       /**Horizontal speed of wavy distortion.*/ var() float Wavy_PanningSpeed;

    structdefaultproperties
    {
        bEnableWavyDistortion=false
        Wavy_Amount=4.0
        Wavy_PanningSpeed=4.0
    }
};
/**Additional settings for screen wavy distortion.*/ var() WavyDistortionSettings MoreSettings;


defaultproperties
{
}
