// The myKeys object will be in the global scope - it makes this script 
// really easy to reuse between projects

"use strict";

var myKeys = {};

myKeys.KEYBOARD = Object.freeze(
{
	"KEY_LEFT": 37, 
	"KEY_UP": 38, 
	"KEY_RIGHT": 39, 
	"KEY_DOWN": 40,
	"KEY_SPACE": 32,
	"KEY_SHIFT": 16
});

// myKeys.keydown array to keep track of which keys are down
// this is called a "key daemon"
// main.js will "poll" this array every frame
// this works because JS has "sparse arrays" - not every language does
myKeys.keydown = [];


// event listeners
window.addEventListener("keydown",function(e)
{
	myKeys.keydown[e.keyCode] = true;
});
	
window.addEventListener("keyup",function(e)
{
	myKeys.keydown[e.keyCode] = false;
	
	// pausing and resuming
	var char = String.fromCharCode(e.keyCode);
	if (char == "p" || char == "P")
    {
		if (app.main.paused)
        {
			app.main.resumeGame();
		} 
        else 
        {
			app.main.pauseGame();
		}
	}
    if(char.toLowerCase() == "d")
    {
        if(app.main.debug)
        {
            app.main.debug = false;
        }
        else
        {
            app.main.debug = true;
        }
    }
    if(e.keyCode == 37)
    {
        app.main.cycleClubs(-1);
    }
    if(e.keyCode == 39)
    {
        app.main.cycleClubs(1);
    }
});