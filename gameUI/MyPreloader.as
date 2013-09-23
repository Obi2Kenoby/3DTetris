package gameUI
{
	import com.newgrounds.*;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getDefinitionByName;
	
	/**
	 * PRELOADER NOT WORKING
	 * */
	public class MyPreloader extends MovieClip 
	{
		private var bar:Shape = new Shape();
		private var maxWidth:uint = 400;
		private var loadedText:TextField = new TextField();
		
		public function MyPreloader() 
		{
			trace('preloader START');
			if (stage)
				initPre();
			else
				addEventListener(Event.ADDED_TO_STAGE, initPre);
			

//			if (stage) {
//				stage.scaleMode = StageScaleMode.NO_SCALE;
//				stage.align = StageAlign.TOP_LEFT;
//				
//				bar.graphics.beginFill( 0x00000 ); 
//				bar.graphics.drawRect( 0, 0, maxWidth, 5 );
//				
//				loadedText.autoSize = TextFieldAutoSize.CENTER;
//				
//				addChild( loadedText );
//				addChild( bar );
//			}
//			
//			addEventListener(Event.ENTER_FRAME, checkFrame);
//			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
//			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
//			API.connect(loaderInfo, "dummy_var_1", "dummy_var_2");
		}
	
		private function initPre(e:Event = null):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			bar.graphics.beginFill( 0x00000 ); 
			bar.graphics.drawRect( 0, 0, maxWidth, 5 );
			
			loadedText.autoSize = TextFieldAutoSize.CENTER;
			
			addChild( loadedText );
			addChild( bar );
			
//			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
//			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			API.connect(root, "dummy_var_1", "dummy_var_2");
			root.addEventListener(ProgressEvent.PROGRESS, progress);
			root.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			addEventListener(Event.ENTER_FRAME, checkFrame);
		}
		
		//captures errors
		private function ioError(e:IOErrorEvent):void 
		{
			trace(e.text);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			// Updates loader
			var percent:uint = ( e.bytesLoaded / e.bytesTotal ) * 100;
			trace(percent);
			
			bar.width = ( maxWidth * ( percent / 100 ) ); //updates the width of the loader bar
			bar.x = ((stage.stageWidth / 2) - (bar.width / 2)); //keeps the bar centered on the x-axis
			bar.y = ((stage.stageHeight / 2) - (bar.height / 2)); //keeps the bar centered on the y-axis
			
			loadedText.text = percent.toString() + "%"; //updates the textfield that shows the percent loaded
			
			loadedText.y = bar.y + 15;
			loadedText.x = ((stage.stageWidth / 2) - (loadedText.width / 2));
		}
		
		private function checkFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		
		private function loadingFinished():void 
		{ //removes all the loader objects and listeners when loading finishes
			removeEventListener(Event.ENTER_FRAME, checkFrame); 
			root.removeEventListener(ProgressEvent.PROGRESS, progress);
			root.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO hide loader
			removeChild( loadedText );
			removeChild( bar );

			startup();
		}
		private function startup():void 
		{ //adds the main class as a display object to the stage
			var mainClass:Class = getDefinitionByName("MyProject") as Class;
			addChild(new mainClass() as DisplayObject);
//			dispatchEvent(new Event("loaded"));
		}
		
	}
}