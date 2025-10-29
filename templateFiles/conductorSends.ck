class public conductorSend{
    @import "/templateFiles/bpmSetClass.ck";

    oscSends send;

    OscOut toClient1;
    OscOut toClient2;
    OscOut toClient3;
    //add more clients as needed and just copy code below


    //IP Address of clients will need put into this array
    string clientSend[toClient1, toClient2, toClient3] // add clients as needed

    string data[];

    fun init(string ipAddress[], int port[] ){
        for(0 => int i; i < clientSend.size() - 1; i++){
            clientSend[i].dest(ipAddress[i], port[i]);
    }
    }

    fun setMessages(string data[]){
        
        for(0 => int i; i < clientSend.size() - 1; i++){
            clientSend[i].start("/toClient");
            for(0 => int j; j < data.size() - 1; j++ ){
                clientSend[i].add(data[j]);      
            }
            clientSend[i].send();      
        }

    }
}


