@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";
@import "./clientRecievesClass.ck";

oscSends oscSends;
bpmSet bpmClass;
clientReceive ductReceive;

"192.168.1.145" => string ipAddress;
8001 => int portServer;
8005 => int portDuct;

80 => int bpm;
8 => int totalBeats;

bpmClass.bpm(bpm) => float msPerBeat;
msPerBeat::ms => dur beat;

SinOsc osc => ADSR env1 => dac;
440.0 => float freq;
0.8 => float amp;

[0, 4, 7] @=> int major[];
[0, 3, 7] @=> int minor[];

48 => int offset;
int position;
0 => int start; // our flag
amp => osc.gain;
(1::ms, beat / 8, 0, 1::ms) => env1.set;
// --- initialize clientReceive properly
ductReceive.init(portDuct);

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
            bpmClass.bpm(bpm) => float msPerBeat;
            msPerBeat::ms => beat;
            <<<"Received time settings:", bpm, totalBeats>>>;
        }
        if (data[1] == "/freq") {
            Std.atof(data[2]) => freq;
            Std.atof(data[3]) => amp;
            <<<"Received freq:", freq, amp>>>;
        }
        if (data[1] == "/start") {
            1 => start;
            <<<"Received start signal!">>>;
        }
        data.clear();
    }
}

// function to play an arpeggio
fun void arp() {
    while (true) {
        if (start == 1) {
            for (0 => int j; j < minor.cap(); j++) {
                Std.mtof(minor[j] + offset + position) => osc.freq;
                1 => env1.keyOn;
                beat => now;
            }
        } else {
            50::ms => now; // short wait to prevent busy loop
            //<<<"AHHHH">>>;
        }
    }
}

// start both in parallel
spork ~ dataReceived();
spork ~ arp();

while (true) {
    1::second => now;
}


