'use strict';

var app = app || {};

function Hole(position)
{
    this.size = 10;
    this.position = position;
    this.buildHole();
}
Hole.prototype.buildHole = function()
{
    app.main.topCtx.save();
        app.main.topCtx.translate(this.position.x * 1.5, this.position.y / 1.5);
        app.main.topCtx.fillStyle = "#333333";
        app.main.topCtx.beginPath();
            app.main.topCtx.arc(0, 0, this.size, 0, Math.PI * 2, false);
        app.main.topCtx.closePath();
        app.main.topCtx.fill();
    app.main.topCtx.restore();
}
Hole.prototype.displayHole = function()
{
    
}
Hole.prototype.moveFlag = function()
{
    
}