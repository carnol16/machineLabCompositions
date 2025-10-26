//Init 

HMM hmm;

SinOsc sillySound => dac;

1 => sillySound.gain;

Math.random2(40,63) * 1.0 => float note;

Std.mtof(note) => sillySound.freq;

//create dataset
[7, 7, 7, 7, 7, 7, 5, 5, 3, 1, 1, 1, 1] @=> int intervals[];

hmm.train(2, 8, intervals);

intervals.cap()*5 => int resultsSize;

int results[resultsSize];

hmm.generate(resultsSize, results);

for (0 => int i; i < results.cap(); i++)
{
    //<<<results[i]>>>;
    chout <= results[i] <= " ";
}

chout <= IO.newline();


for (0 => int i; i < 16; i++)
{
    Math.random2(0, 1) => int direction;

    if (direction == 0)
    {
        note + results[i] => note;
    }
    if (direction == 1)
    {
        note - results[i] => note;
    }

    Std.mtof(note) => sillySound.freq;

    1::second => now;
}