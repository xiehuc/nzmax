package com
{
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author c
	 */
	public class FuncMan
	{
		private var store:Object;
		public function FuncMan() 
		{
			store = new Object();
		}
		public function setFunc(key:String,value:Object):void
		{
			store[key] = value;
		}
		public function getRow():Object
		{
			return store;
		}
		public function getFunc(key:String):Object
		{
			if (store[key] == undefined)
			{
				return new Object();
			}
			return store[key];
		}
		
	}
	
}