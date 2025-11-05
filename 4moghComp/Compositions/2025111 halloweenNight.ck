//halloween night dot ck
// Amogh Dwivedi

// i want to learn array operations
//      - how do i remove items?
//      - how do i add items
//      xx for the second argument of hmm.train -- is it just the max value + 1? also, does the array need to have all the intermediate values?

SinOsc sillySound[16];
TriOsc sillySoundHarm[16];

ADSR env[16];
ADSR envHarm[16];

NRev rev;
1.0 => rev.mix;

chout <= "*****************";
chout <= IO.newline();

for (0 => int i; i < 16; i++)
{
    (3, 9, 0.1, 4) => env[i].set;
    sillySound[i] => env[i];

    (1.0/16.0) => sillySound[i].gain;

    env[i] => dac;

    (0.05/16.0) => sillySoundHarm[i].gain;
    (5, 3, 0.1, 8) => envHarm[i].set;
    sillySoundHarm[i] => envHarm[i] => rev;

    if(i%2 == 0) envHarm[i] => dac.left;
    if(i%2 == 1) envHarm[i] => dac.right;
}

rev => dac;

HMM hmmScale;

HMM hmmHarmonic[5];

/// this is my basic scale.
[0, 7, 5, 7, 10, 7, 7, 5, 3, 5, 0, 0, 0, 7, 5, 3, 5] @=> int basicScale[];
//0, 3, 5, 7, 10

// these are the suggested harmonic possibilities 
// for each note in the scale
[
    [7, 7, 7, 3], // INDEX 0: harmonic choices for 0 (7,7,7,3)
    [5, 5, 5, 12], // INDEX 1: harmonic choices for 3
    [1, 1, 0], // INDEX 2: harmonic choices for 5
    [10, 10, 10, 3, 0], // INDEX 3: harmonic choices for 7
    [7, 7, 0] // INDEX 4: harmonic choices for 10

] @=> int scaleHarmonizations[][];

[8, 13, 2, 11, 8] @=> int scaleHarmonizationsNumEmissions[];

hmmScale.train(2, 11, basicScale);

int scaleResults[16];

hmmScale.generate(scaleResults.cap(), scaleResults);

for (0 => int i; i < 5; i++)
{
    hmmHarmonic[i].train(2, scaleHarmonizationsNumEmissions[i], scaleHarmonizations[i]);
}

int harmResults[5][4];

for (0 => int i; i < 5; i++)
{
    hmmHarmonic[i].generate(4, harmResults[i]);
}

chout <= "scaleResults:";

for (0 => int i; i < scaleResults.cap(); i++)
{
    chout <= scaleResults[i] <= " ";
}

chout <= IO.newline();

for (0 => int i; i < 5; i++)
{
    chout <= "note " <= i <= " harmonic choices:" <= " ";
    for (0 => int j; j < 4; j++)
    {
        chout <= harmResults[i][j] <= " ";
    }
    chout <= IO.newline();
}

//chout <= IO.newline();

1::second => now;

while (true)
{
    for (0 => int i; i < 16; i++)
{
    scaleResults[i] => int currentNote;

    chout <= "i: " <= i <= "/////// currentNote: " <= currentNote;
    chout <= IO.newline();

    Std.mtof(currentNote+63) => sillySound[i].freq;

    harmResults[fetchIndex(currentNote)][Math.random2(0, 3)] => int harmNote;

    chout <= "harmNote: " <= harmNote;
    chout <= IO.newline();

    Std.mtof(harmNote+63+12) => sillySoundHarm[i].freq;

    1 => env[i].keyOn;
    1 => envHarm[i].keyOn;

    Math.random2f(1, 3)::second => now;
    
    1 => env[i].keyOff;
    1 => envHarm[i].keyOff;
}
}


15::second => now;

public int fetchIndex(int noteNum)
{
    -1 => int indexVal;
    if (noteNum == 0)
        0 => indexVal;
    if (noteNum == 3)
        1 => indexVal;
    if (noteNum == 5)
        2 => indexVal;
    if (noteNum == 7)
        3 => indexVal;
    if (noteNum == 10)
        4 => indexVal;

    return indexVal;                                     
}