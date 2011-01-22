package configs
{
	import codex.dynamics.DURLLoader;
	import mx.collections.ArrayCollection;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author ...
	 */
	public class FileManage
	{
		static public var data:ArrayCollection;
		static public var ScriptDirectory:File;
		static public var CommonDirectory:File;
		static public var SaveDirectory:File;
		static public var ScriptInfo:XML;
		static private var list:Array;//directoryFile,infoXML
		static private var directory:File;
		
		static public function setWorkIndex(index:int):void
		{
			CommonDirectory = File.applicationDirectory.resolvePath("script/common");
			SaveDirectory = File.applicationDirectory.resolvePath("save");
			ScriptDirectory = list[index][0];
			ScriptInfo = list[index][1];
		}
		static public function getResolvePath(path:String):String
		{
			var f:File = ScriptDirectory.resolvePath(path);
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
		static public function getParentPath(path:String):String
		{
			return path.slice(0, path.lastIndexOf("\\"));
		}
		static private function info_load_complete(e:Event):void 
		{
			var xml:XML = new XML(e.currentTarget.data);
			list[e.currentTarget.index][1] = xml;
			data.addItem( { label:xml.name.toString(), data:list[e.currentTarget.index][0] } );
		}
		public function FileManage() 
		{
			
		}
		
	}
}