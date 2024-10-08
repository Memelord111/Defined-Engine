package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;



class CategoryState extends MusicBeatState
{
	public static var categorySelected:String;

	private var InMainFreeplayState:Bool = false;

	private var CurrentSongIcon:FlxSprite;

	var icons:Array<FlxSprite> = [];
	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	private var AllPossibleSongs:Array<String> = ["dave", "extras"];

	private var CurrentPack:Int = 0;

	var bg:FlxSprite = new FlxSprite();

	var loadingPack:Bool = false;

	public static var bgPaths:Array<String> = 
	[
		'backgrounds/SUSSUS AMOGUS',
		'backgrounds/SwagnotrllyTheMod',
		'backgrounds/Olyantwo',
		'backgrounds/morie',
		'backgrounds/mantis',
		'backgrounds/mamakotomi',
		'backgrounds/T5mpler'
	];

	public static var loadingCategory:Bool = false;

	override function create()
	{
		#if desktop DiscordClient.changePresence("In the Freeplay Menus", null); #end

		// lmao
		bg.loadGraphic(randomizeBG());
		bg.color = 0xFF0077FF;
		bg.scrollFactor.set();
		add(bg);

		for (i in 0...AllPossibleSongs.length)
		{
			Highscore.load();
	
			var CurrentSongIcon:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('Category/' + 'menu_' + (AllPossibleSongs[i].toLowerCase())));
			CurrentSongIcon.centerOffsets(false);
			CurrentSongIcon.x = (1000 * i + 1) + (1000 - CurrentSongIcon.width);
			CurrentSongIcon.y = (FlxG.height / 2) - 400;
			CurrentSongIcon.scale.set(1,1);
			CurrentSongIcon.antialiasing = true;
	
			add(CurrentSongIcon);
			icons.push(CurrentSongIcon);
		}

		var scale:Float = 1;
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(icons[CurrentPack].x + 220, icons[CurrentPack].y + 300);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
	
		add(camFollow);
			
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.focusOn(camFollow.getPosition());

		UpdatePackSelection(0);
		super.create();
	}

	public function LoadProperPack()
	{
		switch (AllPossibleSongs[CurrentPack].toLowerCase())
		{
			case 'dave':
				FlxG.switchState(new FreeplayState());
				categorySelected = 'dave';
			case 'extras':
				FlxG.switchState(new FreeplayState());
				categorySelected = 'extras';
		}
	}

	public function UpdatePackSelection(change:Int)
	{
		CurrentPack += change;
		if (CurrentPack == -1)
			CurrentPack = AllPossibleSongs.length - 1;
		
		if (CurrentPack == AllPossibleSongs.length)
			CurrentPack = 0;
	
		camFollow.x = icons[CurrentPack].x + 220; 
	}
	override function update(elapsed:Float)
	{

		if (!InMainFreeplayState) 
			{
			if (!loadingCategory)
			{
				if (controls.UI_LEFT_P)
				{
					UpdatePackSelection(-1);
				}
				if (controls.UI_RIGHT_P)
				{
					UpdatePackSelection(1);
				}
				if (controls.ACCEPT && !loadingPack)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
						loadingCategory = true;
		
						new FlxTimer().start(0.2, function(Dumbshit:FlxTimer)
						{
							for (item in icons) { FlxTween.tween(item, {alpha: 0, y: item.y - 200}, 0.5, {ease: FlxEase.cubeInOut}); }
							FlxTween.tween(camera, {'alpha': 0}, 0.4, {ease: FlxEase.cubeInOut}); // i tried to do an a lil different transition
							new FlxTimer().start(0.7, function(Dumbshit:FlxTimer)
							{
								for (item in icons) { item.visible = false; }
		
								LoadProperPack();
								loadingCategory = false;
							});
						});
					}
				if (controls.BACK)
					{
						FlxG.sound.play(Paths.sound('cancelMenu'));
						MusicBeatState.switchState(new MainMenuState());
					}	
				
					return;
				}					
			} else {

			}
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
	}
	public static function randomizeBG():flixel.system.FlxAssets.FlxGraphicAsset
		{
			var chance:Int = FlxG.random.int(0, bgPaths.length - 1);
			return Paths.image(bgPaths[chance]);
		}
}


		




class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var blocked:Bool = false;

	public function new(song:String, week:Int, songCharacter:String, color:Int, blocked:Bool)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		this.blocked = blocked;
		if(this.folder == null) this.folder = '';
	}
}