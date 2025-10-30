@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";
@import "./clientRecievesClass.ck";

oscSends oscSends;
bpmSet bpmClass;
clientReceive ductReceive;

// connection info
"192.168.1.145" => string ipAddressServer;
8001 => int portServer;
8005 => int portDuct;

// initialize OSC listener once
ductReceive.init(portDuct);

// defaults
80 => int bpm;
8 => int totalBeats;
bpmClass.bpm(bpm) => float msPerBeat;
msPerBeat::ms => dur beat;

// synth setup
SinOsc osc => ADSR env1 => dac;
0.4 => osc.gain;

440.0 => float freq;
[0, 4, 7] @=> int major[];
[0, 3, 7] @=> int minor[];
48 => int offset;
int position;
0 => int start;

//--------------------------------------
// receive OSC
fun void dataReceived() {
    while (true) {
        ductReceive.receive() @=> string data[];
        if (data.size() == 0) continue;

        if (data[0] == "/time") {
            Std.atoi(data[1]) => bpm;
            Std.atoi(data[2]) => totalBeats;
            bpmClass.bpm(bpm) => float msPerBeat;
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

//--------------------------------------
spork ~ dataReceived();
spork ~ arp();

while (true) 1::second => now;
