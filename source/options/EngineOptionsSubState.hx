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
	var option:Option = new Option('Mobile Middlescroll',
	"If checked, your notes and the opponent's notes get centered.",
	'mobileMidScroll',
	'bool',
	false);
	addOption(option);
	var option:Option = new Option('Opponent Note Transparency: ',
	"How visible do you want the opponent's notes to be when Middlescroll is enabled? \n(0% = invisible, 100% = fully visible)",
	'oppNoteAlpha',
	'percent',
	0.65);
	option.scrollSpeed = 1.8;
	option.minValue = 0.0;
	option.maxValue = 1;
	option.changeValue = 0.01;
	option.decimals = 2;
	addOption(option);
	var option:Option = new Option('Light Opponent Strums',
	"If this is unchecked, the Opponent strums won't light up when the Opponent hits a note.",
	'opponentLightStrum',
	'bool',
	true);
	addOption(option);
	var option:Option = new Option('Light Botplay Strums',
	"If this is unchecked, the Player strums won't light when Botplay is active.",
	'botLightStrum',
	'bool',
	true);
	addOption(option);
	var option:Option = new Option('Enable Lane Underlay',
	"Enables a black underlay behind the notes\nfor better reading!\n(Similar to Funky Friday's Scroll Underlay or osu!mania's thing)",
	'laneunderlay',
	'bool',
	true);
addOption(option);

var option:Option = new Option('Lane Underlay Transparency',
	'Set the Lane Underlay Transparency (Lane Underlay must be enabled)',
	'laneTransparency',
	'percent',
	1);
option.scrollSpeed = 1.6;
option.minValue = 0.0;
option.maxValue = 1;
option.changeValue = 0.1;
option.decimals = 1;
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
