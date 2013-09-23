package gameUI
{
	import com.newgrounds.*;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Preloader3 extends MovieClip
	{
		public function Preloader3()
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			API.connect(loaderInfo, <Private>, <Private>);
				
				
				
				loadBar = new LoadComponent(280, 40, 0x008080, 1, true);
						
				
				trace("API VERSION: " + API.VERSION);
				_loadingFinished = false;
				_metaFinished = false;
				
				API.addEventListener(APIEvent.API_CONNECTED, onApiConnected);
				API.addEventListener(APIEvent.METADATA_LOADED, onMetaData);
		}
		
		public function onApiConnected(e:APIEvent):void 
		{
			trace("API CONNECTION");
			API.removeEventListener(APIEvent.API_CONNECTED, onApiConnected);
			trace(API.connected);
			var text:TextField = new TextField();
			text.width = 800;
			text.defaultTextFormat = new TextFormat("serif", 12, 0xFFFFFF);
			text.text = "CON: " + API.connected + ", UNAME: " + API.username;
		}
		
		public function onMetaData(e:Event):void {
			_metaFinished = true;
			API.removeEventListener(APIEvent.METADATA_LOADED, onMetaData);
		
			if (_loadingFinished) {
				startup();
			}
		}
		
		// ... FUNCTIONS AND STUFF, PROGRESS, ERROR HANDLING, ETC
		
		private function loadingFinished():void {
			_loadingFinished = true;
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO hide loader
			if(_metaFinished) {
				startup();
			}
			}
		
	}
}