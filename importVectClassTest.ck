@import "./intervalClassVectClass.ck";

intervalClassVect vect;

[62, 65, 69] @=> int pitchColl[];
vect.init(pitchColl);

vect.popArray();

<<<"wait for it...">>>;
2::second => now;

vect.calcIntervalClassVector();

vect.printIntervalClassVector();