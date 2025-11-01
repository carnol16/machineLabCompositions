public class clientReceive {
    OscIn in;
    OscMsg msg;
    string data[];

    // initialize OSC receiver
    fun void init(int port) {
        in.port(port);
        in.addAddress("/toClient");
        <<< "Client listening on port:", port >>>;
    }

    // wait for and return one incoming message
    fun string[] receive() {
        data.clear();
        in => now;

        while (in.recv(msg)) {
            msg.address => string address;
            data << address;

            // collect up to two arguments (more if needed)
            for (0 => int i; i < msg.numArgs(); i++) {
                msg.getString(i) => string arg;
                data << arg;
            }
        }

        return data;
    }
}
