//======================================
// Rhythmic KNN Marimba Pattern Generator v2
// Using HMM rhythm pattern from Colton Arnold (Fall 2025)
//======================================

@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";


KNN2 knn;
HMM hmm;
oscSends osc;
bpmSet bpmClass;

osc.init("192.168.1.145", 8001);
["/marimba"] @=> string labelNames[];

// Training note sets (3-note chords)
[[[45,127],[48,80],[52,90]], 
[[47,120],[50,85],[54,95]], 
[[48,110],[52,70],[55,88]], 
[[50,115],[53,90],[57,100]], 
[[52,105],[55,75],[59,87]], 
[[53,112],[57,95],[60,100]], 
[[54,108],[59,85],[62,92]],
[[55,120],[60,78],[64,85]], 
[[57,107],[62,93],[65,97]], 
[[59,103],[64,82],[67,88]], 
[[60,118],[65,100],[69,110]],
[[62,95],[66,80],[71,90]], 
[[64,125],[67,85],[72,95]], 
[[65,105],[69,83],[74,87]],
[[67,110],[71,88],[76,100]],
[[69,108],[72,77],[77,85]], 
[[71,115],[74,92],[81,98]], 
[[72,97],[76,85],[81,90]], 
[[74,120],[77,100],[83,110]], 
[[76,110],[79,85],[84,95]]] @=> int noteSets[][][];

3 => int noteSetLength;

//--------------------------------------
// Build features + labels for KNN
//--------------------------------------
float features[0][0];
int labels[0];

for (int i; i < noteSets.size(); i++) {
    float v[0];
    for (int j; j < noteSets[i].size(); j++) {
        v << noteSets[i][j][1];
    }
    features << v;
    labels << i;
}

knn.train(features, labels);

//bpm
float durArray[0];
int orderArray[0];
bpmClass.bpm(80) => float msPerBeat;
msPerBeat::ms => dur beat;
16 => int totalBeats;

//rhythm set
fun void noteDur() {
    totalBeats * 1.0 => float remainderLength;
    durArray.clear();
    totalBeats * 2 => int length;

    [0, 1, 0, 2, 5, 1, 5, 1, 2, 1, 3, 1] @=> int observations[];
    hmm.train(2, 6, observations);
    int results1[length];
    hmm.generate(length, results1);

    0.0 => float counter;

    for (0 => int i; counter < totalBeats && i < length; i++) {
        float duration;
        if (results1[i] == 0) { 0.5 => duration; }
        else if (results1[i] == 1) { 1.0 => duration; }
        else if (results1[i] == 2) { 2.0 => duration; }
        // else if (results1[i] == 3) { 0.66 => dur; }
        // else if (results1[i] == 4) { 1.33 => dur; }
        // else if (results1[i] == 5) { 3.0 => dur; }
        else { continue; }

        counter + duration => counter;
        durArray << duration;
        chout <= results1[i] <= " ";
    }
    chout <= IO.newline();

    if (counter > remainderLength) {
        counter - remainderLength => float remainder;
        <<<"Over by:", remainder>>>;

        durArray[durArray.size() - 1] => float lastDur;
        counter - lastDur => counter;

        if (lastDur - remainder > 0.0) {
            durArray << (lastDur - remainder);
            counter + (lastDur - remainder) => counter;
        }
    }

    <<<"Final duration sum:", counter>>>;
}



// Send + play OSC note

fun void marimbotSend(string instrument, int note, int vel) {
    osc.send(instrument, note, vel);
}

fun void marimbotPlay(string instrument, int note, int vel, dur duration) {
    
    marimbotSend(instrument, note, vel);
    duration => now;
    marimbotSend(instrument, note, 0);    

}

fun void breakBoPlay(){
    for(0 => int i; i < totalBeats; i++){
        osc.send("/breakBot", 1, 127);
        if(i % 2 == 1){
            osc.send("/breakBot", 5, 127);
        }
        if(i % 4 == 0){
            osc.send("/breakBot", 11, 127);
        }
        beat => now;
    }
}



// Generate and play rhythmic chord sequence

fun void rhythmicChordPattern() {
    noteDur(); // fill durArray

    //chord or arp

    [0, 1, 0, 0, 1, 0, 0, 1] @=> int observations2[];
    hmm.train( 2, 2, observations2 );
    int results2[totalBeats];
    hmm.generate( totalBeats, results2 );

    // make 32 random chords from noteSets
    int chordSeq[0][0][0]; 
    for (int i; i < totalBeats * 2; i++) {
        Math.random2(0, noteSets.size()-1) => int idx;
        chordSeq << noteSets[idx];
    }
    // play through pattern
    for (int i; i < durArray.size() && i < chordSeq.size(); i++) {
        durArray[i] * beat => dur durTime;
        "" => string noteList;

        for (int j; j < chordSeq[i].size(); j++) {

            if(results2[j] == 0){
                chordSeq[i][j][0] => int note;
                chordSeq[i][j][1] => int vel;
                noteList + "[" + Std.itoa(note) + "," + Std.itoa(vel) + "] " => noteList;

                if(vel < 79){
                    80 => vel;
                }
                if(note < 60 && vel < 95){
                    95 => vel;
                }
                spork ~ marimbotPlay(labelNames[0], note, vel, durTime);

            }

            if(results2[j] == 1){
                chordSeq[i][j][0] => int note;
                chordSeq[i][j][1] => int vel;
                noteList + "[" + Std.itoa(note) + "," + Std.itoa(vel) + "] " => noteList;
                if(vel < 79){
                    80 => vel;
                }   

                if(note < 60 && vel < 95){
                    95 => vel;
                }   

                marimbotPlay(labelNames[0], note, vel, durTime / noteSetLength);
                
            }
            
        }
        <<< "Chord", i, "Dur:", durArray[i], "beats → Notes:", noteList >>>;
        durTime => now;
    }

    <<< "--- Measure Complete ---" >>>;
}

while (true) {
    //spork ~ breakBoPlay();
    spork~rhythmicChordPattern(); // generate + play new pattern
    beat * totalBeats => now;
}


