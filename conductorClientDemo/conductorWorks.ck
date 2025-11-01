@import "../signalSendClasses/OSC/globalOSCSendClass.ck";
@import "../templateFiles/bpmSetClass.ck";
@import "./conductorSendsClass.ck";


oscSends oscSends;
bpmSet bpmClass;
conductorSend ductSend;

//send to clients
["192.168.1.145"] @=> string ipAddress[];
[8005] @=> int port[];
["/time", "/freq", "/start"] @=> string address[];

ductSend.init(ipAddress, port);


120 => int bpm;


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

100::ms => now;
while(true){

    for(0 => int j; j < minor.cap(); j++){
        Std.mtof(minor[j] + offset + position) => osc.freq;
        1 => env1.keyOn;
        beat => now;
    }

}