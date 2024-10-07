#if(!macro) import Paths; #end

//math
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

//normal
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;

//systme
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;

import flixel.text.FlxText;

//util
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

//tweens
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

//discord
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end

//things of the application
import lime.app.Application;
import openfl.Assets;

import openfl.utils.Assets as OpenFlAssets;

//for animations
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;

//for sprites
import openfl.display.Bitmap;
import openfl.display.BitmapData;

//gamepad like xbox 360 controlles suppport
import flixel.input.gamepad.FlxGamepad;

//keys
import flixel.input.keyboard.FlxKey;

//addons
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;

//json
import haxe.Json;

//files thing
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end