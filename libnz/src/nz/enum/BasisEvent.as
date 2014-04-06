package nz.enum
{
	import flash.events.Event;
	public class BasisEvent extends Event
	{
		public static const FINISH:String = "finish";
		public static const INIT_FINISH:String = "init_finish";
		public static const COMPLETE:String = "complete";
		public static const CHANGE:String = "change";
		public static const FRAME_CONSTRUCTED:String = "frameConstructed";
		public static const FIRSTRUN:String = "firstrun";
		public static const START:String = "start";
		
		protected var _data:Object;
		public function BasisEvent(type:String,bubbles:Boolean=false, cancelable:Boolean=false,data:Object = null)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		public function get data():Object
		{
			return _data;
		}
		override public function toString():String 
		{
			return formatToString("BasisEvent", "type", "bubbles", "cancelable", "data");
		}
		override public function clone():Event 
		{
			return new BasisEvent(type, bubbles, cancelable,_data);
		}
	}
}
