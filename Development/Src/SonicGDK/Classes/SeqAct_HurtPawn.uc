//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Hurt Pawn > SequenceAction > SequenceOp > SequenceObject >
//     > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action hurts the given pawn by using a damage type.
//================================================================================
class SeqAct_HurtPawn extends SequenceAction;


     /**Type of damage to apply.*/ var() class<DamageType> DamageClass<AllowAbstract>;
/**Actor responsible for damage.*/ var Actor Instigator;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Pawn P;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        P = GetPawn(Actor(ObjectVar.GetObjectValue()));

        if (P != none)
            P.TakeDamage(1,none,P.Location,vect(0,0,0),DamageClass,,Instigator);
    }
}


defaultproperties
{
    bCallHandler=false  //The handler function won't be called on all targeted actors.
    ObjCategory="SGDK"  //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Hurt Pawn" //Text label that describes this object.
    VariableLinks[0]=(MinVars=1,MaxVars=1)
    VariableLinks[1]=(ExpectedType=class'SeqVar_Object',LinkDesc="Instigator",MinVars=0,MaxVars=1,PropertyName=Instigator)
}
