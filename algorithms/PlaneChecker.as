package algorithms
{
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.errors.IsoError;
	import gameUI.GameData;

	public class PlaneChecker
	{
		
		private var gridXSize:int;
		private var gridYSize:int;
		private var playHeight:int;
		private var cellSize:int;
		private var scene:IsoScene;
		
		public function PlaneChecker(gameData:GameData, scene:IsoScene)
		{
			this.gridXSize = gameData.getGridXSize();
			this.gridYSize = gameData.getGridYSize();
			this.playHeight = gameData.getPlayHeight();
			this.cellSize = gameData.getCellSize();
			this.scene = scene;
		}
		
		public function getFullPlanes(arr3D:Array):Array
		{
			var arrHeight:Array = new Array(playHeight);
			for (var i:int = 0; i < arrHeight.length; i++) {
				arrHeight[i] = false;
			}
			
			performChecks(arrHeight, arr3D);
			
			return arrHeight;
		}
		
		public function getFullPlaneBoxes(frozenBoxList:Array):Array
		{
			var count:int;
			var my_array:Array = new Array();
			for (var i:int = 0; i < playHeight; i++) {
				count = 0;
				for each (var box:IsoBox in frozenBoxList) {
					if (box.z == i * cellSize)
						count++;
				}
				if (count == gridXSize * gridYSize)
					pushBoxes(my_array, i, frozenBoxList);
			}
			return my_array;
		}
		
		public function getNotFullPlaneBoxes(frozenBoxList:Array):Array
		{
			var count:int;
			var my_array:Array = new Array();
			for (var i:int = 0; i < playHeight; i++) {
				count = 0;
				for each (var box:IsoBox in frozenBoxList) {
					if (box.z == i * cellSize)
						count++;
				}
				if (count != gridXSize * gridYSize)
					pushBoxes(my_array, i, frozenBoxList);
			}
			return my_array;
		}
		
		public function getPlanesToRemove(frozenBoxList:Array):Array
		{
			var toRemoveArray:Array = new Array(playHeight);
			for (var k:int = 0; k < playHeight; k++) {
				toRemoveArray[k] = false;
			}
			
			
			var arr2D:Array; 
			for (var i:int = 0; i < playHeight; i++) {
				arr2D = getFalse2DArray();
				
				// find boxes in frozenBoxList
				for each (var box:IsoBox in frozenBoxList) {
					if (box.z == i * cellSize) {
						arr2D[box.x / cellSize][box.y / cellSize] = true;
					}
				}
				
				// remove boxes from frozenBoxList if arr2D is full plane
				var count:int = 0;
				for (var a:int = 0; a < gridXSize; a++) {
					for (var b:int = 0; b < gridYSize; b++) {
						if (arr2D[a][b] == true) {
							count++;
						}
					}
				}
				if (count == gridXSize * gridYSize) {
					trace("plane found: " + i);
					toRemoveArray[i] = true;
				}
			}
			
			return toRemoveArray;
		}
	
		private function getFalse2DArray():Array
		{
			var arr2D:Array = new Array(gridXSize);
			for (var i:int = 0; i < gridXSize; i++) {
				arr2D[i] = new Array(gridYSize);
			}
			
			for (var a:int = 0; a < gridXSize; a++) {
				for (var b:int = 0; b < gridYSize; b++) {
					arr2D[a][b] = false;
				}
			}
			return arr2D;
		}
		
		private function printOutFrozenBlocks(frozenBoxList:Array):void
		{
			for each (var box:IsoBox in frozenBoxList)
			trace("x: " + box.x + " y: " + box.y + " z: " + box.z);
		}
		
		private function pushBoxes(my_array:Array, height:int, frozenBoxList:Array):void
		{
			for each (var box:IsoBox in frozenBoxList) {
				if (box.z == height * cellSize)
					my_array.push(box);
			}
		}
		
		private function performChecks(arrHeight:Array, arr3D:Array):void
		{
			var count:int;
			
			// check if a plane has been formed
			for (var z:int = 0; z < playHeight; z++) {
				count = 0;
				for (var x:int = 0; x < gridXSize; x++) {
					for (var y:int = 0; y < gridYSize; y++) {
						if (arr3D[z][x][y]) {
							count++;
						}
					}
				}
				if (count == x*y) {
					arrHeight[z] = true;
					trace("plane formed: " + z);
				}
				
			}
		}
	}
}