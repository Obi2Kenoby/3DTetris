package gameUI
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	public class Preloader2 extends MovieClip
	{
		public function Preloader2()
		{
			trace("Preloader");
			stop();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function onEnterFrame(event:Event):void
		{
			if(framesLoaded == totalFrames)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				nextFrame();
				init();
			}
			else
			{
				var percent:Number = (stage.loaderInfo.bytesLoaded / stage.loaderInfo.bytesTotal) * 100;
				trace(percent);
			}
		}
		
		private function init():void
		{
			//if class is inside package you'll have use full path ex.org.actionscript.Main
			var mainClass:Class = Class(getDefinitionByName("Main")); 
			if(mainClass)
			{
				var main:Object = new mainClass();
				addChild(main as DisplayObject);
			}
		}
	}
}