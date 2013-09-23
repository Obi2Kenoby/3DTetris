package graphics
{
	import com.newgrounds.API;
	import com.newgrounds.Medal;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class ScoreHud extends MovieClip
	{
		private var stageRef:Stage;
		private var s_score:Number = 0;
		private var s_level:Number = 0;
		private var s_planes:Number = 0;
		
		private var points_per_plane:Number;
		
		private var planesBeforeNextLevel:Number;
		
		public function ScoreHud(myStage:Stage, x:int, y:int)
		{
			this.stageRef = myStage;
			this.x = x;
			this.y = y;
			
			planesBeforeNextLevel = 1;
			points_per_plane = 100;
			s_level = 1;
			s_planes = 0;
			s_score = 0;
			
			this['level'].text = String(s_level);
			this['score'].text = String(s_score);
			this['planes'].text = String(s_planes);
			
		}
		
		public function restart():void
		{
			planesBeforeNextLevel = 1;
			points_per_plane = 100;
			s_level = 1;
			s_planes = 0;
			s_score = 0;
			
			this['level'].text = String(s_level);
			this['score'].text = String(s_score);
			this['planes'].text = String(s_planes);
		}
		
		
		public function updateLevel() : void
		{
			s_level += 1;
			this['level'].text = String(s_level);
			
			if (s_level == 5) {
				API.unlockMedal("Level 5");
			}
			else if (s_level == 10) {
				API.unlockMedal("Level 10");
			}
			else if (s_level == 20) {
				API.unlockMedal("Level 20");
			}
		}
		
		public function updatePlanes(aantal:Number) : void
		{
			s_planes += aantal;
			this['planes'].text = String(s_planes);
			updateScore(aantal * points_per_plane);
			planesBeforeNextLevel--;
			
			if (planesBeforeNextLevel == 0) {
				updateLevel();
				planesBeforeNextLevel = s_level;
				dispatchEvent(new Event("AdvanceLevel"));
			}
			
			if (s_planes == 1) {
				API.unlockMedal("1st plane");
			}
			else if(s_planes == 5) {
				API.unlockMedal("5 planes");
			}
			else if(s_planes == 10) {
				API.unlockMedal("10 planes");
			}
			else if(s_planes == 50) {
				API.unlockMedal("50 planes");
			}
			else if(s_planes == 100) {
				API.unlockMedal("100 planes");
			}
			
		}
		
		public function updateScore(value:Number) : void
		{
			s_score += value * s_level;
			this['score'].text = String(s_score);
		}
	}
}