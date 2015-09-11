class BlobShadowActor extends DecalActorMovable;


/**
 * Sets a new decal material on the decal component.
 * @param NewMaterial  new decal material
 */
function SetMaterial(MaterialInterface NewMaterial)
{
    Decal.SetDecalMaterial(NewMaterial);
}


defaultproperties
{
    Begin Object Name=NewDecalComponent
        DecalMaterial=DecalMaterial'SonicGDKPackSkeletalMeshes.Materials.BlobShadowMaterialA' //The material of the 2D image.
        bMovableDecal=true //Will recompute its receivers whenever its location is changed.
        bStaticDecal=false //Decal is created at runtime.
        Height=64.0        //Height size of the projected 2D image.
        Width=64.0         //Width size of the projected 2D image.
        FarPlane=8192.0    //After this distance nothing will be projected anymore.
        NearPlane=0.0      //Before this distance nothing will be projected anymore.
    End Object
    Decal=NewDecalComponent


    bBlockActors=false         //Doesn't block other nonplayer actors.
    bCollideActors=false       //Doesn't collide with other actors.
    bCollideWorld=false        //Doesn't collide with the world.
    bHidden=true               //Actor isn't displayed from start.
    bIgnoreBaseRotation=true   //Ignores the effects of changes in its base's rotation.
    bMovable=true              //Actor can be moved.
    bNoDelete=false            //Can be deleted during play.
    bPushedByEncroachers=false //Encroachers can't push this actor.
    bStatic=false              //It moves or changes over time.
    Physics=PHYS_None          //Actor's physics mode; no physics.
}
