package blocks
{
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	
	import exceptions.BlockCreationError;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import gameUI.GameData;
	
	public class BlockCreator extends EventDispatcher
	{
		private var XYGrid:IsoGrid;
		private var scene:IsoScene;
		private var nextBlockScene:IsoScene;
		private var myStage:Stage;
		
		private var totalBlocks:Number;
		
		public function BlockCreator(XYGrid:IsoGrid, scene:IsoScene, nextBlockScene:IsoScene, stage:Stage)
		{
			this.XYGrid = XYGrid;
			
			this.scene = scene;
			this.nextBlockScene = nextBlockScene;
			this.myStage = stage;
			
		}
		
		public function createNextRandomBlock(gameData:GameData):Block
		{
			var random:Number = Math.random();
			var choice:Number = random * 6;  //= random * 6;
			var block:Block;
			var frozenBlockPartList:Array = new Array();
			
			if (choice < 1) {
				try {
					block = new Block1(XYGrid, nextBlockScene, myStage, gameData, frozenBlockPartList, false);
				} catch (e:BlockCreationError) {
					throw e;
				}
			} else if (choice >= 1 && choice < 2) {
				try {
					block = new Block2(XYGrid, nextBlockScene, myStage, gameData, frozenBlockPartList, false);
				} catch (e:BlockCreationError) {
					throw e;
				}
			} else if (choice >= 2 && choice < 3.5) {
				try {
					block = new Block3(XYGrid, nextBlockScene, myStage, gameData, frozenBlockPartList, false);
				} catch (e:BlockCreationError) {
					throw e;
				}
			} else if (choice >= 3.5 && choice < 4.5) {
				try {
					block = new Block4(XYGrid, nextBlockScene, myStage, gameData, frozenBlockPartList, false);
				} catch (e:BlockCreationError) {
					throw e;
				}
			} else if (choice >= 4.5 && choice < 6) {
				try {
					block = new Block5(XYGrid, nextBlockScene, myStage, gameData, frozenBlockPartList, false);
				} catch (e:BlockCreationError) {
					throw e;
				}
			} else {
				try {
					block = new Block1(XYGrid, nextBlockScene, myStage, gameData, frozenBlockPartList, false);
				} catch (e:BlockCreationError) {
					throw e;
				}
			}
			return block;
		}
		
		public function createBlock(gameData:GameData, frozenBlockPartList:Array, blockType:Class):Block
		{
			var block:Block;
			var myScene:IsoScene = scene;
			switch(blockType)
			{
				case Block1:
				{
					try {
						block = new Block1(XYGrid, myScene, myStage, gameData, frozenBlockPartList, true);
					} catch (e:BlockCreationError) {
						throw e;
					}
					break;
				}
				case Block2:
				{
					try {
						block = new Block2(XYGrid, myScene, myStage, gameData, frozenBlockPartList, true);
					} catch (e:BlockCreationError) {
						throw e;
					}
					break;
				}
				case Block3:
				{
					try {
						block = new Block3(XYGrid, myScene, myStage, gameData, frozenBlockPartList, true);
					} catch (e:BlockCreationError) {
						throw e;
					}
					break;
				}
				case Block4:
				{
					try {
						block = new Block4(XYGrid, myScene, myStage, gameData, frozenBlockPartList, true);
					} catch (e:BlockCreationError) {
						throw e;
					}
					break;
				}
				case Block5:
				{
					try {
						block = new Block5(XYGrid, myScene, myStage, gameData, frozenBlockPartList, true);
					} catch (e:BlockCreationError) {
						throw e;
					}
					break;
				}
				
				default:
				{
					try {
						block = new Block1(XYGrid, myScene, myStage, gameData, frozenBlockPartList, true);
					} catch (e:BlockCreationError) {
						throw e;
					}
					break;
				}
			}
			return block;
		}
	}
}