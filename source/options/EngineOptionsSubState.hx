package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class EngineOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Defined Engine Options';
		rpcTitle = 'Defined Engine Options'; //for Discord Rich Presence

	//Custom Mod Options Start
	var option:Option = new Option('Icon Bounce:',
		"Which icon bounce would you like?",
		'iconBounceType',
		'string',
		'Golden Apple',
		['Golden Apple', 'Dave and Bambi', 'Old Psych', 'New Psych', 'VS Steve']);
	addOption(option);
	var option:Option = new Option('Double Note Ghosts',
		"If this is checked, hitting a Double Note will show an afterimage, just like in VS Impostor!",
		'doubleGhost',
		'bool',
		true);
	addOption(option);
//Custom Mod Options End
		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}
