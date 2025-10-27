//Init 

HMM hmm;

SinOsc sillySound => dac;

0.1 => sillySound.gain;

Math.random2(40, 63) => int note;

Std.mtof(note) => sillySound.freq;


//create dataset
[0, 1, 6, 7, 7, 7, 7, 7, 3] @=> int intervals[];

hmm.train(2, 8, intervals);

int results[32];

hmm.generate(32, results);


for( 0 => int i; i < results.size(); i++){
    chout <= results[i] <= " ";
}
chout <= IO.newline();

for(0 => int i; i < results.size(); i++){
    Math.random2(0, 1) => int direction;

    if(direction == 0){
        note + results[i] => note;
    }

    else if(direction == 1){
        note - results[i] => note;
    }

    Std.mtof(note) => sillySound.freq;

    1::second => now;
}




