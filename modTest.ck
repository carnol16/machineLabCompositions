@import "./signalSendClasses/OSC/globalOSCSendClass.ck";

oscSends osc;
osc.init("192.168.0.15", 8001);

while(true){
    for(0 => int i; i < 32; i++){
        osc.send("/modulettes", i, 127);
        100::ms => now;
        <<<i>>>;
    }
}
