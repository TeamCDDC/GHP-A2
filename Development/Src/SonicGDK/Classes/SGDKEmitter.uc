//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// SGDK Emitter > UTEmitter > Emitter > Actor
//
// The emitter is the base class that holds particle system components.
//================================================================================
class SGDKEmitter extends UTEmitter;


/**
 * Smoothly deactivates the particles.
 */
function Deactivate()
{
    ParticleSystemComponent.DeactivateSystem();
    bCurrentlyActive = false;
}

/**
 * Destroys this actor after the particle system is gently deactivated.
 * @param bDontDetach  true to not detach from base
 * @param ExtraTime    particle system is gently deactivated after this additional time
 */
function DelayedDestroy(optional bool bDontDetach,optional float ExtraTime)
{
    if (ExtraTime == 0.0)
    {
        bDestroyOnSystemFinish = true;

        Deactivate();

        if (!bDontDetach)
            SetBase(none);
    }
    else
        SetTimer(ExtraTime,false,NameOf(DelayedDestroy));
}


defaultproperties
{
    LifeSpan=0.0 //How old the object lives before dying; 0 means forever.
}
