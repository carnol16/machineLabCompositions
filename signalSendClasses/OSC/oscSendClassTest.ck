//Written by Colton Arnold Fall 2025


@import "../machineLabCode/globalOSCSendClass.ck";

oscSends osc;
osc.init("192.168.1.145", 8000);
osc.send("/meow", 50, 127);