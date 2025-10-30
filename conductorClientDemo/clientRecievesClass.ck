public class clientReceive{

    OscIn in;
    OscMsg msg;
    string data[];

    // Initialize the OscIn once, with port and address
    fun void init(int port) {
        OscIn() => in;
        in.port(port);
    }
    string data[];

    fun int start(){
    
        if(in.recv(msg)){
            return 1;
        }
        return 0;
    }  

    fun int messageSent(){
        
        if(in.recv(msg)){
            return 1;
        }
        else{
            return 0;
        }
    }

    fun string[] receive() {
        in.addAddress("/toClient");
        //in.addAddress(instrument);
        while( true )
        {   
            in => now;
            // for(0 => int i; i < 3; i++){
            //     <<<data[i]>>>;
            // }
            // wait for event to arrive
            //in => now;
            data.clear();
            //<<<data, "data cleared">>>;
            
            // grab the next message from the queue. 
            while( in.recv(msg) )
            { 
                // expected datatypes
                //fetch Address
                msg.address => string address;
                msg.getString(0) => string dataPoint1;
                msg.getString(1) => string dataPoint2;

                data << address;
                data << dataPoint1;
                data << dataPoint2;
                
                return data;
            }
            
        }
        return [""];
    }

    // fun toComp(){
    //     in.listenAll();
        
    //     receive() => string receivedMsg[];

    //     for(0 => int i; i < receivedMsg.size() - 1; i++){
    //         chout <= receivedMsg[i] <= " ";
    //     }
    //     chout <= IO.newline();



    //     while( in.recv(msg) )
    //     { 
    //         localSend.start("/fromConductor");
    //         localSend.add(receivedMsg);
    //         localSend.send();

    //     }   
            
    // }

}



        




