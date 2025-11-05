KNN knn;

SinOsc randomSin[3];
TriOsc knnSin[3];

for (0 => int i; i < 3; i++)
{
    randomSin[i] => dac.left;
    0.1 => randomSin[i].gain;

    0.1 => knnSin[i].gain;
    knnSin[i] => dac.right;   
}

["Cm", "Dm", "C#m", "F/C", "Am/C", "E", "Bb/D", "C+", "B°/D", "F#/C#"] @=> string labels[];
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] @=> int labelsNum[];

[

    [0, 3, 7], //Cm
    [2, 5, 9], //Dm
    [1, 4, 8], //C#m
    [0, 4, 7], // F/C
    [0, 4, 9], // Am/C
    [4, 8, 11],// E 
    [2, 5, 10], // Bb/D
    [0, 4, 8],// C+
    [2, 5, 11],// b°/d
    [1, 6, 10] // F#/C#

] @=> int triads[][];

// triads[0].size() => int noteSetLength;
3 => int noteSetLength;

labels.size() => int labelSize;

float features[labelSize][noteSetLength];

makeRandomChord() @=> int thisRandomChord[];
setRandSin(thisRandomChord);


for (0=> int i; i <3; i++)
{
    <<<thisRandomChord[i]>>>;
}

knnTraining(thisRandomChord) => int getThisChord;

for (0 => int i; i < 3; i++)
{
    Std.mtof(triads[getThisChord][i]+60) => knnSin[i].freq;
}


50::second => now;


fun setRandSin(int freq[])
{   
    for (0 => int i; i < 3; i++)
    {
        Std.mtof(freq[i]+60) => randomSin[i].freq;
    }
}

fun setKnnSin(int chordIndex)
{

}


fun int knnTraining(int chord[])
    {
        for (0 => int i; i < labelSize; i++)
    {
        for(0 => int j; j < noteSetLength; j++)
        {
        triads[i][j] * 1.0 => features [i][j];
        }
    }

    knn.train(features);

    int neighborLabels[2];
    int neighborTriads[2];

    convertIntFloat(chord) @=> float testChord[]; // A/C#

    knn.search(testChord, 2, neighborLabels); // our k value is 2.

    //<<<"Nearest neighobrs by index:", neighborLabels[0], neighborLabels[1]>>>;

    for (0 => int i; i < neighborLabels.size(); i++)
    {
        <<<"Neighbor", i, "=", labels[neighborLabels[i]] >>>;
    }

    return neighborLabels[0];
}

fun int[] makeRandomChord()
{
    Math.random2(0, 4) => int bass;
    bass + Math.random2(3, 5) => int note1;

    0 => int note2;

    if (note1 < 5) note1 + Math.random2(3, 7) =>  note2;
    else note1 + Math.random2(3, 4) =>  note2;

    [bass, note1, note2] @=> int randomChord[];

        // <<<bass>>>;
        //     <<<note1>>>;
        //         <<<note2>>>;

    return randomChord;
}

fun float[] convertIntFloat (int arr[])
{
    float actualArray[arr.cap()];

    for (0 => int i; i < arr.size(); i++)
    {
        arr[i] * 1.0 => actualArray[i];
    }

    return actualArray;
}