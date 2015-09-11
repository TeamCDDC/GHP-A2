//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Player Input > UTPlayerInput > UDKPlayerInput > GamePlayerInput >
//     > PlayerInput > Input > Interaction > UIRoot > Object
//
// Object within player controllers that manages player input (pressed keys).
//================================================================================
class SGDKPlayerInput extends UTPlayerInput within SGDKPlayerController;


/**Used to look up/down and fix pitch view rotation to a predetermined value.*/ var input float aFixedLook;
           /**Same as aStrafe but activated with left thumbstick of gamepads.*/ var input float aStrafe2;
             /**Same as aTurn but activated with left thumbstick of gamepads.*/ var input float aTurn2;

/**If true, an UnDuck command is pending.*/ var bool bPendingUnDuck;
        /**Stores forward/backward input.*/ var float OldBaseY;


/**
 * Postprocesses the player's input.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last tick
 */
event PlayerInput(float DeltaTime)
{
    local SGDKPlayerPawn P;
    local float BaseY;

    super.PlayerInput(Deltatime);

    P = SGDKPlayerPawn(Pawn);

    if (IsDirInputIgnored())
    {
        //Ignore directional move input.
        aForward = 0.0;
        aStrafe = 0.0;
        aUp = 0.0;
    }

    //If player wants to look up/down, looking input is allowed and it has been more than 0.5 seconds
    //since the last valid fixed look up/down input...
    if (aFixedLook != 0.0 && !IsLookInputIgnored() && WorldInfo.TimeSeconds - LastFixedLookTime > 0.5)
    {
        LastFixedLookTime = WorldInfo.TimeSeconds;

        //Reverse value if mouse isn't inverted.
        if (!bInvertMouse)
            aFixedLook *= -1;

        //Call appropiate function.
        if (aFixedLook > 0.0)
            FixedLookUp();
        else
            FixedLookDown();
    }

    if (bKeepForward)
        aForward = MaxPlayerInput;
    else
        //Clamp forward input value between minimum and maximum absolute magnitude.
        aForward = FClamp(aForward,-MaxPlayerInput,MaxPlayerInput);

    //Clamp strafe input value between minimum and maximum absolute magnitude.
    aStrafe = FClamp(aStrafe,-MaxPlayerInput,MaxPlayerInput);

    if (!bUsingGamepad)
        //Always maximum acceleration rate.
        AnalogAccelPct = 1.0;
    else
    {
        //Get maximum absolute input first.
        AnalogAccelPct = FMax(Abs(aForward),Abs(aStrafe));

        //Calculate new percent to apply to acceleration rate.
        if (AnalogAccelPct != 0.0)
            AnalogAccelPct = FMin(AnalogAccelPct / (MaxPlayerInput * 0.75),1.0);
        else
            AnalogAccelPct = 1.0;
    }

    if (bBackwardDucks && P != none)
    {
        if (!P.bClassicMovement || !P.bConstrainMovement)
        {
            //If player was ducking with negative-forward input...
            if (OldBaseY < 0.0 && bDuck == 1)
                UnDuck();

            OldBaseY = 0.0;
        }
        else
        {
            if (!bUsingGamepad)
                BaseY = FClamp(aBaseY,-1.0,1.0);
            else
            {
                //Decrease sensitivity of forward input.
                BaseY = aBaseY / MaxPlayerInput;

                if (BaseY > 0.75)
                    BaseY = 1.0;
                else
                    if (BaseY < -0.75)
                        BaseY = -1.0;
                    else
                        BaseY = 0.0;
            }

            //If player wants to duck/unduck with forward input...
            if (BaseY != OldBaseY)
            {
                if (BaseY < 0.0 && bDuck == 0)
                    Duck();
                else
                    if (BaseY >= 0.0 && bDuck == 1)
                        UnDuck();
            }

            OldBaseY = BaseY;
        }
    }

    //If UnDuck command is pending...
    if (bPendingUnDuck)
        UnDuck();
}

/**
 * Player has pressed the duck button/key.
 */
simulated exec function Duck()
{
    //If player movement input isn't being ignored...
    if (!IsPaused() && !IsMoveInputIgnored())
    {
        if (Pawn != none)
            //Notify pawn.
            SGDKPlayerPawn(Pawn).Duck(true);

        //Set value of player controller.
        bDuck = 1;
    }
}

/**
 * Player has pressed the jump button/key.
 */
exec function Jump()
{
    local SGDKPlayerPawn P;

    //If player movement input isn't being ignored...
    if (!IsPaused() && !IsMoveInputIgnored())
    {
        P = SGDKPlayerPawn(Pawn);

        //If pawn exists and is feigning death...
        if (P != none && P.bFeigningDeath)
            //Cancel feign death.
            P.FeignDeath();
        else
            //Set value of player controller.
            bPressedJump = true;
    }
}

/**
 * Preprocesses the player's input.
 * @param DeltaTime  contains the amount of time in seconds that has passed since the last tick
 */
function PreProcessInput(float DeltaTime)
{
    local SGDKPlayerPawn P;

    super.PreProcessInput(DeltaTime);

    MaxPlayerInput = Outer.default.MaxPlayerInput * DeltaTime;
    P = SGDKPlayerPawn(Pawn);

    if (bUsingGamepad)
    {
        //If only strafing left/right with left thumbstick of gamepad...
        if (aStrafe == 0.0 && aStrafe2 != 0.0)
        {
            if (P == none || P.Physics == PHYS_Falling || P.bClassicMovement|| P.IsRolling())
                //Copy input value to original strafe command.
                aStrafe = aStrafe2;
            else
                //Ignore low-medium input value.
                if (Abs(aStrafe2) > 0.99)
                    //Copy decreased input value to original strafe command.
                    aStrafe = aStrafe2 * 0.33;
        }

        //If present, analog triggers are used for smooth turning.
        if (aLeftAnalogTrigger > 0.0 || aRightAnalogTrigger > 0.0)
        {
            aTurn = aRightAnalogTrigger - aLeftAnalogTrigger;

            //Discard all turning produced by other buttons.
            aBaseX = 0.0;
        }

        //Adjust aTurn2 value so that it remains low for half an input zone.
        if (aTurn2 != 0.0)
        {
            if (Abs(aTurn2) < 0.5)
                //Don't discard aTurn2 value, use a low fixed input value instead.
                aTurn2 = FClamp(aTurn2 * 10.0,-0.1,0.1);
            else
                if (aTurn2 > 0.0)
                    aTurn2 = FClamp((aTurn2 - 0.5) * 3.0,0.1,1.0);
                else
                    aTurn2 = FClamp((aTurn2 + 0.5) * 3.0,-1.0,-0.1);
        }

        //If only turning left/right with left thumbstick of gamepad...
        if (aTurn == 0.0 && P != none && P.Physics != PHYS_Falling && !P.IsRolling())
            //Copy input value to original turn command.
            aTurn = aTurn2;
    }
}

/**
 * Player has pressed the special move button/key.
 */
exec function SpecialMove()
{
    //If game isn't paused and pawn is alive, set special move flag.
    if (!IsPaused() && Pawn != none && Pawn.Health > 0)
    {
        //Set values of player controller.
        bSpecialMove = true;
        bUnSpecialMove = false;
    }
}

/**
 * Player has released the duck button/key.
 */
simulated exec function UnDuck()
{
    if (!IsPaused())
    {
        if (Pawn != none)
            //Notify pawn.
            SGDKPlayerPawn(Pawn).Duck(false);

        //Set value of player controller.
        bDuck = 0;

        bPendingUnDuck = false;
    }
    else
        bPendingUnDuck = true;
}

/**
 * Player has released the jump button/key.
 */
exec function UnJump()
{
    //Set value of player controller.
    bUnJump = true;
}

/**
 * Player has released the special move button/key.
 */
exec function UnSpecialMove()
{
    //Set values of player controller.
    bSpecialMove = false;
    bUnSpecialMove = true;
}


defaultproperties
{
}
