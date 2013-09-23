package algorithms
{
	import as3isolib.core.ClassFactory;
	import as3isolib.core.IFactory;
	import as3isolib.display.IsoSprite;
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.primitive.IsoRectangle;
	import as3isolib.display.renderers.DefaultShadowRenderer;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.enum.IsoOrientation;
	import as3isolib.graphics.SolidColorFill;
	
	import blocks.Block;
	
	import com.newgrounds.API;
	import com.newgrounds.Medal;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	
	import gameUI.GameData;
	
	import graphics.PlaneRemoveSound;

	public class FrozenBlockContainer extends EventDispatcher
	{
		private var gridXSize:int;
		private var gridYSize:int;
		private var playHeight:int;
		private var cellSize:int;
		private var gameData:GameData;
		private var scene:IsoScene;
		
		private var frozenBlockParts:Array;
		private var planeChecker:PlaneChecker;
		private var myStage:Stage;
		
		private var frozenBlockTurner:IsoBlockTurner;
		private var planeRemoveSound:PlaneRemoveSound;
		
		private var my_rect:Array;
		
		public function FrozenBlockContainer(gameData:GameData, scene:IsoScene, myStage:Stage)
		{
			this.gridXSize = gameData.getGridXSize();
			this.gridYSize = gameData.getGridYSize();
			this.playHeight = gameData.getPlayHeight();
			this.cellSize = gameData.getCellSize();
			this.gameData = gameData;
			this.scene = scene;
			this.myStage = myStage;
			this.planeRemoveSound = new PlaneRemoveSound();
			this.my_rect = new Array();

			frozenBlockTurner = new IsoBlockTurner(gameData);
			planeChecker = new PlaneChecker(gameData, scene);
			
//			// frozenblockparts array [x][y][z]
//			frozenBlockParts = new Array(playHeight);
//			var y:int, x:int;
//			
//			for (x = 0; x < gridXSize; x++) {
//				frozenBlockParts[x] = new Array(gridYSize);
//				for (y = 0; y < 5; y++) {
//					frozenBlockParts[x][y] = new Array(playHeight);
//				}
//			}
			
			frozenBlockParts = new Array();
			
			//myStage.addEventListener(KeyboardEvent.KEY_DOWN, rotateView);
		}
		
		private function _3dArrayToSimpleArray():Array
		{
			var arr:Array = new Array();
			for (var x:int = 0 ; x < gridXSize; x++) {
				for (var y:int = 0; y < gridYSize; y++) {
					for (var z:int = 0; z < playHeight; z++) {
						arr.push(frozenBlockParts[x][y][z]);
					}
				}
			}
			return arr;
		}
		
		private function rotateView(e:KeyboardEvent):void
		{
			if(e.keyCode == 70) { // f
				rotateLeftZAxis();
				trace("left");
			}
			if(e.keyCode == 74) { // j
				rotateRightZAxis();
			}
			scene.render();
		}
		
		private function rotateLeftZAxis():void
		{
			var xMid:int = gridXSize * cellSize / 2;
			var yMid:int = gridYSize * cellSize / 2;
			for each (var part:IsoBox in frozenBlockParts) {
				var new_x:int =  xMid - (yMid - part.y);
				var new_y:int =  yMid + (xMid - part.x);
				var new_z:int = part.z;
				part.moveTo(new_x, new_y, new_z);
			}
		}
		
		private function rotateRightZAxis():void
		{
			var xMid:int = gridXSize * cellSize / 2;
			var yMid:int = gridYSize * cellSize / 2;
			for each (var part:IsoBox in frozenBlockParts) {
				var new_x:int = xMid + (yMid - part.y);
				var new_y:int = yMid - (xMid - part.x);
				var new_z:int = part.z;
				part.moveTo(new_x, new_y, new_z);
			}
		}
		
		private function calculateChanges():void
		{
			var toRemoveArray:Array = planeChecker.getPlanesToRemove(frozenBlockParts);
			for (var i:int = 0; i < toRemoveArray.length; i++) {
				if(toRemoveArray[i])
					removePlaneFromList(i);
			}
			for (var j:int = toRemoveArray.length - 1; j >= 0; j--) {
				if(toRemoveArray[j])
					dropFrozenBoxesOnce(j);
			}
		}
		
		private function dropFrozenBoxesOnce(heightNumber:int):void
		{
			var count:int = 0;
			for each (var box:IsoBox in frozenBlockParts) {
				if (box.z > heightNumber * cellSize) {
					count++;
					box.moveBy(0,0,-cellSize);
					setColor(box);
				}
			}
		}
		
		public function getFrozenBlocks():Array
		{
			var cloneArray:Array = new Array();
			for (var i:int = 0; i < frozenBlockParts.length; i++) {
				cloneArray.push(frozenBlockParts[i]);
			}
			return cloneArray;
		}
		
		private function removePlaneFromList(heightNumber:int):void
		{
			var toRemoveArray:Array = new Array();
			var newFrozenBlockArray:Array = new Array();
			for each (var box:IsoBox in frozenBlockParts) {
				if (box.z == heightNumber * cellSize) {
					toRemoveArray.push(box);
				} else {
					newFrozenBlockArray.push(box);
				}
			}
			planeRemoveSound.play();
			scene.removeAllChildren();
			for each (var newBox:IsoBox in newFrozenBlockArray) {
				scene.addChild(newBox);
			}
			
			frozenBlockParts = newFrozenBlockArray;
			dispatchEvent(new Event("PlaneRemoved"));
		}
		
		public function restart():void
		{
			while(frozenBlockParts.length > 0) {
				//remove the last item:
				frozenBlockParts.pop();
			}
		}
		
		public function addBlock(block:Block):void
		{
			
			for each(var part:IsoBox in block.getPartArray()) {
				frozenBlockParts.push(part);
				setColor(part);
				
				// medal
				if (frozenBlockParts.length < 30 && part.z >= 10*cellSize) {
					API.unlockMedal("Tower Build");
				}
			}
			calculateChanges();
		}
		
		public function turnFrozenBlocksLeft():void
		{
			frozenBlockParts = frozenBlockTurner.turnLeft(frozenBlockParts);
		}
		
		
		public function turnFrozenBlocksRight():void
		{
			frozenBlockParts = frozenBlockTurner.turnRight(frozenBlockParts);
		}
		
		public function hideFrozenBlocksAndShowDepth():void
		{
			// hide blocks
			for each (var block:IsoBox in frozenBlockParts) {
				if (scene.children.indexOf(block) >= 0)
					scene.removeChild(block);
			}
			
			// show depth
			showDepth();
		}
		
		public function updateDepthShadows():void
		{
			removeDepth();
			showDepth();
		}
		
		
		public function showFrozenBlocks():void
		{
			for each (var block:IsoBox in frozenBlockParts) {
				if (scene.children.indexOf(block) < 0)
					scene.addChild(block);
			}
			
			removeDepth();
		}
		
		private function showDepth():void
		{
			var arr2D:Array = new Array(gridXSize);
			
			for (var x:int = 0; x < gridXSize; x++) {
				arr2D[x] = new Array(gridYSize);
			}
			
			for (var z:int = (playHeight-1)*cellSize ; z >= 0; z = z - cellSize) {
				
				for each (var box:IsoBox in getFrozenBlocks()) {
					if (box.z == z && arr2D[box.x / cellSize][box.y / cellSize] == null) {
						arr2D[box.x / cellSize][box.y / cellSize] = box;
					}
				}
				
			}
//			trace("SHOWDEPTH");
			for (var i:int = 0; i < gridXSize; i++) {
				for (var j:int = 0 ; j < gridYSize; j++) {
					if (arr2D[i][j] != null) {
//						trace ("i: " + i + " j: " + j + " color: " + getColor(arr2D[i][j]).color);
						
						var color:uint = getColor(arr2D[i][j]).color;
						
						var rect:IsoRectangle = new IsoRectangle();
						rect.setSize(cellSize,cellSize,0);
						rect.moveTo(i*cellSize,j*cellSize,0);
						rect.fill = new SolidColorFill(color,1);
						my_rect.push(rect);
						//						scene.addChild(rect);
						//						scene.addChild(arr2D[i][j] as IsoBox);
					}
				}
			}
			
			for each (var rect_:IsoRectangle in my_rect) {
				if (scene.children.indexOf(rect_) < 0)
					scene.addChild(rect_);
			}
		}
		
		private function removeDepth():void
		{
			for each (var rect:IsoRectangle in my_rect) {
				if (scene.children.indexOf(rect) >=0 )
					scene.removeChild(rect);
			}
			my_rect = new Array();
		}
		
		private function getColor(box:IsoBox):SolidColorFill
		{
			return box.fill as SolidColorFill;
//			switch(box.z)
//			{
//				case 0:
//				{
//					return new SolidColorFill(0x8b00ff,1);
//				}
//				case cellSize:
//				{
//					return new SolidColorFill(0x6600ff,1);
//				}
//				case cellSize * 2:
//				{
//					return new SolidColorFill(0x0000ff,1);
//				}
//				case cellSize * 3:
//				{
//					return new SolidColorFill(0x00ff7f,1);
//				}
//				case cellSize * 4:
//				{
//					return new SolidColorFill(0x00ff00,1);
//				}
//				case cellSize * 5:
//				{
//					return new SolidColorFill(0x7fff00,1);
//				}
//				case cellSize * 6:
//				{
//					return new SolidColorFill(0xffff00,1);
//				}
//				case cellSize * 7:
//				{
//					return new SolidColorFill(0xff7f00,1); // orange
//				}
//				case cellSize * 8:
//				{
//					return new SolidColorFill(0xff0000,1); // red
//				}
//				case cellSize * 9:
//				{
//					return new SolidColorFill(0x960018,1); // carmine
//				}
//				case cellSize * 10:
//				{
//					return new SolidColorFill(0x8A3324,1); // Burnt Umber
//				}
//				case cellSize * 11:
//				{
//					return new SolidColorFill(0x321414,1); // Dark brown
//				}
//				case cellSize * 12:
//				{
//					return new SolidColorFill(0x111111,1); // dark grey
//				}
//					
//				default:
//				{
//					return new SolidColorFill(0x000000,1); 
//				}
//			}
		}
		
		private function setColor(box:IsoBox):void
		{
			switch(box.z)
			{
				case 0:
				{
					box.fill = new SolidColorFill(0x8b00ff,1);
//					box.container.filters = [new GlowFilter()];
					break;
				}
				case cellSize:
				{
					box.fill = new SolidColorFill(0x6600ff,1);
					break;
				}
				case cellSize * 2:
				{
					box.fill = new SolidColorFill(0x0000ff,1);
					break;
				}
				case cellSize * 3:
				{
					box.fill = new SolidColorFill(0x00ff7f,1);
					break;
				}
				case cellSize * 4:
				{
					box.fill = new SolidColorFill(0x00ff00,1);
					break;
				}
				case cellSize * 5:
				{
					box.fill = new SolidColorFill(0x7fff00,1);
					break;
				}
				case cellSize * 6:
				{
					box.fill = new SolidColorFill(0xffff00,1);
					break;
				}
				case cellSize * 7:
				{
					box.fill = new SolidColorFill(0xff7f00,1); // orange
					break;
				}
				case cellSize * 8:
				{
					box.fill = new SolidColorFill(0xff0000,1); // red
					break;
				}
				case cellSize * 9:
				{
					box.fill = new SolidColorFill(0x960018,1); // carmine
					break;
				}
				case cellSize * 10:
				{
					box.fill = new SolidColorFill(0x8A3324,1); // Burnt Umber
					break;
				}
				case cellSize * 11:
				{
					box.fill = new SolidColorFill(0x321414,1); // Dark brown
					break;
				}
				case cellSize * 12:
				{
					box.fill = new SolidColorFill(0x111111,1); // dark grey
					break;
				}
					
				default:
				{
					box.fill = new SolidColorFill(0x000000,1); 
					break;
				}
			}
		
		}
		
		
	}
}