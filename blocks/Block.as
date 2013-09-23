package blocks
{
	import algorithms.BoundingBoxChecker;
	import algorithms.ColorUtil;
	
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.geom.IsoMath;
	import as3isolib.geom.Pt;
	import as3isolib.graphics.SolidColorFill;
	
	import exceptions.BlockCreationError;
	import exceptions.BlockMovementError;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import gameUI.GameData;
	
	import graphics.DropSound;

	public /* abstract */ class Block extends MovieClip
	{
		protected var part1:IsoBox;
		protected var part2:IsoBox;
		protected var part3:IsoBox;
		protected var part4:IsoBox;
		protected var partArray:Array;
		
		protected var XYGrid:IsoGrid;
		protected var scene:IsoScene;
		protected var mystage:Stage;
		protected var boundingBoxChecker:BoundingBoxChecker;
		
		protected var gameData:GameData;
		protected var cellSize:int;
		
		protected var points:Number;
		
		private var frozenBlockPartList:Array;
		private var moveable:Boolean;
		
		public function Block(XYGrid:IsoGrid, scene:IsoScene, stage:Stage, gameData:GameData, frozenBlockPartList:Array, moveable:Boolean)
		{
			
			this.part1 = new IsoBox();
			this.part2 = new IsoBox();
			this.part3 = new IsoBox();
			this.part4 = new IsoBox();
			partArray = new Array();
			partArray.push(part1);
			partArray.push(part2);
			partArray.push(part3);
			partArray.push(part4);
			
			this.moveable = moveable;
			this.XYGrid = XYGrid;
			this.scene = scene;
			this.mystage = stage;
			this.gameData = gameData;
			this.cellSize = gameData.getCellSize();
			this.frozenBlockPartList = frozenBlockPartList;
			this.boundingBoxChecker = new BoundingBoxChecker(this, gameData, frozenBlockPartList);
			
			part1.setSize(cellSize,cellSize,cellSize);
			part2.setSize(cellSize,cellSize,cellSize);
			part3.setSize(cellSize,cellSize,cellSize);
			part4.setSize(cellSize,cellSize,cellSize);
			
			scene.addChild(part1);
			scene.addChild(part2);
			scene.addChild(part3);
			scene.addChild(part4);
			
			
			points = 0;
			if (moveable)
				mystage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		public function pause():void
		{
			mystage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		public function endPause():void
		{
			mystage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		public function updateShadows():void
		{
			removeShadows();
			var topBlocks:Array = new Array();
			for each (var part:IsoBox in frozenBlockPartList) {
				for each (var blockPart:IsoBox in partArray) {
					if (part.x == blockPart.x && part.y == blockPart.y) {
						topBlocks.push(part);
					}
				}
			}
			for each (var box:IsoBox in topBlocks) {
				var my_color:Number = ColorUtil.darkenColor(box.fills[1].color,30);
				box.fills = [
					new SolidColorFill(my_color,1),
					new SolidColorFill(box.fills[1].color,1),
					new SolidColorFill(box.fills[1].color,1),
					new SolidColorFill(box.fills[1].color,1),
					new SolidColorFill(box.fills[1].color,1),
					new SolidColorFill(box.fills[1].color,1)
				];
				
			}
		}
		
		public function assembleBlock(part1:IsoBox, part2:IsoBox, part3:IsoBox, part4:IsoBox):void
		{
			this.part1.moveTo(part1.x,part1.y,part1.z);
			this.part2.moveTo(part2.x,part2.y,part2.z);
			this.part3.moveTo(part3.x,part3.y,part3.z);
			this.part4.moveTo(part4.x,part4.y,part4.z);
		}
		
		private function removeShadows():void
		{
			for each (var box:IsoBox in frozenBlockPartList) {
				box.fill = new SolidColorFill(box.fills[1].color,1);
			}
		}
		
		protected function moveBlockPart(part:IsoBox, x:int, y:int, z:int):void
		{
			if (boundingBoxChecker.isLocationTaken(x, y, z))
				throw new BlockCreationError();
			else
				part.moveTo(x, y, z);
		}
		
		public function getPoints():Number
		{
			return points;
		}
		
		public function getPartArray():Array
		{
			var my_array:Array = new Array();
			for each (var part:IsoBox in partArray) {
				my_array.push(part);
			}
			return my_array;	
		}
		
		public function getBoundingBoxChecker():BoundingBoxChecker
		{
			return boundingBoxChecker;
		}
		
		public function freeze():void
		{
			mystage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			dispatchEvent(new Event("FrozenBlock"));
		}
		
		private function canMoveToSideByUnits(x:int, y:int):Boolean
		{
			// check sides
			for each (var part:IsoBox in partArray) {
				if (part.x + x*cellSize > (XYGrid.gridSize[0]-1)*cellSize || part.x + x*cellSize < 0)
					return false;
				if (part.y + y*cellSize > (XYGrid.gridSize[1]-1)*cellSize || part.y + y*cellSize < 0)
					return false;
			}
			
			// check other blocks
			if (!boundingBoxChecker.canBlockMove(new Pt(x, y, 0)))
				return false;
			
			return true;
		}
		
		private function moveBy(x:int, y:int, z:int):void
		{
			for each (var part:IsoBox in partArray) {
				part.moveBy(x,y,z);
			}
		}
		
		private function keyDown(e:KeyboardEvent)
		{
			// MOVE BLOCK
			if(e.keyCode == 37 && canMoveToSideByUnits(-1, 0) && !e.shiftKey) {
				//trace("left");
				this.moveBy(-cellSize, 0, 0);
			}
			if(e.keyCode == 39 && canMoveToSideByUnits(1, 0) && !e.shiftKey) {
				//trace("right");
				this.moveBy(cellSize, 0, 0);
			}
			if(e.keyCode == 38 && canMoveToSideByUnits(0, -1)) {
				//trace("up");
				this.moveBy(0, -cellSize, 0);
			}
			if(e.keyCode == 40 && canMoveToSideByUnits(0, 1)) {
				//trace("down");
				this.moveBy(0, cellSize, 0);
			}
			
			// ROTATE BLOCK
			if(e.keyCode == 69) { // e
				//trace("rotateLeftZ");
				try {
					rotateLeftZAxis();
				} catch(e:BlockMovementError) {}
			}
			if(e.keyCode == 82) { // r
				//trace("rotateRightZ");
				try {
					rotateRightZAxis();
				} catch(e:BlockMovementError) {}
			}
			if(e.keyCode == 68) { // d
				//trace("rotateLeftY");
				try {
					rotateLeftYAxis();
				} catch(e:BlockMovementError) {}
			}
			if(e.keyCode == 70) { // f
				//trace("rotateRightY");
				try {
					rotateRightYAxis();
				} catch(e:BlockMovementError) {}
			}
			if(e.keyCode == 67) { // c
				//trace("rotateLeftX");
				try {
					rotateLeftXAxis();
				} catch(e:BlockMovementError) {}
			}
			if(e.keyCode == 86) { // v
				//trace("rotateRightX");
				try {
					rotateRightXAxis();
				} catch(e:BlockMovementError) {}
			}
			
//			if(e.keyCode == 82) { // r
//				try {
//					testMoveUp();
//				} catch(e:BlockMovementError) {}
//			}
			
			updateShadows();
			
			if(e.keyCode == 32) // spacebar
			{
				//trace("drop");
				var count:int = 0;
				
				while (boundingBoxChecker.canGoDownOne()) {
					goDownOne();
					count++;
				}
				removeShadows();
				points = count;
				removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			}
			
		}
		
		/**
		 * care! no checks performed.
		 */
		public function goDownOne():void
		{
			part1.moveBy(0,0,-cellSize);
			part2.moveBy(0,0,-cellSize);
			part3.moveBy(0,0,-cellSize);
			part4.moveBy(0,0,-cellSize);
		}
		
//		private function testMoveUp():void
//		{
//			for each (var check_part:IsoBox in getPartArray()) {
//				var check_new_x:int = check_part.x;
//				var check_new_y:int = part2.y - (part2.z - check_part.z);
//				var check_new_z:int = part2.z + (part2.y - check_part.y);
//				if (boundingBoxChecker.isLocationTaken(check_new_x, check_new_y, check_new_z))
//					throw new BlockMovementError(check_new_x,check_new_y,check_new_z);
//			}
//			for each (var part:IsoBox in getPartArray()) {
//				Tweener.addTween(part, {z:(part.z + cellSize), time:0.5});
//			}
//				
//		}
		
		private function rotateLeftXAxis():void
		{
			// perform checks first
			for each (var check_part:IsoBox in getPartArray()) {
				var check_new_x:int = check_part.x;
				var check_new_y:int = part2.y - (part2.z - check_part.z);
				var check_new_z:int = part2.z + (part2.y - check_part.y);
				if (boundingBoxChecker.isLocationTaken(check_new_x, check_new_y, check_new_z))
					throw new BlockMovementError(check_new_x,check_new_y,check_new_z);
			}
			// perform movement
			for each (var part:IsoBox in getPartArray()) {
				var new_x:int = part.x;
				var new_y:int = part2.y - (part2.z - part.z);
				var new_z:int = part2.z + (part2.y - part.y);
				part.moveTo(new_x, new_y, new_z);
			}
		}
		
		private function rotateRightXAxis():void
		{
			for each (var check_part:IsoBox in getPartArray()) {
				var check_new_x:int = check_part.x;
				var check_new_y:int = part2.y + (part2.z - check_part.z);
				var check_new_z:int = part2.z - (part2.y - check_part.y);
				if (boundingBoxChecker.isLocationTaken(check_new_x, check_new_y, check_new_z))
					throw new BlockMovementError(check_new_x,check_new_y,check_new_z);
			}
			for each (var part:IsoBox in getPartArray()) {
				var new_x:int = part.x;
				var new_y:int = part2.y + (part2.z - part.z);
				var new_z:int = part2.z - (part2.y - part.y);
				part.moveTo(new_x, new_y, new_z);
			}
		}
		
		private function rotateLeftYAxis():void
		{
			for each (var check_part:IsoBox in getPartArray()) {
				var check_new_x:int = part2.x + (part2.z - check_part.z);
				var check_new_y:int = check_part.y;
				var check_new_z:int = part2.z - (part2.x - check_part.x);
				if (boundingBoxChecker.isLocationTaken(check_new_x, check_new_y, check_new_z))
					throw new BlockMovementError(check_new_x,check_new_y,check_new_z);
			}
			for each (var part:IsoBox in getPartArray()) {
				var new_x:int = part2.x + (part2.z - part.z);
				var new_y:int = part.y;
				var new_z:int = part2.z - (part2.x - part.x);
//				Tweener.addTween(part, {x:new_x, y:new_y, z:new_z, time:0.3});
				part.moveTo(new_x, new_y, new_z);
			}
		}
		
		private function rotateRightYAxis():void
		{
			for each (var check_part:IsoBox in getPartArray()) {
				var check_new_x:int = part2.x - (part2.z - check_part.z);
				var check_new_y:int = check_part.y;
				var check_new_z:int = part2.z + (part2.x - check_part.x);
				if (boundingBoxChecker.isLocationTaken(check_new_x, check_new_y, check_new_z))
					throw new BlockMovementError(check_new_x,check_new_y,check_new_z);
			}
			for each (var part:IsoBox in getPartArray()) {
				var new_x:int = part2.x - (part2.z - part.z);
				var new_y:int = part.y;
				var new_z:int = part2.z + (part2.x - part.x);
				part.moveTo(new_x, new_y, new_z);
			}
		}
		
		private function rotateLeftZAxis():void
		{
			for each (var check_part:IsoBox in getPartArray()) {
				var check_new_x:int = part2.x - (part2.y - check_part.y);
				var check_new_y:int = part2.y + (part2.x - check_part.x);
				var check_new_z:int = check_part.z;
				if (boundingBoxChecker.isLocationTaken(check_new_x, check_new_y, check_new_z))
					throw new BlockMovementError(check_new_x,check_new_y,check_new_z);
			}
			for each (var part:IsoBox in getPartArray()) {
				var new_x:int = part2.x - (part2.y - part.y);
				var new_y:int = part2.y + (part2.x - part.x);
				var new_z:int = part.z;
				part.moveTo(new_x, new_y, new_z);
//				Tweener.addTween(part, {x:new_x, y:new_y, z:new_z, time:0.1});
//				Tweener.addTween(part, {x:new_x, y:new_y, z:new_z, time:0.5, transition:"lineair"});
			}
		}
		
		private function rotateRightZAxis():void
		{
			for each (var check_part:IsoBox in getPartArray()) {
				var check_new_x:int = part2.x + (part2.y - check_part.y);
				var check_new_y:int = part2.y - (part2.x - check_part.x);
				var check_new_z:int = check_part.z;
				if (boundingBoxChecker.isLocationTaken(check_new_x, check_new_y, check_new_z))
					throw new BlockMovementError(check_new_x,check_new_y,check_new_z);
			}
			for each (var part:IsoBox in getPartArray()) {
				var new_x:int = part2.x + (part2.y - part.y);
				var new_y:int = part2.y - (part2.x - part.x);
				var new_z:int = part.z;
				part.moveTo(new_x, new_y, new_z);
			}
		}
		
	}
}