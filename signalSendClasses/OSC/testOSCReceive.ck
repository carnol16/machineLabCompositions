//Written by Colton Arnold Fall 2025


@import "/Users/mtiid/git/robots/testOSCReceive.ck";

oscRecieve oscReceive;

oscReceive.init("localhost", 7002, 10005);

oscRecieve.receive("/meow", 20, 60);