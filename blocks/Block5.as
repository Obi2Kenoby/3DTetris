package blocks
{
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.graphics.SolidColorFill;
	
	import flash.display.Stage;
	import gameUI.GameData;
	
	public class Block5 extends Block
	{
		public function Block5(XYGrid:IsoGrid, scene:IsoScene, stage:Stage, gameData:GameData, frozenBlockPartList:Array, moveable:Boolean)
		{
			super(XYGrid, scene, stage, gameData, frozenBlockPartList, moveable);
			
			var startX:int = (XYGrid.gridSize[0] / 2) * cellSize;
			var startY:int = (XYGrid.gridSize[1] / 2) * cellSize;
			var startZ:int = (this.gameData.getPlayHeight() - 1) * cellSize;
			
			// part 2 (centerpart)
			moveBlockPart(part2, startX,startY,startZ);
			part2.fill = new SolidColorFill(0xff0000,1);
			
			// part 1
			moveBlockPart(part1, part2.x, part2.y + cellSize, part2.z);
			
			// part 3
			moveBlockPart(part3, part2.x + cellSize, part2.y , part2.z);
			
			// part 4
			moveBlockPart(part4, part2.x + cellSize, part2.y - cellSize, part2.z);
		}
	}
}