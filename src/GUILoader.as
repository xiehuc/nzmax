package
{
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class GUILoader
	{
		//全局的Loader,Function请用Event
		private static var loader:Loader = new Loader();
		private static var urlloader:URLLoader = new URLLoader();
		private static var task:Array = new Array();
		private static var state:String = State.STOP;
		/*EVENT:
			BasisEvent.COMPLETE -> {url:String,data:BitmapData}
			BasisEvent.FINISH -> {}
			*/
		public static function pushLoad(url:String,onComplete:Function,onCompleteParams:Array=null,first:Boolean = false):void
		{
			if(first){
				task.unshift([url,onComplete,null,onCompleteParams]);
				//第三个数据是预留给FileType的
			}else{
				task.push([url,onComplete,null,onCompleteParams]);
			}
			if(state == State.STOP){
				start();
			}
		}
		public static function ready():void
		{
			if(!loader.contentLoaderInfo.hasEventListener(Event.COMPLETE)){
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loader_complete);
			}
			if (!urlloader.hasEventListener(Event.COMPLETE)) {
				urlloader.dataFormat = URLLoaderDataFormat.BINARY;
				urlloader.addEventListener(Event.COMPLETE,loader_complete);
			}
		}
		static public function containerAddChild(e:BasisEvent):void
		{
			e.data.params[0].addChild(new Bitmap(e.data.data));
		}
		private static function start():void
		{
			state = State.START;
			task[0][2] = FileType.getType(task[0][0]);
			switch(task[0][2]) {
				case  FileType.ImageType:
					loader.load(new URLRequest(task[0][0]));
				break;
				case FileType.TextType:
					urlloader.load(new URLRequest(task[0][0]));
				break;
				case FileType.XMLType:
					urlloader.load(new URLRequest(task[0][0]));
				break;
				case FileType.SwfType:
					loader.load(new URLRequest(task[0][0]));
				break;
			}
		}
		public function GUILoader():void
		{
		}
		private static function loader_complete(event:Event):void
		{
			switch(task[0][2]) {
				case FileType.ImageType:
				var oriData:BitmapData = (loader.content as Bitmap).bitmapData;
				task[0][1].apply(null, [new BasisEvent(BasisEvent.COMPLETE, false, false, {
													type:task[0][2],
													url:task[0][0],
													params:task[0][3],
													data:oriData.clone()})]);
				oriData.dispose();
				break;
				case FileType.TextType:
				var BA:ByteArray = new ByteArray();
				BA.writeBytes(urlloader.data);
				BA.position = 0;
				var encodeData:String = BA.readMultiByte(BA.length,"gb2312");
				task[0][1].apply(null, [new BasisEvent(BasisEvent.COMPLETE, false, false, {
													type:task[0][2],
													url:task[0][0],
													params:task[0][3],
													data:encodeData } )]);
				break;
				case FileType.XMLType:
				task[0][1].apply(null, [new BasisEvent(BasisEvent.COMPLETE, false, false, {
													type:task[0][2],
													url:task[0][0],
													params:task[0][3],
													data:urlloader.data } )]);
				break;
				case FileType.SwfType:
				task[0][1].apply(null, [new BasisEvent(BasisEvent.COMPLETE, false, false, {
													type:task[0][2],
													url:task[0][0],
													params:task[0][3],
													data:loader.content } )]);
				loader = new Loader();
				ready();
				break;
			}
			if(task.length>1){
				task.shift();
				start();
			}else{
				state = State.STOP;
			}
		}
	}
}