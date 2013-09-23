package gameUI
{
	import com.newgrounds.*;
	import com.newgrounds.components.APIConnector;
	import com.newgrounds.components.MedalPopup;
	import com.newgrounds.components.Preloader;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
//	[SWF(frameRate = '24', backgroundColor = '0x6495ED', width = '550', height = '400')]
//	[Frame(factoryClass="gameUI.MyPreloader")]
	public class Main extends MovieClip
	{
		private var game:Game;
		private var loopSound:Sound;
		private var loadingScreen:LoadingScreen;
		
		public function Main()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			trace("loaded");
			
			// SHOW LOADINGSCREEN
			loadingScreen = new LoadingScreen();
			loadingScreen.x = 0;
			loadingScreen.y = 0;
			stage.addChild(loadingScreen);
			
			var medalPopup:MedalPopup = new MedalPopup();
			medalPopup.x = 3;
			medalPopup.y = 3;
			medalPopup.alwaysOnTop = "true";
			stage.addChild(medalPopup);
			
			loopSound = new LoopSound();
			
			// entry point: for viewing medals on newgrounds (connection details omitted)
			/*API.addEventListener(APIEvent.API_CONNECTED, onAPIConnected);
			API.connect(root, "dummy_var_1", "dummy_var_2");*/
		}
		
		private function playSound():void
		{
			var channel:SoundChannel = loopSound.play();
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		private function onSoundComplete(event:Event):void
		{
			SoundChannel(event.target).removeEventListener(event.type, onSoundComplete);
			playSound();
		}
		
		private function buildGame():void
		{
			trace("startGame");
			game = new Game(stage);
			game.addEventListener("EndGame", endGameHandler);
		}
		
		
		private function endGameHandler(e:Event):void
		{
			var gameOverScreen:GameOver = new GameOver(stage);
			stage.addChildAt(gameOverScreen, stage.numChildren);
			gameOverScreen.addEventListener("playAgain",playAgain);
		}
		
		
		
		private function playAgain(e:Event):void
		{
			game.restart();
		}
		
		private function onAPIConnected(event:APIEvent):void
		{
			if(event.success)
			{
				trace("The API is connected and ready to use!");
				stage.removeChild(loadingScreen);
				buildGame();
				playSound();
				stage.focus = stage;
				game.startGame();
			}
			else
			{
				trace("Error connecting to the API: " + event.error);
			}
		}
		
	}
}