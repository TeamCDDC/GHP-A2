//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Family Info Metal Sonic > SGDKFamilyInfo > UTFamilyInfo > Object
//
// A FamilyInfo is a structure which stores information about a particular race or
// 'family' (eg. Ironguard Male).
// This subclass is Metal Sonic's.
//================================================================================
class FamilyInfoMetalSonic extends SGDKFamilyInfo;


defaultproperties
{
    AnimSets[0]=AnimSet'SonicGDKPackSkeletalMeshes.Animation.SonicAnimSet'
    AnimTreeTemplate=AnimTree'SonicGDKPackSkeletalMeshes.Animation.SonicAnimTree'
    CharacterMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.SonicSkeletalMesh'
    PhysAsset=PhysicsAsset'SonicGDKPackSkeletalMeshes.PhysicsAssets.SonicPhysicsAsset'

    SuperAnimSet=none
    SuperCharacterMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.SuperSonicSkeletalMesh'
    HyperCharacterMesh=SkeletalMesh'SonicGDKPackSkeletalMeshes.SkeletalMeshes.HyperSonicSkeletalMesh'

    SoundGroupClass=class'SGDKPlayerPawnSoundGroup'
    VoiceClass=class'UTVoice_Robot'

    DefaultMeshScale=1.0
    BaseTranslationOffset=0.0
    CrouchTranslationOffset=0.0
}
