KNN knn;
SinOsc sin => dac;

// chord labels
["Cm", "Dm", "C#m", "F/C", "Am/C", "E", "Bb/D", "C+", "Bdim/d", "F#/C#"] @=> string labels[];
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9] @=> int labelsNum[];

// triads (MIDI note numbers or relative scale degrees)
[
    [0, 3, 7],    // Cm
    [2, 5, 9],    // Dm
    [1, 4, 8],    // C#m
    [0, 4, 7],    // F/C
    [0, 4, 9],    // Am/C
    [4, 8, 11],   // E
    [2, 5, 10],   // Bb/D
    [0, 4, 8],    // C+
    [2, 5, 11],   // Bdim/d
    [1, 6, 10]    // F#/C#
] @=> int triads[][];

3 => int noteSetLength;
labels.size() => int labelSize;

// feature matrix: labelSize x noteSetLength
float features[labelSize][noteSetLength];



fun knnTraining(){
    // fill feature matrix
    for (0 => int i; i < labelSize; i++) {
        for (0 => int j; j < noteSetLength; j++) {
            triads[i][j] * 1.0 => features[i][j];
        }
    }

    // train KNN
    knn.train(features);

    // create array for results
    int neighborLabels[2];

    // test chord
    [5.0, 1.0, 2.0] @=> float testChord[];

    // run KNN search (K = 2)
    knn.search(testChord, 4, neighborLabels);

    // print results
    <<< "Nearest neighbors (by index):", neighborLabels[0], neighborLabels[1], neighborLabels[2], neighborLabels[3] >>>;

    // optional: print the chord labels
    for (0 => int i; i < neighborLabels.size(); i++) {
        <<< "Neighbor", i, "=", labels[neighborLabels[i]] >>>;
    }
}

fun makeRandomChord(){
    
}
