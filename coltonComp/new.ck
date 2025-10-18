@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";

oscSends send;
bpmSet bpm;

bpm.bpm(160) => float msPerBeat;
msPerBeat::ms => dur beat;

"192.168.1.145" => string ipAddress;
8001 => int port;

// Marimba MIDI notes
[45, 47, 48, 50, 52, 53, 54, 55, 57, 59, 
60, 62, 64, 65, 66, 67, 69, 71, 72, 74, 
76, 77, 78, 79, 81, 83, 84, 86, 88, 89, 
90, 91, 93, 95, 96] @=> int mScl[];

send.init(ipAddress, port);

for(0 => int i; i < 4; i++){
    send.send("/marimba", mScl[i], 127);
    beat / 2 => now;
}

