package gameUI
{
	import algorithms.BoundingBoxChecker;
	import algorithms.FrozenBlockContainer;
	import algorithms.IsoBlockTurner;
	import algorithms.PlaneChecker;
	
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.renderers.DefaultShadowRenderer;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.geom.IsoMath;
	import as3isolib.geom.Pt;
	import as3isolib.graphics.Stroke;
	
	import avmplus.getQualifiedClassName;
	
	import blocks.Block;
	import blocks.Block1;
	import blocks.Block2;
	import blocks.BlockCreator;
	import blocks.blockStates.IState;
	import blocks.blockStates.NormalState;
	
	import exceptions.BlockCreationError;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import flashx.textLayout.conversion.PlainTextExporter;
	
	import graphics.Background;
	import graphics.ScoreHud;
	
	import mx.core.ClassFactory;
	
	public class Game extends Sprite
	{
		private var myStage:Stage;
		private var view:IsoView;
		private var nextBlockView:IsoView;
		private var bg:Background;
		private var scoreHud:ScoreHud;
		private var scene:IsoScene;
		private var nextBlockScene:IsoScene;
		private var XYgridHolder:IsoScene;
		private var nextBlockGridHolder:IsoScene;
		private var XYGrid:IsoGrid;
		private var nextBlockGrid:IsoGrid;
		
		private var frozenBlockContainer:FrozenBlockContainer;
		private var blockCreator:BlockCreator;
		private var stepTimer:Timer;
		private var totalPlanes:int;
		private var pauseScreen:PauseScreen;
		
		private var gameData:GameData;
		private var cellSize:int;
		private var gridXSize:int;
		private var gridYSize:int;
		private var playHeight:int;
		
		private var currentBlock:Block;
		private var nextBlock:Block;
		private var isPaused:Boolean;
		private var isStarted:Boolean;
		private var startSpeed:Number;
		private var isKeyPressed:Boolean;
		
		private var blockTurner:IsoBlockTurner;
		
		public function Game(stage:Stage)
		{
			this.myStage = stage;
			this.isPaused = false;
			this.isStarted = false;
			this.startSpeed = 1500;
			this.isKeyPressed = false;
			
			gameData = new GameData();
			cellSize = gameData.getCellSize();
			gridXSize = gameData.getGridXSize();
			gridYSize = gameData.getGridYSize();
			playHeight = gameData.getPlayHeight();
			
			createPauseScreen();
			createView();
			createScenes();
			createGrids();
			
			blockTurner = new IsoBlockTurner(gameData);
			blockCreator = new BlockCreator(XYGrid, scene, nextBlockScene, myStage);
			frozenBlockContainer = new FrozenBlockContainer(gameData, scene, myStage);
			frozenBlockContainer.addEventListener("PlaneRemoved", updateScorePlaneRemoved);
			totalPlanes = 0;
			
			stepTimer = new Timer(startSpeed,1);
			stepTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerStepHandler);
			
			myStage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			myStage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
			
			nextBlockGridHolder.render();
			nextBlockScene.render();
			
			XYgridHolder.render();
			myStage.addEventListener(Event.ENTER_FRAME, onRender);
		}
		
		private function onRender(e:Event):void
		{
			scene.render();
		}
		
		public function restart():void
		{
			frozenBlockContainer.restart();
			scoreHud.restart();
			nextBlockScene.removeAllChildren();
			scene.removeAllChildren();
			stepTimer.delay = startSpeed;
			myStage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			myStage.focus = myStage; // focus back on stage! (not game over screen)
			startGame();
		}
		
		public function startGame():void
		{
			if (!isStarted) {
				isStarted = true;
				isPaused = false;
				pauseGame();
				myStage.addChildAt(pauseScreen,myStage.numChildren);
				//stepTimer.start();
			} else {
				isPaused = false;
				stepTimer.start();
			}
		}
		
		public function pauseGame():void
		{
			isPaused = true;
			stepTimer.stop();
			
			// remove all listeners
			if (currentBlock != null)
				currentBlock.pause();
		}
		
		public function endPauseGame():void
		{
			isPaused = false;
			stepTimer.start();
			
			// add all listeners
			if (currentBlock != null)
				currentBlock.endPause();
		}
		
		public function gameIsPaused():Boolean
		{
			return isPaused;
		}
		
		public function gameHasStarted():Boolean
		{
			return isStarted;
		}
		
		private function createPauseScreen():void
		{
			// SHOW PAUSESCREEN (+ STARTSCREEN)
			pauseScreen = new PauseScreen();
			pauseScreen.x = 23;
			pauseScreen.y = 10;
		}
		
		private function levelAdvanced(e:Event):void
		{
			stepTimer.delay = stepTimer.delay - Math.ceil(stepTimer.delay/10);
			//trace("Delay: " + stepTimer.delay);	
		}
		
		private function updateScorePlaneRemoved(e:Event):void{
			scoreHud.updatePlanes(1);
		}
		
		private function addFrozenBlockToContainer(e:Event):void
		{
			var frozenBlock:Block = e.target as Block;
			myStage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			myStage.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
			
			frozenBlockContainer.addBlock(frozenBlock);
			frozenBlockContainer.showFrozenBlocks();
			
			myStage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			myStage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
			
			frozenBlock.removeEventListener("FrozenBlock", addFrozenBlockToContainer);
		}
		
		private function timerStepHandler(e:TimerEvent):void
		{
			if (nextBlock == null) {
				nextBlock = blockCreator.createNextRandomBlock(new nextBlockData());
			}
			
			if (currentBlock == null) {
				try {
					currentBlock = blockCreator.createBlock(gameData, frozenBlockContainer.getFrozenBlocks(),getClass(nextBlock));
					currentBlock.updateShadows();
					currentBlock.addEventListener("FrozenBlock",addFrozenBlockToContainer);
					nextBlockScene.removeAllChildren();
					nextBlock = null;
					nextStep();
				} catch (e:BlockCreationError) {
					myStage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
					endGame();
				}
			} else if (currentBlock.getBoundingBoxChecker().canGoDownOne()) {
				currentBlock.goDownOne();
				nextStep();
			} else {
				currentBlock.freeze();
				scoreHud.updateScore(currentBlock.getPoints());
				currentBlock = null;
				nextStep();
			}
		}
		
		private function nextStep():void
		{
			scene.render();
			nextBlockScene.render();
			stepTimer.start();
		}
		
		private function endGame():void
		{
			trace("EndGame");
			dispatchEvent(new Event("EndGame"));
		}
		
		private function keyPressed(e:KeyboardEvent):void
		{
			// PAUSE GAME
			if(e.keyCode == 80) { // p
				if (gameIsPaused()) {
					endPauseGame();
					myStage.removeChild(pauseScreen);
				} else {
					pauseGame();
					myStage.addChildAt(pauseScreen,myStage.numChildren);
				}
			}
			
			// TURN BOARD
			if(e.keyCode == 37 && e.shiftKey && !gameIsPaused()) {
				turnBlocksLeft();
			}
			
			if(e.keyCode == 39 && e.shiftKey && !gameIsPaused()) {
				turnBlocksRight();
			}
			
			// HIDE FROZEN BLOCKS
			if(e.keyCode == 71 && !isKeyPressed) { // g
//				trace("HIDE FROZEN BLOCKS");
				
				isKeyPressed = true;
				frozenBlockContainer.hideFrozenBlocksAndShowDepth();
			}
			
		}
		
		private function keyReleased(e:KeyboardEvent):void
		{
			if(e.keyCode == 71) { // g
//				trace("SHOX FROZEN BLOCKS");
				isKeyPressed = false;
				frozenBlockContainer.showFrozenBlocks();
			}
		}
		
		private function turnBlocksLeft():void
		{
			frozenBlockContainer.turnFrozenBlocksLeft();
			if (currentBlock != null) {
				var newList:Array = new Array(4);
				for (var i:int = 0 ; i < currentBlock.getPartArray().length; i++) {
					newList[i] = currentBlock.getPartArray()[i];
				}
				blockTurner.turnLeft(newList);
				currentBlock.assembleBlock(newList[0],newList[1],newList[2],newList[3]);
			}
		}
		
		private function turnBlocksRight():void
		{
			frozenBlockContainer.turnFrozenBlocksRight();
			if (currentBlock != null) {
				var newList:Array = new Array(4);
				for (var i:int = 0 ; i < currentBlock.getPartArray().length; i++) {
					newList[i] = currentBlock.getPartArray()[i];
				}
				blockTurner.turnRight(newList);
				currentBlock.assembleBlock(newList[0],newList[1],newList[2],newList[3]);
			}
		}
		
		
		private function getClass(obj:Object):Class 
		{
			 return Class(getDefinitionByName(getQualifiedClassName(obj)));
		}
		
		/**
		 * IsoView setup:
		 * camera, or a viewport
		 */
		private function createView():void
		{
			view = new IsoView();
			view.setSize((myStage.stageWidth), myStage.stageHeight);
			view.clipContent = true; // hide content outside the view
			myStage.addChild(view);
			view.centerOnPt(new Pt(0,-(gridYSize * cellSize)));
			//view.centerOnPt(new Pt(cellSize * gridXSize / 2 - cellSize, cellSize * gridYSize /2 - cellSize));
			
			// background
			bg = new Background();
			bg.x = 0;
			bg.y = 0;
			myStage.addChildAt(bg,0);
			
			scoreHud = new ScoreHud(myStage,285,0);
			myStage.addChild(scoreHud);
			scoreHud.addEventListener("AdvanceLevel", levelAdvanced);
			
			nextBlockView = new IsoView();
			nextBlockView.setSize(140, 52); // verhouding met scoreHud
			myStage.addChild(nextBlockView);
			nextBlockView.centerOnPt(new Pt(3*cellSize,3*cellSize));
			nextBlockView.x = 346; 
			nextBlockView.y = 301; 
			nextBlockView.showBorder = false; 
		}
		
		/**
		 * add 2 scenes to the view:
		 * container for isometric shapes
		 * depth sorting, rendering,..
		 */
		private function createScenes():void
		{
			XYgridHolder = new IsoScene();
			view.addScene(XYgridHolder);
			
			scene = new IsoScene();
			var shadows:mx.core.ClassFactory = new mx.core.ClassFactory(DefaultShadowRenderer); 
			shadows.properties = {shadowColor:0x000000, shadowAlpha:0.15, drawAll:false}; 
			scene.styleRenderers = [shadows];
			view.addScene(scene);
			
			nextBlockGridHolder = new IsoScene();
			nextBlockView.addScene(nextBlockGridHolder);
			nextBlockScene = new IsoScene();
			nextBlockView.addScene(nextBlockScene);
		}
		
		/**
		 * add a grid to a scene.
		 */
		private function createGrids():void
		{
			XYGrid = new IsoGrid();
			XYGrid.cellSize = cellSize;
			XYGrid.setGridSize(gridXSize, gridYSize, 0); // x, y and z axis
			XYgridHolder.addChild(XYGrid);
			XYGrid.showOrigin = false;
			XYGrid.strokes = [new Stroke(1,0xffffff,1)];
			
			nextBlockGrid = new IsoGrid();
			nextBlockGrid.cellSize = cellSize;
			nextBlockGrid.setGridSize(6, 6, 0); // x, y and z axis
			nextBlockGridHolder.addChild(nextBlockGrid);
			
			nextBlockGrid.showOrigin = false;
			nextBlockGrid.strokes = [new Stroke(1,0x999999,1)];
		}
	}
}