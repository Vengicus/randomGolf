'use strict';

var app = app || {};

function LevelGenerator(numStrokes)
{
    this.PROBABILITIES = 
    {
        WATER: 0,
        BUNKERS: 0,
        FOLIAGE: 0
    };
    this.NUM_PROPS = 
    {
        FAIRWAY_PATCHES: 0,
        OTHER: 0
    };
    this.numStrokes = numStrokes;
    this.terrainList = [];
    this.foliageList = [];
    
    this.chooseColorPalette();
    this.calcProbability();
    this.buildTerrain();
}

LevelGenerator.prototype.chooseColorPalette = function()
{
    switch(app.main.currentLevel)
    {
        case 0:
            app.main.COLOR_PALETTE.HOLE_GREEN = "#30D127";
            app.main.COLOR_PALETTE.FAIRWAY = "#2BBA22";
            app.main.COLOR_PALETTE.BUNKER = "#E8C188";
            app.main.COLOR_PALETTE.WATER = "#3366E8";
            app.main.COLOR_PALETTE.ROUGH = "#208C1A";
            break;
        case 1:
            app.main.COLOR_PALETTE.HOLE_GREEN = "#7DBA3A";
            app.main.COLOR_PALETTE.FAIRWAY = "#B7BA3A";
            app.main.COLOR_PALETTE.BUNKER = "#E8C188";
            app.main.COLOR_PALETTE.WATER = "#1E5BCF";
            app.main.COLOR_PALETTE.ROUGH = "#878A2B";
            break;
        case 2:
            app.main.COLOR_PALETTE.HOLE_GREEN = "#56C114";
            app.main.COLOR_PALETTE.FAIRWAY = "#5FD822";
            app.main.COLOR_PALETTE.BUNKER = "#E8C188";
            app.main.COLOR_PALETTE.WATER = "#3366E8";
            app.main.COLOR_PALETTE.ROUGH = "#22B147";
            break;
        case 3:
            app.main.COLOR_PALETTE.HOLE_GREEN = "#37E080";
            app.main.COLOR_PALETTE.FAIRWAY = "#63E080";
            app.main.COLOR_PALETTE.BUNKER = "#C1BA90";
            app.main.COLOR_PALETTE.WATER = "#5382E0";
            app.main.COLOR_PALETTE.ROUGH = "#A0D7E0";
            break;
        default:
            app.main.COLOR_PALETTE.HOLE_GREEN = "#30D127";
            app.main.COLOR_PALETTE.FAIRWAY = "#2BBA22";
            app.main.COLOR_PALETTE.BUNKER = "#E8C188";
            app.main.COLOR_PALETTE.WATER = "#3366E8";
            app.main.COLOR_PALETTE.ROUGH = "#208C1A";
            break;
    }
}
LevelGenerator.prototype.buildTerrain = function()
{
    app.main.topCtx.save();
        app.main.topCtx.fillStyle = app.main.COLOR_PALETTE.ROUGH;
        app.main.topCtx.fillRect(0, 0, app.main.canvas.width, app.main.topCanvas.height * 2);
    app.main.topCtx.restore();
    
    app.main.terrainList.push(new GreenWithHole(app.main.COLOR_PALETTE.HOLE_GREEN));
    
    var finalYPos = 0;
    for(var y = 1; y < this.NUM_PROPS.FAIRWAY_PATCHES + 1; y++)
    {
        var xPos = parseInt(app.main.terrainList[y-1].getXOffset());
        var yPos = y;
        if(y == 1)
        {
            yPos = 1.5;
        }
        if(y == this.NUM_PROPS.FAIRWAY_PATCHES)
        {
            finalYPos = app.main.terrainList[y-1].getYOffset();
        }
        app.main.terrainList.push(new Fairway({x: xPos, y: yPos}, getRandom(2, 4), getRandom(3, 6), getRandom(0, 10), app.main.COLOR_PALETTE.FAIRWAY));
    }
    
    app.main.terrainList.push(new Tee({x: getRandom(100, app.main.canvas.width - 600), y: finalYPos}, getRandom(1, 2), getRandom(1, 2), getRandom(0, 10), app.main.COLOR_PALETTE.HOLE_GREEN/*app.main.COLOR_PALETTE.HOLE_GREEN*/));
    
    for(var y = 1; y < this.NUM_PROPS.OTHER +1; y++)
    {
        for(var x = 0; x < 3; x++)
        {
            if(y < this.NUM_PROPS.OTHER - 6)
            {
                var probability = Math.random();
                if(probability < this.PROBABILITIES.WATER)
                {
                    app.main.terrainList.push(new WaterHazard({x: x, y: y}, getRandom(2, 8), getRandom(2, 8), getRandom(0,10), app.main.COLOR_PALETTE.WATER));
                    x = 3;
                }
                else if(probability < this.PROBABILITIES.BUNKERS)
                {
                    
                    app.main.terrainList.push(new Bunker({x: x, y: y}, getRandom(1,2), getRandom(1,2), getRandom(0,10), app.main.COLOR_PALETTE.BUNKER));
                    x = 3;
                }
                else if(probability < this.PROBABILITIES.FOLIAGE)
                {
                    
                }
            }
        }
    }
}
LevelGenerator.prototype.displayTerrain = function()
{
    
}
LevelGenerator.prototype.calcProbability = function()
{
    if(this.numStrokes == 3)
    {
        this.PROBABILITIES.WATER = 0.2;
        this.PROBABILITIES.BUNKERS = 0.5;
        this.PROBABILITIES.FOLIAGE = 1.0;
        this.NUM_PROPS.FAIRWAY_PATCHES = 2;
        this.NUM_PROPS.OTHER = 10;
    }
    else if(this.numStrokes == 4)
    {
        this.PROBABILITIES.WATER = 0.2;
        this.PROBABILITIES.BUNKERS = 0.3;
        this.PROBABILITIES.FOLIAGE = 1.0;
        this.NUM_PROPS.FAIRWAY_PATCHES = 3;
        this.NUM_PROPS.OTHER = 15;
    }
    else if(this.numStrokes == 5)
    {
        this.PROBABILITIES.WATER = 0.25;
        this.PROBABILITIES.BUNKERS = 0.5;
        this.PROBABILITIES.FOLIAGE = 1.0;
        this.NUM_PROPS.FAIRWAY_PATCHES = 4;
        this.NUM_PROPS.OTHER = 20;
    }
}