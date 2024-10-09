package;

import flixel.addons.transition.Transition;
import flixel.addons.transition.FlxTransitionableState;
import sys.io.File;
import lime.app.Application;
import haxe.Exception;
import Controls.Control;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
#if windows
import lime.app.Application;
import sys.FileSystem;
#end

 /**
	hey you fun commiting people, 
	i don't know about the rest of the mod but since this is basically 99% my code 
	i do not give you guys permission to grab this specific code and re-use it in your own mods without asking me first.
	the secondary dev, ben
*/
using StringTools;
class CharacterInSelect
{
	public var name:String;
	public var noteMs:Array<Float>;
	public var forms:Array<CharacterForm>;

	public function new(name:String, noteMs:Array<Float>, forms:Array<CharacterForm>)
	{
		this.name = name;
		this.noteMs = noteMs;
		this.forms = forms;
	}
}
class CharacterForm
{
	public var name:String;
	public var polishedName:String;
	public var noteType:String;
	public var noteMs:Array<Float>;

	public function new(name:String, polishedName:String, noteMs:Array<Float>, noteType:String = 'normal')
	{
		this.name = name;
		this.polishedName = polishedName;
		this.noteType = noteType;
		this.noteMs = noteMs;
	}
}
class CharacterSelectState extends MusicBeatState
{
	public var char:Boyfriend;
	public var current:Int = 0;
	public var curForm:Int = 0;
	public var notemodtext:FlxText;
	public var characterText:FlxText;
	public var wasInFullscreen:Bool;

	public var alreadySelected:Bool = false;
	
	public var funnyIconMan:HealthIcon;

	var strummies:FlxTypedGroup<FlxSprite>;

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var arrowStrums:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;

	var selectedCharacter:Bool = false;

	var currentSelectedCharacter:CharacterInSelect;

	var noteMsTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	var arrows:Array<FlxSprite> = [];
	var basePosition:FlxPoint;
	
	public var characters:Array<CharacterInSelect> = 
	[
		new CharacterInSelect('bf', [1, 1, 1, 1], [
			new CharacterForm('bf', 'Boyfriend', [1,1,1,1]),
	//		new CharacterForm('3D BF', '3D Boyfriend', [1,1,1,1], '3D'),
			new CharacterForm('pixelBF', 'Pixel Boyfriend', [1,1,1,1])
		]),
/*
        new CharacterInSelect('Dave', [1, 1, 1, 1], [
			new CharacterForm('Playable Dave', 'Dave', [1,1,1,1]),
            new CharacterForm('Playable 3D Dave', '3D Dave', [1,1,1,1])
		]),

        new CharacterInSelect('Bambi', [1, 1, 1, 1], [
			new CharacterForm('Playable Bambi', 'Bambi', [1,1,1,1]),
            new CharacterForm('Playable Cheating Expunged', 'Cheating Expunged', [1,1,1,1], '3D'),
		]),*/
	];
	#if SHADERS_ENABLED
	var bgShader:Shaders.GlitchEffect;
	#end
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		Conductor.changeBPM(200);

		FlxG.camera.zoom = 0.7;

		if (FlxG.save.data.charactersUnlocked == null)
		{
			reset();
		}
		currentSelectedCharacter = characters[current];

		//FlxG.sound.playMusic(Paths.music("charSelectSong"), 1, true);

		//create BG

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		bg.antialiasing = true;
		bg.scrollFactor.set(1, 1);
		bg.setGraphicSize(Std.int(bg.width * 1.7));
        bg.screenCenter();
		bg.active = false;
		add(bg);
		
		var varientColor = 0xFF878787;

		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, 'bf');
		char.screenCenter();
		char.x += 480;
		char.y += 65;
		char.y -= 115;
		add(char);

		basePosition = char.getPosition();

		strummies = new FlxTypedGroup<FlxSprite>();
		
		add(strummies);
		generateStaticArrows(false);
		
		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - 225, "Boyfriend");
		characterText.setFormat(Paths.font("comic.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterText.borderSize = 5.5;
		characterText.screenCenter();
		characterText.antialiasing = true;
		characterText.y += 250;
		characterText.x -= 605;
		add(characterText);

		funnyIconMan = new HealthIcon('bf', true);
		funnyIconMan.visible = true;
		funnyIconMan.antialiasing = true;
		funnyIconMan.setGraphicSize(Std.int(funnyIconMan.width * 1.2));
		funnyIconMan.flipX = true;
		updateIconPosition();
		add(funnyIconMan);

		var tutorialThing:FlxSprite = new FlxSprite(-110, -30).loadGraphic(Paths.image('ui/charSelectGuide'));
		tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.6));
		tutorialThing.antialiasing = false;
		tutorialThing.screenCenter(X);
		add(tutorialThing);

		super.create();

		add(arrowStrums);

		unlockCharacter('3D BF');
	}

	public function preload(graphic:String) //preload assets
	{
		if (char != null)
		{
			char.stunned = true;
		}
		var newthing:FlxSprite = new FlxSprite(9000,-9000).loadGraphic(Paths.image(graphic));
		add(newthing);
		remove(newthing);
		if (char != null)
		{
			char.stunned = false;
		}
	}

	private function generateStaticArrows(noteType:String = 'normal', regenerated:Bool):Void
	{
		if (regenerated)
		{
			if (strummies.length > 0)
			{
				strummies.forEach(function(babyArrow:FlxSprite)
				{
					remove(babyArrow);
					strummies.remove(babyArrow);
				});
			}
		}
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, FlxG.height - 40);

			var noteAsset:String = 'NOTE_assets';
			switch (noteType)
			{
				case '3D':
					noteAsset = 'polynote';
			}

			babyArrow.frames = Paths.getSparrowAtlas(noteAsset);
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.9));

			babyArrow.x += Note.swagWidth * i;
			switch (Math.abs(i))
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
					babyArrow.x += 35;
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
					babyArrow.x += 70;
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					babyArrow.x += 105;
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.ID = i;
	
			babyArrow.animation.play('static');
			babyArrow.x += 50 - 600;
			babyArrow.x += ((FlxG.width / 3.5));
			babyArrow.y -= 10;
			babyArrow.alpha = 0;

			var baseDelay:Float = regenerated ? 0 : 0.5;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: baseDelay + (0.2 * i)});
			strummies.add(babyArrow);
			arrowStrums.add(babyArrow);
		}
	}
	override public function update(elapsed:Float):Void 
	{


		#if SHADERS_ENABLED
		if (bgShader != null)
		{
			bgShader.shader.uTime.value[0] += elapsed;
		}
		#end
		Conductor.songPosition = FlxG.sound.music.time;
		
		var controlSet:Array<Bool> = [controls.UI_LEFT_P, controls.UI_DOWN_P, controls.UI_UP_P, controls.UI_RIGHT_P];

		super.update(elapsed);

		if(char.animation.curAnim != null && char.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * char.singDuration && char.animation.curAnim.name.startsWith('sing') && !char.stunned) {
			char.dance();
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (wasInFullscreen)
			{
				FlxG.fullscreen = true;
			}
			LoadingState.loadAndSwitchState(new FreeplayState());
		}

		#if !debug
		if (FlxG.keys.justPressed.SEVEN)
		{
			for (character in characters)
			{
				for (form in character.forms)
				{
					unlockCharacter(form.name); // unlock everyone
				}
			}
		}
		#end
		
		for (i in 0...controlSet.length)
		{
			if (controlSet[i] && !PressedTheFunny)
			{
				switch (i)
				{
					case 0:
						char.playAnim('singLEFT', true);

						arrowStrums.members[0].animation.play('confirm');
						arrowStrums.members[0].centerOffsets();
						arrowStrums.members[0].offset.x -= 8;
						arrowStrums.members[0].offset.y -= 8;
					case 1:
						char.playAnim('singDOWN', true);

						arrowStrums.members[1].animation.play('confirm');
						arrowStrums.members[1].centerOffsets();
						arrowStrums.members[1].offset.x -= 6;
						arrowStrums.members[1].offset.y -= 6;
					case 2:
						char.playAnim('singUP', true);

						arrowStrums.members[2].animation.play('confirm');
						arrowStrums.members[2].centerOffsets();
						arrowStrums.members[2].offset.x -= 7;
						arrowStrums.members[2].offset.y -= 8;
					case 3:
						char.playAnim('singRIGHT', true);

						arrowStrums.members[3].animation.play('confirm');
						arrowStrums.members[3].centerOffsets();
						arrowStrums.members[3].offset.x -= 7;
						arrowStrums.members[3].offset.y -= 7;
				}
			}
		}

		if(controls.UI_LEFT_R)
			{
				arrowStrums.members[0].animation.play('static');
				arrowStrums.members[0].centerOffsets();
			}
		if(controls.UI_DOWN_R)
			{
				arrowStrums.members[1].animation.play('static');
				arrowStrums.members[1].centerOffsets();
			}
		if(controls.UI_UP_R)
			{
				arrowStrums.members[2].animation.play('static');
				arrowStrums.members[2].centerOffsets();
			}
		if(controls.UI_RIGHT_R)
			{
				arrowStrums.members[3].animation.play('static');
				arrowStrums.members[3].centerOffsets();
			}

		if (controls.ACCEPT)
		{
			if (isLocked(characters[current].forms[curForm].name))
			{
				FlxG.camera.shake(0.05, 0.1);
				FlxG.sound.play(Paths.sound('badnoise1'), 0.9);
				return;
			}
			if (PressedTheFunny)
			{
				return;
			}
			else
			{
				PressedTheFunny = true;
			}
			selectedCharacter = true;
			var heyAnimation:Bool = char.animation.getByName("hey") != null; 
			char.playAnim(heyAnimation ? 'hey' : 'singUP', true);
			FlxG.sound.music.fadeOut(1.9, 0);
			FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));
			alreadySelected = true;
			FlxG.camera.flash(FlxColor.WHITE, 1);
			new FlxTimer().start(1.9, endIt);
		}
		if (FlxG.keys.justPressed.LEFT && !selectedCharacter)
		{
			curForm = 0;
			current--;
			if (current < 0)
			{
				current = characters.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		if (FlxG.keys.justPressed.RIGHT && !selectedCharacter)
		{
			curForm = 0;
			current++;
			if (current > characters.length - 1)
			{
				current = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		if (FlxG.keys.justPressed.DOWN && !selectedCharacter)
		{
			curForm--;
			if (curForm < 0)
			{
				curForm = characters[current].forms.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (FlxG.keys.justPressed.UP && !selectedCharacter)
		{
			curForm++;
			if (curForm > characters[current].forms.length - 1)
			{
				curForm = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		#if debug
		if (FlxG.keys.justPressed.R && !selectedCharacter)
		{
			reset();
			FlxG.resetState();
		}
		#end
	}
	public static function unlockCharacter(character:String)
	{
		if (!FlxG.save.data.charactersUnlocked.contains(character))
		{
			FlxG.save.data.charactersUnlocked.push(character);
			FlxG.save.flush();
		}
	}
	public static function isLocked(character:String):Bool
	{
		return !FlxG.save.data.charactersUnlocked.contains(character);
	}
	public static function reset()
	{
		FlxG.save.data.charactersUnlocked = new Array<String>();
		unlockCharacter('bf');
		unlockCharacter('3D BF');
		FlxG.save.flush();
	}

	public function UpdateBF()
	{
		var newSelectedCharacter = characters[current];
		if (currentSelectedCharacter.forms[curForm].noteType != newSelectedCharacter.forms[curForm].noteType)
		{
			generateStaticArrows(newSelectedCharacter.forms[curForm].noteType, true);
		}
		
		currentSelectedCharacter = newSelectedCharacter;
		characterText.text = currentSelectedCharacter.forms[curForm].polishedName;
		char.destroy();
		char = new Boyfriend(char.x, char.y, currentSelectedCharacter.forms[curForm].name);

		switch (currentSelectedCharacter.forms[curForm].name)
		{
			case 'Dave':
				char.x -= 150;
				char.y -= 150;
		}
		
		insert(members.indexOf(strummies), char);
		funnyIconMan.changeIcon(char.curCharacter);
		funnyIconMan.color = FlxColor.WHITE;
		if (isLocked(characters[current].forms[curForm].name))
		{
			char.color = FlxColor.BLACK;
			funnyIconMan.color = FlxColor.BLACK;
			characterText.text = '???';
		}
		updateIconPosition();
	}

	override function beatHit()
	{
		super.beatHit();
		if (curBeat % char.danceEveryNumBeats == 0 && char.animation.curAnim != null && !char.animation.curAnim.name.startsWith('sing') && !char.stunned)
		{
			if(!alreadySelected)
			{
				char.dance();
			}
		}
	}
	function updateIconPosition()
	{
		//var xValues = CoolUtil.getMinAndMax(funnyIconMan.width, characterText.width);
		var yValues = CoolUtil.getMinAndMax(funnyIconMan.height, characterText.height);
		
		funnyIconMan.x = characterText.width - 150;
		funnyIconMan.y = characterText.y + ((yValues[0] - yValues[1]) / 2);
	}
	
	public function endIt(e:FlxTimer = null)
	{
		PlayState.characteroverride = currentSelectedCharacter.name;
		PlayState.formoverride = currentSelectedCharacter.forms[curForm].name;

		FlxG.sound.music.stop();
		LoadingState.loadAndSwitchState(new PlayState());
	}
}