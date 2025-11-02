KNN knn;

SinOsc sin => dac;


["Cm", "Dm", "C#m", "F/C", "Am/C", "E", "Bb/D", "C+", "Bdim/d", "F#/C#"] @=> string labels[];
//triads
[
    [0, 3, 7], //c minor
    [2, 5, 9], //d minor
    [1, 3, 8], //c# minor
    [0, 4, 7], //f major 2nd inv.
    [0, 4, 9], //am/c
    [4, 8, 11], //E
    [2, 5, 10], // Bb/D
    [0, 4, 8], //C+
    [2, 5, 11], // bdim
    [1, 6, 10] //F#/C#

] @=> int triads[][];

triads[0].size() => int noteSetLength;

labels.size() => int labelLength;



