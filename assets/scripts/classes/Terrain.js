'use strict';

var app = app || {};

function Terrain(edgeComplexity, sizeXOffset, sizeYOffset, fillCol, type)
{
    this.edgeComplexity = edgeComplexity;
    this.sizeXOffset = sizeXOffset;
    this.sizeYOffset = sizeYOffset;
    this.fillCol = fillCol;
    this.type = type;
    this.xPosOffset = 50;
    this.yPosOffset = 50;
    
    this.randomRotation = getRandom(-30, 30);
    
    
}

Terrain.prototype.display = function()
{
    
}
Terrain.prototype.randomlyGenerateTerrain = function()
{
    var radius = 30;
    var drawingPos = {x: this.xPosOffset, y: this.yPosOffset};
    var scale = {x: this.sizeXOffset, y: this.sizeYOffset};
    app.main.topCtx.save();
        //app.main.topCtx.scale(scale.x, scale.y);
        app.main.topCtx.translate(this.xPosOffset, this.yPosOffset);
            app.main.topCtx.save();
                app.main.topCtx.beginPath();
                app.main.topCtx.fillStyle = this.fillCol;
                    for(var x = 0; x < this.edgeComplexity; x++)
                    {
                        //radius = radius.map(0, 1, 0, this.WIDTH);
                        radius += getRandom(-2, 2);

                        drawingPos.x = Math.cos(((360 / this.edgeComplexity) * x).toRadians()) * radius * scale.x;
                        drawingPos.y = Math.sin(((360 / this.edgeComplexity) * x).toRadians()) * radius * scale.y;
                        if(x == 0)
                        {
                            app.main.topCtx.moveTo(drawingPos.x, drawingPos.y);
                        }
                        else
                        {
                            app.main.topCtx.lineTo(drawingPos.x, drawingPos.y);
                        }
                    }
                app.main.topCtx.closePath();
                app.main.topCtx.fill();
            app.main.topCtx.restore();
    app.main.topCtx.restore();
    
}
Terrain.prototype.changeFillColor = function(col)
{
    this.fillCol = col;
}
Terrain.prototype.getXOffset = function()
{
    return this.xPosOffset;
}
Terrain.prototype.getYOffset = function()
{
    return this.yPosOffset;
}


///////////////////////FAIRWAY CHILD///////////////////////////
function Fairway(position, xSize, ySize, rotation, fillCol)
{
    Terrain.call(this, 50, xSize, ySize, fillCol, 0);
    var randomPosFairway = 
    {
        x: 0,
        y: 0
    }
    var spacing = 75;
    randomPosFairway.x = position.x + getRandom(-50, 50);
    randomPosFairway.y = (position.y * ((ySize * spacing)/1.05)) + getRandom(0, 20);
    this.xPosOffset = randomPosFairway.x;
    this.yPosOffset = randomPosFairway.y;
    this.randomRotation = rotation;
    this.randomlyGenerateTerrain();
}
Fairway.prototype = Object.create(Terrain.prototype);
Fairway.prototype.constructor = Fairway;
///////////////////////////////////////////////////////////////



//////////////////////GREEN CHILD///////////////////////////////
function GreenWithHole(fillCol)
{
    Terrain.call(this, 50, 4, 4, fillCol, 1);
    var randomXPosGreen = getRandom(300, app.main.canvas.width - 300);
    var randomYPosGreen = parseInt(getRandom(100, 150));
    
    var randomHoleLocX = getRandom(randomXPosGreen - 25, randomXPosGreen + 25);
    var randomHoleLocY = getRandom(randomYPosGreen - 25, randomYPosGreen + 25);
    
    this.xPosOffset = randomHoleLocX;
    this.yPosOffset = randomHoleLocY;
    this.randomlyGenerateTerrain();
    var golfHole = new Hole({x: randomHoleLocX / 1.5, y: randomHoleLocY * 2});
    
    app.main.holePosition = {x: golfHole.position.x * 1.5, y: golfHole.position.y/3}
    
}
GreenWithHole.prototype = Object.create(Terrain.prototype);
GreenWithHole.prototype.constructor = GreenWithHole;
////////////////////////////////////////////////////////////////



///////////////////////WATER HAZARD CHILD///////////////////////
function WaterHazard(position, xSize, ySize, rotation, fillCol)
{
    Terrain.call(this, 50, xSize, ySize, fillCol, 2);
    
    var randomXPosWater = ((position.x * xSize) * 300) + getRandom(-100, 100);
    var randomYPosWater = ((position.y * ySize) * 100) + parseInt(getRandom(100, 150));
    
    this.xPosOffset = randomXPosWater;
    this.yPosOffset = randomYPosWater;
    this.randomlyGenerateTerrain();
}
WaterHazard.prototype = Object.create(Terrain.prototype);
WaterHazard.prototype.constructor = WaterHazard;
////////////////////////////////////////////////////////////////



////////////////////////BUNKER CHILD///////////////////////////
function Bunker(position, xSize, ySize, rotation, fillCol)
{
    Terrain.call(this, 50, xSize, ySize, fillCol, 3);
    
    var randomXPosBunker = ((position.x * xSize) * 300) + getRandom(-100, 100);
    var randomYPosBunker = ((position.y * ySize) * 100) + parseInt(getRandom(100, 150));
    
    this.xPosOffset = randomXPosBunker;
    this.yPosOffset = randomYPosBunker;
    this.randomlyGenerateTerrain();
}
Bunker.prototype = Object.create(Terrain.prototype);
Bunker.prototype.constructor = Bunker;
///////////////////////////////////////////////////////////////



/////////////////////////TEE CHILD/////////////////////////////
function Tee(position, xSize, ySize, rotation, fillCol)
{
    Terrain.call(this, 50, xSize, ySize, fillCol, 1);
    var spacing = 75;
    var randomXPosTee = (position.x * xSize) + getRandom(-100, 100);
    var randomYPosTee = (position.y * ySize) + spacing + getRandom(0, 20);
    //var randomYPosTee = (position.y * ySize) + parseInt(getRandom(100, 150));
    
    this.xPosOffset = randomXPosTee;
    this.yPosOffset = randomYPosTee;
    app.main.teePosition.x = this.xPosOffset;
    app.main.teePosition.y = this.yPosOffset;
    
    this.randomlyGenerateTerrain();
    
    //FIX PLAYER BALL LOCATION, CAMERA NOW WORKS
    //app.main.playerBall = new PlayerBall({x: randomXPosTee, y: randomYPosTee}, "#FAFAFA");
}
Tee.prototype = Object.create(Terrain.prototype);
Tee.prototype.constructor = Tee;
///////////////////////////////////////////////////////////////