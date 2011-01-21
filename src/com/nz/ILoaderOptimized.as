package com.nz 
{
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author codex
	 */
	public interface ILoaderOptimized extends IEventDispatcher
	{
		function load(url:Object = null):void;
	}
	
}