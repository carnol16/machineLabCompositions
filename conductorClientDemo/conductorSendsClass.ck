public class conductorSend {
    @import "/templateFiles/bpmSetClass.ck";

    oscSends send;

    OscOut toClient1;
    OscOut toClient2;
    OscOut toClient3;
    //add more clients as needed and just copy code below


    //IP Address of clients will need put into this array
    [toClient1] @=> OscOut clientSend[]; // add clients as needed

    string data[];

fun void init(string ipAddress[], int port[]){
    for(0 => int i; i < clientSend.size(); i++){
        clientSend[i].dest(ipAddress[i], port[i]);
    }
}


    //compiles msg to send to client
    fun setMessages(string data[]){    
        for(0 => int i; i < clientSend.size(); i++){
            clientSend[i].start("/toClient");
            for(0 => int j; j < data.size(); j++ ){
                clientSend[i].add(data[j]);      
            }
            clientSend[i].send();      
        }

    }
}



