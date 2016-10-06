class HoleDetector
{
    PVector location,
            holeLoc;
            
    HoleDetector(x, y, holeLocX, holeLocY)
    {
        location = new PVector(x, y);
        holeLoc = new PVector(holeLocX, holeLocY);
    }
}
