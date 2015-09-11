//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Sequence Action Start Music Track > SequenceAction > SequenceOp >
//     > SequenceObject > Object
//
// A sequence action is a representation of an action that performs a behavior on
// any targeted objects.
// This action plays/stops a music track.
//================================================================================
class SeqAct_StartMusicTrack extends SequenceAction;


                                /**The music track to play/stop.*/ var() SoundCue MusicSoundCue;
/**Time taken to fade a track out while fading another track in.*/ var() float CrossfadeTime;


/**
 * Called when this node is activated.
 */
event Activated()
{
    local SeqVar_Object ObjectVar;
    local Controller C;

    foreach LinkedVariables(class'SeqVar_Object',ObjectVar,"Target")
    {
        C = GetController(Actor(ObjectVar.GetObjectValue()));

        if (C != none && SGDKPlayerController(C) != none)
        {
            if (InputLinks[0].bHasImpulse)
            {
                SGDKPlayerController(C).GetMusicManager().StartMusicTrack(MusicSoundCue,CrossfadeTime);

                OutputLinks[0].bHasImpulse = true;
            }
            else
            {
                SGDKPlayerController(C).GetMusicManager().StopMusicTrack(MusicSoundCue,CrossfadeTime);

                OutputLinks[1].bHasImpulse = true;
            }
        }
    }
}


defaultproperties
{
    bAutoActivateOutputLinks=false      //All output links won't automatically be activated when this op has finished executing.
    bCallHandler=false                  //The handler function won't be called on all targeted actors.
    InputLinks[0]=(LinkDesc="Play")     //Input link containing a connection; activated if the music track must be played.
    InputLinks[1]=(LinkDesc="Stop")     //Input link containing a connection; activated if the music track must be stopped.
    ObjCategory="SGDK"                  //Editor category for this object. Determines which kismet submenu this object should be placed in.
    ObjName="Start Music Track"         //Text label that describes this object.
    OutputLinks[0]=(LinkDesc="Played")  //Output link containing a connection; activated if the music track is played.
    OutputLinks[1]=(LinkDesc="Stopped") //Output link containing a connection; activated if the music track is stopped.
}
