//interval class vector calculator
//coded by Amogh Dwivedi
// 25 October 2025

//entire the pitch class in this array. no duplicates!
[67, 61, 62, 66, 60, 68] @=> int pitchColl[];
int pitchCollPairs[calcNumPairs()][2];

popArray();
print2dArray(pitchCollPairs);

<<<"wait for it...">>>;
2::second => now;

[0, 0, 0, 0, 0, 0] @=> int intervalClassVector[];
calcIntervalClassVector();

printIntervalClassVector();

fun void calcIntervalClassVector()
{
    for(0 => int i; i < pitchCollPairs.cap(); i++)
    {
        pitchCollPairs[i][0] - pitchCollPairs[i][1] => int vector;
        Std.abs(vector) => vector;

        if (vector > 6)
        {
            12 - vector => vector;
        }
        
        intervalClassVector[vector-1] + 1 => intervalClassVector[vector-1];
    }
}

fun void printIntervalClassVector()
{
    for (0 => int i; i < intervalClassVector.cap(); i++)
    {
        chout <= intervalClassVector[i] <= " ";
    }
    chout <= IO.newline();
}

fun int factorialCalc(int fact)
{
    if (fact == 0)
    {
        return 1;
    }
    else
    {
        return (fact*(factorialCalc(fact-1)));
    }
}

fun int calcNumPairs()
{
    /// formula for calculating possible number of combinations
    factorialCalc(pitchColl.cap()) => int nFact;
    factorialCalc(2) => int twoFact;
    factorialCalc(pitchColl.cap()-2) => int nMinusRFact;
    (nFact)/(twoFact*nMinusRFact) => int numPossibilities;

    return numPossibilities;
}

fun void print2dArray(int arr[][])
{
    for (0 => int i; i < arr.cap(); i++)
    {
        for (0 => int j; j < arr[i].cap(); j++)
        {
            chout <= arr[i][j] <= " ";
        }
        chout <= IO.newline();
    }
}

fun void popArray()
{
    0 => int currentIndex;
    0 => int rowIndex;

    for (pitchColl.cap() - 1 => int i; i > 0; i--)
    {
        for(0 => int j; j < i; j++)
        {
            pitchColl[currentIndex] => pitchCollPairs[rowIndex][0];
            pitchColl[currentIndex+(j+1)] => pitchCollPairs[rowIndex][1];
            rowIndex++;
        }
        currentIndex++;
    }
}
