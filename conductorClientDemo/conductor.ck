@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";
@import "./conductorSendsClass.ck";


oscSends oscSends;
bpmSet bpmClass;
conductorSend ductSend;
HMM hmm;

//send to clients
["192.168.1.148", "192.168.1.117"] @=> string ipAddress[];

[8005, 8006] @=> int port[];
["/time", "/freq", "/start"] @=> string address[];

"192.168.1.145" => string ipAddressServer;
8001 => int portServer;


ductSend.init(ipAddress, port);

oscSends.init(ipAddressServer, portServer);


80 => int bpm;


bpmClass.bpm(bpm) => float msPerBeat;
msPerBeat::ms => dur beat;
16 => int totalBeats;

Std.itoa(bpm) => string bpmString;
Std.itoa(totalBeats) => string totalBeatsString;

[address[0], bpmString, totalBeatsString] @=> string timeInfo[];
ductSend.setMessages(timeInfo);

1000::ms => now;

[address[2], "1"] @=> string startInfo[];
ductSend.setMessages(startInfo);

//piece for conductor
fun string toString(int dataPoint){
    Std.itoa(dataPoint) => string pointString;
    return pointString;
}

fun int toInt(string dataPoint){
    Std.atoi(dataPoint) => int pointInt;
    return pointInt;
}

SinOsc osc => ADSR env1 => dac;

0.5 => osc.gain;

(1::ms, beat / 8, 0, 1::ms) => env1.set;


[0, 4, 7] @=> int major[];
[0, 3, 7] @=> int minor[];

48 => int offset;
int position;


// Marimba MIDI notes
[45, 47, 48, 50, 52, 53, 54, 55, 57, 59, 
60, 62, 64, 65, 66, 67, 69, 71, 72, 74, 
76, 77, 78, 79, 81, 83, 84, 86, 88, 89, 
90, 91, 93, 95, 96] @=> int mScl[];

fun void marimbotSend(int note, int vel){
    oscSends.send("/marimba", note, vel);

}

fun void marimbotPlay(int note, int vel, dur long){
   marimbotSend(note, vel);
   long => now;
   marimbotSend(note, 0);
}

fun void marimBotOut(){
    while(true){
        [10, 21, 28, 2, 32, 5, 34, 22, 15, 4] @=> int observations2[];
        hmm.train( 2, 36, observations2 );
        int results2[16];
        hmm.generate( 16, results2 );

        

        // output
        for ( 0 => int i; i < results2.size(); i++ )
        {
            
            //chout <= results2[i] <= " ";
            marimbotPlay( mScl[results2[i]], 127, beat);

            chout <= results2[i] <= " ";
            
        }
        <<<"Slices">>>;
        chout <= IO.newline();
        chout <= IO.newline();
    }
    //noteDur();


}

fun void arp() {
    while (true) {
        for (0 => int j; j < minor.cap(); j++) {
            Std.mtof(minor[j] + offset + position) => osc.freq;
            1 => env1.keyOn;
            beat => now;
        } 
    }
}
150::ms => now;

spork~ marimBotOut();
//spork~ arp();

while(true){
    1::second => now;

}



