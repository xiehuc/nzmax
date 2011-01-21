package com.nz 
{
	import flash.events.Event;
	import mx.controls.Button;
	import mx.controls.List;
	/**
	 * Control的接口
	 * @author CodeX
	 */
	public interface IControl
	{
		/**
		 * 转到某个页面
		 * @param	page 指定的页面
		 */
		function gotoPage(page:String):void
		/**@private */
		function get playButtonEnabled():Boolean
		/**@private */
		function set playButtonEnabled(value:Boolean):void
		/**@private */
		function set objectModeEnabled(value:Boolean):void
		/**@private */
		function get objectModeEnabled():Boolean;
		/**@private */
		function openSaver(mode:String, first:Boolean = false ):void;
		/**@private */
		function updateSaver(obj:Object = null):void
		/**@private */
		function regPlugin(p:IPlugin):void
		/**@private */
		function unregPlugin(p:IPlugin):void
		/**@private */
		function activePlugin(p:IPlugin):void
		/**@private */
		function showPanel(p:Place):void
		
		/**@private */
		function saveData(link:String):void;
		/**@private */
		function loadData(link:String):void;
		
		/**@private */
		function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void;
		/**@private */
		function dispatchEvent (event:Event) : Boolean;
		/**@private */
		function hasEventListener (type:String) : Boolean;
		/**@private */
		function removeEventListener (type:String, listener:Function, useCapture:Boolean = false) : void;
		/**@private */
		function willTrigger (type:String) : Boolean;
		
	}

}