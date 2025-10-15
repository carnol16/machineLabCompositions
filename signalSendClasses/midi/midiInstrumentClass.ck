//Written by Colton Arnold Fall 2025

public class midiInstrumentSends{

    // instantiate a MIDI out object
    MidiOut mout;
    // a message to work with
    MidiMsg msg;


<<< "MIDI output device opened...", "" >>>;

    fun init(int port){
        if( !mout.open(port) ) me.exit();
    }

    fun messageSend(int note, int vel, int length){
        
    

        // MIDI note on message
        // 0x90 + channel (0 in this case)
        0x90 => msg.data1;
        // pitch
        note => msg.data2;
        // velocity
        vel => msg.data3;
        // print
        //<<< "sending NOTE ON message...", "" >>>;
        // send MIDI message
        mout.send( msg );

        //length that note is held down: Think of how long
        //a player holds down a piano note down
        0::ms => now;
        
        // MIDI note off message
        // 0x80 + channel (0 in this case)
        0x80 => msg.data1;
        // pitch
        note => msg.data2;
        // velocity
        0 => msg.data3;
        // print
        //<<< "sending NOTE OFF message...", "" >>>;
        // send MIDI message
        mout.send( msg );
    }

}