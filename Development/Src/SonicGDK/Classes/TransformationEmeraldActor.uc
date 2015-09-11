//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Transformation Emerald Actor > DynamicSMActor > Actor
//
// A Chaos Emerald for super transformation sequences.
//================================================================================
class TransformationEmeraldActor extends DynamicSMActor;


/**The material instance to change its color.*/ var MaterialInstanceConstant MeshMaterialInstance;


/**
 * Called immediately after gameplay begins.
 */
event PostBeginPlay()
{
    super.PostBeginPlay();

    MeshMaterialInstance = StaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
    StaticMeshComponent.SetMaterial(0,MeshMaterialInstance);
}

/**
 * Changes the color of the mesh material.
 * @param ColorIndex  the index of the new color
 */
function ChangeColor(byte ColorIndex)
{
    local LinearColor NewLinearColor;

    switch (ColorIndex)
    {
        case 0:
            NewLinearColor = MakeLinearColor(1.0,0.0,0.0,1.0);

            break;
        case 1:
            NewLinearColor = MakeLinearColor(1.0,1.0,0.0,1.0);

            break;
        case 2:
            NewLinearColor = MakeLinearColor(0.0,1.0,0.0,1.0);

            break;
        case 3:
            NewLinearColor = MakeLinearColor(0.0,1.0,1.0,1.0);

            break;
        case 4:
            NewLinearColor = MakeLinearColor(0.0,0.0,1.0,1.0);

            break;
        case 5:
            NewLinearColor = MakeLinearColor(1.0,0.0,1.0,1.0);

            break;
        case 6:
            NewLinearColor = MakeLinearColor(0.5,0.5,0.5,1.0);
    }

    MeshMaterialInstance.SetVectorParameterValue('ColorParameter',NewLinearColor);
}

/**
 * Resets this actor to its initial state; used when restarting level without reloading.
 */
function Reset()
{
    Destroy();
}


defaultproperties
{
    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'SonicGDKPackStaticMeshes.StaticMeshes.ChaosEmeraldStaticMesh'
        Scale=0.5
    End Object
    CollisionComponent=StaticMeshComponent0
    StaticMeshComponent=StaticMeshComponent0


    Physics=PHYS_Rotating
    RotationRate=(Pitch=2500,Yaw=65535,Roll=0)
}
