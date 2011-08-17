package nz.manager
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author CodeX
	 *  &lt;  <     
        &gt;  >     
        &amp; &   
        &apos;'   
        &quot;"   

	 */
	public class SAVEManager
	{
		static public const READ_SUCCESS:String = "read_success";
		static public const READ_FAILED:String = "read_failed";
		static public const INIT:String = "init";
		static public const PREPARE_DATA:String = "prepare";
		static public const RESTART:String = "restart";//重新开始
		static public const RETURNTOTITLE:String = "returntotitle";//返回开始
		
		static private var eventdisp:EventDispatcher;
		/*static private var savefile:File;
		static private var savestream:FileStream;
		static private var saveObject:Object;
		
		static private var createXML:XML;
		static private var pluginXML:XML;*/
		static public function ready():void
		{
			if(eventdisp == null){
				eventdisp = new EventDispatcher();
			}
			/*if (savestream == null) {
				savestream = new FileStream();
				eventdisp = new EventDispatcher();
				var f:File = new File(File.applicationDirectory.resolvePath("save").nativePath);
				pluginXML = <nz></nz>
				if (!f.exists) {
					f.createDirectory();
				}
			}*/
		}
		static public function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int = 0,useWeakReference:Boolean = false):void
		{
			eventdisp.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}
		static public function prepare():void
		{
			eventdisp.dispatchEvent(new Event(PREPARE_DATA));
		}
		static public function save(index:int):void
		{
			/*createXML.appendChild(pluginXML["Main"]);
			appendRowData("Create", createXML);
			savefile = new File(FileManage.SaveDirectory.resolvePath(FileManage.ScriptDirectory.name + "_" + index+".sav").nativePath);
			savestream.open(savefile, FileMode.WRITE);
			savestream.position = 0;
			savestream.writeObject(saveObject);
			savestream.close();
			pluginXML = <nz></nz>*/
		}
		static public function read(index:int):void
		{
			/*savefile = new File(FileManage.SaveDirectory.resolvePath(FileManage.ScriptDirectory.name + "_" + index + ".sav").nativePath);
			if (savefile.exists) {
				savestream.open(savefile, FileMode.READ);
				saveObject = savestream.readObject();
				savestream.close();
				eventdisp.dispatchEvent(new Event(READ_SUCCESS));
			}else {
				eventdisp.dispatchEvent(new Event(READ_FAILED));
			}*/
		}
		static public function cleanData():void
		{
			/*saveObject = new Object();
			createXML =<nz></nz>;
			createXML["Main"] = "";
			createXML["Main"].@create = "";*/
		}
		static public function pushPluginData(path:String, link:String = ""):void
		{
			/*if(pluginXML["Main"] == null) pluginXML["Main"] = new XMLList();
			var x:XMLList = pluginXML["Main"];
			x[x.length()] = "";
			if (link != "") {
				x[x.length()-1].@pluginLink = link;
			}
			x[x.length()-1].@pluginLoad = path;*/
		}
		static public function popPluginData(link:String = ""):void
		{
			/*var x:XMLList = pluginXML["Main"];
			var n:XMLList = new XMLList();
			
			for (var i:int = 0; i < x.length(); i++) {
				if (x[i].@pluginLink == null || x[i].@pluginLink != link) {
					n[n.length()] = x[i];
				}
			}
			pluginXML["Main"] = n;*/
		}
		static public function appendCreateData(name:String,attrib:Object):void
		{
			/*createXML["Main"][name] = "";
			for (var item:String in attrib) {
				createXML["Main"][name].@[item] = attrib[item];
			}*/
		}
		static public function appendRowData(mod:String,obj:Object,fld:String = "global"):void
		{
			//fld就是指域
			/*if (saveObject[fld] == null) {
				saveObject[fld] = new Object();
			}
			saveObject[fld][mod] = obj;*/
		}
		static public function appendData(name:String,attrib:Object,value:* = null):void
		{
			/*var x:XML = <nz/>
			x.setName(name);
			if(value !=null) x.setChildren(value);
			for (var item:String in attrib) {
				x.@[item] = attrib[item];
			}
			createXML.appendChild(x);*/
		}
		static public function getData(mod:String,fld:String = "global"):Object
		{
			//return saveObject[fld][mod];
			return null;
		}
		static public function getField(fld:String):Object
		{
			//return saveObject[fld];
			return null;
		}
		public function SAVEManager() 
		{
			
		}
		
	}
	
}
