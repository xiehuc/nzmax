package nz 
{
	import flash.utils.Dictionary;
	
	import nz.enum.Mode;
	import nz.support.IControl;
	import nz.support.IFileManager;
	import nz.support.IRole;

	//import spark.components.Group;
	/**
	 * ...
	 * @author codex
	 */
	public class Transport
	{
		static public var send:Function;
		static public var pushError:Function;
		static public var Pro:Object;
		static public var c:IControl;
		static public var DisplayRoot:Object = new Object();
		static public var CreateTypeList:Object = new Object();
		static public var KeyMap:Object;
		static public var CurrentRole:IRole;
		static public var eventList:Object;
		static public var upTextShowDict:Dictionary = new Dictionary();
		static public function getEvent(str:String):Function
		{
			return eventList[str];
		}
		public function Transport() 
		{
			
		}
		
	}

}