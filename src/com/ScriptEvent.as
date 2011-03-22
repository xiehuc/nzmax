package com
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author c
	 */
	public class ScriptEvent extends Event 
	{
		static public const START:String = "script_start";
		static public const STOP:String = "script_stop";
		static public const END:String = "script_end";
		static public const PROGRESS:String = "script_progress";
		static public const STEPCASE:String = "script_stepcase";
		static public const PROGRESS_END:String = "script_progress_end";
		private var _name:String;
		private var _value:XMLList;
		private var _node:XML;
		public function ScriptEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,name:String = null,value:XMLList = null,node:XML = null):void
		{ 
			super(type, bubbles, cancelable);
			_name = name;
			_value = value;
			_node = node;
		} 
		public function get name():String
		{
			return _name;
		}
		public function get value():XMLList
		{
			return _value;
		}
		public function get node():XML
		{
			return _node;
		}
		public override function clone():Event 
		{ 
			return new ScriptEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ScriptEvent", "type", "bubbles", "cancelable", "name","value"); 
		}
		
	}
	
}