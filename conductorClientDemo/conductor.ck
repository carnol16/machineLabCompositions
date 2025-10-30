@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";
@import "./conductorSendsClass.ck";

oscSends oscSends;
bpmSet bpmClass;
conductorSend ductSend;

// send to clients
["192.168.1.117"] @=> string ipAddress[];
[8005] @=> int port[];
["/time", "/freq", "/start"] @=> string address[];

ductSend.init(ipAddress, port);

120 => int bpm;
16 => int totalBeats;

bpmClass.bpm(bpm) => float msPerBeat;
msPerBeat::ms => dur beat;

//--------------------------------------
// send initial setup
Std.itoa(bpm) => string bpmString;
Std.itoa(totalBeats) => string totalBeatsString;

[address[0], bpmString, totalBeatsString] @=> string timeMsg[];
ductSend.setMessages(timeMsg);

// send freq/amp info
["/freq", "440.0", "1.0"] @=> string freqMsg[];
ductSend.setMessages(freqMsg);

// small delay before starting
2::second => now;

// send start command
["/start", "1", "0"] @=> string startMsg[];
ductSend.setMessages(startMsg);

//--------------------------------------
// Conductor plays its own sound
SinOsc osc => ADSR env1 => dac;
0.3 => osc.gain;
(1::ms, beat / 8, 0, 1::ms) => env1.set;

[0, 4, 7] @=> int major[];
48 => int offset;
int position;

while (true) {
    for (0 => int j; j < major.cap(); j++) {
        Std.mtof(major[j] + offset + position) => osc.freq;
        1 => env1.keyOn;
        beat / 2 => now;
    }
}
