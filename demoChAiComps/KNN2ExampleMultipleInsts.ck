//======================================
// Rhythmic KNN Marimba Pattern Generator v2
// Using HMM rhythm pattern from Colton Arnold (Fall 2025)
//======================================

@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";


KNN2 knn;
HMM hmm;
oscSends osc;
oscSends oscLydia;
bpmSet bpmClass;

osc.init("192.168.1.145", 8001);
oscLydia.init("192.168.1.145", 50000);
["/marimba", "/trimpbeat"] @=> string labelNames[];

// Combined note sets per instrument
[
    // marimba
    [
        [[45,127],[48,80],[52,90]],
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
        [[76,110],[81,85],[84,95]]
    ],

    // trimpbeat
    [
        [[60,100],[64,85],[67,90]],
        [[61,95],[64,80],[68,88]],
        [[62,105],[65,85],[69,90]],
        [[63,100],[67,85],[70,90]],
        [[64,110],[67,90],[71,95]],
        [[65,108],[69,88],[72,95]],
        [[66,107],[69,85],[73,92]],
        [[67,115],[71,90],[74,95]],
        [[68,110],[72,85],[75,90]],
        [[69,120],[72,90],[76,95]],
        [[70,105],[74,85],[77,90]],
        [[71,115],[75,88],[78,95]],
        [[72,120],[76,90],[79,95]],
        [[73,108],[77,88],[79,92]],
        [[74,110],[78,85],[79,90]],
        [[75,115],[79,87],[79,93]],
        [[76,120],[79,90],[79,95]],
        [[77,110],[79,85],[79,90]],
        [[78,115],[79,88],[79,90]],
        [[79,120],[79,95],[79,95]]
    ]
] @=> int pitchedNoteSets[][][][]; // pitched


3 => int noteSetLength;



//--------------------------------------
// Build features + labels for KNN
//--------------------------------------
float features[0][0];
int labels[0];


// Loop through all instruments
for (int inst; inst < pitchedNoteSets.size(); inst++) {
    // Loop through all chords in that instrument
    for (int i; i < pitchedNoteSets[inst].size(); i++) {
        float v[0];
        // Grab all velocities in that chord
        for (int j; j < pitchedNoteSets[inst][i].size(); j++) {
            v << pitchedNoteSets[inst][i][j][1];
        }
        // Store feature vector + label
        features << v;
        labels << i + (inst * 1000); // unique label per instrument (avoid overlap)
    }
}

// Train KNN once using all instrument data
knn.train(features, labels);

//bpm
float durArrayMarimba[0];
float durArrayLydia[0];
int orderArray[0];
bpmClass.bpm(60) => float msPerBeat;
msPerBeat::ms => dur beat;
16 => int totalBeats;



fun float[] noteDur() {
    totalBeats * 1.0 => float remainderLength;
    float localDurArray[0];
    totalBeats * 2 => int length;


    [2,1,0,1,1,2,1,2,] @=> int observations[];
    hmm.train(2, 3, observations);

    int results1[length];
    hmm.generate(length, results1);

    0.0 => float counter;

    for (0 => int i; counter < 16 && i < length; i++) {
        float duration;

        if (results1[i] == 0) { 0.5 => duration; }
        else if (results1[i] == 1) { 1.0 => duration; }
        else if (results1[i] == 2) { 2.0 => duration; }
        else { continue; }

        counter + duration => counter;
        localDurArray << duration;
        chout <= results1[i] <= " ";
    }

    chout <= IO.newline();

    if (counter > remainderLength) {
        counter - remainderLength => float remainder;
        <<<"Over by:", remainder>>>;

        // Remove last duration
        localDurArray[localDurArray.size() - 1]=> float lastDur;
        counter - lastDur => counter;

        // Add back trimmed duration if remainder is less than the last duration
        if (lastDur - remainder > 0.0) {
            localDurArray << (lastDur - remainder);
            counter + (lastDur - remainder) => counter;
        }
    }
    
    <<<"Final duration sum:", counter>>>;
    return localDurArray;
}




// Send + play OSC note

fun void instSend(string instrument, int note, int vel) {
    oscLydia.send(instrument, note, vel);
}

fun void instPlay(string instrument, int note, int vel, dur duration) {
    
    instSend(instrument, note, vel);
    duration => now;
    instSend(instrument, note, 0);    

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

fun void rhythmicChordPattern(int name) {
    // Each instrument gets its own unique rhythm
    noteDur() @=> float durArray[];

    // HMM to decide per-beat behavior (0 = chord, 1 = arp)
    [0, 1, 0, 0, 1, 0, 0, 1] @=> int observations2[];
    hmm.train(2, 2, observations2);
    int results2[totalBeats * 2];
    hmm.generate(totalBeats * 2, results2);

    pitchedNoteSets[name] @=> int currentNoteSet[][][];

    // Create random chord sequence
    int chordSeq[0][0][0];
    for (int i; i < totalBeats * 2; i++) {
        Math.random2(0, currentNoteSet.size() - 1) => int idx;
        chordSeq << currentNoteSet[idx];
    }

    // Main performance loop
    for (int i; i < durArray.size() && i < chordSeq.size(); i++) {
        durArray[i] * beat => dur durTime;

        <<< "Instrument:", labelNames[name], "Step:", i,
            "Mode:", (results2[i] == 0 ? "Chord" : "Arp"),
            "Dur:", durArray[i] >>>;

        // CHORD MODE
        if (results2[i] == 0) {
            <<< "→ chord" >>>;
            // Play all notes simultaneously
            for (int j; j < chordSeq[i].size(); j++) {
                chordSeq[i][j][0] => int note;
                chordSeq[i][j][1] => int vel;

                if(labelNames[0] == "/marimba"){
                    if (vel < 79){
                        80 => vel;
                    }
                    
                    if (note < 60 && vel < 95){ 
                        95 => vel;
                    }
                }
                spork ~ instPlay(labelNames[name], note, vel, durTime);
            }

            // Advance time after full chord duration
            durTime => now;
        }

        // ARP MODE
        else if (results2[i] == 1) {
            <<< "→ arp" >>>;
            durTime / noteSetLength => dur subDur;

            for (int j; j < chordSeq[i].size(); j++) {
                chordSeq[i][j][0] => int note;
                chordSeq[i][j][1] => int vel;

                if(labelNames[0] == "/marimba"){
                    if (vel < 79){
                        80 => vel;
                    }
                    
                    if (note < 60 && vel < 95){ 
                        95 => vel;
                    }
                }
                // sequentially play notes, each for subDur
                instPlay(labelNames[name], note, vel, subDur);
            }

            // no extra "durTime => now" here, since instPlay already advances time
        }
    }

    //<<< "---", labelNames[name], "Measure Complete ---" >>>;
}




while (true) {
    spork~rhythmicChordPattern(0); // generate + play new pattern
    //spork~rhythmicChordPattern(1);
    spork~breakBoPlay();
    
    totalBeats::beat => now; // wait one measure before restarting


}


