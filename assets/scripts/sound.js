"use strict";

var app = app || {};

app.sound = (function()
{
	var bgAudio = undefined;
	var effectAudio = undefined;
	var currentEffect = 0;
	var currentDirection = 1;
	var effectSounds = 
    [
        "putt.mp3",
        "lightSwing.mp3",
        "heavySwing.mp3",
        "inHole.mp3"
    ];
	var pausedTime = 0;

	function init()
    {
		bgAudio = document.querySelector("#bgAudio");
		bgAudio.volume=0.25;
		effectAudio = document.querySelector("#effectAudio");
		effectAudio.volume = 0.3;
	}
    
    function playBGAudio()
    {
        bgAudio.play();
        bgAudio.currentTime = pausedTime;
        bgAudio.volume = 0.25;
    }
		
	function stopBGAudio()
    {
		pausedTime = bgAudio.currentTime;
        bgAudio.pause();
        bgAudio.volume = 0;
	}
	
	function playEffect(effectToPlay)
    {
		effectAudio.src = "../assets/media/audio/" + effectSounds[effectToPlay];
		effectAudio.play();
	}
    function changeBGAudio(songNumber)
    {
        bgAudio.src = "../assets/media/audio/song0" + songNumber + ".mp3";
        bgAudio.play();
        pausedTime = 0;
    }
    return{
        init: init,
        playBGAudio: playBGAudio,
        stopBGAudio: stopBGAudio,
        playEffect: playEffect,
        changeBGAudio: changeBGAudio
    };
}());