//Written by Colton Arnold Fall 2025


public class oscSends {
    OscOut out;
    OscOut outMonitor;

    "localhost" => string ipAddress;
    50000 => int outPort;
    7000 => int outMonitorPort;

    fun void init(string ipAddress, int outPort){
        out.dest(ipAddress, outPort);
        outMonitor.dest(ipAddress, outMonitorPort);
    }

    fun void send(string instrument, int note, int vel) {
        out.start(instrument);
        out.add(note);
        out.add(vel);
        out.send();

        outMonitor.start(instrument);
        outMonitor.add(note);
        outMonitor.add(vel);
        outMonitor.send();
        //5::ms => now;
    }
}