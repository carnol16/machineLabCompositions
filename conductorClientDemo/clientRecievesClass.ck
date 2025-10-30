public class clientReceive {

    OscIn in;
    OscMsg msg;
    string data[];

    // Initialize the OscIn once
    fun void init(int port) {
        OscIn() => in;
        in.port(port);
        in.addAddress("/toClient");
    }

    fun string[] receive() {
        data.clear();
        while(in.recv(msg)) {
            // Only access the strings if they exist
            msg.address => string address;
            "" => string dataPoint1;
            "" => string dataPoint2;

            if(msg.size() > 0) msg.getString(0) => dataPoint1;
            if(msg.size() > 1) msg.getString(1) => dataPoint2;

            data << address;
            data << dataPoint1;
            data << dataPoint2;

            return data;
        }
        return [""];
    }
}
