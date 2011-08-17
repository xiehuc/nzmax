package
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import nz.support.IFileManager;

	/**
	 * ...
	 * @author ...
	 */
	public class FileManage implements IFileManager 
	{
		[Bindable]
		public var data:ArrayCollection = new ArrayCollection();
		public var ScriptDirectory:String;
		public var SaveDirectory:String;
		public var ScriptInfo:XML;
		public var define_complete:Function;
		private var directory:String;
		private var host:String;
		
		private var filelist:XML;
		private var commonFileList:XML;
		
		public function setDirectory(dir:String,globalhost:String = ""):void
		{
			//第一步
			host = globalhost;
			directory = dir;
			data.removeAll();
			var u:URLLoader = new URLLoader();
			u.addEventListener(Event.COMPLETE,com_info_complete);
			u.load(new URLRequest(host+"comlib/info.xml"));
			rescan();
		}
		public function setStoryInfo(info:XML):void
		{
			SaveDirectory = null;
			ScriptDirectory = directory;
			ScriptInfo = info;
			filelist = info.require[0];
		}
		public function getStoryPath():String
		{
			return ScriptInfo.script[0].toString();
		}
		public function getResolvePath(path:String):String
		{
			var fl:XML = filelist;
			/*if(dic == null){
				fl = filelist;
			}else{
				fl = dic;
			}*/
			if(fl.file.(@path == path) == undefined){
				if(commonFileList.file.(@path == path) == undefined){
					//Alert.show("IO错误,找不到路径:\n"+path);
				}
				return host+commonFileList.file.(@path == path).@url;
			}
			return ScriptDirectory + fl.file.(@path == path).@url;
		}
		public function rescan():void
		{
			data.removeAll();
			var infoFile:String = directory+"/info.xml";
			var urlloader:URLLoader = new URLLoader();
			urlloader.load(new URLRequest(infoFile));
			urlloader.addEventListener(Event.COMPLETE,info_load_complete);
			
		}
		private function com_info_complete(e:Event):void
		{
			var xml:XML = new XML(e.currentTarget.data);
			commonFileList = xml.require[0];
			for each(var x:XML in xml.child("import")) {
				var define:URLLoader = new URLLoader(new URLRequest(x.toString()));
				define.addEventListener(Event.COMPLETE, define_complete);
			}
		}
		private function info_load_complete(e:Event):void
		{
			var xml:XML = new XML(e.currentTarget.data);
			data.addItem({label:xml.name.toString(),finish:xml.finish.toString(),xmlData:xml});
		}
	}
}