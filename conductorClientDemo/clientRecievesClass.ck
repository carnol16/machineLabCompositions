public class clientReceive {

    OscIn in;
    OscMsg msg;
    string data[];

    // Initialize the OscIn once, with port and address
    fun void init(int port) {
        in.port(port);
        in.addAddress("/toClient");
    }

    // Receive next OSC message and return its contents as string array
    fun string[] receive() {
        data.clear();

        // Only process if a message is available
        if(in.recv(msg)) {
            msg.address => string address;

            // Safely fetch first two string arguments if they exist
            "" => string dataPoint1;
            "" => string dataPoint2;

            if(msg.numArgs() > 0) msg.getString(0) => dataPoint1;
            if(msg.numArgs() > 1) msg.getString(1) => dataPoint2;

            data << address;
            data << dataPoint1;
            data << dataPoint2;
        }

        return data;
    }
}
