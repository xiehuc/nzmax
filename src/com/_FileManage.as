package com
{
	import codex.dynamics.DURLLoader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author ...
	 */
	public class FileManage
	{
		[Bindable]
		static public var data:ArrayCollection;
		static public var ScriptDirectory:File;
		static public var CommonDirectory:File = File.applicationDirectory.resolvePath("comlib");
		static public var SaveDirectory:File;
		static public var ScriptInfo:XML;
		static private var list:Array;//directoryFile,infoXML
		static private var directory:File;
		static private var infoStream:FileStream;
		
		static public function setWorkIndex(f:Object):void
		{
			SaveDirectory = File.applicationDirectory.resolvePath("save");
			ScriptDirectory = f.file;
			ScriptInfo = f.xmlData;
		}
		static public function getResolvePath(path:String,dic:File = null):String
		{
			if (dic == null) {
				dic = ScriptDirectory;
			}
			var f:File = dic.resolvePath(path);
			if (f.exists == false) {
				f = CommonDirectory.resolvePath(path);
			}
			return f.nativePath;
		}
		static public function setDirectory(dir:File):void
		{
			directory = dir;
			list = new Array();
			data = new ArrayCollection();
			rescan();
		}
		static public function rescan():void
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
		}
		static public function writeFinish():void
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
		}
		static private function info_load_complete(e:Event):void 
		{
			var xml:XML = new XML(e.currentTarget.data);
			list[e.currentTarget.index][1] = xml;
			data.addItem( { label:xml.name.toString(), file:list[e.currentTarget.index][0],finish:xml.finish.toString() ,xmlData:xml} );
		}
		public function FileManage() 
		{
			
		}
		
	}
}