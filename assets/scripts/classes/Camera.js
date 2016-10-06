"use strict";
var app = app || {};

(function()
{
    function Camera(xView, yView, canvasWidth, canvasHeight, worldWidth, worldHeight)
    {
        this.AXIS = 
        {
            NONE: "none", 
            HORIZONTAL: "horizontal", 
            VERTICAL: "vertical", 
            BOTH: "both"
        };
        // position of camera (left-top coordinate)
        this.xView = xView || 0;
        this.yView = yView || 0;

        // distance from followed object to border before camera starts move
        this.xDeadZone = 0; // min distance to horizontal borders
        this.yDeadZone = 0; // min distance to vertical borders

        // viewport dimensions
        this.wView = canvasWidth;
        this.hView = canvasHeight;			

        // allow camera to move in vertical and horizontal axis
        this.axis = this.AXIS.BOTH;	

        // object that should be followed
        this.followed = null;

        // rectangle that represents the viewport
        this.viewportRect = new app.main.Rectangle(this.xView, this.yView, this.wView, this.hView);				

        // rectangle that represents the world's boundary (room's boundary)
        this.worldRect = new app.main.Rectangle(0, 0, worldWidth, worldHeight);

    }
    // gameObject needs to have "x" and "y" properties (as world(or room) position)
    Camera.prototype.follow = function(gameObject, xDeadZone, yDeadZone)
    {		
        this.followed = gameObject;	
        this.xDeadZone = xDeadZone;
        this.yDeadZone = yDeadZone;
    }					

    Camera.prototype.update = function()
    {
        // keep following the player (or other desired object)
        if(this.followed != null)
        {		
            if(this.axis == this.AXIS.HORIZONTAL || this.axis == this.AXIS.BOTH)
            {		
                // moves camera on horizontal axis based on followed object position
                if(this.followed.position.x - this.xView  + this.xDeadZone > this.wView)
                {
                    this.xView = this.followed.position.x - (this.wView - this.xDeadZone);
                }
                else if(this.followed.position.x  - this.xDeadZone < this.xView)
                {
                    this.xView = this.followed.position.x  - this.xDeadZone;
                }

            }
            if(this.axis == this.AXIS.VERTICAL || this.axis == this.AXIS.BOTH)
            {
                // moves camera on vertical axis based on followed object position
                if(this.followed.position.y - this.yView + this.yDeadZone > this.hView)
                {
                    this.yView = this.followed.position.y - (this.hView - this.yDeadZone);
                }
                else if(this.followed.position.y - this.yDeadZone < this.yView)
                {
                    this.yView = this.followed.position.y - this.yDeadZone;
                }
            }						

        }		

        // update viewportRect
        this.viewportRect.set(this.xView, this.yView);

        // don't let camera leaves the world's boundary
        if(!this.viewportRect.within(this.worldRect))
        {
            if(this.viewportRect.left < this.worldRect.left)
            {
                this.xView = this.worldRect.left;
                if(this.viewportRect.top < this.worldRect.top)
                {
                    this.yView = this.worldRect.top;
                }
                if(this.viewportRect.right > this.worldRect.right)
                {
                    this.xView = this.worldRect.right - this.wView;
                }
                if(this.viewportRect.bottom > this.worldRect.bottom)
                {
                    this.yView = this.worldRect.bottom - this.hView;
                }

            }
        }
        app.main.topCtx.fillRect(this.viewportRect.top, this.viewportRect.left, this.viewportRect.width, this.viewportRect.height);
    }
    app.main.Camera = Camera;
})();