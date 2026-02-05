//Written by Colton Arnold Fall 2025

@import "../signalSendClasses/OSC/globalOSCSendClass.ck";


oscSends osc;
// Marimba MIDI notes
[
[0, 1, 2, 3, 4, 5, 6, 7],
[8, 9, 10, 11, 12, 13, 14, 15],
[16, 17, 18, 19, 20, 21, 22, 23],
[24, 25, 26, 27, 28, 29, 30, 31],
[32, 33, 34, 35, 36, 37, 38, 39]] @=> int mScl[][];

HMM hmm;

osc.init("192.168.0.15", 8001);

float durArray[0];
250::ms => dur beat;

// Note Duration HMM
fun void noteDur() {
    32 => int length;

    [0, 1, 0, 2, 1, 1, 1, 1, 2, 1, 1, 1] @=> int observations[];
    hmm.train(2, 3, observations);

    int results1[length];
    hmm.generate(length, results1);

    0.0 => float counter;

    for (0 => int i; counter < length / 2 && i < length; i++) {
        float dur;

        if (results1[i] == 0) { 0.5 => dur; }
        else if (results1[i] == 1) { 1.0 => dur; }
        else if (results1[i] == 2) { 2.0 => dur; }
        else { continue; }

        counter + dur => counter;
        durArray << dur;
        chout <= results1[i] <= " ";
    }

    chout <= IO.newline();

    if (counter > 16.0) {
        counter - 16.0 => float remainder;
        <<<"Over by:", remainder>>>;

        // Remove last duration
        durArray[durArray.size() - 1]=> float lastDur;
        counter - lastDur => counter;

        // Add back trimmed duration if remainder is less than the last duration
        if (lastDur - remainder > 0.0) {
            durArray << (lastDur - remainder);
            counter + (lastDur - remainder) => counter;
        }
    }

    <<<"Final duration sum:", counter>>>;

}

fun void marimbotSend(int note, int vel){
    osc.init("192.168.0.15", 8001);
    osc.send("/modulettes", note, vel);

}

fun void marimbotPlay(int note, int vel, dur long){
   marimbotSend(note, vel);
   long => now;
   marimbotSend(note, 0);
}

fun void marimBotOut(){

    noteDur();

    [2, 1, 2, 3, 4, 0, 1] @=> int observations2[];
    hmm.train( 2, 6, observations2 );
    int results2[16];
    hmm.generate( 16, results2 );

    

    // output
    for ( 0 => int i; i < results2.size(); i++ )
    {
        
        //chout <= results2[i] <= " ";
        marimbotPlay( mScl[results2[i]][Math.random2(0, 7)], 127, durArray[i] * beat);

        chout <= results2[i] <= " ";
        
    }
    <<<"Slices">>>;
    chout <= IO.newline();
    durArray.reset();
    chout <= IO.newline();

}


while(true) {
    marimBotOut();
    // shakeShake(1000, 20);
}