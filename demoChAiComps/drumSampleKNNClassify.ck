
// Feature extraction + KNN + PCA 2D mapping + nearest-neighbor search


// Base folder
me.dir() + "drums/" => string baseDir;

// init arrays
string kicks[15];
string snares[15];
string claps[15];
string hats[15];

// Fill arrays
for (1 => int i; i <= 15; i++) {
    "kick" + i + ".wav" @=> kicks[i-1];
    "snare" + i + ".wav" @=> snares[i-1];
    "clap" + i + ".wav" @=> claps[i-1];
    "hat" + i + ".wav" @=> hats[i-1];
}

// Combine all into one array of full paths
string allFiles[0];
string allLabels[0];
for (0 => int i; i < 15; i++) {
    // Kicks
    baseDir + "kick/" + kicks[i] => string filepath;
    allFiles << filepath;
    allLabels << "kick";

    // Snares
    baseDir + "snare/" + snares[i] => string filepath2;
    allFiles << filepath2;
    allLabels << "snare";

    // Claps
    baseDir + "clap/" + claps[i] => string filepath3;
    allFiles << filepath3;
    allLabels << "clap";

    // Hats
    baseDir + "hat/" + hats[i] => string filepath4;
    allFiles << filepath4;
    allLabels << "hat";
}


// feature matrix
float featureMatrix[0][0];
allFiles.size() => int N;

// feature extraction func
fun float[] extractFeatures(string filename) {
    SndBuf buf => Flip flip => FFT fft;
    fft => Centroid centroid => RMS rms => Flux flux => MFCC mfcc => FeatureCollector collector;

    1024 => int frameSize;
    frameSize => fft.size;
    Windowing.hamming(frameSize) => fft.window;
    13 => mfcc.numCoeffs;
    44100 => mfcc.sampleRate;

    // Connect analysis chain
    fft =^ centroid;
    fft =^ rms;
    fft =^ flux;
    fft =^ mfcc;
    centroid =^ collector;
    rms =^ collector;
    flux =^ collector;
    mfcc =^ collector;

    filename => buf.read;
    1 => buf.loop;
    buf.length() => now;

    collector.upchuck() @=> UAnaBlob blob;
    blob.fvals() @=> float feats[];
    return feats;
}

// EXTRACT FEATURES
for (0 => int i; i < N; i++) {
    extractFeatures(allFiles[i]) @=> float feats[];
    featureMatrix << feats;
}

//train knn
KNN2 knn2;

// Map indices back to class names
["kick", "snare", "clap", "hat"] @=> string classNames[];

// Pick a random sample from allFiles
Math.random2(0, allFiles.size() - 1) => int sampleIndex;
baseDir + "newSample.wav" => string newFile;
allLabels[sampleIndex] => string actualLabel;

<<< "Classifying file:", newFile >>>;
<<< "Actual class:", actualLabel >>>;

// Extract features
extractFeatures(newFile) @=> float newVec[];

// Number of neighbors
3 => int k;

// Prepare output
int predictedLabel;
float prob[4];

// Predict
knn2.predict(newVec, k, prob) => predictedLabel;

// Print predicted class name
<<< "Predicted class:", classNames[predictedLabel] >>>;

// Print probabilities numerically
<<< "Class probabilities: kick, snare, clap, hat ->" >>>;
for (0 => int i; i < prob.size(); i++) {
    <<< classNames[i], ":", prob[i] >>>;
}

// Give ChucK a small yield so it finishes cleanly
0.1::second => now;

//STEP 4: PCA REDUCTION TO 2D
featureMatrix[0].size() => int M;
float input[N][M];
for (0 => int i; i < N; i++) {
    for (0 => int j; j < M; j++) featureMatrix[i][j] => input[i][j];
}

float output[N][2];
PCA.reduce(input, 2, output);

//STEP 5: SAVE PCA MAP TO CSV
FileIO fout;
"xy_map_pca.csv" => string csvFile;
fout.open(csvFile, FileIO.WRITE);
fout.write("x,y,label\n");
for (0 => int i; i < N; i++) {
    output[i][0] => float x;
    output[i][1] => float y;
    fout.write(x + "," + y + "," + allLabels[i] + "\n");
}
fout.close();
<<< "Saved PCA 2D map to CSV:", csvFile >>>;

//  STEP 6: NEAREST-NEIGHBOR SEARCH IN PCA SPACE
fun string findNearestSample(float xQuery, float yQuery) {
    1e10 => float minDist;
    0 => int nearestIndex;

    for (0 => int i; i < N; i++) {
        output[i][0] - xQuery => float dx;
        output[i][1] - yQuery => float dy;
        Math.sqrt(dx*dx + dy*dy) => float dist;

        if (dist < minDist) {
            dist => minDist;
            i => nearestIndex;
        }
    }
    return allLabels[nearestIndex];
}

// Example query
0.1 => float qx;
0.2 => float qy;
findNearestSample(qx, qy) @=> string nearestSample;
<<< "Nearest sample to (", qx, ",", qy, "):", nearestSample >>>;

