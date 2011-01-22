package com 
{
	import codex.events.BasisEvent;
	import com.nz.ILoaderOptimized;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import mx.controls.Alert;
	/**
	 * ...
	 * @author codex
	 */
	public class LoaderOptimizer
	{
		public static const SHOW_PROGRESS:String = "show_progress";
		private static var loader:URLLoader;
		private static var dispatcher:EventDispatcher;
		private static var loadlist:Array;
		private static var stateBox:Dictionary;
		public static var loaderContext:LoaderContext;
		
		public static function init():void
		{
			dispatcher = new EventDispatcher();
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, load_next_list);
			loaderContext = new LoaderContext(true);
			loadlist = new Array();
			stateBox = new Dictionary();
		}
		
		static private function load_next_list(e:Event):void 
		{
			if (loadlist.length == 0) {
				return;
			}
			setState(FileManage.getResolvePath(loadlist[0]));
			loadlist.shift();
			var ln:String = loadlist[0];
			loader.load(new URLRequest(FileManage.getResolvePath(ln)));
		}
		public static function presetLoadStack(xml:XML):void
		{
			for each(var x:XML in xml.children()) {
				if (x.@path.toString() != "") {
					pushLoadList(x.@path.toString());
				}else if (x.hasComplexContent()) {
					presetLoadStack(x);
				}
			}
		}
		public static function presetLoad(xml:XML):void
		{
			for each(var x:XML in xml.children()) {
				if (x.@path.toString() != "") {
					pushLoadList(x.@path.toString());
				}else if (x.hasComplexContent()) {
					presetLoadStack(x);
				}
			}
		}
		private static function pushLoadList(url:String):void
		{
			for each (var i:String in loadlist) {
				if (i == url) return;
			}
			loadlist.push(url);
		}
		public static function dispatchLoad(target:Object,url:Object,useurlrequest:Boolean=false):void
		{
			if (!checkState(url)) {
				if (useurlrequest) target.load(new URLRequest(url as String));
				else target.load(url);
				dispatchLoader(target);
				setState(url);
			}else {
				if (useurlrequest) target.load(new URLRequest(url as String));
				else target.load(url);
			}
		}
		
		public static function displayProgress(target:ILoaderOptimized):void
		{
			dispatchLoader(target);
		}
		private static function dispatchLoader(t:Object):void
		{	
			dispatchEvent(new BasisEvent(SHOW_PROGRESS,false,false,t));
		}
		private static function checkState(url:Object):Boolean
		{
			return (stateBox[url] == true);
		}
		static private function setState(url:Object):void
		{
			stateBox[url] = true;
		}
		public static function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function dispatchEvent (event:Event) : Boolean 
		{
			return dispatcher.dispatchEvent(event);
		}

		public static function hasEventListener (type:String) : Boolean 
		{
			return dispatcher.hasEventListener(type);
		}
		public static function removeEventListener (type:String, listener:Function, useCapture:Boolean = false) : void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger (type:String) : Boolean 
		{
			return dispatcher.willTrigger(type);
		}
		public function LoaderOptimizer() 
		{
			
		}
		
	}

}
