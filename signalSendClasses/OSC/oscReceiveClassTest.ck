//Written by Colton Arnold Fall 2025


//change file path to local path on Machine Lab device
//not letting us use the relative path?
//@import "../MachineLabCode/globalOSCReceiveClass.ck";
@import "../OSC/globalOSCReceiveClass.ck";

oscReceive oscReceive;

//localhost will be transfered to Mr.Roboto IP

oscReceive.init(8000);

while(true){
    oscReceive.receive();
}






