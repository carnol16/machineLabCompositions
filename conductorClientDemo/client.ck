@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";
@import "./clientRecievesClass.ck";

oscSends oscSendInst;
bpmSet bpmClass;
clientReceive ductReceive;

// connection info
"192.168.1.145" => string ipAddressServer;
8001 => int portServer;
8005 => int portDuct;

//Instrument sends adn notes
["/marimba", "/breakBot", "/tammy", "/ganapali"] @=> string instAddress;

//notes for breakBot
[0, 1, 3, 5, 11] @=> int breakBotArray[];

//notes for ganapati
[1, 2, 3, 7, 8, 10, 12, 13, 14] @=> int ganapatiArray[];

//notes for tammy
[2, 3, 4, 5, 6, 7, 8, 10, 12, 13, 14] @=> int tammyArray[];


//time based parameters
80 => int bpm;
8 => int totalBeats;
bpmClass.bpm(bpm) => float msPerBeat;
msPerBeat::ms => dur beat;

//setup sound
SinOsc osc => ADSR env1 => dac;
0.4 => osc.gain;

440.0 => float freq;
[0, 4, 7] @=> int major[];
[0, 3, 7] @=> int minor[];
48 => int offset;
int position;
0 => int start; // our flag
amp => osc.gain;
(1::ms, beat / 8, 0, 1::ms) => env1.set;
// --- initialize clientReceive properly
ductReceive.init(portDuct);

//connect to robotic server
oscSendInst.init(ipAddressServer, 8005);


// function to receive OSC messages
fun void dataReceived() {
    while (true) {
        ductReceive.receive() @=> string data[];
        
        //if (data.size() == 0) continue;
        for(0 => int i; i < data.size(); i++){
            <<<data[i]>>>;
        }
        
        // handle messages
        if (data[1] == "/time") {
            Std.atoi(data[2]) => bpm;
            Std.atoi(data[3]) => totalBeats;
            bpmClass.bpm(bpm) => msPerBeat;
            msPerBeat::ms => beat;
            <<<"Received /time:", bpm, totalBeats>>>;
        }
        else if (data[0] == "/freq") {
            Std.atof(data[1]) => freq;
            <<<"Received /freq:", freq>>>;
        }
        else if (data[0] == "/start") {
            1 => start;
            <<<"Received /start signal – GO!">>>;
        }
        data.clear();
    }
}

//--------------------------------------
// simple arpeggiator
fun void arp() {
    while (true) {
        if (start == 1) {
            for (0 => int j; j < minor.cap(); j++) {
                Std.mtof(minor[j] + offset + position) => osc.freq;
                1 => env1.keyOn;
                beat => now;
            }
        } else {
            50::ms => now;
        }
    }
}


//create and send notes
fun void instSend(string instrument, int note, int vel) {
    osc.send(instrument, note, vel);
}

fun void instPlay(string instrument, int note, int vel) {
    
    instSend(instrument, note, vel);
    100::ms => now;
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

// start both in parallel
spork ~ dataReceived();
spork ~ arp();
spork~ breakBoPlay();

while (true) {
    1::second => now;
}


