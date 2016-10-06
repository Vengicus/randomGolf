'use strict';

var app = app || {};

window.onload = function()
{
    //app.sound.init();
    //app.main.sound = app.sound;
    app.sound.init();
	app.main.init();
};

window.onblur = function()
{
    app.main.pauseGame();
};

window.onfocus = function()
{
    app.main.resumeGame();
};

window.onmousemove = function(e)
{
    app.main.updateMouse(e);
};

window.onmousedown = function(e)
{
    app.main.doMouseDown(e);
};
window.onmousewheel = function(e)
{
    var e = window.event || e; // old IE support
	var delta = Math.max(-1, Math.min(1, (e.wheelDelta || -e.detail)));
    
    app.main.doMouseWheel(delta);
}

