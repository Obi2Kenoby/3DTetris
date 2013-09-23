package gameUI
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import graphics.Pop;
	
	public class GameOver extends MovieClip
	{
		private var playAgainButton:MyStartButton;
		private var myStage:Stage;
		
		public function GameOver(myStage:Stage)
		{
			super();
			this.myStage = myStage;
			this.x = 45;
			this.y = 140;
			playAgainButton = new MyStartButton();
			playAgainButton.x = 40;
			playAgainButton.y = 67;
			this.addChild(playAgainButton);
			
			var sound:Pop = new Pop();
			sound.play();
			
			playAgainButton.addEventListener(MouseEvent.CLICK,playAgain);
		}
		
		private function playAgain(e:MouseEvent):void{
			playAgainButton.removeEventListener(MouseEvent.CLICK, playAgain);
			myStage.removeChild(this);
			dispatchEvent(new Event("playAgain"));	
		}
		
	}
}