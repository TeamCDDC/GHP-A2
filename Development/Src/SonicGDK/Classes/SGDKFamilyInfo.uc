//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Family Info > UTFamilyInfo > Object
//
// A FamilyInfo is a structure which stores information about a particular race or
// 'family' (eg. Ironguard Male).
//================================================================================
class SGDKFamilyInfo extends UTFamilyInfo;


        /**Animation tree to use for the character skeletal mesh.*/ var AnimTree AnimTreeTemplate;
/**Character mesh translation offset along Z axis when crouching.*/ var float CrouchTranslationOffset;

/**Animation set used on top of all anim sets for super form.*/ var AnimSet SuperAnimSet;
          /**Mesh reference for super form of this character.*/ var SkeletalMesh SuperCharacterMesh;
          /**Mesh reference for hyper form of this character.*/ var SkeletalMesh HyperCharacterMesh;


defaultproperties
{
    Faction="Characters"
    FamilyID="CHARS"

    CharacterTeamHeadMaterials[0]=MaterialInterface'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VRed'
    CharacterTeamBodyMaterials[0]=MaterialInterface'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VRed'
    CharacterTeamHeadMaterials[1]=MaterialInterface'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VBlue'
    CharacterTeamBodyMaterials[1]=MaterialInterface'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VBlue'

    ArmMeshPackageName="CH_Corrupt_Arms"
    ArmSkinPackageName="CH_Corrupt_Arms"
    ArmMesh=CH_Corrupt_Arms.Mesh.SK_CH_Corrupt_Arms_MaleA_1P
    RedArmMaterial=CH_Corrupt_Arms.Materials.MI_CH_Corrupt_FirstPersonArms_VRed
    BlueArmMaterial=CH_Corrupt_Arms.Materials.MI_CH_Corrupt_FirstPersonArms_VBlue

    NonTeamEmissiveColor=(R=8.0,G=3.0,B=1.0)
    NonTeamTintColor=(R=3.0,G=2.0,B=1.4)

    BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Corrupt_Base'
    BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Corrupt_BioDeath'

    HeadShotEffect=ParticleSystem'T_FX.Effects.P_FX_HeadShot_Corrupt'

    BloodSplatterDecalMaterial=MaterialInstanceTimeVarying'T_FX.DecalMaterials.MITV_FX_OilDecal_Small01'

    GibExplosionTemplate=ParticleSystem'T_FX.Effects.P_FX_GibExplode_Corrupt'

    HeadGib=(BoneName=b_Head,GibClass=class'UTGib_RobotHead',bHighDetailOnly=false)

    Gibs[0]=(BoneName=b_LeftForeArm,GibClass=class'UTGib_RobotArm',bHighDetailOnly=false)
    Gibs[1]=(BoneName=b_RightForeArm,GibClass=class'UTGib_RobotHand',bHighDetailOnly=true)
    Gibs[2]=(BoneName=b_LeftLeg,GibClass=class'UTGib_RobotLeg',bHighDetailOnly=false)
    Gibs[3]=(BoneName=b_RightLeg,GibClass=class'UTGib_RobotLeg',bHighDetailOnly=false)
    Gibs[4]=(BoneName=b_Spine,GibClass=class'UTGib_RobotTorso',bHighDetailOnly=false)
    Gibs[5]=(BoneName=b_Spine1,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
    Gibs[6]=(BoneName=b_Spine2,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
    Gibs[7]=(BoneName=b_LeftClav,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
    Gibs[8]=(BoneName=b_RightClav,GibClass=class'UTGib_RobotArm',bHighDetailOnly=true)

    BloodEffects[0]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Far',MinDistance=750.0)
    BloodEffects[1]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Mid',MinDistance=350.0)
    BloodEffects[2]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Near',MinDistance=0.0)
}
