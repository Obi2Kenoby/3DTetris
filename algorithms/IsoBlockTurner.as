package algorithms
{
	import as3isolib.display.primitive.IsoBox;
	
	import blocks.Block;
	
	import caurina.transitions.Tweener;
	
	import fl.transitions.TweenEvent;
	
	import flash.display.MovieClip;
	
	import gameUI.GameData;

	public class IsoBlockTurner extends MovieClip
	{
		private var cellSize:int;
		private var gridXSize:int;
		private var gridYSize:int;
		private var playHeight:int;
		
		private var finished:Boolean;
		
		public function IsoBlockTurner(gameData:GameData)
		{
			
			cellSize = gameData.getCellSize();
			gridXSize = gameData.getGridXSize();
			gridYSize = gameData.getGridYSize();
			playHeight = gameData.getPlayHeight();
			
			addEventListener(TweenEvent.MOTION_FINISH, onFinish);
		}
		
		private function onFinish(e:TweenEvent):void
		{
			finished = true;
			trace("finish");
		}
		
		public function turnLeft(isoBlockList:Array):Array 
		{
			finished = false;
			var newIsoPartList:Array = new Array();
			for each (var part:IsoBox in isoBlockList) {
				var x_new:Number = cellSize * gridXSize - cellSize - part.y;
				var y_new:Number = part.x;
				var x_final:Number = Math.round(x_new/20.0)*20;
				var y_final:Number = Math.round(y_new/20.0)*20;
				part.moveTo(x_new,y_new, part.z);
//				Tweener.addTween(part, {x:x_new, y:y_new, time:0.3}); // TODO!!
//				trace("x: " + part.x + " xN: " + x_final);
//				trace("y: " + part.y + " yN: " + y_final);
//				trace("z: " + part.z);
				
			}
//			while(!finished) {}
			return isoBlockList;
		}
		
		public function turnRight(isoBlockList:Array):Array 
		{
			for each (var part:IsoBox in isoBlockList) {
				var x_new:int = part.y;
				var y_new:int = cellSize * gridXSize - cellSize - part.x;
//				Tweener.addTween(part, {x:x_new, y:y_new, time:0.3});
				part.moveTo(x_new,y_new, part.z);
			}
			return isoBlockList;
		}
	}
}