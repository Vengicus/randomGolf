'use strict';

var app = app || {};

function PlayerBall(position, fillCol)
{
    this.position = position;
    this.ballColor = fillCol;
    this.velocity = {x: 0, y: 0};
    this.maxSpeed = 30;
    this.initialScale = 5;
    this.maxScale = 100;
    this.scale = 5;
    this.debug = false;
    this.hangTime = 0;
    this.hangTimeRatio = 0;
    this.display();
}

PlayerBall.prototype.display = function()
{
    //app.main.ctx.clearRect(0, 0, app.main.topCanvas.width, app.main.topCanvas.height);
    app.main.ctx.save();
        app.main.ctx.fillStyle = this.ballColor;
        app.main.ctx.beginPath();
            app.main.ctx.arc(this.position.x, this.position.y, this.scale, 0, Math.PI * 2, false);
        app.main.ctx.closePath();
        app.main.ctx.fill();
    app.main.ctx.restore();
    if(this.debug)
    {
        console.log(this.position.y);
        //COMPENSATE FOR SECOND CANVAS
        this.debug = false;   
    }
    //app.main.ctx.drawImage(app.main.topCanvas, 0, 0);
}
PlayerBall.prototype.move = function(dt, acceleration)
{
    //Calculate forces
    //Add forces to acceleration
    //Add acceleration to velocity
    //Limit by maxVelocity
    //Add velocity to position
    //Zero out acceleration
    var accel = acceleration;
    //accel = accel.addVector({x:0, y:0});
    this.velocity = this.velocity.addVector(accel);
    this.position = this.position.addVector(this.velocity);
}