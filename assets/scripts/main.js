'use strict';

var app = app || {};

app.main = 
{
    GAME_STATE:Object.freeze(
    {
        MENU: 1,
        OPTIONS: 2,
        EXIT: 3,
        GAME_PLAY: 4,
        GAME_SHOW_PAR: 5,
        GAME_SHOW_SCORE: 6,
        GAME_OVER: 7,
        GAME_PAUSED: 8
    }),
    LEVEL_NAMES: Object.freeze(
    {
        0: "Watering Plains",
        1: "Sand Peaks",
        2: "Grassy Knoll",
        3: "Chilling Shores"
    }),
    CLUB_TYPES: Object.freeze(
    {
        0: "Putter",
        1: "SW",
        2: "9 Iron",
        3: "8 Iron",
        4: "7 Iron",
        5: "6 Iron",
        6: "5 Hybrid",
        7: "4 Hybrid",
        8: "3 Wood",
        9: "Driver"
    }),
    BALL_STATE: Object.freeze(
    {
        STATIC: 0,
        HIT_IMPULSE: 1,
        UPWARDS: 2,
        PEAK: 3,
        DOWNWARDS: 4,
        BOUNCE: 5,
        PUTTING: 6
    }),
    COLOR_PALETTE:
    {
        FAIRWAY: "#2BBA22",
        HOLE_GREEN: "#30D127",
        BUNKER: "#E8C188",
        WATER: "#3366E8",
        ROUGH: "#208C1A"
    },
    WIDTH: 1280,
    HEIGHT: 720,
    paused: false,
    canvas: undefined,
    ctx: undefined,
    topCanvas: undefined,
    topCtx: undefined,
    levelNameElement: undefined,
    menuElement: undefined,
    mousePos: undefined,
    
    gameState: undefined,
    currentLevel: 0,
    maxLevels: 4,
    levelImages: [],
    levelImagesBG: [],
    
    terrainList: [],
    levelGenerator: undefined,
    
    playerBall: undefined,
    ballState: 0,
    
    holePosition: undefined,
    previousBallPosition: undefined,
    
    
    camera: undefined,
    teePosition: {x: 0, y: 0},
    generatedCourse: undefined,
    courseBuilt: false,
    ballPower: 0,
    ballImpulse: 0,
    clubSelected: 9,
    clubsImage: undefined,
    holeNumber: 0,
    par: 3,
    currentStroke: 1,
    maxStrokes: 9,
    maxHoles: 18,
    
    holeData:[],
    showOutOfBoundsMessage: false,
    
    init : function() 
    {
		// initialize properties
		this.canvas = document.querySelector('#canvas');
		this.canvas.width = this.WIDTH;
		this.canvas.height = this.HEIGHT;
		this.ctx = this.canvas.getContext('2d');
        
        this.topCanvas = document.querySelector('#topCanvas');
		this.topCanvas.width = this.WIDTH;
		this.topCanvas.height = this.HEIGHT * 3;
		this.topCtx = this.topCanvas.getContext('2d');
        
        this.camera = new this.Camera(0, 0, this.canvas.width, this.canvas.height, this.topCanvas.width, this.topCanvas.height);
        for(var x = 1; x < 5; x++)
        {
            var img = new Image();
            img.src = "../assets/media/images/golfPreview" + x + ".jpg";
            this.levelImages.push(img);
            img = new Image();
            img.src = "../assets/media/images/golf" + x + ".jpg";
            this.levelImagesBG.push(img);
        }
        this.clubsImage = new Image();
        this.clubsImage.src = "../assets/media/images/clubs.png";
        this.setupMenuFunctionality();
        //this.canvas.onmousedown = this.doMouseDown.bind(this);
        this.gameState = this.GAME_STATE.MENU;
        this.setupCourse();
        
        app.sound.playBGAudio();
		this.update();
        
    },
	update: function()
    {
	 	this.animationID = requestAnimationFrame(this.update.bind(this));
	 	var dt = this.calculateDeltaTime();
        if(this.paused || document.querySelector(".pause").style.display == "block")
        {
            document.querySelector(".pause").style.display = "block";
            document.querySelector("body").style.cursor = "default";
            return;
        }
        switch(this.gameState)
        {
            case this.GAME_STATE.MENU:
                this.menuElement.style.display = "block";
                document.querySelector("body").style.cursor = "default";
                break;
            case this.GAME_STATE.OPTIONS:
                document.querySelector("body").style.cursor = "default";
                break;
            case this.GAME_STATE.EXIT:
                document.querySelector("body").style.cursor = "default";
                break;
            case this.GAME_STATE.GAME_PLAY:
                this.menuElement.style.display = "none";
                document.querySelector("body").style.cursor = "none";
                break;
            case this.GAME_STATE.GAME_SHOW_PAR:
                document.querySelector("body").style.cursor = "default";
                break;
            case this.GAME_STATE.GAME_SHOW_SCORE:
                document.querySelector("body").style.cursor = "default";
                break;
            case this.GAME_STATE.GAME_OVER:
                document.querySelector("body").style.cursor = "default";
                break;
            case this.GAME_STATE.GAME_PAUSED:
                document.querySelector("body").style.cursor = "default";
                return;
                break;
        }
        if(this.gameState == this.GAME_STATE.MENU)
        {
            document.querySelector("#returnToMenu").style.display = "none";
        }
        else
        {
            document.querySelector("#returnToMenu").style.display = "block";
        }
        
        if(this.playerBall != undefined && this.courseBuilt)
        {
            this.moveBall(dt);
            this.drawHUD();
        }
        switch(this.ballState)
        {
            case this.BALL_STATE.UPWARDS:
                this.playerBall.hangTime++;
                if(this.playerBall.hangTime >= this.playerBall.hangTimeRatio - 50)
                {
                    this.ballState = this.BALL_STATE.PEAK;
                }
                break;
            case this.BALL_STATE.PEAK:
                this.playerBall.hangTime++;
                if(this.playerBall.hangTime >= this.playerBall.hangTimeRatio)
                {
                    this.ballState = this.BALL_STATE.DOWNWARDS;
                }
                break;
            case this.BALL_STATE.DOWNWARDS:
                this.playerBall.hangTime = 0;
                break;
            case this.BALL_STATE.BOUNCE:
                this.ballState = this.BALL_STATE.STATIC;
                break;
            case this.BALL_STATE.PUTTING:
                this.playerBall.hangTime++;
                if(this.playerBall.hangTime >= this.playerBall.hangTimeRatio)
                {
                    this.ballState = this.BALL_STATE.STATIC;
                }
                break;
        }
        
    },
    calculateDeltaTime: function()
    {
		// what's with (+ new Date) below?
		// + calls Date.valueOf(), which converts it from an object to a 	
		// primitive (number of milliseconds since January 1, 1970 local time)
		var now,fps;
		now = (+new Date); 
		fps = 1000 / (now - this.lastTime);
		fps = clamp(fps, 12, 60);
		this.lastTime = now; 
		return 1/fps;
	},
    drawHUD: function()
    {
        if(this.mousePos != undefined && this.gameState == this.GAME_STATE.GAME_PLAY)
        {
            this.ctx.save();
                var distance = getDistance(this.mousePos, this.playerBall.position) / 2.1;
                if(distance > 100)
                {
                    distance = 100;
                }
                else if(distance < 0)
                {
                    distance = 0;
                }
                this.ballPower = distance;
                var color = "#FFFFFF";
                if(distance > 0)
                {
                    color = "#00FF00";
                }
                if(distance > 50)
                {
                    color = "#FFFF00";
                }
                if(distance > 75)
                {
                    color = "#FF0000";
                }
                this.ctx.strokeStyle = color;
                this.ctx.lineWidth = 10;
                this.ctx.lineCap = "round";
                this.ctx.lineJoin = "round";
                this.ctx.globalAlpha = 0.5;
                
                
                this.ctx.beginPath();
                    this.ctx.moveTo(this.playerBall.position.x, this.playerBall.position.y);
                    this.ctx.lineTo(this.mousePos.x, this.mousePos.y);
                this.ctx.closePath();
                this.ctx.stroke();
                
                this.ctx.globalAlpha = 0.25;
                this.ctx.fillStyle = "#FFFFFF";
                this.ctx.fillRect(this.canvas.width - 150, this.canvas.height - 50, 135, 40);
                this.ctx.globalAlpha = 0.5;
                this.ctx.fillStyle = color;
                this.ctx.fillRect(this.canvas.width - 150, this.canvas.height - 50, distance.map(0, 100, 0, 135), 40);
                this.ctx.fillStyle = "#FFFFFF";
                this.ctx.textAlign = "center";
                this.ctx.font = "24px Oswald";
                this.ctx.fillText("Power", this.canvas.width - 80, this.canvas.height - 20);
            this.ctx.restore();
        }
        if(this.showOutOfBoundsMessage == true && this.gameState == this.GAME_STATE.GAME_PLAY)
        {
            this.ctx.save();
                this.ctx.fillStyle = "#FFFFFF";
                this.ctx.globalAlpha = 0.5;
                this.ctx.textAlign = "center";
                this.ctx.font = "24px Oswald";
                this.ctx.fillText("OUT OF BOUNDS", this.canvas.width/2, this.canvas.height * 0.33);
            this.ctx.restore();
        }
        if(this.clubsImage != undefined && this.gameState == this.GAME_STATE.GAME_PLAY)
        {
            this.ctx.save();
                this.ctx.fillStyle = "#FFFFFF";
                this.ctx.globalAlpha = 0.25;
                this.ctx.fillRect(15, this.canvas.height - 50, 135, 40);
                this.ctx.globalAlpha = 0.5;
                this.ctx.textAlign = "right";
                this.ctx.font = "24px Oswald";
                this.ctx.fillText(this.CLUB_TYPES[this.clubSelected], 140, this.canvas.height - 20);
                var destination = {
                    x: 25,
                    y: this.canvas.height - 47,
                    w: 35,
                    h: 35
                }
                switch(this.clubSelected)
                {
                    case 9:
                    case 8:
                        this.ctx.drawImage(this.clubsImage, 
                                          0, 0, 64, 64,
                                          destination.x, destination.y, destination.w, destination.h);
                        break;
                    case 7:
                    case 6:
                    case 5:
                    case 4:
                    case 3:
                    case 2:
                        this.ctx.drawImage(this.clubsImage, 
                                          64, 0, 64, 64,
                                          destination.x, destination.y, destination.w, destination.h);
                        break;
                    case 1:
                        this.ctx.drawImage(this.clubsImage, 
                                          128, 0, 64, 64,
                                          destination.x, destination.y, destination.w, destination.h);
                        break;
                    case 0:
                        this.ctx.drawImage(this.clubsImage, 
                                          192, 0, 64, 64,
                                          destination.x, destination.y, destination.w, destination.h);
                        break;
                }
            this.ctx.restore();
        }
        if(this.holePosition != undefined && this.gameState == this.GAME_STATE.GAME_PLAY)
        {
            var holeDistance = parseInt(getDistance(this.holePosition, this.playerBall.position) / 2.1);
            this.ctx.save();
                this.ctx.fillStyle = "#FFFFFF";
                this.ctx.globalAlpha = 0.5;
                this.ctx.textAlign = "right";
                this.ctx.font = "24px Oswald";
                this.ctx.fillText("Distance to hole: " + holeDistance + " yrds", this.canvas.width - 10, 30);
            
                this.ctx.fillStyle = "#333333";
                this.ctx.fillRect(this.canvas.width - 250, 50, 250, 300);
                this.ctx.drawImage(this.generatedCourse, 0, 0, this.generatedCourse.width, this.generatedCourse.height,
                                  this.canvas.width - 250, 50, 250, 300);
                this.ctx.fillStyle = "#FFFFFF";
                this.ctx.fillText("Hole " + this.holeNumber, this.canvas.width - 10, 380);
                this.ctx.textAlign = "left";
                this.ctx.font = "18px Oswald";
                this.ctx.fillText("Stroke " + this.currentStroke, this.canvas.width - 240, 330);
                this.ctx.textAlign = "right";
                this.ctx.fillText("Par " + this.par, this.canvas.width - 10, 330);
            this.ctx.restore();
        }
        
        if(this.gameState == this.GAME_STATE.GAME_SHOW_SCORE)
        {
            this.ctx.save();
                this.ctx.fillStyle = "#333333";
                this.ctx.globalAlpha = 0.5;
                this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
                this.ctx.globalAlpha = 0.75;
                this.ctx.fillStyle = "#FFFFFF";
                this.ctx.textAlign = "center";
                this.ctx.font = "18px Oswald";
                this.ctx.fillText("SCORECARD", this.canvas.width/2, 30);
                for(var y = 1; y < Object.keys(this.holeData).length + 1; y++)
                {
                    this.ctx.fillStyle = "#FFFFFF";
                    this.ctx.fillRect(this.canvas.width * 0.25, y * 35, this.canvas.width * 0.5, 30);
                    this.ctx.fillStyle = "#333333";
                    this.ctx.textAlign = "left";
                    this.ctx.fillText("HOLE " + this.holeData[y-1].hole, this.canvas.width * 0.25 + 25, y * 35 + 23);
                    this.ctx.textAlign = "center";
                    this.ctx.fillText("PAR " + this.holeData[y-1].par, this.canvas.width * 0.5, y * 35 + 23);
                    this.ctx.textAlign = "right";
                    this.ctx.fillText("STROKES " + this.holeData[y-1].strokes, this.canvas.width * 0.75 - 25, y * 35 + 23);
                    
                }
                this.ctx.fillStyle = "#FFFFFF";
                this.ctx.textAlign = "center";
                var message = "PRESS ANY BUTTON TO GO TO THE NEXT HOLE";
                if(this.holeNumber == this.maxHoles)
                {
                    message = "WELL DONE! PRESS ANY BUTTON TO RETURN TO MENU";
                }
                this.ctx.fillText(message, this.canvas.width * 0.5, (Object.keys(this.holeData).length + 1) * 35 + 23);
            this.ctx.restore();
        }
    },
    pauseGame: function()
    {
        this.paused = true;
        cancelAnimationFrame(this.animationID);
        document.querySelector("body").style.cursor = "default";
        document.querySelector(".pause").style.display = "block";
        app.sound.stopBGAudio();
        this.update();
    },
    resumeGame: function()
    {
        cancelAnimationFrame(this.animationID);
        document.querySelector(".pause").style.display = "none";
        this.paused = false;
        app.sound.playBGAudio();
        this.update();
    },
    updateMouse: function(e)
    {
        this.mousePos = getMouse(e);
    },
    doMouseDown: function(e)
    {
        if(this.gameState == this.GAME_STATE.GAME_PLAY)
        {
            if(this.ballState == this.BALL_STATE.STATIC)
            {
                this.ballState = this.BALL_STATE.HIT_IMPULSE;
            }
        }
        else if(this.gameState == this.GAME_STATE.GAME_SHOW_SCORE)
        {
            if(this.holeNumber == this.maxHoles)
            {
                this.gameState = this.GAME_STATE.MENU;
                document.querySelector("body").style.cursor = "default";
                document.querySelector(".menu").style.display = "block";
            }
            else
            {
                this.gameState = this.GAME_STATE.GAME_PLAY;
                this.setupCourse();
            }
        }
    },
    doMouseWheel: function(scrollDirection)
    {
        this.cycleClubs(scrollDirection);
    },
    cycleClubs: function(direction)
    {
        this.clubSelected += direction;
        if(this.clubSelected > Object.keys(this.CLUB_TYPES).length - 1)
        {
            this.clubSelected = 0;
        }
        else if(this.clubSelected < 0)
        {
            this.clubSelected = Object.keys(this.CLUB_TYPES).length - 1;
        }
    },
    cycleLevel: function(nextLevel)
    {
        this.currentLevel += nextLevel;
        if(this.currentLevel < 0)
        {
            this.currentLevel = this.maxLevels - 1;
        }
        else if(this.currentLevel >= this.maxLevels)
        {
            this.currentLevel = 0;
        }
        document.querySelector("#preview").src = this.levelImages[this.currentLevel].src;
        document.querySelector(".menu").style.background = 'url(' + this.levelImagesBG[this.currentLevel].src + ')';
        this.levelNameElement.innerHTML = this.LEVEL_NAMES[this.currentLevel];
        app.sound.changeBGAudio(this.currentLevel + 1);
        this.setupCourse();
    },
    setupMenuFunctionality: function()
    {
        document.querySelector("#newGame").addEventListener('click', function()
        {
            app.main.gameState = app.main.GAME_STATE.GAME_PLAY;
            app.main.holeData = [];
            app.main.holeNumber = 0;
            app.main.setupCourse();
        });
        document.querySelector('#cycleLevelLeft').addEventListener('click', function()
        {
            app.main.cycleLevel(-1);
        });
        document.querySelector('#cycleLevelRight').addEventListener('click', function()
        {
            app.main.cycleLevel(1);
        });
        document.querySelector("#continueButton").addEventListener('click', function()
        {
            app.main.resumeGame();
        });
        document.querySelector("#returnToMenu").addEventListener('click', function()
        {
            document.querySelector(".menu").style.display = "block";
            app.main.gameState = app.main.GAME_STATE.MENU;
            app.main.resumeGame();
        });
        document.querySelector("#pauseButton").addEventListener('click', function()
        {
            
            if(document.querySelector(".pause").style.display == "none")
            {
                app.main.pauseGame();
            }
            else
            {
                app.main.resumeGame();
            }
        });
        this.levelNameElement = document.querySelector("#levelName");
        this.menuElement = document.querySelector(".menu");
    },
    setupCourse: function()
    {
        this.par = parseInt(getRandom(3, 6));
        this.currentStroke = 1;
        this.holeNumber++;
        this.levelGenerator = undefined;
        this.playerBall = undefined;
        this.holePosition = undefined;
        this.ballPower = 0;
        this.ballImpulse = 0;
        
        this.levelGenerator = new LevelGenerator(this.par);
        this.generatedCourse = new Image();
        this.generatedCourse.src = this.topCtx.canvas.toDataURL("image/png");
        var sWidth =  this.ctx.canvas.width;
        var sHeight = this.ctx.canvas.height;
        // if cropped image is smaller than canvas we need to change the source dimensions
        /*if(this.generatedCourse.width - this.camera.xView < sWidth)
        {
            sWidth = this.generatedCourse.width - this.camera.xView;
        }*/
        if(this.generatedCourse.height - this.camera.yView < sHeight)
        {
            sHeight = this.generatedCourse.height - this.camera.yView; 
        }
        this.ctx.drawImage(this.generatedCourse, 0, this.camera.yView, sWidth, sHeight, 0, 0, sWidth, sHeight);
        app.main.playerBall = new PlayerBall({x: this.teePosition.x, y: this.teePosition.y / 2}, "#FAFAFA");
        //this.teePosition.y - (this.teePosition.y * Math.exp((this.teePosition.y + 200) / this.topCanvas.height / 3) - this.teePosition.y)
        this.camera.follow(this.playerBall, this.canvas.width, this.canvas.height);
        //this.camera.update();
        this.courseBuilt = true;
        //Math.abs(this.teePosition.y / this.topCanvas.height)
        //this.teePosition.y - 50 + (this.canvas.height - this.teePosition.y / this.topCanvas.height - this.teePosition.y) * 0.9
    },
    moveBall: function(dt)
    {
        this.ctx.clearRect(0, 0, this.ctx.canvas.width, this.ctx.canvas.height);
        var accel = {x: 0, y: 0};
        if(this.ballState == this.BALL_STATE.HIT_IMPULSE)
        {
            this.previousBallPosition = this.playerBall.position;
            this.currentStroke++;
            if(this.currentStroke > this.maxStrokes)
            {
                this.endRound();
            }
            this.ballImpulse = (this.ballPower / 50) + ((this.clubSelected + 1) * Math.random()) / 10;
            accel = limitVector(this.mousePos.subVector(this.playerBall.position), this.ballImpulse);
            this.playerBall.hangTimeRatio = this.ballImpulse * 50;
            this.playerBall.move(dt, accel);
            if(this.clubSelected != 0)
            {
                this.ballState = this.BALL_STATE.UPWARDS;
                if(this.clubSelected > 6)
                {
                    app.sound.playEffect(2);
                }
                else
                {
                    app.sound.playEffect(1);
                }
            }
            else
            {
                this.ballState = this.BALL_STATE.PUTTING;
                app.sound.playEffect(0);
            }
            
        }
        else if(this.ballState == this.BALL_STATE.UPWARDS)
        {
            this.playerBall.scale += 2 / this.ballImpulse;
            if(this.playerBall.scale > this.playerBall.maxScale)
            {
                this.playerBall.scale = this.playerBall.maxScale;
            }
            this.playerBall.move(dt, accel);
        }
        else if(this.ballState == this.BALL_STATE.PEAK)
        {
            this.playerBall.move(dt, accel);
        }
        else if(this.ballState == this.BALL_STATE.DOWNWARDS)
        {
            this.playerBall.scale -= 2 / this.ballImpulse;
            if(this.playerBall.scale < this.playerBall.initialScale)
            {
                this.playerBall.scale = this.playerBall.initialScale;
                this.ballState = this.BALL_STATE.BOUNCE;
            }
            this.playerBall.move(dt, accel);
        }
        else if(this.ballState == this.BALL_STATE.PUTTING)
        {
            this.playerBall.move(dt, accel);
            this.checkForCollisions();
        }
        else
        {
            this.playerBall.velocity = {x: 0, y: 0};
            this.playerBall.hangTime = 0;
            this.playerBall.hangTimeRatio = 0;
            this.checkForCollisions();
        }
        
        this.camera.update();
        var sWidth =  this.ctx.canvas.width;
        var sHeight = this.ctx.canvas.height;
        // if cropped image is smaller than canvas we need to change the source dimensions
        /*if(this.generatedCourse.width - this.camera.xView < sWidth)
        {
            sWidth = this.generatedCourse.width - this.camera.xView;
        }*/
        /*if(this.generatedCourse.height - this.camera.yView < sHeight)
        {
            sHeight = this.generatedCourse.height - this.camera.yView; 
        }*/
        this.ctx.drawImage(this.generatedCourse, 0, this.playerBall.position.y, sWidth, sHeight, 0, 0, sWidth, sHeight);
        this.playerBall.display();
    },
    endRound: function()
    {
        this.gameState = this.GAME_STATE.GAME_SHOW_SCORE;
        this.clubSelected = 9;
        this.holeData.push(
        {
            hole: this.holeNumber,
            par: this.par,
            strokes: this.currentStroke
        });
    },
    checkForCollisions: function()
    {
        if(this.gameState == this.GAME_STATE.GAME_PLAY)
        {
            var dx = this.playerBall.position.x - this.holePosition.x;
            var dy = this.playerBall.position.y - this.holePosition.y;
            var dist = Math.sqrt(dx*dx + dy*dy);
            if(dist < this.playerBall.scale + 20)
            {
                app.sound.playEffect(3);
                this.endRound();
            }
            if(this.playerBall.position.x < 0 || this.playerBall.position.x > this.canvas.width || this.playerBall.position.y < 0)
            {
                this.currentStroke++;
                this.playerBall.position = this.previousBallPosition;
                this.showOutOfBoundsMessage = true;
                setTimeout(function(){app.main.showOutOfBoundsMessage = false;}, 2000);
            }
        }
    }
    
};