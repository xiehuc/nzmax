package com
{
	import codex.dynamics.DURLLoader;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author ...
	 */
	public class FileManage
	{
		[Bindable]
		static public var data:ArrayCollection = new ArrayCollection();
		static public var ScriptDirectory:String;
		static public var SaveDirectory:String;
		static public var ScriptInfo:XML;
		static public var define_complete:Function;
		static private var directory:String;
		static private var host:String;
		
		static private var filelist:XML;
		static private var commonFileList:XML;
		static public function setDirectory(dir:String,globalhost:String = ""):void
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
		static public function setWorkIndex(f:Object):void
		{
			SaveDirectory = null;
			ScriptDirectory = directory;
			ScriptInfo = f.xmlData;
			filelist = f.xmlData.require[0];
		}
		static public function getResolvePath(path:String,dic:XML = null):String
		{
			var fl:XML;
			if(dic == null){
				fl = filelist;
			}else{
				fl = dic;
			}
			if(fl.file.(@path == path) == undefined){
				if(commonFileList.file.(@path == path) == undefined){
					Alert.show("IO错误,找不到路径:\n"+path);
				}
				return host+commonFileList.file.(@path == path).@url;
			}
			return ScriptDirectory + fl.file.(@path == path).@url;
		}
		static public function rescan():void
		{
			data.removeAll();
			var infoFile:String = directory+"/info.xml";
			var urlloader:URLLoader = new URLLoader();
			urlloader.load(new URLRequest(infoFile));
			urlloader.addEventListener(Event.COMPLETE,info_load_complete);
			
		}
		/*static public function rescan():void
		{
			data.removeAll();
			var ar:Array = directory.getDirectoryListing();
			for each(var file:File in ar) {
				var infoFile:File = file.resolvePath("info.xml");
				if (file.isDirectory && infoFile.exists) {
					var urlloader:DURLLoader = new DURLLoader();
					urlloader.load(new URLRequest(file.resolvePath("info.xml").nativePath));
					urlloader.addEventListener(Event.COMPLETE, info_load_complete);
					list.push([file]);
					urlloader.index = list.length - 1;
				}
			}
		}*/
		/*static public function writeFinish():void
		{
			ScriptInfo.finish = "true";
			infoStream = new FileStream();
			var f:File = new File(ScriptDirectory.resolvePath("info.xml").nativePath);
			infoStream.open(f, FileMode.WRITE);
			infoStream.writeUTFBytes(ScriptInfo.toXMLString());
			infoStream.close();
		}
		static public function writeShowChapter(i:int):void
		{
			ScriptInfo.script[i].@hide = "false";
			infoStream = new FileStream();
			var f:File = new File(ScriptDirectory.resolvePath("info.xml").nativePath);
			infoStream.open(f, FileMode.WRITE);
			infoStream.writeUTFBytes(ScriptInfo.toXMLString());
			infoStream.close();
		}*/
		static public function writeShowChapter(i:int):void
		{
			
		}
		static public function writeFinish():void
		{
			
		}
		static private function com_info_complete(e:Event):void
		{
			var xml:XML = new XML(e.currentTarget.data);
			commonFileList = xml.require[0];
			for each(var x:XML in xml.child("import")) {
				var define:URLLoader = new URLLoader(new URLRequest(x.toString()));
				define.addEventListener(Event.COMPLETE, define_complete);
			}
		}
		static private function info_load_complete(e:Event):void
		{
			var xml:XML = new XML(e.currentTarget.data);
			data.addItem({label:xml.name.toString(),finish:xml.finish.toString(),xmlData:xml});
		}
		public function FileManage() 
		{
			
		}
		
	}
}