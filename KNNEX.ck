//-----------------------------------------------------------------------------
// KNN chord classifier example
//-----------------------------------------------------------------------------

// audio setup
SinOsc sin => dac;
0.3 => sin.gain;

// KNN setup
KNN knn;

// chord labels
["Cm", "Dm", "C#m", "F/C", "Am/C", "E", "Bb/D", "C+", "Bdim/d", "F#/C#"] @=> string labels[];

// triads (feature vectors)
[
    [0, 3, 7],    // Cm
    [2, 5, 9],    // Dm
    [1, 3, 8],    // C#m
    [0, 4, 7],    // F/C
    [0, 4, 9],    // Am/C
    [4, 8, 11],   // E
    [2, 5, 10],   // Bb/D
    [0, 4, 8],    // C+
    [2, 5, 11],   // Bdim/d
    [1, 6, 10]    // F#/C#
] @=> int triads[][];

// convert int[][] -> float[][] for KNN
triads.size() => int N;
triads[0].size() => int D;
float features[N][D];
for (0 => int i; i < N; i++)
    for (0 => int j; j < D; j++)
        triads[i][j] $ float => features[i][j];

// train the model
knn.train(features);

// prediction function

fun string predictChord(int notes[]) {
    float input[notes.size()];
    for (0 => int i; i < notes.size(); i++)
        notes[i] $ float => input[i];

    // predict label index
    knn.predict(input) => int idx;
    return labels[idx];
}

//-----------------------------------------------------------------------------
// test the model interactively
//-----------------------------------------------------------------------------
fun void testChord(int notes[]) {
    <<< "Input:", notes >>>;
    string prediction = predictChord(notes);
    <<< "Predicted chord:", prediction >>>;

    // simple tone output based on root
    notes[0] => int root;
    Std.mtof(60 + root) => sin.freq;
    1::second => now;
}

//-----------------------------------------------------------------------------
// Run a few test cases
//-----------------------------------------------------------------------------

// Try one that matches a known triad
[0, 3, 7] @=> int test1[]; // should match Cm
testChord(test1);

// Try a close variant
[1, 4, 8] @=> int test2[]; // near C#m or C+
testChord(test2);

// Try something out of set
[5, 9, 0] @=> int test3[];
testChord(test3);
