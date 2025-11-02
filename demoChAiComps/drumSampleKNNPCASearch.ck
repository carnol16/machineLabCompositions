// ---------------------- CONFIG ----------------------
me.dir() + "drums/" => string baseDir;

// Number of samples per drum type
15 => int numSamples;

// Arrays for each drum type
string kicks[numSamples];
string snares[numSamples];
string claps[numSamples];
string hats[numSamples];

for (1 => int i; i <= numSamples; i++) {
    "kick" + i + ".wav" => kicks[i-1];
    "snare" + i + ".wav" => snares[i-1];
    "clap" + i + ".wav" => claps[i-1];
    "hat" + i + ".wav" => hats[i-1];
}

// -------------------- COMBINE ALL FILES --------------------
numSamples * 4 => int nSamples;
string allFiles[nSamples];
string allLabels[nSamples];

for (0 => int i; i < numSamples; i++) {
    (baseDir + "/kick/" + kicks[i]) => allFiles[i * 4];
    "kick" => allLabels[i * 4];

    (baseDir + "/snare/" + snares[i]) => allFiles[i * 4 + 1];
    "snare" => allLabels[i * 4 + 1];

    (baseDir + "/clap/" + claps[i]) => allFiles[i * 4 + 2];
    "clap" => allLabels[i * 4 + 2];

    (baseDir + "/hat/" + hats[i]) => allFiles[i * 4 + 3];
    "hat" => allLabels[i * 4 + 3];
}

// -------------------- FEATURE EXTRACTION --------------------
fun float[] extractFeatures(string filePath) {
    SndBuf buf => blackhole;
    buf.read(filePath);
    10::ms => now; // small wait to initialize

    float features[0];

    // RMS
    RMS rms => buf;
    rms.upchuck() @=> UAnaBlob blobRMS;
    features << blobRMS.fval(0);

    // Centroid
    Centroid centroid => buf;
    centroid.upchuck() @=> UAnaBlob blobCentroid;
    features << blobCentroid.fval(0);

    // Zero-crossings
    ZeroX zx => buf;
    zx.upchuck() @=> UAnaBlob blobZX;
    features << blobZX.fval(0);

    // MFCC (13 coefficients)
    MFCC mfcc => buf;
    mfcc.numCoeffs(13);
    mfcc.upchuck() @=> UAnaBlob blobMFCC;
    for (0 => int i; i < 13; i++) {
        features << blobMFCC.fval(i);
    }

    return features;
}

// -------------------- EXTRACT FEATURES FOR ALL SAMPLES --------------------
float featureMatrix[0][0]; // dynamic array of arrays
for (0 => int i; i < allFiles.size(); i++) {
    extractFeatures(allFiles[i]) @=> float features[];
    featureMatrix << features; // append each feature vector
}
<<<"Features extracted">>>;


// -------------------- PCA REDUCTION --------------------
float projectedFeatures[0][0]; // dynamic array of arrays
PCA.reduce(featureMatrix, 2, projectedFeatures);
<<<"PCA reduction complete">>>;

// Map projected features to XY coordinates
float xyMap[0][0];
for (0 => int i; i < projectedFeatures.size(); i++) {
    xyMap << projectedFeatures[i];
}

// -------------------- SND PLAYBACK --------------------
SndBuf player => dac;

// -------------------- PLAY SAMPLE FUNCTION --------------------
fun void playSample(string path) {
    path => player.read;
    0 => player.pos;
    1.0 => player.play;
}

// -------------------- FIND NEAREST SAMPLE --------------------
fun int findNearest(float queryX, float queryY) {
    1e10 => float minDist;
    0 => int nearestIndex;

    for (0 => int i; i < nSamples; i++) {
        (xyMap[i][0] - queryX) * (xyMap[i][0] - queryX) +
        (xyMap[i][1] - queryY) * (xyMap[i][1] - queryY) => float distSquared;
        Math.sqrt(distSquared) => float dist;

        if (dist < minDist) {
            dist => minDist;
            i => nearestIndex;
        }
    }

    return nearestIndex;
}

// -------------------- AUTO SEARCH LOOP --------------------
while (true) {
    // Random coordinates on PCA plane
    Math.random2f(0.0, 1.0) => float queryX;
    Math.random2f(0.0, 1.0) => float queryY;

    // Find nearest sample
    findNearest(queryX, queryY) => int nearest;

    <<< "Playing nearest sample:", allFiles[nearest], "Class:", allLabels[nearest] >>>;

    // Play it
    playSample(allFiles[nearest]);

    // Wait a bit so we can hear the sample
    1::second => now;
}
