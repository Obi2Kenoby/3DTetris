package algorithms
{
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.geom.Pt;
	
	import blocks.Block;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import gameUI.GameData;

	public class BoundingBoxChecker
	{
		private var frozenBoxList:Array;
		private var movingBlock:Block;
		
		private var cellSize:int;
		private var gridXSize:int;
		private var gridYSize:int;
		private var playHeight:int;
		
		public function BoundingBoxChecker(block:Block, gameData:GameData, frozenBlockPartList:Array)
		{
			if (frozenBlockPartList == null)
				frozenBlockPartList = new Array();
			frozenBoxList = frozenBlockPartList;
			movingBlock = block;
			
			cellSize = gameData.getCellSize();
			gridXSize = gameData.getGridXSize();
			gridYSize = gameData.getGridYSize();
			playHeight = gameData.getPlayHeight();
		}
		
//		public function updateFrozenBlockList(frozenBlockPartsList:Array):void
//		{
//			if (frozenBlockPartsList == null)
//				throw new IllegalOperationError("Argument is null");
//			this.frozenBoxList = frozenBlockPartsList;
//		}
		
		public function canBlockMove(vector:Pt):Boolean
		{
			for each (var part:IsoBox in movingBlock.getPartArray()) {
				if (!canBoxMove(part, vector))
					return false;
			}
			return true;
		}
		
		public function canGoDownOne():Boolean
		{
			// check other blocks
			if (!canBlockMove(new Pt(0,0,-1))) {
				return false;
			}
			return true;
		}
		
		public function isLocationTaken(x:int, y:int, z:int):Boolean
		{
			// check other boxes
			for each (var part:IsoBox in frozenBoxList) {
				if (part.x == x && part.y == y && part.z == z)
					return true;
			}
			
			// check boundaries
			if (x >= gridXSize * cellSize || x < 0)
					return true;
			if (y >= gridYSize * cellSize || y < 0)
				return true;
			if (z > playHeight * cellSize || z < 0)
				return true;
			
			return false;
		}
		
		/**
		 * vector parameter is a point object that wants to move the box in units 1.
		 */
		private function canBoxMove(box:IsoBox, vector:Pt):Boolean
		{
			var newBoxX:int = vector.x * cellSize + box.x;
			var newBoxY:int = vector.y * cellSize + box.y;
			var newBoxZ:int = vector.z * cellSize + box.z;
			if (frozenBoxList.length == 0) {
				if (newBoxZ < 0)
					return false;
			}
			for each (var part:IsoBox in frozenBoxList) {
				if (part.x == newBoxX && part.y == newBoxY && part.z == newBoxZ)
					return false;
				if (newBoxZ < 0)
					return false;
			}
			return true;
		}
		
		
	}
}