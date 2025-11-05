@import "./interClassVecClass.ck";

intervalClassVector vect;

//entire the pitch class in this array. no duplicates!
[60, 63, 68] @=> int pitchColl[];
int pitchCollPairs[calcNumPairs()][2];

vect.popArray();
vect.print2dArray(pitchCollPairs);

<<<"wait for it...">>>;
2::second => now;

[0, 0, 0, 0, 0, 0] @=> int intervalClassVector[];
vect.calcIntervalClassVector();

vect.printIntervalClassVector();