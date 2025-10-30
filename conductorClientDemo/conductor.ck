@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";
@import "./conductorSendsClass.ck";

oscSends oscSends;
bpmSet bpmClass;
conductorSend ductSend;

//send to clients
["192.168.1.145"] @=> string ipAddress[];
[8005, 8006, 8007] @=> int port[];
["/time", "/freq", "/start"] @=> string ductAddress[];

["/marimba", "/breakBot", "/tammy", "/ganapali"] @=> string instAddress;

ductSend.init(ipAddress, port);

120 => int bpm;


bpmClass.bpm(bpm) => float msPerBeat;
msPerBeat::ms => dur beat;

//--------------------------------------
// send initial setup
Std.itoa(bpm) => string bpmString;
Std.itoa(totalBeats) => string totalBeatsString;

[ductAddress[0], bpmString, totalBeatsString] @=> string timeInfo[];
ductSend.setMessages(timeInfo);

// send freq/amp info
["/freq", "440.0", "1.0"] @=> string freqMsg[];
ductSend.setMessages(freqMsg);

[ductAddress[2], "1"] @=> string startInfo[];
ductSend.setMessages(startInfo);

// send start command
["/start", "1", "0"] @=> string startMsg[];
ductSend.setMessages(startMsg);

fun int toInt(string dataPoint){
    Std.atoi(dataPoint) => int pointInt;
    return pointInt;
}

SinOsc osc => ADSR env1 => dac;
0.3 => osc.gain;
(1::ms, beat / 8, 0, 1::ms) => env1.set;

[0, 4, 7] @=> int major[];
48 => int offset;
int position;

fun void arp(){

        for(0 => int j; j < minor.cap(); j++){
        Std.mtof(minor[j] + offset + position) => osc.freq;
        1 => env1.keyOn;
        beat / 2 => now;
    }

}
