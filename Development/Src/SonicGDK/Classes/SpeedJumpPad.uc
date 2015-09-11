//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Speed Jump Pad > UDKJumpPad > NavigationPoint > Actor
//
// The Speed Jump Pad is a customized jump pad only usable by players if they are
// running and their speed is greater than a threshold.
//================================================================================
class SpeedJumpPad extends UDKJumpPad
    ClassGroup(SGDK,Invisible)
    placeable;


/**If true, use pawn speed instead of pre-calculated jump velocity.*/ var() bool bUsePawnSpeed;
                        /**Minimum pawn speed to use this jump pad.*/ var() float MinPawnSpeed;


/**
 * Called for PendingTouch actor after the native physics step completes.
 * @param Other  the other actor involved in the previous touch event
 */
event PostTouch(Actor Other)
{
    local SGDKPlayerPawn P;
    local vector V;

    P = SGDKPlayerPawn(Other);

    if (P != none && P.Health > 0 && P.IsTouchingGround() && P.DrivenVehicle == none)
    {
        if (!bUsePawnSpeed)
            V = JumpVelocity;
        else
            V = Normal(JumpVelocity) * VSize(P.GetVelocity());

        if (WorldInfo.WorldGravityZ == WorldInfo.DefaultGravityZ || P.GetGravityZ() != WorldInfo.WorldGravityZ)
            P.AerialBoost(V,false,self,'SpeedJumpPad');
        else
            P.AerialBoost(V * Sqrt(P.GetGravityZ() / WorldInfo.DefaultGravityZ),false,self,'SpeedJumpPad');

        P.AirControl *= JumpAirControl;
        P.Acceleration = vect(0,0,0);

        TriggerEventClass(class'SeqEvent_TouchAccepted',P,0);
    }
}

/**
 * Called when collision with another actor happens; also called every tick that the collision still occurs.
 * @param Other           the other actor involved in the collision
 * @param OtherComponent  the associated primitive component of the other actor
 * @param HitLocation     the world location where the touch occurred
 * @param HitNormal       the surface normal of this actor where the touch occurred
 */
event Touch(Actor Other,PrimitiveComponent OtherComponent,vector HitLocation,vector HitNormal)
{
    if (SGDKPlayerPawn(Other) != none && VSizeSq(SGDKPlayerPawn(Other).GetVelocity()) >= Square(MinPawnSpeed))
    {
        PendingTouch = Other.PendingTouch;
        Other.PendingTouch = self;
    }
}


defaultproperties
{
    Components.Remove(JumpPadLightEnvironment);


    Begin Object Class=SpriteComponent Name=GoodSpriteComponent
        Sprite=Texture2D'EditorResources.S_NavP'
        AlwaysLoadOnClient=false
        AlwaysLoadOnServer=false
        HiddenEditor=false
        HiddenGame=true
    End Object
    Components.Add(GoodSpriteComponent)
    GoodSprite=GoodSpriteComponent


    SupportedEvents.Add(class'SeqEvent_TouchAccepted')


    JumpAirControl=1.0

    bUsePawnSpeed=false
    MinPawnSpeed=0.0
}
